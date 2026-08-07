import os
from datetime import datetime, timezone
from typing import Any

import requests
from dotenv import load_dotenv
from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.database import SessionLocal

load_dotenv()

OPENSKY_CLIENT_ID = os.getenv("OPENSKY_CLIENT_ID")
OPENSKY_CLIENT_SECRET = os.getenv("OPENSKY_CLIENT_SECRET")

TOKEN_URL = "https://auth.opensky-network.org/auth/realms/opensky-network/protocol/openid-connect/token"
STATES_URL = "https://opensky-network.org/api/states/all"

REQUEST_TIMEOUT = 45


def get_access_token() -> str:
    if not OPENSKY_CLIENT_ID or not OPENSKY_CLIENT_SECRET:
        raise ValueError(
            "Missing OPENSKY_CLIENT_ID or OPENSKY_CLIENT_SECRET in environment."
        )

    response = requests.post(
        TOKEN_URL,
        data={"grant_type": "client_credentials"},
        auth=(OPENSKY_CLIENT_ID, OPENSKY_CLIENT_SECRET),
        timeout=REQUEST_TIMEOUT,
    )
    response.raise_for_status()

    token = response.json().get("access_token")
    if not token:
        raise ValueError("OpenSky token response did not include access_token.")

    return token


def fetch_states(token: str) -> dict[str, Any]:
    response = requests.get(
        STATES_URL,
        headers={"Authorization": f"Bearer {token}"},
        timeout=REQUEST_TIMEOUT,
    )
    response.raise_for_status()
    return response.json()


def meters_to_feet(value: float | None) -> int | None:
    if value is None:
        return None
    return int(round(value * 3.28084))


def mps_to_knots(value: float | None) -> float | None:
    if value is None:
        return None
    return round(value * 1.94384, 1)


def mps_to_fpm(value: float | None) -> float | None:
    if value is None:
        return None
    return round(value * 196.850394, 1)


def parse_opensky_time(epoch_value: int | float | None) -> datetime | None:
    if epoch_value is None:
        return None
    return datetime.fromtimestamp(epoch_value, tz=timezone.utc)


def classify_status(callsign: str | None) -> str:
    if not callsign:
        return "unknown"

    cleaned = callsign.strip().upper()

    cargo_prefixes = ("FDX", "UPS", "BCS", "GTI", "CLX", "ABR")
    private_prefixes = ("N", "G", "D", "F", "HB", "OE")

    if cleaned.startswith(cargo_prefixes):
        return "cargo"

    if len(cleaned) <= 6 and cleaned.startswith(private_prefixes):
        return "private"

    return "passenger"


def build_flight_id(icao24: str | None, callsign: str | None) -> str:
    if icao24:
        return icao24.lower()

    if callsign:
        return callsign.strip().upper()

    return f"unknown-{datetime.now(timezone.utc).timestamp()}"


def map_state_vector(state: list[Any], batch_time: datetime) -> dict[str, Any] | None:
    """
    OpenSky state vector indexes:
    0  icao24
    1  callsign
    2  origin_country
    3  time_position
    4  last_contact
    5  longitude
    6  latitude
    7  baro_altitude
    8  on_ground
    9  velocity
    10 true_track
    11 vertical_rate
    12 sensors
    13 geo_altitude
    14 squawk
    15 spi
    16 position_source
    17 category
    """

    icao24 = (state[0] or "").strip().lower() or None
    callsign = (state[1] or "").strip().upper() or None
    time_position = parse_opensky_time(state[3])
    last_contact = parse_opensky_time(state[4])
    longitude = state[5]
    latitude = state[6]
    baro_altitude_m = state[7]
    on_ground = state[8]
    ground_speed_mps = state[9]
    heading_deg = state[10]
    vertical_rate_mps = state[11]
    geo_altitude_m = state[13]
    squawk = state[14]
    spi = state[15]
    position_source = state[16]
    aircraft_category = state[17] if len(state) > 17 else None

    if latitude is None or longitude is None:
        return None

    return {
        "flight_id": build_flight_id(icao24, callsign),
        "icao24": icao24,
        "callsign": callsign,
        "flight_number": callsign,
        "registration": None,
        "operator_code": None,
        "operator_name": None,
        "aircraft_icao_type": None,
        "aircraft_name": None,
        "aircraft_category": aircraft_category,
        "latitude": latitude,
        "longitude": longitude,
        "baro_altitude_m": baro_altitude_m,
        "geo_altitude_m": geo_altitude_m,
        "altitude_ft": meters_to_feet(geo_altitude_m if geo_altitude_m is not None else baro_altitude_m),
        "ground_speed_mps": ground_speed_mps,
        "ground_speed_kts": mps_to_knots(ground_speed_mps),
        "heading_deg": heading_deg,
        "vertical_rate_mps": vertical_rate_mps,
        "vertical_rate_fpm": mps_to_fpm(vertical_rate_mps),
        "on_ground": on_ground,
        "squawk": squawk,
        "spi": spi,
        "position_source": position_source,
        "origin_airport_code": None,
        "destination_airport_code": None,
        "diverted_airport_code": None,
        "route_status": None,
        "status": classify_status(callsign),
        "source_live": "opensky",
        "source_route": None,
        "source_aircraft": None,
        "source_operator": None,
        "source": "opensky",
        "route_confidence": None,
        "aircraft_confidence": None,
        "opensky_time_position": time_position,
        "opensky_last_contact": last_contact,
        "first_seen_at": batch_time,
        "last_seen_at": batch_time,
        "updated_at": batch_time,
        "raw_payload": state,
    }


