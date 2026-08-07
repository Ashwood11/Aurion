from fastapi import APIRouter, HTTPException
from sqlalchemy import text

from app.core.database import SessionLocal

router = APIRouter(prefix="/weather", tags=["weather"])


@router.get("/latest/{location_code}")
def get_latest_weather(location_code: str):
    session = SessionLocal()
    try:
        location = session.execute(
            text(
                """
                SELECT id, location_code, name, country_code, latitude, longitude
                FROM weather_location
                WHERE location_code = :location_code
                LIMIT 1
                """
            ),
            {"location_code": location_code},
        ).mappings().first()

        if not location:
            raise HTTPException(status_code=404, detail="Location not found")

        rows = session.execute(
            text(
                """
                SELECT
                    observed_at,
                    ingested_at,
                    temperature_c,
                    feels_like_c,
                    dew_point_c,
                    humidity_pct,
                    pressure_hpa,
                    wind_speed_mps,
                    wind_gust_mps,
                    wind_dir_deg,
                    precip_mm,
                    snow_mm,
                    cloud_cover_pct,
                    visibility_km,
                    uv_index,
                    condition_code,
                    condition_text,
                    provider
                FROM weather_observation
                WHERE location_id = :location_id
                ORDER BY observed_at DESC
                LIMIT 24
                """
            ),
            {"location_id": str(location["id"])},
        ).mappings().all()

        return {
            "location": dict(location),
            "rows": [dict(row) for row in rows],
        }
    finally:
        session.close()