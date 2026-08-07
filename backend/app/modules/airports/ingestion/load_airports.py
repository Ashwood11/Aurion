import csv
import json
from pathlib import Path

from sqlalchemy import text
from app.core.database import SessionLocal

CSV_PATH = Path(__file__).resolve().parents[2] / "data" / "airports.csv"


def clean_text(value: str | None) -> str | None:
    if value is None:
        return None
    value = value.strip()
    return value if value else None


def clean_int(value: str | None) -> int | None:
    value = clean_text(value)
    if value is None:
        return None
    try:
        return int(float(value))
    except ValueError:
        return None


def clean_float(value: str | None) -> float | None:
    value = clean_text(value)
    if value is None:
        return None
    try:
        return float(value)
    except ValueError:
        return None


def load_airports() -> None:
    if not CSV_PATH.exists():
        raise FileNotFoundError(f"airports.csv not found at: {CSV_PATH}")

    db = SessionLocal()

    inserted = 0
    skipped = 0

    try:
        with CSV_PATH.open("r", encoding="utf-8", newline="") as f:
            reader = csv.DictReader(f)

            for row in reader:
                ident = clean_text(row.get("ident"))
                airport_type = clean_text(row.get("type"))
                name = clean_text(row.get("name"))
                lat = clean_float(row.get("latitude_deg"))
                lng = clean_float(row.get("longitude_deg"))

                if not ident or not airport_type or lat is None or lng is None:
                    skipped += 1
                    continue

                elevation_ft = clean_int(row.get("elevation_ft"))
                country_code = clean_text(row.get("iso_country"))
                region_code = clean_text(row.get("iso_region"))
                municipality = clean_text(row.get("municipality"))
                scheduled_service = clean_text(row.get("scheduled_service"))
                gps_code = clean_text(row.get("gps_code"))
                iata_code = clean_text(row.get("iata_code"))
                local_code = clean_text(row.get("local_code"))
                home_link = clean_text(row.get("home_link"))
                wikipedia_link = clean_text(row.get("wikipedia_link"))

                details = {
                    "continent": clean_text(row.get("continent")),
                    "keywords": clean_text(row.get("keywords")),
                }

                location_result = db.execute(
                    text("""
                        INSERT INTO geo.locations (
                            entity_type,
                            name,
                            lat,
                            lng,
                            elevation_ft,
                            country_code,
                            region_code,
                            municipality,
                            source_system,
                            source_id,
                            details
                        )
                        VALUES (
                            :entity_type,
                            :name,
                            :lat,
                            :lng,
                            :elevation_ft,
                            :country_code,
                            :region_code,
                            :municipality,
                            :source_system,
                            :source_id,
                            CAST(:details AS jsonb)
                        )
                        RETURNING id
                    """),
                    {
                        "entity_type": "airport",
                        "name": name,
                        "lat": lat,
                        "lng": lng,
                        "elevation_ft": elevation_ft,
                        "country_code": country_code,
                        "region_code": region_code,
                        "municipality": municipality,
                        "source_system": "ourairports",
                        "source_id": ident,
                        "details": json.dumps(details),
                    },
                )

                location_id = location_result.scalar_one()

                db.execute(
                    text("""
                        INSERT INTO geo.airports (
                            location_id,
                            ident,
                            iata_code,
                            airport_type,
                            scheduled_service,
                            gps_code,
                            local_code,
                            home_link,
                            wikipedia_link
                        )
                        VALUES (
                            :location_id,
                            :ident,
                            :iata_code,
                            :airport_type,
                            :scheduled_service,
                            :gps_code,
                            :local_code,
                            :home_link,
                            :wikipedia_link
                        )
                    """),
                    {
                        "location_id": location_id,
                        "ident": ident,
                        "iata_code": iata_code,
                        "airport_type": airport_type,
                        "scheduled_service": scheduled_service,
                        "gps_code": gps_code,
                        "local_code": local_code,
                        "home_link": home_link,
                        "wikipedia_link": wikipedia_link,
                    },
                )

                inserted += 1

        db.commit()
        print(f"Done. Inserted: {inserted}, Skipped: {skipped}")

    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    load_airports()