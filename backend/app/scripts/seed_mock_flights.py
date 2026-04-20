from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.core.database import SessionLocal
from app.models.aviation import FlightLive


MOCK_FLIGHTS = [
    {
        "flight_id": "AAL101",
        "icao24": "abc101",
        "callsign": "AAL101",
        "aircraft_type": "B777",
        "latitude": 53.2,
        "longitude": -18.4,
        "altitude_ft": 33000,
        "ground_speed_kts": 470,
        "heading_deg": 265,
        "vertical_rate_fpm": 0,
        "origin_airport_code": "LHR",
        "destination_airport_code": "JFK",
        "status": "passenger",
        "source": "mock",
    },
    {
        "flight_id": "DAL220",
        "icao24": "abc220",
        "callsign": "DAL220",
        "aircraft_type": "A330",
        "latitude": 49.8,
        "longitude": -32.1,
        "altitude_ft": 35000,
        "ground_speed_kts": 455,
        "heading_deg": 255,
        "vertical_rate_fpm": 0,
        "origin_airport_code": "CDG",
        "destination_airport_code": "BOS",
        "status": "passenger",
        "source": "mock",
    },
    {
        "flight_id": "FDX900",
        "icao24": "fdx900",
        "callsign": "FDX900",
        "aircraft_type": "B767F",
        "latitude": 51.1,
        "longitude": -9.5,
        "altitude_ft": 31000,
        "ground_speed_kts": 430,
        "heading_deg": 280,
        "vertical_rate_fpm": 0,
        "origin_airport_code": "EMA",
        "destination_airport_code": "EWR",
        "status": "cargo",
        "source": "mock",
    },
    {
        "flight_id": "UAE7",
        "icao24": "uae007",
        "callsign": "UAE7",
        "aircraft_type": "A380",
        "latitude": 27.8,
        "longitude": 49.0,
        "altitude_ft": 37000,
        "ground_speed_kts": 490,
        "heading_deg": 110,
        "vertical_rate_fpm": 0,
        "origin_airport_code": "DXB",
        "destination_airport_code": "SIN",
        "status": "passenger",
        "source": "mock",
    },
    {
        "flight_id": "N123PJ",
        "icao24": "priv123",
        "callsign": "N123PJ",
        "aircraft_type": "G650",
        "latitude": 40.9,
        "longitude": -73.5,
        "altitude_ft": 41000,
        "ground_speed_kts": 510,
        "heading_deg": 72,
        "vertical_rate_fpm": 0,
        "origin_airport_code": "TEB",
        "destination_airport_code": "LFPB",
        "status": "private",
        "source": "mock",
    },
]


def seed_mock_flights():
    db: Session = SessionLocal()
    now = datetime.now(timezone.utc)

    try:
        for item in MOCK_FLIGHTS:
            existing = (
                db.query(FlightLive)
                .filter(FlightLive.flight_id == item["flight_id"])
                .first()
            )

            if existing:
                existing.icao24 = item["icao24"]
                existing.callsign = item["callsign"]
                existing.aircraft_type = item["aircraft_type"]
                existing.latitude = item["latitude"]
                existing.longitude = item["longitude"]
                existing.altitude_ft = item["altitude_ft"]
                existing.ground_speed_kts = item["ground_speed_kts"]
                existing.heading_deg = item["heading_deg"]
                existing.vertical_rate_fpm = item["vertical_rate_fpm"]
                existing.origin_airport_code = item["origin_airport_code"]
                existing.destination_airport_code = item["destination_airport_code"]
                existing.status = item["status"]
                existing.source = item["source"]
                existing.last_seen_at = now
                if not existing.first_seen_at:
                    existing.first_seen_at = now
            else:
                row = FlightLive(
                    **item,
                    first_seen_at=now,
                    last_seen_at=now,
                )
                db.add(row)

        db.commit()
        print("Seeded mock flights into aviation.flight_live")
    finally:
        db.close()


if __name__ == "__main__":
    seed_mock_flights()