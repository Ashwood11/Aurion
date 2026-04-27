import csv
from pathlib import Path

from sqlalchemy import text

from app.core.database import SessionLocal


BASE_DIR = Path(__file__).resolve().parents[2]
CSV_PATH = BASE_DIR / "data" / "airports.csv"


def clean(value: str | None) -> str | None:
    if value is None:
        return None

    value = value.strip()

    if value == "":
        return None

    return value


def main():
    if not CSV_PATH.exists():
        raise FileNotFoundError(f"CSV not found: {CSV_PATH}")

    db = SessionLocal()

    try:
        with CSV_PATH.open("r", encoding="utf-8", newline="") as file:
            reader = csv.DictReader(file)

            updated = 0
            missing = 0

            for row in reader:
                ident = clean(row.get("ident"))

                if not ident:
                    continue

                result = db.execute(
                    text("""
                        UPDATE geo.airports a
                        SET
                            airport_type = :airport_type,
                            scheduled_service = :scheduled_service,
                            gps_code = :gps_code,
                            iata_code = :iata_code,
                            local_code = :local_code,
                            home_link = :home_link,
                            wikipedia_link = :wikipedia_link
                        FROM geo.locations l
                        WHERE a.location_id = l.id
                          AND l.entity_type = 'airport'
                          AND l.source_system = 'ourairports'
                          AND l.source_id = :ident
                    """),
                    {
                        "ident": ident,
                        "airport_type": clean(row.get("type")) or "unknown",
                        "scheduled_service": clean(row.get("scheduled_service")) or "unknown",
                        "gps_code": clean(row.get("gps_code")),
                        "iata_code": clean(row.get("iata_code")),
                        "local_code": clean(row.get("local_code")),
                        "home_link": clean(row.get("home_link")),
                        "wikipedia_link": clean(row.get("wikipedia_link")),
                    },
                )

                if result.rowcount:
                    updated += result.rowcount
                else:
                    missing += 1

            db.commit()

            print("Airport enrichment complete")
            print(f"Updated rows: {updated}")
            print(f"CSV rows not matched: {missing}")

    except Exception:
        db.rollback()
        raise

    finally:
        db.close()


if __name__ == "__main__":
    main()