import os
import calendar
from datetime import datetime
from io import BytesIO
from typing import Optional

import pandas as pd
import requests
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine


# ============================================================
# AURION - Natural Gas Monthly Production Ingestion
# Source: EIA historical XLS files
# Target table: gas.production_monthly
# ============================================================

load_dotenv()


PGHOST = os.getenv("PGHOST", "localhost")
PGPORT = os.getenv("PGPORT", "5432")
PGDATABASE = os.getenv("PGDATABASE")
PGUSER = os.getenv("PGUSER")
PGPASSWORD = os.getenv("PGPASSWORD")


# EIA historical monthly files.
# Values are in MMcf, so we convert MMcf -> Bcf.
SERIES = {
    "dry_production_bcf": {
        "url": "https://www.eia.gov/dnav/ng/hist_xls/N9070US2m.xls",
        "source_series": "N9070US2M",
    },
    "marketed_production_bcf": {
        "url": "https://www.eia.gov/dnav/ng/hist_xls/N9050US2m.xls",
        "source_series": "N9050US2M",
    },
    "gross_withdrawals_bcf": {
        "url": "https://www.eia.gov/dnav/ng/hist_xls/N9010US2m.xls",
        "source_series": "N9010US2M",
    },
}


def get_engine() -> Engine:
    if not PGDATABASE or not PGUSER or not PGPASSWORD:
        raise RuntimeError(
            "Missing PostgreSQL environment variables. "
            "Check PGDATABASE, PGUSER and PGPASSWORD in your .env file."
        )

    url = (
        f"postgresql+psycopg2://{PGUSER}:{PGPASSWORD}"
        f"@{PGHOST}:{PGPORT}/{PGDATABASE}"
    )

    return create_engine(url, pool_pre_ping=True)


def ensure_table(engine: Engine) -> None:
    sql = """
    CREATE SCHEMA IF NOT EXISTS gas;

    CREATE TABLE IF NOT EXISTS gas.production_monthly (
        id BIGSERIAL PRIMARY KEY,

        month DATE NOT NULL,
        region TEXT NOT NULL DEFAULT 'United States',

        dry_production_bcf NUMERIC(12, 3),
        marketed_production_bcf NUMERIC(12, 3),
        gross_withdrawals_bcf NUMERIC(12, 3),

        dry_production_bcfd NUMERIC(10, 3),
        marketed_production_bcfd NUMERIC(10, 3),
        gross_withdrawals_bcfd NUMERIC(10, 3),

        source_system TEXT NOT NULL DEFAULT 'EIA',
        source_series TEXT,
        ingested_at TIMESTAMPTZ NOT NULL DEFAULT now(),

        CONSTRAINT ux_production_monthly_month_region
            UNIQUE (month, region)
    );
    """

    with engine.begin() as conn:
        conn.execute(text(sql))


def download_excel(url: str) -> bytes:
    print(f"Downloading {url}")
    response = requests.get(url, timeout=60)
    response.raise_for_status()
    return response.content


def parse_eia_monthly_xls(url: str, value_column_name: str) -> pd.DataFrame:
    excel_bytes = download_excel(url)

    raw = pd.read_excel(
        BytesIO(excel_bytes),
        sheet_name="Data 1",
        header=None,
    )

    header_row_index: Optional[int] = None

    for idx, row in raw.iterrows():
        values = [str(v).strip().lower() for v in row.tolist()]
        if "date" in values:
            header_row_index = idx
            break

    if header_row_index is None:
        raise RuntimeError(f"Could not find header row in EIA file: {url}")

    df = pd.read_excel(
        BytesIO(excel_bytes),
        sheet_name="Data 1",
        header=header_row_index,
    )

    if df.empty:
        raise RuntimeError(f"No data found in EIA file: {url}")

    date_col = df.columns[0]

    value_col = None

    for col in df.columns[1:]:
        numeric_test = pd.to_numeric(df[col], errors="coerce")

        if numeric_test.notna().sum() > 5:
            value_col = col
            break

    if value_col is None:
        raise RuntimeError(f"Could not find numeric value column in EIA file: {url}")

    clean = df[[date_col, value_col]].copy()
    clean.columns = ["month", value_column_name]

    clean["month"] = pd.to_datetime(clean["month"], errors="coerce").dt.date
    clean[value_column_name] = pd.to_numeric(clean[value_column_name], errors="coerce")

    clean = clean.dropna(subset=["month", value_column_name])

    # EIA values are MMcf. Convert MMcf -> Bcf.
    clean[value_column_name] = clean[value_column_name] / 1000.0

    return clean


