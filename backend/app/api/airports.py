from fastapi import APIRouter, Query
from sqlalchemy import text

from app.core.database import SessionLocal


router = APIRouter(prefix="/api/airports", tags=["airports"])


@router.get("")
def get_airports(
    limit: int = Query(default=3000, ge=1, le=50000),
    airport_types: str = Query(default="large_airport,medium_airport"),
):
    db = SessionLocal()

    try:
        airport_type_list = [
            airport_type.strip()
            for airport_type in airport_types.split(",")
            if airport_type.strip()
        ]

        if not airport_type_list:
            airport_type_list = ["large_airport", "medium_airport"]

        placeholders = ", ".join(
            [f":type_{i}" for i in range(len(airport_type_list))]
        )

        query = text(f"""
            SELECT
                l.id,
                l.name,
                l.lat,
                l.lng,
                l.elevation_ft,
                l.country_code,
                l.region_code,
                l.municipality,
                l.source_system,
                l.source_id,
                a.ident,
                a.iata_code,
                a.gps_code,
                a.local_code,
                a.airport_type,
                a.scheduled_service,
                a.home_link,
                a.wikipedia_link
            FROM geo.locations l
            JOIN geo.airports a
              ON a.location_id = l.id
            WHERE l.entity_type = 'airport'
              AND l.source_system = 'ourairports'
              AND a.airport_type IN ({placeholders})
            ORDER BY
                CASE
                    WHEN a.airport_type = 'large_airport' THEN 1
                    WHEN a.airport_type = 'medium_airport' THEN 2
                    WHEN a.airport_type = 'small_airport' THEN 3
                    WHEN a.airport_type = 'heliport' THEN 4
                    WHEN a.airport_type = 'seaplane_base' THEN 5
                    ELSE 6
                END,
                l.name ASC
            LIMIT :limit
        """)

        params: dict[str, object] = {"limit": limit}

        for i, airport_type in enumerate(airport_type_list):
            params[f"type_{i}"] = airport_type

        rows = db.execute(query, params).fetchall()

        return [
            {
                "id": row.id,
                "name": row.name,
                "lat": row.lat,
                "lng": row.lng,
                "code": row.iata_code or row.ident or row.source_id,
                "ident": row.ident,
                "iata_code": row.iata_code,
                "gps_code": row.gps_code,
                "local_code": row.local_code,
                "airport_type": row.airport_type,
                "scheduled_service": row.scheduled_service,
                "elevation_ft": row.elevation_ft,
                "country_code": row.country_code,
                "region_code": row.region_code,
                "municipality": row.municipality,
                "source_system": row.source_system,
                "home_link": row.home_link,
                "wikipedia_link": row.wikipedia_link,
            }
            for row in rows
        ]

    finally:
        db.close()