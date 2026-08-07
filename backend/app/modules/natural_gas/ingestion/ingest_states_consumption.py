import os
from datetime import datetime
from typing import Any

import requests
from dotenv import load_dotenv
from sqlalchemy import create_engine, text
from sqlalchemy.engine import Engine

load_dotenv()

EIA_API_KEY = os.getenv("EIA_API_KEY")

PGHOST = os.getenv("PGHOST", "localhost")
PGPORT = os.getenv("PGPORT", "5432")
PGDATABASE = os.getenv("PGDATABASE")
PGUSER = os.getenv("PGUSER")
PGPASSWORD = os.getenv("PGPASSWORD")

EIA_URL = "https://api.eia.gov/v2/natural-gas/cons/sum/data/"

STATES = {
    "AL": "Alabama", "AK": "Alaska", "AZ": "Arizona", "AR": "Arkansas",
    "CA": "California", "CO": "Colorado", "CT": "Connecticut", "DE": "Delaware",
    "DC": "District of Columbia", "FL": "Florida", "GA": "Georgia", "HI": "Hawaii",
    "ID": "Idaho", "IL": "Illinois", "IN": "Indiana", "IA": "Iowa",
    "KS": "Kansas", "KY": "Kentucky", "LA": "Louisiana", "ME": "Maine",
    "MD": "Maryland", "MA": "Massachusetts", "MI": "Michigan", "MN": "Minnesota",
    "MS": "Mississippi", "MO": "Missouri", "MT": "Montana", "NE": "Nebraska",
    "NV": "Nevada", "NH": "New Hampshire", "NJ": "New Jersey", "NM": "New Mexico",
    "NY": "New York", "NC": "North Carolina", "ND": "North Dakota", "OH": "Ohio",
    "OK": "Oklahoma", "OR": "Oregon", "PA": "Pennsylvania", "RI": "Rhode Island",
    "SC": "South Carolina", "SD": "South Dakota", "TN": "Tennessee", "TX": "Texas",
    "UT": "Utah", "VT": "Vermont", "VA": "Virginia", "WA": "Washington",
    "WV": "West Virginia", "WI": "Wisconsin", "WY": "Wyoming",
}

PROCESS_MAP = {
    "VRS": "residential_bcf",
    "VCS": "commercial_bcf",
    "VIN": "industrial_bcf",
    "VEU": "electric_power_bcf",
    "VGT": "total_delivered_bcf",
}


def get_engine() -> Engine:
    if not all([PGDATABASE, PGUSER, PGPASSWORD]):
        raise RuntimeError("Missing PostgreSQL details in .env")

    url = f"postgresql+psycopg2://{PGUSER}:{PGPASSWORD}@{PGHOST}:{PGPORT}/{PGDATABASE}"
    return create_engine(url)


def parse_month(period: str):
    return datetime.strptime(period, "%Y-%m").date().replace(day=1)


def to_bcf(value: Any) -> float | None:
    if value in (None, "", "NA"):
        return None

    try:
        return float(value) / 1000.0
    except (TypeError, ValueError):
        return None


def clean_state_code(raw_area: str | None) -> str | None:
    if not raw_area:
        return None

    raw_area = str(raw_area).strip().upper()

    if raw_area.startswith("S") and len(raw_area) == 3:
        return raw_area[1:]

    if len(raw_area) == 2:
        return raw_area

    return None


def fetch_eia_page(offset: int, length: int) -> list[dict[str, Any]]:
    params = {
        "api_key": EIA_API_KEY,
        "frequency": "monthly",
        "data[0]": "value",
        "facets[duoarea][]": [f"S{state}" for state in STATES.keys()],
        "facets[process][]": list(PROCESS_MAP.keys()),
        "sort[0][column]": "period",
        "sort[0][direction]": "desc",
        "offset": offset,
        "length": length,
    }

    response = requests.get(EIA_URL, params=params, timeout=60)

    if response.status_code != 200:
        print("Bad EIA request")
        print("URL:", response.url)
        print("Status:", response.status_code)
        print("Response:", response.text[:2000])
        response.raise_for_status()

    payload = response.json()
    return payload.get("response", {}).get("data", [])


