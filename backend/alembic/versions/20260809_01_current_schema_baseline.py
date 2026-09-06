"""Adopt the existing Aurion database as the Alembic baseline.

Revision ID: 20260809_01
Revises:
Create Date: 2026-08-09

This is intentionally a no-op migration. Aurion already has a populated
PostgreSQL database that predates Alembic. This revision marks that existing
schema as the starting point for versioned migrations without attempting to
recreate or replace production data.
"""

from typing import Sequence, Union


revision: str = "20260809_01"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    pass


def downgrade() -> None:
    pass
