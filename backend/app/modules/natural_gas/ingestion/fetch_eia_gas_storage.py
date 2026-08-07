import os

import pandas as pd
import psycopg2
from dotenv import load_dotenv
from psycopg2.extras import execute_values

load_dotenv()

DB_CONFIG = {
    "host": os.getenv("PGHOST", "localhost"),
    "port": os.getenv("PGPORT", "5432"),
    "dbname": os.getenv("PGDATABASE", "aurion"),
    "user": os.getenv("PGUSER", "postgres"),
    "password": os.getenv("PGPASSWORD"),
}

DATA_URL = "https://www.eia.gov/dnav/ng/hist_xls/NW2_EPG0_SWO_R48_BCFw.xls"
SERIES_ID = "NW2_EPG0_SWO_R48_BCF"
REGION = "Lower 48"


def get_storage_season(report_date):
    if 4 <= report_date.month <= 10:
        return "injection"
    return "withdrawal"


def fetch_eia_series():
    df = pd.read_excel(DATA_URL, sheet_name=1, header=None)

    parsed = []

    for _, row in df.iterrows():
        date_value = row[0]
        storage_value = row[1]

        if pd.isna(date_value) or pd.isna(storage_value):
            continue

        try:
            report_date = pd.to_datetime(date_value).date()
            total_bcf = float(storage_value)
        except Exception:
            continue

        iso_year, iso_week, _ = report_date.isocalendar()

        parsed.append(
            {
                "region": REGION,
                "report_date": report_date,
                "storage_year": iso_year,
                "storage_week": iso_week,
                "storage_month": report_date.month,
                "storage_season": get_storage_season(report_date),
                "total_bcf": total_bcf,
                "source_series": SERIES_ID,
            }
        )

    if not parsed:
        raise RuntimeError("No gas storage rows parsed from EIA Excel file.")

    return parsed


def calculate_storage_metrics(rows):
    rows = sorted(rows, key=lambda x: x["report_date"])

    rows_by_year_week = {}

    for row in rows:
        key = (row["storage_year"], row["storage_week"])
        rows_by_year_week[key] = row

    previous_total = None

    for row in rows:
        current_total = row["total_bcf"]
        current_year = row["storage_year"]
        current_week = row["storage_week"]

        if previous_total is None:
            row["change_bcf"] = None
        else:
            row["change_bcf"] = round(current_total - previous_total, 2)

        previous_total = current_total

        year_ago_row = rows_by_year_week.get((current_year - 1, current_week))

        if year_ago_row:
            row["year_ago_bcf"] = year_ago_row["total_bcf"]
            row["surplus_vs_year_ago_bcf"] = round(
                current_total - year_ago_row["total_bcf"], 2
            )
        else:
            row["year_ago_bcf"] = None
            row["surplus_vs_year_ago_bcf"] = None

        five_year_values = []

        for year_offset in range(1, 6):
            comparison_row = rows_by_year_week.get(
                (current_year - year_offset, current_week)
            )

            if comparison_row:
                five_year_values.append(comparison_row["total_bcf"])

        if five_year_values:
            five_year_avg = sum(five_year_values) / len(five_year_values)
            row["five_year_avg_bcf"] = round(five_year_avg, 2)
            row["surplus_vs_five_year_avg_bcf"] = round(
                current_total - five_year_avg, 2
            )
        else:
            row["five_year_avg_bcf"] = None
            row["surplus_vs_five_year_avg_bcf"] = None

    return rows


def validate_rows(rows):
    for row in rows:
        total = row["total_bcf"]
        change = row.get("change_bcf")

        if total < 0:
            raise ValueError(
                f"Negative storage detected: {total} Bcf on {row['report_date']}"
            )

        if total > 5000:
            raise ValueError(
                f"Unrealistic storage detected: {total} Bcf on {row['report_date']}"
            )

        if change is not None and abs(change) > 500:
            raise ValueError(
                f"Unrealistic weekly change detected: "
                f"{change} Bcf on {row['report_date']}"
            )


