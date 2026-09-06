# `mining` Schema

**Tables in snapshot:** 1

This file currently provides exact structural inventory. Additional narrative semantics should be expanded when this schema becomes an active implementation focus.

## `mining.assets`

| Column | Definition from schema |
|---|---|
| `id` | `bigint CONSTRAINT mines_id_not_null NOT NULL` |
| `location_id` | `bigint CONSTRAINT mines_location_id_not_null NOT NULL` |
| `source_system` | `text DEFAULT 'icmm'::text CONSTRAINT mines_source_system_not_null NOT NULL` |
| `source_id` | `text` |
| `mine_name` | `text` |
| `confidence_factor` | `text` |
| `asset_type_raw` | `text` |
| `primary_commodity` | `text CONSTRAINT mines_primary_commodity_not_null NOT NULL` |
| `primary_commodity_group` | `text` |
| `secondary_commodity` | `text` |
| `other_commodities` | `text[] DEFAULT '{}'::text[]` |
| `all_commodities` | `text[] DEFAULT '{}'::text[]` |
| `group_names` | `text` |
| `importance_score` | `double precision DEFAULT 0.9` |
| `details` | `jsonb DEFAULT '{}'::jsonb` |
| `created_at` | `timestamp with time zone DEFAULT now()` |
| `updated_at` | `timestamp with time zone DEFAULT now()` |

**Declared constraints**

- `mines_pkey` — `PRIMARY KEY (id)`
- `assets_location_id_canonical_fkey` — `FOREIGN KEY (location_id) REFERENCES geo.location(location_id) ON DELETE CASCADE`

**Indexes**

- `idx_mining_mines_all_commodities` — `USING gin (all_commodities)`
- `idx_mining_mines_location_id` — `USING btree (location_id)`
- `idx_mining_mines_primary_commodity` — `USING btree (primary_commodity)`
- `idx_mining_mines_primary_group` — `USING btree (primary_commodity_group)`
- `UNIQUE idx_mining_mines_source_id` — `USING btree (source_system, source_id) WHERE (source_id IS NOT NULL)`
- `UNIQUE idx_mining_mines_source_unique` — `USING btree (source_system, source_id) WHERE (source_id IS NOT NULL)`
