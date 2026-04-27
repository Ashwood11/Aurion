from fastapi import APIRouter, Query
from sqlalchemy import text
from app.core.database import SessionLocal

router = APIRouter(prefix="/api/ports", tags=["ports"])


@router.get("")
def get_ports(
    limit: int = Query(default=8000, ge=100, le=20000),
    country_code: str | None = Query(default=None),
    port_types: str | None = Query(default=None),
    harbor_uses: str | None = Query(default=None),
    size_classes: str | None = Query(default=None),
    has_container: bool | None = Query(default=None),
    has_oil_terminal: bool | None = Query(default=None),
    has_lng_terminal: bool | None = Query(default=None),
):
    db = SessionLocal()
    try:
        conditions = ["1=1"]
        params: dict[str, object] = {"limit": limit}

        if country_code:
            conditions.append("country_code = :country_code")
            params["country_code"] = country_code.upper()

        if port_types:
            values = [v.strip() for v in port_types.split(",") if v.strip()]
            if values:
                parts = []
                for i, value in enumerate(values):
                    key = f"port_type_{i}"
                    parts.append(f"COALESCE(port_type, '') ILIKE :{key}")
                    params[key] = f"%{value}%"
                conditions.append("(" + " OR ".join(parts) + ")")

        if harbor_uses:
            values = [v.strip() for v in harbor_uses.split(",") if v.strip()]
            if values:
                parts = []
                for i, value in enumerate(values):
                    key = f"harbor_use_{i}"
                    parts.append(f"COALESCE(harbor_use, '') ILIKE :{key}")
                    params[key] = f"%{value}%"
                conditions.append("(" + " OR ".join(parts) + ")")

        if size_classes:
            values = [v.strip() for v in size_classes.split(",") if v.strip()]
            if values:
                parts = []
                for i, value in enumerate(values):
                    key = f"size_class_{i}"
                    parts.append(f"COALESCE(size_class, '') ILIKE :{key}")
                    params[key] = f"%{value}%"
                conditions.append("(" + " OR ".join(parts) + ")")

        facility_parts = []
        if has_container is True:
            facility_parts.append("COALESCE(has_container, false) = true")
        if has_oil_terminal is True:
            facility_parts.append("COALESCE(has_oil_terminal, false) = true")
        if has_lng_terminal is True:
            facility_parts.append("COALESCE(has_lng_terminal, false) = true")

        if facility_parts:
            conditions.append("(" + " OR ".join(facility_parts) + ")")

        where_clause = " AND ".join(conditions)

        query = text(f"""
            SELECT
                id,
                name,
                alt_name,
                unlocode,
                country_code,
                water_body,
                latitude AS lat,
                longitude AS lng,
                port_type,
                size_class,
                harbor_use,
                tidal_range,
                channel_depth,
                anchorage_depth,
                cargo_pier_depth,
                max_vessel_length,
                max_vessel_beam,
                max_vessel_draft,
                shelter_afforded,
                has_container,
                has_oil_terminal,
                has_lng_terminal
            FROM geo.ports
            WHERE {where_clause}
            ORDER BY
                CASE
                    WHEN COALESCE(size_class, '') ILIKE 'Large%' THEN 1
                    WHEN COALESCE(size_class, '') ILIKE 'Medium%' THEN 2
                    WHEN COALESCE(size_class, '') ILIKE 'Small%' THEN 3
                    ELSE 4
                END,
                name ASC
            LIMIT :limit
        """)

        result = db.execute(query, params).fetchall()

        return [
            {
                "id": r.id,
                "name": r.name,
                "alt_name": r.alt_name,
                "unlocode": r.unlocode,
                "country_code": r.country_code,
                "water_body": r.water_body,
                "lat": r.lat,
                "lng": r.lng,
                "port_type": r.port_type,
                "size_class": r.size_class,
                "harbor_use": r.harbor_use,
                "tidal_range": r.tidal_range,
                "channel_depth": r.channel_depth,
                "anchorage_depth": r.anchorage_depth,
                "cargo_pier_depth": r.cargo_pier_depth,
                "max_vessel_length": r.max_vessel_length,
                "max_vessel_beam": r.max_vessel_beam,
                "max_vessel_draft": r.max_vessel_draft,
                "shelter_afforded": r.shelter_afforded,
                "has_container": r.has_container,
                "has_oil_terminal": r.has_oil_terminal,
                "has_lng_terminal": r.has_lng_terminal,
            }
            for r in result
        ]
    finally:
        db.close()