def get_latest_db_date():
    conn = psycopg2.connect(**DB_CONFIG)

    try:
        with conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    SELECT MAX(report_date)
                    FROM gas.storage_weekly
                    WHERE region = %s
                    """,
                    (REGION,),
                )

                result = cur.fetchone()
                return result[0] if result else None
    finally:
        conn.close()


def insert_rows(rows):
    if not rows:
        return

    sql = """
        INSERT INTO gas.storage_weekly (
            region,
            report_date,
            storage_year,
            storage_week,
            storage_month,
            storage_season,
            total_bcf,
            change_bcf,
            year_ago_bcf,
            five_year_avg_bcf,
            surplus_vs_year_ago_bcf,
            surplus_vs_five_year_avg_bcf,
            source_system,
            source_series
        )
        VALUES %s
        ON CONFLICT (region, report_date, source_system)
        DO UPDATE SET
            storage_year = EXCLUDED.storage_year,
            storage_week = EXCLUDED.storage_week,
            storage_month = EXCLUDED.storage_month,
            storage_season = EXCLUDED.storage_season,
            total_bcf = EXCLUDED.total_bcf,
            change_bcf = EXCLUDED.change_bcf,
            year_ago_bcf = EXCLUDED.year_ago_bcf,
            five_year_avg_bcf = EXCLUDED.five_year_avg_bcf,
            surplus_vs_year_ago_bcf = EXCLUDED.surplus_vs_year_ago_bcf,
            surplus_vs_five_year_avg_bcf = EXCLUDED.surplus_vs_five_year_avg_bcf,
            source_series = EXCLUDED.source_series,
            ingested_at = NOW();
    """

    values = [
        (
            row["region"],
            row["report_date"],
            row["storage_year"],
            row["storage_week"],
            row["storage_month"],
            row["storage_season"],
            row["total_bcf"],
            row.get("change_bcf"),
            row.get("year_ago_bcf"),
            row.get("five_year_avg_bcf"),
            row.get("surplus_vs_year_ago_bcf"),
            row.get("surplus_vs_five_year_avg_bcf"),
            "eia",
            row["source_series"],
        )
        for row in rows
    ]

    conn = psycopg2.connect(**DB_CONFIG)

    try:
        with conn:
            with conn.cursor() as cur:
                execute_values(cur, sql, values)
    finally:
        conn.close()


def log_ingestion(rows, status="success", message=None):
    conn = psycopg2.connect(**DB_CONFIG)

    latest_date = None
    rows_processed = len(rows) if rows else 0

    if rows:
        latest = max(rows, key=lambda x: x["report_date"])
        latest_date = latest["report_date"]

    try:
        with conn:
            with conn.cursor() as cur:
                cur.execute(
                    """
                    INSERT INTO gas.ingestion_log (
                        source_system,
                        dataset_name,
                        rows_processed,
                        latest_date,
                        status,
                        message
                    )
                    VALUES (%s, %s, %s, %s, %s, %s)
                    """,
                    (
                        "eia",
                        "lower_48_storage_weekly",
                        rows_processed,
                        latest_date,
                        status,
                        message,
                    ),
                )
    finally:
        conn.close()


def generate_storage_signal(latest):
    surplus_5y = latest.get("surplus_vs_five_year_avg_bcf")
    change_bcf = latest.get("change_bcf")
    season = latest.get("storage_season")

    if surplus_5y is None:
        return {
            "direction": "neutral",
            "score": 0,
            "confidence": "low",
            "explanation": "Not enough historical data to compare storage against the 5-year average.",
        }

    score = 0
    reasons = []

    if surplus_5y <= -200:
        score += 40
        reasons.append("storage is far below the 5-year average")
    elif surplus_5y <= -100:
        score += 25
        reasons.append("storage is below the 5-year average")
    elif surplus_5y >= 200:
        score -= 40
        reasons.append("storage is far above the 5-year average")
    elif surplus_5y >= 100:
        score -= 25
        reasons.append("storage is above the 5-year average")
    else:
        reasons.append("storage is close to the 5-year average")

    if change_bcf is not None:
        if season == "injection":
            if change_bcf < 30:
                score += 15
                reasons.append("weekly injection was weak")
            elif change_bcf > 90:
                score -= 15
                reasons.append("weekly injection was strong")

        if season == "withdrawal":
            if change_bcf < -150:
                score += 15
                reasons.append("weekly withdrawal was heavy")
            elif change_bcf > -50:
                score -= 10
                reasons.append("weekly withdrawal was light")

    if score >= 25:
        direction = "bullish"
    elif score <= -25:
        direction = "bearish"
    else:
        direction = "neutral"

    confidence = "medium" if abs(score) >= 25 else "low"

    return {
        "direction": direction,
        "score": score,
        "confidence": confidence,
        "explanation": "; ".join(reasons),
    }


def insert_storage_signal(latest, signal):
    sql = """
        INSERT INTO gas.market_signals (
            signal_date,
            region,
            signal_type,
            direction,
            score,
            confidence,
            explanation,
            source_system
        )
        VALUES (%s, %s, %s, %s, %s, %s, %s, %s)
        ON CONFLICT (signal_date, region, signal_type, source_system)
        DO UPDATE SET
            direction = EXCLUDED.direction,
            score = EXCLUDED.score,
            confidence = EXCLUDED.confidence,
            explanation = EXCLUDED.explanation,
            created_at = NOW();
    """

    conn = psycopg2.connect(**DB_CONFIG)

    try:
        with conn:
            with conn.cursor() as cur:
                cur.execute(
                    sql,
                    (
                        latest["report_date"],
                        latest["region"],
                        "storage_pressure",
                        signal["direction"],
                        signal["score"],
                        signal["confidence"],
                        signal["explanation"],
                        "aurion",
                    ),
                )
    finally:
        conn.close()


def main():
    try:
        rows = fetch_eia_series()
        rows = calculate_storage_metrics(rows)
        validate_rows(rows)

        latest_db_date = get_latest_db_date()

        rows_to_insert = rows

        if latest_db_date:
            rows_to_insert = [
                row for row in rows if row["report_date"] >= latest_db_date
            ]

        insert_rows(rows_to_insert)

        latest = max(rows, key=lambda x: x["report_date"])
        signal = generate_storage_signal(latest)
        insert_storage_signal(latest, signal)

        log_ingestion(rows_to_insert, status="success")

        print("EIA gas storage import complete.")
        print(f"Rows fetched: {len(rows)}")
        print(f"Rows inserted/updated: {len(rows_to_insert)}")
        print(f"Latest date: {latest['report_date']}")
        print(f"Latest storage week: {latest['storage_week']}")
        print(f"Latest storage season: {latest['storage_season']}")
        print(f"Latest Lower 48 storage: {latest['total_bcf']} Bcf")
        print(f"Latest weekly change: {latest['change_bcf']} Bcf")
        print(f"Latest year-ago storage: {latest.get('year_ago_bcf')} Bcf")
        print(f"Latest 5-year avg: {latest.get('five_year_avg_bcf')} Bcf")
        print(
            f"Latest surplus vs 5-year avg: "
            f"{latest.get('surplus_vs_five_year_avg_bcf')} Bcf"
        )
        print(
            f"Storage signal: {signal['direction']} "
            f"({signal['score']}, {signal['confidence']})"
        )
        print(f"Signal reason: {signal['explanation']}")

    except Exception as exc:
        try:
            log_ingestion([], status="failed", message=str(exc))
        except Exception:
            pass

        raise


if __name__ == "__main__":
    main()