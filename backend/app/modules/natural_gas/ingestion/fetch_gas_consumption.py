import os
import time
from datetime import datetime, date
from typing import Any

import requests
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine


# ============================================================
# AURION - Natural Gas Monthly Consumption Ingestion
# Source: EIA API v2
# Target table: gas.consumption_monthly
# ============================================================

load_dotenv()


EIA_API_KEY = os.getenv("EIA_API_KEY")

PGHOST = os.getenv("PGHOST", "localhost")
PGPORT = os.getenv("PGPORT", "5432")
PGDATABASE = os.getenv("PGDATABASE")
PGUSER = os.getenv("PGUSER")
PGPASSWORD = os.getenv("PGPASSWORD")


SERIES_MAP = {
    "total_consumption_bcf": "NG.N9140US2.M",
    "residential_bcf": "NG.N3010US2.M",
    "commercial_bcf": "NG.N3020US2.M",
    "industrial_bcf": "NG.N3035US2.M",
    "electric_power_bcf": "NG.N3045US2.M",
}


SOURCE_BASE_URL = "https://api.eia.gov/v2/seriesid/"


def require_env() -> None:
    missing = []

    required = {
        "EIA_API_KEY": EIA_API_KEY,
        "PGDATABASE": PGDATABASE,
        "PGUSER": PGUSER,
        "PGPASSWORD": PGPASSWORD,
    }

    for key, value in required.items():
        if not value:
            missing.append(key)

    if missing:
        raise RuntimeError(
            f"Missing environment variables: {', '.join(missing)}"
        )


def get_engine() -> Engine:
    db_url = (
        f"postgresql+psycopg2://{PGUSER}:{PGPASSWORD}"
        f"@{PGHOST}:{PGPORT}/{PGDATABASE}"
    )

    return create_engine(db_url, pool_pre_ping=True)


def parse_eia_month(period: str) -> date:
    """
    EIA v2 monthly periods usually come back like:
    2024-01

    This also supports:
    202401
    """
    period = str(period).strip()

    for fmt in ("%Y-%m", "%Y%m"):
        try:
            return datetime.strptime(period, fmt).date()
        except ValueError:
            continue

    raise ValueError(f"Unsupported EIA monthly period format: {period}")


def eia_value_to_bcf(value: Any) -> float | None:
    """
    EIA monthly US natural gas consumption series are in MMcf.
    AURION stores Bcf.

    1 Bcf = 1,000 MMcf
    """
    if value is None:
        return None

    try:
        return round(float(value) / 1000.0, 3)
    except (TypeError, ValueError):
        return None


def fetch_eia_series(series_id: str, max_attempts: int = 3) -> list[dict[str, Any]]:
    url = f"{SOURCE_BASE_URL}{series_id}"

    params = {
        "api_key": EIA_API_KEY,
    }

    last_error: Exception | None = None

    for attempt in range(1, max_attempts + 1):
        try:
            response = requests.get(url, params=params, timeout=30)
            response.raise_for_status()

            payload = response.json()
            data = payload.get("response", {}).get("data", [])

            if not data:
                raise RuntimeError(f"No data returned for series: {series_id}")

            return data

        except Exception as exc:
            last_error = exc

            if attempt < max_attempts:
                wait_seconds = attempt * 2
                print(
                    f"WARNING: fetch failed for {series_id} "
                    f"(attempt {attempt}/{max_attempts}). Retrying in {wait_seconds}s..."
                )
                time.sleep(wait_seconds)
            else:
                break

    raise RuntimeError(
        f"Failed to fetch EIA series after {max_attempts} attempts: {series_id}. "
        f"Last error: {last_error}"
    )


def build_consumption_rows() -> tuple[
    dict[date, dict[str, Any]],
    list[str],
    list[str],
]:
    rows_by_month: dict[date, dict[str, Any]] = {}

    successful_series: list[str] = []
    failed_series: list[str] = []

    for column_name, series_id in SERIES_MAP.items():
        print(f"Fetching {column_name}: {series_id}")

        try:
            data = fetch_eia_series(series_id)
        except Exception as exc:
            print(f"ERROR: failed to fetch {series_id}: {exc}")
            failed_series.append(series_id)
            continue

        successful_series.append(series_id)
        print(f"Rows fetched for {column_name}: {len(data)}")

        for item in data:
            period = item.get("period")
            value = item.get("value")

            if not period:
                continue

            try:
                report_month = parse_eia_month(period)
            except ValueError as exc:
                print(f"WARNING: skipping bad period value: {period}. {exc}")
                continue

            bcf_value = eia_value_to_bcf(value)

            if report_month not in rows_by_month:
                rows_by_month[report_month] = {
                    "region": "United States",
                    "report_month": report_month,
                    "total_consumption_bcf": None,
                    "residential_bcf": None,
                    "commercial_bcf": None,
                    "industrial_bcf": None,
                    "electric_power_bcf": None,
                    "vehicle_fuel_bcf": None,
                    "data_status": "official",
                    "source_system": "EIA",
                    "source_series": "",
                    "source_url": SOURCE_BASE_URL,
                }

            rows_by_month[report_month][column_name] = bcf_value

    data_status = "official" if not failed_series else "partial"
    source_series = ",".join(successful_series)

    for row in rows_by_month.values():
        row["data_status"] = data_status
        row["source_series"] = source_series

    return rows_by_month, successful_series, failed_series


