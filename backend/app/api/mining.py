from fastapi import APIRouter, Query
from sqlalchemy import text

from app.core.database import SessionLocal

router = APIRouter(prefix="/api/mining", tags=["Mining"])


@router.get("/assets")
def get_mining_assets(
    limit: int = Query(5000, ge=1, le=20000),
    commodity: str | None = None,
    asset_type: str | None = None,
):
    db = SessionLocal()

    try:
        sql = """
            SELECT
                a.id,
                a.mine_name AS name,
                l.entity_type,
                l.lat,
                l.lng,
                l.country_code,
                a.primary_commodity,
                a.primary_commodity_group,
                a.all_commodities,
                a.asset_type_raw,
                a.confidence_factor,
                a.importance_score
            FROM mining.assets a
            JOIN geo.locations l ON l.id = a.location_id
            WHERE 1 = 1
        """

        params = {"limit": limit}

        if commodity:
            sql += " AND :commodity = ANY(a.all_commodities)"
            params["commodity"] = commodity

        if asset_type:
            sql += " AND l.entity_type = :asset_type"
            params["asset_type"] = asset_type

        sql += """
            ORDER BY a.importance_score DESC, a.id ASC
            LIMIT :limit
        """

        rows = db.execute(text(sql), params).mappings().all()

        return [
            {
                "id": row["id"],
                "name": row["name"],
                "entityType": row["entity_type"],
                "lat": row["lat"],
                "lng": row["lng"],
                "country": row["country_code"],
                "primaryCommodity": row["primary_commodity"],
                "commodityGroup": row["primary_commodity_group"],
                "allCommodities": row["all_commodities"],
                "assetTypeRaw": row["asset_type_raw"],
                "confidenceFactor": row["confidence_factor"],
                "importanceScore": row["importance_score"],
            }
            for row in rows
        ]

    finally:
        db.close()