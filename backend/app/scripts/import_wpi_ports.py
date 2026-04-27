# backend/app/scripts/import_wpi_ports.py

import csv
import json
from pathlib import Path

from sqlalchemy import text
from app.core.database import SessionLocal

# === CORRECT PATH FOR YOUR MACHINE ===
CSV_PATH = Path(r"C:\Users\Ryan\Desktop\Projects\aurion\backend\data\ports.csv")
# Alternative (if the above doesn't work):
# CSV_PATH = Path("C:/Users/Ryan/Desktop/Projects/aurion/attachments/UpdatedPub150.csv")

def pick(row, *names):
    for name in names:
        if name in row and row[name] not in (None, "", " ", "Unknown", "None"):
            val = row[name]
            return val.strip() if isinstance(val, str) else val
    return None


def to_float(value):
    if value in (None, "", " ", "Unknown", "None"):
        return None
    try:
        return float(str(value).strip())
    except (ValueError, TypeError):
        return None


def to_bool(value):
    if value == "Yes":
        return True
    elif value == "No":
        return False
    return None


def main():
    if not CSV_PATH.exists():
        raise FileNotFoundError(f"CSV file not found at:\n{CSV_PATH}\nPlease check the path.")

    db = SessionLocal()
    processed = 0
    skipped = 0

    try:
        with CSV_PATH.open("r", encoding="utf-8-sig", newline="") as f:
            reader = csv.DictReader(f)

            for row in reader:
                source_id = pick(row, "World Port Index Number", "OID_")
                name = pick(row, "Main Port Name")

                if not source_id or not name:
                    skipped += 1
                    continue

                latitude = to_float(pick(row, "Latitude"))
                longitude = to_float(pick(row, "Longitude"))

                if latitude is None or longitude is None:
                    skipped += 1
                    continue

                db.execute(text("""
                    INSERT INTO geo.ports (
                        source, source_id, name, alt_name, unlocode, country_code,
                        water_body, latitude, longitude,
                        port_type, size_class, harbor_use,
                        tidal_range, channel_depth, anchorage_depth, cargo_pier_depth,
                        max_vessel_length, max_vessel_beam, max_vessel_draft,
                        shelter_afforded,
                        has_container, has_oil_terminal, has_lng_terminal,
                        raw_json
                    )
                    VALUES (
                        :source, :source_id, :name, :alt_name, :unlocode, :country_code,
                        :water_body, :latitude, :longitude,
                        :port_type, :size_class, :harbor_use,
                        :tidal_range, :channel_depth, :anchorage_depth, :cargo_pier_depth,
                        :max_vessel_length, :max_vessel_beam, :max_vessel_draft,
                        :shelter_afforded,
                        :has_container, :has_oil_terminal, :has_lng_terminal,
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
                        port_type = EXCLUDED.port_type,
                        size_class = EXCLUDED.size_class,
                        harbor_use = EXCLUDED.harbor_use,
                        tidal_range = EXCLUDED.tidal_range,
                        channel_depth = EXCLUDED.channel_depth,
                        anchorage_depth = EXCLUDED.anchorage_depth,
                        cargo_pier_depth = EXCLUDED.cargo_pier_depth,
                        max_vessel_length = EXCLUDED.max_vessel_length,
                        max_vessel_beam = EXCLUDED.max_vessel_beam,
                        max_vessel_draft = EXCLUDED.max_vessel_draft,
                        shelter_afforded = EXCLUDED.shelter_afforded,
                        has_container = EXCLUDED.has_container,
                        has_oil_terminal = EXCLUDED.has_oil_terminal,
                        has_lng_terminal = EXCLUDED.has_lng_terminal,
                        raw_json = EXCLUDED.raw_json,
                        updated_at = NOW()
                """), {
                    "source": "wpi",
                    "source_id": str(source_id),
                    "name": name,
                    "alt_name": pick(row, "Alternate Port Name"),
                    "unlocode": pick(row, "UN/LOCODE"),
                    "country_code": pick(row, "Country Code"),
                    "water_body": pick(row, "World Water Body"),
                    "latitude": latitude,
                    "longitude": longitude,

                    "port_type": pick(row, "Harbor Type"),
                    "size_class": pick(row, "Harbor Size"),
                    "harbor_use": pick(row, "Harbor Use"),

                    "tidal_range": to_float(pick(row, "Tidal Range (m)")),
                    "channel_depth": to_float(pick(row, "Channel Depth (m)")),
                    "anchorage_depth": to_float(pick(row, "Anchorage Depth (m)")),
                    "cargo_pier_depth": to_float(pick(row, "Cargo Pier Depth (m)")),
                    "max_vessel_length": to_float(pick(row, "Maximum Vessel Length (m)")),
                    "max_vessel_beam": to_float(pick(row, "Maximum Vessel Beam (m)")),
                    "max_vessel_draft": to_float(pick(row, "Maximum Vessel Draft (m)")),

                    "shelter_afforded": pick(row, "Shelter Afforded"),

                    "has_container": to_bool(pick(row, "Facilities - Container")),
                    "has_oil_terminal": to_bool(pick(row, "Facilities - Oil Terminal")),
                    "has_lng_terminal": to_bool(pick(row, "Facilities - LNG Terminal")),

                    "raw_json": json.dumps(row),
                })

                processed += 1

        db.commit()
        print(f"✅ Import completed successfully!")
        print(f"   Processed / Upserted: {processed:,} ports")
        print(f"   Skipped: {skipped} rows")

    except Exception as e:
        db.rollback()
        print(f"❌ Error: {e}")
        raise
    finally:
        db.close()


if __name__ == "__main__":
    main()