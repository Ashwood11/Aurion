import os
import time
from datetime import datetime, date
from typing import Any

import requests
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine


# ============================================================
# AURION - Natural Gas Daily Price Ingestion
# Source: EIA API v2
# Target table: gas.prices_daily
# Market: Henry Hub Spot Price
# Unit: USD per MMBtu
# ============================================================

load_dotenv()


EIA_API_KEY = os.getenv("EIA_API_KEY")

PGHOST = os.getenv("PGHOST", "localhost")
PGPORT = os.getenv("PGPORT", "5432")
PGDATABASE = os.getenv("PGDATABASE")
PGUSER = os.getenv("PGUSER")
PGPASSWORD = os.getenv("PGPASSWORD")


TABLE_NAME = "gas.prices_daily"

HENRY_HUB_DAILY_SERIES = "NG.RNGWHHD.D"
SOURCE_BASE_URL = "https://api.eia.gov/v2/seriesid/"
SOURCE_URL = f"{SOURCE_BASE_URL}{HENRY_HUB_DAILY_SERIES}"


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


def parse_eia_day(period: str) -> date:
    """
    EIA daily periods usually come back like:
    2026-05-04

    This also supports:
    20260504
    """
    period = str(period).strip()

    for fmt in ("%Y-%m-%d", "%Y%m%d"):
        try:
            return datetime.strptime(period, fmt).date()
        except ValueError:
            continue

    raise ValueError(f"Unsupported EIA daily period format: {period}")


def eia_value_to_price(value: Any) -> float | None:
    if value is None:
        return None

    try:
        return round(float(value), 4)
    except (TypeError, ValueError):
        return None


def fetch_eia_series(max_attempts: int = 3) -> list[dict[str, Any]]:
    params = {
        "api_key": EIA_API_KEY,
    }

    last_error: Exception | None = None

    for attempt in range(1, max_attempts + 1):
        try:
            response = requests.get(SOURCE_URL, params=params, timeout=30)
            response.raise_for_status()

            payload = response.json()
            data = payload.get("response", {}).get("data", [])

            if not data:
                raise RuntimeError(
                    f"No data returned for series: {HENRY_HUB_DAILY_SERIES}"
                )

            return data

        except Exception as exc:
            last_error = exc

            if attempt < max_attempts:
                wait_seconds = attempt * 2
                print(
                    f"WARNING: fetch failed for {HENRY_HUB_DAILY_SERIES} "
                    f"(attempt {attempt}/{max_attempts}). Retrying in {wait_seconds}s..."
                )
                time.sleep(wait_seconds)

    raise RuntimeError(
        f"Failed to fetch EIA series after {max_attempts} attempts: "
        f"{HENRY_HUB_DAILY_SERIES}. Last error: {last_error}"
    )


def build_price_rows() -> list[dict[str, Any]]:
    print(f"Fetching Henry Hub daily spot price: {HENRY_HUB_DAILY_SERIES}")

    data = fetch_eia_series()

    print(f"Rows fetched: {len(data)}")

    raw_rows: list[dict[str, Any]] = []

    for item in data:
        period = item.get("period")
        value = item.get("value")

        if not period:
            continue

        try:
            price_date = parse_eia_day(period)
        except ValueError as exc:
            print(f"WARNING: skipping bad period value: {period}. {exc}")
            continue

        price = eia_value_to_price(value)

        if price is None:
            continue

        raw_rows.append(
            {
                "market": "Henry Hub",
                "region": "United States",
                "price_date": price_date,
                "price_usd_per_mmbtu": price,
                "change_usd": None,
                "change_pct": None,
                "data_status": "official",
                "source_system": "EIA",
                "source_series": HENRY_HUB_DAILY_SERIES,
                "source_url": SOURCE_URL,
            }
        )

    raw_rows.sort(key=lambda row: row["price_date"])

    previous_price: float | None = None

    for row in raw_rows:
        current_price = row["price_usd_per_mmbtu"]

        if previous_price is not None and previous_price != 0:
            change_usd = round(current_price - previous_price, 4)
            change_pct = round((change_usd / previous_price) * 100, 4)

            row["change_usd"] = change_usd
            row["change_pct"] = change_pct

        previous_price = current_price

    return raw_rows


def insert_rows(engine: Engine, rows: list[dict[str, Any]]) -> int:
    if not rows:
        return 0

    insert_sql = text(
        """
        INSERT INTO gas.prices_daily AS pd (
            market,
            region,
            price_date,
            price_usd_per_mmbtu,
            change_usd,
            change_pct,
            data_status,
            source_system,
            source_series,
            source_url,
            created_at,
            updated_at,
            ingested_at
        )
        VALUES (
            :market,
            :region,
            :price_date,
            :price_usd_per_mmbtu,
            :change_usd,
            :change_pct,
            :data_status,
            :source_system,
            :source_series,
            :source_url,
            NOW(),
            NOW(),
            NOW()
        )
        ON CONFLICT (market, price_date)
        DO UPDATE SET
            region = EXCLUDED.region,
            price_usd_per_mmbtu = COALESCE(
                EXCLUDED.price_usd_per_mmbtu,
                pd.price_usd_per_mmbtu
            ),
            change_usd = COALESCE(
                EXCLUDED.change_usd,
                pd.change_usd
            ),
            change_pct = COALESCE(
                EXCLUDED.change_pct,
                pd.change_pct
            ),
            data_status = EXCLUDED.data_status,
            source_system = EXCLUDED.source_system,
            source_series = EXCLUDED.source_series,
            source_url = EXCLUDED.source_url,
            updated_at = NOW(),
            ingested_at = NOW();
        """
    )

    with engine.begin() as conn:
        conn.execute(insert_sql, rows)

    return len(rows)


def print_latest_database_record(engine: Engine) -> None:
    latest_sql = text(
        """
        SELECT
            market,
            region,
            price_date,
            price_usd_per_mmbtu,
            change_usd,
            change_pct,
            source_system,
            source_series,
            ingested_at
        FROM gas.prices_daily
        WHERE market = 'Henry Hub'
        ORDER BY price_date DESC
        LIMIT 1;
        """
    )

    with engine.begin() as conn:
        row = conn.execute(latest_sql).fetchone()

    print("")
    print("Latest database price record:")

    if not row:
        print("  No records found in gas.prices_daily.")
        return

    data = dict(row._mapping)

    print(f"  Market: {data['market']}")
    print(f"  Region: {data['region']}")
    print(f"  Date: {data['price_date']}")
    print(f"  Price: ${data['price_usd_per_mmbtu']} / MMBtu")
    print(f"  Change USD: {data['change_usd']}")
    print(f"  Change %: {data['change_pct']}")
    print(f"  Source system: {data['source_system']}")
    print(f"  Source series: {data['source_series']}")
    print(f"  Ingested at: {data['ingested_at']}")


def main() -> None:
    print("Starting AURION daily natural gas price ingestion...")

    require_env()

    print("")
    print("Database target:")
    print(f"  Host: {PGHOST}")
    print(f"  Port: {PGPORT}")
    print(f"  Database: {PGDATABASE}")
    print(f"  User: {PGUSER}")
    print(f"  Table: {TABLE_NAME}")

    engine = get_engine()

    rows = build_price_rows()

    print("")
    print(f"Prepared price rows: {len(rows)}")

    inserted_count = insert_rows(engine, rows)

    print(f"Rows inserted/updated: {inserted_count}")

    print_latest_database_record(engine)

    print("")
    print("Daily natural gas price ingestion complete.")


if __name__ == "__main__":
    main()