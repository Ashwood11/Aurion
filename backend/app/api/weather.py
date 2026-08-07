from datetime import datetime, timezone

from fastapi import APIRouter, Query
from sqlalchemy import text

from app.core.database import SessionLocal


router = APIRouter(prefix="/api/weather", tags=["weather"])


@router.get("/globe")
def get_globe_weather(
    limit: int = Query(default=5000, ge=1, le=50000),
):
    """Return the latest stored weather observation for each grid point."""
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
                FROM weather_observation wo
                JOIN weather_grid_point gp
                  ON gp.id = wo.grid_point_id
                ORDER BY wo.grid_point_id, wo.observation_time DESC
                LIMIT :limit
                """
            ),
            {"limit": limit},
        ).mappings().all()

        return {
            "weather": [
                {
                    "id": row["id"],
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
