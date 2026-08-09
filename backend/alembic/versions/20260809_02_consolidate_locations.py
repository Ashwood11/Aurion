"""Consolidate legacy location tables into geo.locations.

Revision ID: 20260809_02
Revises: 20260809_01
Create Date: 2026-08-09

The migration is intentionally non-destructive. Rows from locations.locations
and public.locations are copied into geo.locations with stable legacy source
identifiers. The old tables remain in place and are marked deprecated so code
can be migrated safely before a later cleanup migration removes them.
"""

from typing import Sequence, Union

from alembic import op
from sqlalchemy import text


revision: str = "20260809_02"
down_revision: Union[str, None] = "20260809_01"
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def _table_exists(bind, qualified_name: str) -> bool:
    return bool(
        bind.execute(
            text("SELECT to_regclass(:qualified_name) IS NOT NULL"),
            {"qualified_name": qualified_name},
        ).scalar()
    )


def upgrade() -> None:
    bind = op.get_bind()

    if not _table_exists(bind, "geo.locations"):
        raise RuntimeError(
            "geo.locations is missing. This migration must be run against the "
            "current Aurion database baseline."
        )

    if _table_exists(bind, "locations.locations"):
        op.execute(
            """
            INSERT INTO geo.locations (
                entity_type,
                name,
                lat,
                lng,
                elevation_ft,
                source_system,
                source_id,
                details,
                created_at,
                updated_at
            )
            SELECT
                COALESCE(NULLIF(trim(type), ''), 'legacy_location'),
                name,
                lat,
                lng,
                elevation_ft,
                'legacy_locations_schema',
                id::text,
                COALESCE(details, '{}'::jsonb)
                    || jsonb_strip_nulls(
                        jsonb_build_object(
                            'legacy_schema', 'locations',
                            'legacy_table', 'locations',
                            'legacy_id', id,
                            'legacy_code', code
                        )
                    ),
                COALESCE(created_at AT TIME ZONE 'UTC', now()),
                now()
            FROM locations.locations
            ON CONFLICT (source_system, source_id)
                WHERE source_id IS NOT NULL
            DO UPDATE SET
                entity_type = EXCLUDED.entity_type,
                name = COALESCE(EXCLUDED.name, geo.locations.name),
                lat = EXCLUDED.lat,
                lng = EXCLUDED.lng,
                elevation_ft = COALESCE(EXCLUDED.elevation_ft, geo.locations.elevation_ft),
                details = geo.locations.details || EXCLUDED.details,
                updated_at = now();
            """
        )
        op.execute(
            "COMMENT ON TABLE locations.locations IS "
            "'DEPRECATED: canonical Aurion locations live in geo.locations. "
            "Retained temporarily for compatibility after migration 20260809_02.'"
        )

    if _table_exists(bind, "public.locations"):
        op.execute(
            """
            INSERT INTO geo.locations (
                entity_type,
                name,
                lat,
                lng,
                source_system,
                source_id,
                details,
                created_at,
                updated_at
            )
            SELECT
                COALESCE(NULLIF(trim(type), ''), 'legacy_location'),
                name,
                lat,
                lng,
                'legacy_public_locations',
                id::text,
                COALESCE(details, '{}'::jsonb)
                    || jsonb_build_object(
                        'legacy_schema', 'public',
                        'legacy_table', 'locations',
                        'legacy_id', id
                    ),
                COALESCE(created_at AT TIME ZONE 'UTC', now()),
                now()
            FROM public.locations
            ON CONFLICT (source_system, source_id)
                WHERE source_id IS NOT NULL
            DO UPDATE SET
                entity_type = EXCLUDED.entity_type,
                name = COALESCE(EXCLUDED.name, geo.locations.name),
                lat = EXCLUDED.lat,
                lng = EXCLUDED.lng,
                details = geo.locations.details || EXCLUDED.details,
                updated_at = now();
            """
        )
        op.execute(
            "COMMENT ON TABLE public.locations IS "
            "'DEPRECATED: canonical Aurion locations live in geo.locations. "
            "Retained temporarily for compatibility after migration 20260809_02.'"
        )

    op.execute(
        "COMMENT ON TABLE geo.locations IS "
        "'Canonical cross-domain location store for Aurion.'"
    )


def downgrade() -> None:
    bind = op.get_bind()

    if _table_exists(bind, "geo.locations"):
        op.execute(
            "DELETE FROM geo.locations "
            "WHERE source_system IN ('legacy_locations_schema', 'legacy_public_locations')"
        )
        op.execute("COMMENT ON TABLE geo.locations IS NULL")

    if _table_exists(bind, "locations.locations"):
        op.execute("COMMENT ON TABLE locations.locations IS NULL")

    if _table_exists(bind, "public.locations"):
        op.execute("COMMENT ON TABLE public.locations IS NULL")
