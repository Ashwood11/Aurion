from fastapi import APIRouter, Query
from sqlalchemy import text

from app.core.database import SessionLocal

router = APIRouter(prefix="/api/planes", tags=["planes"])


@router.get("")
def get_planes(
    limit: int = Query(default=1000, ge=1, le=5000),
    plane_types: str | None = Query(default=None),
):
    db = SessionLocal()
    try:
        plane_type_list = [p.strip() for p in (plane_types or "").split(",") if p.strip()]

        query_sql = """
            SELECT
                fl.flight_id,
                fl.icao24,
                fl.callsign,
                COALESCE(fl.aircraft_icao_type, fl.aircraft_name, 'Unknown') AS aircraft_type,
                fl.latitude,
                fl.longitude,
                fl.altitude_ft,
                fl.ground_speed_kts,
                fl.heading_deg,
                fl.vertical_rate_fpm,
                fl.origin_airport_code,
                fl.destination_airport_code,
                fl.status,
                COALESCE(fl.source, fl.source_live, 'opensky') AS source,
                fl.last_seen_at,

                origin_loc.lat AS origin_lat,
                origin_loc.lng AS origin_lng,
                dest_loc.lat AS destination_lat,
                dest_loc.lng AS destination_lng

            FROM aviation.flight_live fl

            LEFT JOIN geo.airports origin_airport
              ON (
                origin_airport.iata_code = fl.origin_airport_code
                OR origin_airport.ident = fl.origin_airport_code
                OR origin_airport.gps_code = fl.origin_airport_code
              )
            LEFT JOIN geo.locations origin_loc
              ON origin_loc.id = origin_airport.location_id

            LEFT JOIN geo.airports dest_airport
              ON (
                dest_airport.iata_code = fl.destination_airport_code
                OR dest_airport.ident = fl.destination_airport_code
                OR dest_airport.gps_code = fl.destination_airport_code
              )
            LEFT JOIN geo.locations dest_loc
              ON dest_loc.id = dest_airport.location_id

            WHERE fl.last_seen_at >= NOW() - INTERVAL '10 minutes'
        """

        params: dict[str, object] = {"limit": limit}

        if plane_type_list:
            placeholders = ", ".join([f":type_{i}" for i in range(len(plane_type_list))])
            query_sql += f" AND fl.status IN ({placeholders})"

            for i, plane_type in enumerate(plane_type_list):
                params[f"type_{i}"] = plane_type

        query_sql += " ORDER BY fl.last_seen_at DESC LIMIT :limit"

        result = db.execute(text(query_sql), params).fetchall()

        return [
            {
                "id": r.flight_id or r.icao24 or r.callsign,
                "flight_id": r.flight_id,
                "icao24": r.icao24,
                "callsign": r.callsign,
                "aircraft_type": r.aircraft_type,
                "lat": r.latitude,
                "lng": r.longitude,
                "altitude_ft": r.altitude_ft,
                "ground_speed_kts": r.ground_speed_kts,
                "heading_deg": r.heading_deg,
                "vertical_rate_fpm": r.vertical_rate_fpm,
                "origin": r.origin_airport_code,
                "destination": r.destination_airport_code,
                "origin_lat": r.origin_lat,
                "origin_lng": r.origin_lng,
                "destination_lat": r.destination_lat,
                "destination_lng": r.destination_lng,
                "status": r.status,
                "source": r.source,
                "last_seen_at": r.last_seen_at.isoformat() if r.last_seen_at else None,
            }
            for r in result
        ]
    finally:
        db.close()