def insert_raw_rows(db: Session, rows: list[dict[str, Any]], batch_time: datetime) -> None:
    raw_sql = text("""
        INSERT INTO aviation.flight_ingest_raw (
            provider,
            batch_time,
            icao24,
            callsign,
            payload
        )
        VALUES (
            'opensky',
            :batch_time,
            :icao24,
            :callsign,
            CAST(:payload AS JSONB)
        )
    """)

    for row in rows:
        db.execute(
            raw_sql,
            {
                "batch_time": batch_time,
                "icao24": row["icao24"],
                "callsign": row["callsign"],
                "payload": __import__("json").dumps(row["raw_payload"]),
            },
        )


def upsert_live_row(db: Session, row: dict[str, Any]) -> None:
    lookup_sql = text("""
        SELECT
            live_id,
            first_seen_at
        FROM aviation.flight_live
        WHERE icao24 = :icao24
        LIMIT 1
    """)

    existing = None
    if row["icao24"]:
        existing = db.execute(lookup_sql, {"icao24": row["icao24"]}).mappings().first()

    if existing:
        update_sql = text("""
            UPDATE aviation.flight_live
            SET
                flight_id = :flight_id,
                callsign = :callsign,
                flight_number = :flight_number,
                aircraft_category = :aircraft_category,
                latitude = :latitude,
                longitude = :longitude,
                baro_altitude_m = :baro_altitude_m,
                geo_altitude_m = :geo_altitude_m,
                altitude_ft = :altitude_ft,
                ground_speed_mps = :ground_speed_mps,
                ground_speed_kts = :ground_speed_kts,
                heading_deg = :heading_deg,
                vertical_rate_mps = :vertical_rate_mps,
                vertical_rate_fpm = :vertical_rate_fpm,
                on_ground = :on_ground,
                squawk = :squawk,
                spi = :spi,
                position_source = :position_source,
                status = :status,
                source_live = :source_live,
                source = :source,
                opensky_time_position = :opensky_time_position,
                opensky_last_contact = :opensky_last_contact,
                last_seen_at = :last_seen_at,
                updated_at = :updated_at
            WHERE live_id = :live_id
        """)

        db.execute(
            update_sql,
            {
                **row,
                "live_id": existing["live_id"],
            },
        )
        return

    insert_sql = text("""
        INSERT INTO aviation.flight_live (
            flight_id,
            icao24,
            callsign,
            flight_number,
            registration,
            operator_code,
            operator_name,
            aircraft_icao_type,
            aircraft_name,
            aircraft_category,
            latitude,
            longitude,
            baro_altitude_m,
            geo_altitude_m,
            altitude_ft,
            ground_speed_mps,
            ground_speed_kts,
            heading_deg,
            vertical_rate_mps,
            vertical_rate_fpm,
            on_ground,
            squawk,
            spi,
            position_source,
            origin_airport_code,
            destination_airport_code,
            diverted_airport_code,
            route_status,
            status,
            source_live,
            source_route,
            source_aircraft,
            source_operator,
            source,
            route_confidence,
            aircraft_confidence,
            opensky_time_position,
            opensky_last_contact,
            first_seen_at,
            last_seen_at,
            updated_at
        )
        VALUES (
            :flight_id,
            :icao24,
            :callsign,
            :flight_number,
            :registration,
            :operator_code,
            :operator_name,
            :aircraft_icao_type,
            :aircraft_name,
            :aircraft_category,
            :latitude,
            :longitude,
            :baro_altitude_m,
            :geo_altitude_m,
            :altitude_ft,
            :ground_speed_mps,
            :ground_speed_kts,
            :heading_deg,
            :vertical_rate_mps,
            :vertical_rate_fpm,
            :on_ground,
            :squawk,
            :spi,
            :position_source,
            :origin_airport_code,
            :destination_airport_code,
            :diverted_airport_code,
            :route_status,
            :status,
            :source_live,
            :source_route,
            :source_aircraft,
            :source_operator,
            :source,
            :route_confidence,
            :aircraft_confidence,
            :opensky_time_position,
            :opensky_last_contact,
            :first_seen_at,
            :last_seen_at,
            :updated_at
        )
    """)

    db.execute(insert_sql, row)


def run() -> None:
    token = get_access_token()
    payload = fetch_states(token)
    batch_time = datetime.now(timezone.utc)
    states = payload.get("states") or []

    db: Session = SessionLocal()

    try:
        mapped_rows: list[dict[str, Any]] = []

        for state in states:
            row = map_state_vector(state, batch_time)
            if row is not None:
                mapped_rows.append(row)

        insert_raw_rows(db, mapped_rows, batch_time)

        for row in mapped_rows:
            upsert_live_row(db, row)

        db.commit()

        print(f"Fetched state vectors: {len(states)}")
        print(f"Mapped live rows: {len(mapped_rows)}")
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    run()