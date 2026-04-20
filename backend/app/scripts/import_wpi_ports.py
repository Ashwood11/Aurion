# backend/app/scripts/import_wpi_ports.py

import csv
import json
from pathlib import Path

from sqlalchemy import text

from app.core.database.db import SessionLocal


CSV_PATH = Path("data/ports/UpdatedPub150.csv")  # change if needed


def pick(row, *names):
    for name in names:
        if name in row and row[name] not in (None, "", " "):
            return row[name].strip() if isinstance(row[name], str) else row[name]
    return None


def to_float(value):
    if value in (None, "", " "):
        return None
    return float(str(value).strip())


def main():
    if not CSV_PATH.exists():
        raise FileNotFoundError(f"CSV not found: {CSV_PATH}")

    db = SessionLocal()

    inserted = 0
    updated = 0
    skipped = 0

    try:
        with CSV_PATH.open("r", encoding="utf-8-sig", newline="") as f:
            reader = csv.DictReader(f)

            for row in reader:
                source_id = pick(row, "World Port Index Number", "wpinumber", "WPI Number")
                name = pick(row, "Main Port Name", "main_port_", "PORT_NAME")
                alt_name = pick(row, "Alternate Port Name", "alternate_")
                unlocode = pick(row, "UN/LOCODE", "unlocode")
                country_code = pick(row, "Country Code", "countryCode")
                water_body = pick(row, "World Water Body", "dodwaterbo")

                lat = pick(row, "Latitude", "latitude", "LATITUDE")
                lon = pick(row, "Longitude", "longitude", "LONGITUDE")

                latitude = to_float(lat)
                longitude = to_float(lon)

                if not source_id or not name or latitude is None or longitude is None:
                    skipped += 1
                    continue

                db.execute(
                    text("""
                        INSERT INTO geo.ports (
                            source,
                            source_id,
                            name,
                            alt_name,
                            unlocode,
                            country_code,
                            water_body,
                            latitude,
                            longitude,
                            raw_json
                        )
                        VALUES (
                            :source,
                            :source_id,
                            :name,
                            :alt_name,
                            :unlocode,
                            :country_code,
                            :water_body,
                            :latitude,
                            :longitude,
                            CAST(:raw_json AS JSONB)
                        )
                        ON CONFLICT (source, source_id)
                        DO UPDATE SET
                            name = EXCLUDED.name,
                            alt_name = EXCLUDED.alt_name,
                            unlocode = EXCLUDED.unlocode,
                            country_code = EXCLUDED.country_code,
                            water_body = EXCLUDED.water_body,
                            latitude = EXCLUDED.latitude,
                            longitude = EXCLUDED.longitude,
                            raw_json = EXCLUDED.raw_json,
                            updated_at = NOW()
                    """),
                    {
                        "source": "wpi",
                        "source_id": str(source_id),
                        "name": name,
                        "alt_name": alt_name,
                        "unlocode": unlocode,
                        "country_code": country_code,
                        "water_body": water_body,
                        "latitude": latitude,
                        "longitude": longitude,
                        "raw_json": json.dumps(row),
                    }
                )

                updated += 1

        db.commit()
        print(f"Done. Upserted: {updated}, Skipped: {skipped}")

    except Exception:
        db.rollback()
        raise
    finally:
        db.close()


if __name__ == "__main__":
    main()