# Aurion database migrations

Aurion adopted Alembic after the PostgreSQL database was already populated. The first revision (`20260809_01`) is therefore an adoption baseline rather than a schema-creation migration.

## Existing Aurion database

From `backend/`:

```bash
pip install -r requirements-migrations.txt
alembic upgrade head
```

On a database that has never been managed by Alembic, this records the baseline and then runs the location-consolidation migration.

## Important

The baseline assumes the current Aurion schema already exists. It is **not** yet a bootstrap migration for creating a brand-new empty database. Until the complete database model has been brought under migrations, do not run this migration history against an empty PostgreSQL database.

## Location consolidation

Revision `20260809_02` makes `geo.locations` the canonical location store. It copies rows from both legacy tables:

- `locations.locations`
- `public.locations`

The legacy tables are deliberately retained and marked deprecated. A later migration should only drop them after application code and data checks confirm they are no longer needed.

## Creating future revisions

For now, create migrations manually:

```bash
alembic revision -m "description"
```

Autogeneration is intentionally disabled because the current SQLAlchemy ORM does not describe the complete Aurion database. Enabling autogenerate before the ORM is complete could produce destructive drop operations for valid tables.
