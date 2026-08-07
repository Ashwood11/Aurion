from fastapi import APIRouter, Query
from sqlalchemy import text

from app.core.database import SessionLocal

router = APIRouter(prefix="/api/plane-history", tags=["plane-history"])


@router.get("")
def get_plane_history(
    limit: int = Query(default=500, ge=1, le=5000),
    icao24: str | None = Query(default=None),
    callsign: str | None = Query(default=None),
):
    db = SessionLocal()
    try:
        sql = """
            SELECT
                history_id,
                archived_at,
                flight_id,
                icao24,
                callsign,
                flight_number,
                registration,
                operator_code,
                operator_name,
                aircraft_icao_type,
                aircraft_name,
                aircraft_category,
                latitude,
                longitude,
                altitude_ft,
                ground_speed_kts,
                heading_deg,
                vertical_rate_fpm,
                origin_airport_code,
                destination_airport_code,
                route_status,
                status,
                source,
                source_live,
                source_route,
                source_aircraft,
                source_operator,
                first_seen_at,
                last_seen_at
            FROM aviation.flight_history
            WHERE 1=1
        """

        params: dict[str, object] = {"limit": limit}

        if icao24:
            sql += " AND icao24 = :icao24"
            params["icao24"] = icao24.strip().lower()

        if callsign:
            sql += " AND callsign = :callsign"
            params["callsign"] = callsign.strip().upper()

        sql += " ORDER BY archived_at DESC LIMIT :limit"

        rows = db.execute(text(sql), params).mappings().all()
        return [dict(row) for row in rows]
    finally:
        db.close()