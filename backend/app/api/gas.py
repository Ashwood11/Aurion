from fastapi import APIRouter
from sqlalchemy import text

from app.core.database import SessionLocal

router = APIRouter()


@router.get("/api/gas/latest")
def get_latest_gas():
    db = SessionLocal()

    try:
        storage_row = db.execute(
            text("""
                SELECT
                    id,
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
                    source_series,
                    ingested_at
                FROM gas.storage_weekly
                WHERE region = 'Lower 48'
                ORDER BY report_date DESC
                LIMIT 1
            """)
        ).fetchone()

        signal_row = db.execute(
            text("""
                SELECT
                    id,
                    signal_date,
                    region,
                    signal_type,
                    direction,
                    score,
                    confidence,
                    explanation,
                    source_system,
                    created_at
                FROM gas.market_signals
                WHERE region = 'Lower 48'
                ORDER BY signal_date DESC
                LIMIT 1
            """)
        ).fetchone()

        return {
            "storage": dict(storage_row._mapping) if storage_row else None,
            "signal": dict(signal_row._mapping) if signal_row else None,
        }

    finally:
        db.close()


@router.get("/api/gas/history")
def get_gas_history(limit: int = 200):
    db = SessionLocal()

    try:
        rows = db.execute(
            text("""
                SELECT
                    report_date,
                    total_bcf,
                    change_bcf,
                    year_ago_bcf,
                    five_year_avg_bcf,
                    surplus_vs_year_ago_bcf,
                    surplus_vs_five_year_avg_bcf,
                    storage_week,
                    storage_season
                FROM gas.storage_weekly
                WHERE region = 'Lower 48'
                ORDER BY report_date DESC
                LIMIT :limit
            """),
            {"limit": limit},
        ).fetchall()

        return [dict(row._mapping) for row in rows]

    finally:
        db.close()


@router.get("/api/gas/consumption/monthly")
def get_gas_consumption_monthly(limit: int = 240):
    db = SessionLocal()

    try:
        rows = db.execute(
            text("""
                SELECT
                    report_month AS month,
                    region,
                    total_consumption_bcf,
                    residential_bcf,
                    commercial_bcf,
                    industrial_bcf,
                    electric_power_bcf
                FROM gas.consumption_monthly
                ORDER BY report_month DESC
                LIMIT :limit
            """),
            {"limit": limit},
        ).fetchall()

        return {
            "count": len(rows),
            "rows": [dict(row._mapping) for row in rows],
        }

    finally:
        db.close()

@router.get("/api/gas/price/daily")
def get_gas_price_daily(limit: int = 365):
    db = SessionLocal()

    try:
        rows = db.execute(
            text("""
                SELECT
                    market,
                    region,
                    price_date,
                    price_usd_per_mmbtu,
                    change_usd,
                    change_pct,
                    data_status,
                    source_system,
                    source_series,
                    ingested_at
                FROM gas.prices_daily
                WHERE market = 'Henry Hub'
                ORDER BY price_date DESC
                LIMIT :limit
            """),
            {"limit": limit},
        ).fetchall()

        return {
            "count": len(rows),
            "rows": [dict(row._mapping) for row in rows],
        }

    finally:
        db.close()


@router.get("/api/gas/price/latest")
def get_gas_price_latest():
    db = SessionLocal()

    try:
        row = db.execute(
            text("""
                SELECT
                    market,
                    region,
                    price_date,
                    price_usd_per_mmbtu,
                    change_usd,
                    change_pct,
                    data_status,
                    source_system,
                    source_series,
                    ingested_at
                FROM gas.prices_daily
                WHERE market = 'Henry Hub'
                ORDER BY price_date DESC
                LIMIT 1
            """)
        ).fetchone()

        return dict(row._mapping) if row else None

    finally:
        db.close()

@router.get("/api/gas/lng/monthly")
def get_gas_lng_monthly(limit: int = 240):
    db = SessionLocal()

    try:
        rows = db.execute(
            text("""
                SELECT
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
                FROM gas.lng_monthly
                ORDER BY month DESC
                LIMIT :limit
            """),
            {"limit": limit},
        ).fetchall()

        return {
            "count": len(rows),
            "rows": [dict(row._mapping) for row in rows],
        }

    finally:
        db.close()


@router.get("/api/gas/lng/latest")
def get_gas_lng_latest():
    db = SessionLocal()

    try:
        row = db.execute(
            text("""
                SELECT
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
                FROM gas.lng_monthly
                ORDER BY month DESC
                LIMIT 1
            """)
        ).fetchone()

        return dict(row._mapping) if row else None

    finally:
        db.close()

@router.get("/api/gas/production/monthly")
def get_gas_production_monthly(limit: int = 240):
    db = SessionLocal()

    try:
        rows = db.execute(
            text("""
                SELECT
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
                FROM gas.production_monthly
                ORDER BY month DESC
                LIMIT :limit
            """),
            {"limit": limit},
        ).fetchall()

        return {
            "count": len(rows),
            "rows": [dict(row._mapping) for row in rows],
        }

    finally:
        db.close()


@router.get("/api/gas/production/latest")
def get_gas_production_latest():
    db = SessionLocal()

    try:
        row = db.execute(
            text("""
                SELECT
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
                FROM gas.production_monthly
                ORDER BY month DESC
                LIMIT 1
            """)
        ).fetchone()

        return dict(row._mapping) if row else None

    finally:
        db.close()