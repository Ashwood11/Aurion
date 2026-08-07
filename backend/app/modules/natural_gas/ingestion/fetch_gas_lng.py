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
# AURION - Natural Gas LNG Monthly Ingestion
# Source: EIA historical XLS files
# Target table: gas.lng_monthly
# ============================================================

load_dotenv()


PGHOST = os.getenv("PGHOST", "localhost")
PGPORT = os.getenv("PGPORT", "5432")
PGDATABASE = os.getenv("PGDATABASE")
PGUSER = os.getenv("PGUSER")
PGPASSWORD = os.getenv("PGPASSWORD")


# EIA monthly historical files.
# Values are normally in MMcf, so we convert MMcf -> Bcf.
#
# LNG exports:
#   N9133US2M = U.S. Liquefied Natural Gas Exports
#
# LNG imports:
#   N9103US2M = U.S. Liquefied Natural Gas Imports
#
SERIES = {
    "lng_exports_bcf": {
        "url": "https://www.eia.gov/dnav/ng/hist_xls/N9133US2m.xls",
        "source_series": "N9133US2M",
    },
    "lng_imports_bcf": {
        "url": "https://www.eia.gov/dnav/ng/hist_xls/N9103US2m.xls",
        "source_series": "N9103US2M",
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

    CREATE TABLE IF NOT EXISTS gas.lng_monthly (
        id BIGSERIAL PRIMARY KEY,

        month DATE NOT NULL,
        region TEXT NOT NULL DEFAULT 'United States',

        lng_exports_bcf NUMERIC(12, 3),
        lng_imports_bcf NUMERIC(12, 3),
        net_lng_exports_bcf NUMERIC(12, 3),

        lng_exports_bcfd NUMERIC(10, 3),
        lng_imports_bcfd NUMERIC(10, 3),
        net_lng_exports_bcfd NUMERIC(10, 3),

        source_system TEXT NOT NULL DEFAULT 'EIA',
        source_series TEXT,
        ingested_at TIMESTAMPTZ NOT NULL DEFAULT now(),

        CONSTRAINT ux_lng_monthly_month_region
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

    # EIA historical files are usually MMcf. Convert MMcf -> Bcf.
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

    combined["lng_exports_bcf"] = combined["lng_exports_bcf"].fillna(0)
    combined["lng_imports_bcf"] = combined["lng_imports_bcf"].fillna(0)

    combined["net_lng_exports_bcf"] = (
        combined["lng_exports_bcf"] - combined["lng_imports_bcf"]
    )

    combined["days_in_month"] = combined["month"].apply(days_in_month)

    combined["lng_exports_bcfd"] = (
        combined["lng_exports_bcf"] / combined["days_in_month"]
    )

    combined["lng_imports_bcfd"] = (
        combined["lng_imports_bcf"] / combined["days_in_month"]
    )

    combined["net_lng_exports_bcfd"] = (
        combined["net_lng_exports_bcf"] / combined["days_in_month"]
    )

    combined["source_system"] = "EIA"
    combined["source_series"] = "N9133US2M,N9103US2M"
    combined["ingested_at"] = datetime.utcnow()

    return combined


def upsert_rows(engine: Engine, df: pd.DataFrame) -> int:
    sql = """
    INSERT INTO gas.lng_monthly (
        month,
        region,
        lng_exports_bcf,
        lng_imports_bcf,
        net_lng_exports_bcf,
        lng_exports_bcfd,
        lng_imports_bcfd,
        net_lng_exports_bcfd,
        source_system,
        source_series,
        ingested_at
    )
    VALUES (
        :month,
        :region,
        :lng_exports_bcf,
        :lng_imports_bcf,
        :net_lng_exports_bcf,
        :lng_exports_bcfd,
        :lng_imports_bcfd,
        :net_lng_exports_bcfd,
        :source_system,
        :source_series,
        :ingested_at
    )
    ON CONFLICT (month, region)
    DO UPDATE SET
        lng_exports_bcf = EXCLUDED.lng_exports_bcf,
        lng_imports_bcf = EXCLUDED.lng_imports_bcf,
        net_lng_exports_bcf = EXCLUDED.net_lng_exports_bcf,
        lng_exports_bcfd = EXCLUDED.lng_exports_bcfd,
        lng_imports_bcfd = EXCLUDED.lng_imports_bcfd,
        net_lng_exports_bcfd = EXCLUDED.net_lng_exports_bcfd,
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
        lng_exports_bcf,
        lng_imports_bcf,
        net_lng_exports_bcf,
        lng_exports_bcfd,
        lng_imports_bcfd,
        net_lng_exports_bcfd
    FROM gas.lng_monthly
    ORDER BY month DESC
    LIMIT 1;
    """

    with engine.begin() as conn:
        row = conn.execute(text(sql)).mappings().first()

    if not row:
        print("No LNG rows found.")
        return

    print("Latest LNG record:")
    print(f"  Month: {row['month']}")
    print(f"  Region: {row['region']}")
    print(f"  LNG exports Bcf: {row['lng_exports_bcf']}")
    print(f"  LNG imports Bcf: {row['lng_imports_bcf']}")
    print(f"  Net LNG exports Bcf: {row['net_lng_exports_bcf']}")
    print(f"  LNG exports Bcf/d: {row['lng_exports_bcfd']}")
    print(f"  LNG imports Bcf/d: {row['lng_imports_bcfd']}")
    print(f"  Net LNG exports Bcf/d: {row['net_lng_exports_bcfd']}")


def main() -> None:
    print("Starting AURION monthly LNG ingestion...")

    engine = get_engine()

    ensure_table(engine)

    df = build_combined_dataframe()

    print(f"Combined monthly rows prepared: {len(df)}")

    inserted = upsert_rows(engine, df)

    print(f"Rows inserted/updated: {inserted}")

    print_latest(engine)

    print("Natural gas LNG ingestion complete.")


if __name__ == "__main__":
    main()