def days_in_month(month_value) -> int:
    return calendar.monthrange(month_value.year, month_value.month)[1]


def build_combined_dataframe() -> pd.DataFrame:
    frames: list[pd.DataFrame] = []

    for target_column, config in SERIES.items():
        print(f"Fetching {target_column}: {config['source_series']}")

        frame = parse_eia_monthly_xls(
            url=config["url"],
            value_column_name=target_column,
        )

        print(f"Rows fetched for {target_column}: {len(frame)}")
        frames.append(frame)

    combined = frames[0]

    for frame in frames[1:]:
        combined = combined.merge(frame, on="month", how="outer")

    combined = combined.sort_values("month").reset_index(drop=True)

    combined["region"] = "United States"
    combined["days_in_month"] = combined["month"].apply(days_in_month)

    combined["dry_production_bcfd"] = (
        combined["dry_production_bcf"] / combined["days_in_month"]
    )

    combined["marketed_production_bcfd"] = (
        combined["marketed_production_bcf"] / combined["days_in_month"]
    )

    combined["gross_withdrawals_bcfd"] = (
        combined["gross_withdrawals_bcf"] / combined["days_in_month"]
    )

    combined["source_system"] = "EIA"
    combined["source_series"] = "N9070US2M,N9050US2M,N9010US2M"
    combined["ingested_at"] = datetime.utcnow()

    return combined


def upsert_rows(engine: Engine, df: pd.DataFrame) -> int:
    sql = """
    INSERT INTO gas.production_monthly (
        month,
        region,
        dry_production_bcf,
        marketed_production_bcf,
        gross_withdrawals_bcf,
        dry_production_bcfd,
        marketed_production_bcfd,
        gross_withdrawals_bcfd,
        source_system,
        source_series,
        ingested_at
    )
    VALUES (
        :month,
        :region,
        :dry_production_bcf,
        :marketed_production_bcf,
        :gross_withdrawals_bcf,
        :dry_production_bcfd,
        :marketed_production_bcfd,
        :gross_withdrawals_bcfd,
        :source_system,
        :source_series,
        :ingested_at
    )
    ON CONFLICT (month, region)
    DO UPDATE SET
        dry_production_bcf = EXCLUDED.dry_production_bcf,
        marketed_production_bcf = EXCLUDED.marketed_production_bcf,
        gross_withdrawals_bcf = EXCLUDED.gross_withdrawals_bcf,
        dry_production_bcfd = EXCLUDED.dry_production_bcfd,
        marketed_production_bcfd = EXCLUDED.marketed_production_bcfd,
        gross_withdrawals_bcfd = EXCLUDED.gross_withdrawals_bcfd,
        source_system = EXCLUDED.source_system,
        source_series = EXCLUDED.source_series,
        ingested_at = EXCLUDED.ingested_at;
    """

    records = df.where(pd.notnull(df), None).to_dict(orient="records")

    with engine.begin() as conn:
        conn.execute(text(sql), records)

    return len(records)


def print_latest(engine: Engine) -> None:
    sql = """
    SELECT
        month,
        region,
        dry_production_bcf,
        dry_production_bcfd,
        marketed_production_bcf,
        marketed_production_bcfd,
        gross_withdrawals_bcf,
        gross_withdrawals_bcfd
    FROM gas.production_monthly
    ORDER BY month DESC
    LIMIT 1;
    """

    with engine.begin() as conn:
        row = conn.execute(text(sql)).mappings().first()

    if not row:
        print("No production rows found.")
        return

    print("Latest production record:")
    print(f"  Month: {row['month']}")
    print(f"  Region: {row['region']}")
    print(f"  Dry production Bcf: {row['dry_production_bcf']}")
    print(f"  Dry production Bcf/d: {row['dry_production_bcfd']}")
    print(f"  Marketed production Bcf: {row['marketed_production_bcf']}")
    print(f"  Marketed production Bcf/d: {row['marketed_production_bcfd']}")
    print(f"  Gross withdrawals Bcf: {row['gross_withdrawals_bcf']}")
    print(f"  Gross withdrawals Bcf/d: {row['gross_withdrawals_bcfd']}")


def main() -> None:
    print("Starting AURION monthly natural gas production ingestion...")

    engine = get_engine()

    ensure_table(engine)

    df = build_combined_dataframe()

    print(f"Combined monthly rows prepared: {len(df)}")

    inserted = upsert_rows(engine, df)

    print(f"Rows inserted/updated: {inserted}")

    print_latest(engine)

    print("Natural gas production ingestion complete.")


if __name__ == "__main__":
    main()