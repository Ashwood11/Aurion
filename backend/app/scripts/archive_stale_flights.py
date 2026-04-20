from datetime import datetime, timedelta, timezone

from sqlalchemy import text
from sqlalchemy.orm import Session

from app.core.database import SessionLocal

STALE_AFTER_MINUTES = 10


def archive_stale_flights() -> None:
    db: Session = SessionLocal()
    cutoff = datetime.now(timezone.utc) - timedelta(minutes=STALE_AFTER_MINUTES)

    try:
        stale_rows = db.execute(
            text("""
                SELECT *
                FROM aviation.flight_live
                WHERE last_seen_at < :cutoff
            """),
            {"cutoff": cutoff},
        ).mappings().all()

        if not stale_rows:
            print("No stale flights found.")
            return

        insert_sql = text("""
            INSERT INTO aviation.flight_history (
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
                updated_at,
                archived_at
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
                :updated_at,
                NOW()
            )
        """)

        for row in stale_rows:
            db.execute(insert_sql, dict(row))

        db.execute(
            text("""
                DELETE FROM aviation.flight_live
                WHERE last_seen_at < :cutoff
            """),
            {"cutoff": cutoff},
        )

        db.commit()
        print(f"Archived stale flights: {len(stale_rows)}")
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    archive_stale_flights()