def insert_rows(
    engine: Engine,
    rows_by_month: dict[date, dict[str, Any]],
) -> int:
    insert_sql = text(
        """
        INSERT INTO gas.consumption_monthly AS cm (
            region,
            report_month,
            total_consumption_bcf,
            residential_bcf,
            commercial_bcf,
            industrial_bcf,
            electric_power_bcf,
            vehicle_fuel_bcf,
            data_status,
            source_system,
            source_series,
            source_url,
            created_at,
            updated_at,
            ingested_at
        )
        VALUES (
            :region,
            :report_month,
            :total_consumption_bcf,
            :residential_bcf,
            :commercial_bcf,
            :industrial_bcf,
            :electric_power_bcf,
            :vehicle_fuel_bcf,
            :data_status,
            :source_system,
            :source_series,
            :source_url,
            NOW(),
            NOW(),
            NOW()
        )
        ON CONFLICT (region, report_month)
        DO UPDATE SET
            total_consumption_bcf = COALESCE(
                EXCLUDED.total_consumption_bcf,
                cm.total_consumption_bcf
            ),
            residential_bcf = COALESCE(
                EXCLUDED.residential_bcf,
                cm.residential_bcf
            ),
            commercial_bcf = COALESCE(
                EXCLUDED.commercial_bcf,
                cm.commercial_bcf
            ),
            industrial_bcf = COALESCE(
                EXCLUDED.industrial_bcf,
                cm.industrial_bcf
            ),
            electric_power_bcf = COALESCE(
                EXCLUDED.electric_power_bcf,
                cm.electric_power_bcf
            ),
            vehicle_fuel_bcf = COALESCE(
                EXCLUDED.vehicle_fuel_bcf,
                cm.vehicle_fuel_bcf
            ),
            data_status = EXCLUDED.data_status,
            source_system = EXCLUDED.source_system,
            source_series = EXCLUDED.source_series,
            source_url = EXCLUDED.source_url,
            updated_at = NOW(),
            ingested_at = NOW();
        """
    )

    if not rows_by_month:
        return 0

    rows = [rows_by_month[key] for key in sorted(rows_by_month.keys())]

    with engine.begin() as conn:
        conn.execute(insert_sql, rows)

    return len(rows)


def print_collection_summary(
    rows_by_month: dict[date, dict[str, Any]],
    successful_series: list[str],
    failed_series: list[str],
) -> None:
    print("")
    print("Collection summary:")
    print(f"  Successful series: {len(successful_series)}")
    print(f"  Failed series: {len(failed_series)}")
    print(f"  Combined monthly rows prepared: {len(rows_by_month)}")

    if successful_series:
        print("  Successful EIA series:")
        for series_id in successful_series:
            print(f"    - {series_id}")

    if failed_series:
        print("  Failed EIA series:")
        for series_id in failed_series:
            print(f"    - {series_id}")

    if not rows_by_month:
        return

    latest_month = max(rows_by_month.keys())
    latest_row = rows_by_month[latest_month]

    print("")
    print("Latest collected record:")
    print(f"  Month: {latest_month}")
    print(f"  Region: {latest_row['region']}")
    print(f"  Total consumption Bcf: {latest_row['total_consumption_bcf']}")
    print(f"  Residential Bcf: {latest_row['residential_bcf']}")
    print(f"  Commercial Bcf: {latest_row['commercial_bcf']}")
    print(f"  Industrial Bcf: {latest_row['industrial_bcf']}")
    print(f"  Electric power Bcf: {latest_row['electric_power_bcf']}")
    print(f"  Data status: {latest_row['data_status']}")


def print_database_latest(engine: Engine) -> None:
    latest_sql = text(
        """
        SELECT
            report_month,
            region,
            total_consumption_bcf,
            residential_bcf,
            commercial_bcf,
            industrial_bcf,
            electric_power_bcf,
            vehicle_fuel_bcf,
            data_status,
            source_system,
            source_series,
            ingested_at
        FROM gas.consumption_monthly
        WHERE region = 'United States'
        ORDER BY report_month DESC
        LIMIT 1;
        """
    )

    with engine.begin() as conn:
        row = conn.execute(latest_sql).fetchone()

    print("")
    print("Latest database record:")

    if not row:
        print("  No records found in gas.consumption_monthly.")
        return

    data = dict(row._mapping)

    print(f"  Month: {data['report_month']}")
    print(f"  Region: {data['region']}")
    print(f"  Total consumption Bcf: {data['total_consumption_bcf']}")
    print(f"  Residential Bcf: {data['residential_bcf']}")
    print(f"  Commercial Bcf: {data['commercial_bcf']}")
    print(f"  Industrial Bcf: {data['industrial_bcf']}")
    print(f"  Electric power Bcf: {data['electric_power_bcf']}")
    print(f"  Vehicle fuel Bcf: {data['vehicle_fuel_bcf']}")
    print(f"  Data status: {data['data_status']}")
    print(f"  Source system: {data['source_system']}")
    print(f"  Source series: {data['source_series']}")
    print(f"  Ingested at: {data['ingested_at']}")


def main() -> None:
    print("Starting AURION monthly natural gas consumption ingestion...")

    require_env()

    print("")
    print("Database target:")
    print(f"  Host: {PGHOST}")
    print(f"  Port: {PGPORT}")
    print(f"  Database: {PGDATABASE}")
    print(f"  User: {PGUSER}")

    engine = get_engine()

    rows_by_month, successful_series, failed_series = build_consumption_rows()

    print_collection_summary(
        rows_by_month=rows_by_month,
        successful_series=successful_series,
        failed_series=failed_series,
    )

    inserted_count = insert_rows(engine, rows_by_month)

    print("")
    print(f"Rows inserted/updated: {inserted_count}")

    print_database_latest(engine)

    print("")
    print("Monthly natural gas consumption ingestion complete.")


if __name__ == "__main__":
    main()