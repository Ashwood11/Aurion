from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException, Query
from sqlalchemy import text

from app.core.database import SessionLocal


router = APIRouter(prefix="/api/weather", tags=["weather"])


@router.get("/globe")
def get_globe_weather(
    limit: int = Query(default=5000, ge=1, le=50000),
):
    """Return the latest stored observation for each active weather grid point."""
    db = SessionLocal()

    try:
        rows = db.execute(
            text(
                """
                SELECT DISTINCT ON (wo.grid_point_id)
                    gp.id,
                    gp.grid_code,
                    gp.latitude AS lat,
                    gp.longitude AS lng,
                    wo.observation_time,
                    wo.temp_c,
                    wo.wind_speed_kph,
                    wo.precip_mm,
                    wo.data_type,
                    wo.source_system
                FROM public.weather_observation wo
                JOIN public.weather_grid_point gp
                  ON gp.id = wo.grid_point_id
                WHERE gp.is_active = TRUE
                ORDER BY
                    wo.grid_point_id,
                    wo.observation_time DESC
                LIMIT :limit
                """
            ),
            {"limit": limit},
        ).mappings().all()

        return {
            "weather": [
                {
                    "id": str(row["id"]),
                    "name": row["grid_code"],
                    "lat": row["lat"],
                    "lng": row["lng"],
                    "temp": row["temp_c"],
                    "wind": row["wind_speed_kph"],
                    "precip": row["precip_mm"],
                    "observed_at": (
                        row["observation_time"].isoformat()
                        if row["observation_time"]
                        else None
                    ),
                    "data_type": row["data_type"],
                    "source": row["source_system"],
                }
                for row in rows
            ],
            "last_updated": datetime.now(timezone.utc).isoformat(),
        }
    finally:
        db.close()


@router.get("/latest/{location_code}")
def get_latest_weather(
    location_code: str,
    limit: int = Query(default=24, ge=1, le=168),
):
    """
    Return the newest forecast run for a strategic weather location.

    Observations are stored by weather grid point in the current schema, while
    forecast values are stored by weather location. This endpoint therefore
    returns forecast values instead of querying non-existent observation
    location columns.
    """
    db = SessionLocal()

    try:
        location = db.execute(
            text(
                """
                SELECT
                    id,
                    location_code,
                    name,
                    country_code,
                    region_name,
                    latitude,
                    longitude,
                    elevation_m,
                    timezone_name
                FROM public.weather_location
                WHERE location_code = :location_code
                  AND is_active = TRUE
                LIMIT 1
                """
            ),
            {"location_code": location_code},
        ).mappings().first()

        if not location:
            raise HTTPException(status_code=404, detail="Weather location not found")

        rows = db.execute(
            text(
                """
                WITH latest_run AS (
                    SELECT wfv.forecast_run_id
                    FROM public.weather_forecast_value wfv
                    JOIN public.weather_forecast_run wfr
                      ON wfr.id = wfv.forecast_run_id
                    WHERE wfv.location_id = :location_id
                    ORDER BY wfr.issued_at DESC, wfr.ingested_at DESC
                    LIMIT 1
                )
                SELECT
                    wfv.valid_time,
                    wfv.lead_hours,
                    wfv.temperature_c,
                    wfv.feels_like_c,
                    wfv.dew_point_c,
                    wfv.humidity_pct,
                    wfv.pressure_hpa,
                    wfv.wind_speed_mps,
                    wfv.wind_gust_mps,
                    wfv.wind_dir_deg,
                    wfv.precip_mm,
                    wfv.snow_mm,
                    wfv.cloud_cover_pct,
                    wfv.visibility_km,
                    wfv.uv_index,
                    wfv.condition_code,
                    wfv.condition_text,
                    wfr.provider,
                    wfr.model_name,
                    wfr.product_name,
                    wfr.issued_at,
                    wfr.ingested_at
                FROM public.weather_forecast_value wfv
                JOIN latest_run lr
                  ON lr.forecast_run_id = wfv.forecast_run_id
                JOIN public.weather_forecast_run wfr
                  ON wfr.id = wfv.forecast_run_id
                WHERE wfv.location_id = :location_id
                ORDER BY wfv.valid_time ASC
                LIMIT :limit
                """
            ),
            {
                "location_id": str(location["id"]),
                "limit": limit,
            },
        ).mappings().all()

        return {
            "location": dict(location),
            "rows": [dict(row) for row in rows],
        }
    finally:
        db.close()
