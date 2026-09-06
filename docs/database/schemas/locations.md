# `locations` Schema

**Tables in snapshot:** 1

This file currently provides exact structural inventory. Additional narrative semantics should be expanded when this schema becomes an active implementation focus.

## `locations.locations`

| Column | Definition from schema |
|---|---|
| `id` | `integer NOT NULL` |
| `type` | `text NOT NULL` |
| `name` | `text` |
| `lat` | `double precision NOT NULL` |
| `lng` | `double precision NOT NULL` |
| `elevation_ft` | `integer` |
| `code` | `text` |
| `details` | `jsonb` |
| `created_at` | `timestamp without time zone DEFAULT now()` |

**Declared constraints**

- `locations_pkey` — `PRIMARY KEY (id)`

**Indexes**

- `idx_locations_coords` — `USING gist (public.ll_to_earth(lat, lng))`
- `idx_locations_type` — `USING btree (type)`