def ensure_table(engine: Engine):
    sql = text("""
        CREATE SCHEMA IF NOT EXISTS gas;

        CREATE TABLE IF NOT EXISTS gas.states_consumption_monthly (
            month DATE NOT NULL,
            state_code TEXT NOT NULL,
            state_name TEXT,
            residential_bcf NUMERIC,
            commercial_bcf NUMERIC,
            industrial_bcf NUMERIC,
            electric_power_bcf NUMERIC,
            total_delivered_bcf NUMERIC,
            source_system TEXT DEFAULT 'EIA',
            ingested_at TIMESTAMPTZ DEFAULT NOW(),
            PRIMARY KEY (month, state_code)
        );
    """)

    with engine.begin() as conn:
        conn.execute(sql)


def main():
    if not EIA_API_KEY:
        raise RuntimeError("Missing EIA_API_KEY in .env")

    engine = get_engine()
    ensure_table(engine)

    rows: dict[tuple[str, str], dict[str, Any]] = {}

    offset = 0
    length = 5000

    while True:
        print(f"Fetching EIA rows offset={offset}")
        data = fetch_eia_page(offset, length)

        if not data:
            break

        for item in data:
            period = item.get("period")
            process = item.get("process")
            value = item.get("value")

            state_code = clean_state_code(item.get("duoarea"))

            if not period or not state_code or state_code not in STATES:
                continue

            if process not in PROCESS_MAP:
                continue

            key = (state_code, period)

            if key not in rows:
                rows[key] = {
                    "month": parse_month(period),
                    "state_code": state_code,
                    "state_name": STATES[state_code],
                    "residential_bcf": None,
                    "commercial_bcf": None,
                    "industrial_bcf": None,
                    "electric_power_bcf": None,
                    "total_delivered_bcf": None,
                }

            rows[key][PROCESS_MAP[process]] = to_bcf(value)

        if len(data) < length:
            break

        offset += length

    clean_rows = [
        row for row in rows.values()
        if row.get("month") and row.get("state_code")
    ]

    print(f"Total built rows: {len(rows)}")
    print(f"Valid rows: {len(clean_rows)}")
    print(f"Bad rows skipped: {len(rows) - len(clean_rows)}")

    if not clean_rows:
        print("No valid rows to insert.")
        return

    insert_sql = text("""
        INSERT INTO gas.states_consumption_monthly (
            month,
            state_code,
            state_name,
            residential_bcf,
            commercial_bcf,
            industrial_bcf,
            electric_power_bcf,
            total_delivered_bcf,
            source_system,
            ingested_at
        )
        VALUES (
            :month,
            :state_code,
            :state_name,
            :residential_bcf,
            :commercial_bcf,
            :industrial_bcf,
            :electric_power_bcf,
            :total_delivered_bcf,
            'EIA',
            NOW()
        )
        ON CONFLICT (month, state_code)
        DO UPDATE SET
            state_name = EXCLUDED.state_name,
            residential_bcf = EXCLUDED.residential_bcf,
            commercial_bcf = EXCLUDED.commercial_bcf,
            industrial_bcf = EXCLUDED.industrial_bcf,
            electric_power_bcf = EXCLUDED.electric_power_bcf,
            total_delivered_bcf = EXCLUDED.total_delivered_bcf,
            source_system = EXCLUDED.source_system,
            ingested_at = NOW();
    """)

    with engine.begin() as conn:
        conn.execute(insert_sql, clean_rows)

    print(f"Inserted/updated {len(clean_rows)} rows into gas.states_consumption_monthly.")


if __name__ == "__main__":
    main()