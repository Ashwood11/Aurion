# `geo` Schema

**Tables in snapshot:** 19

The `geo` schema is Aurion's reusable real-world geography layer. Stable identity and exact geometry are separated so boundaries can evolve without changing conceptual region identity. Canonical Weather H3 mappings reference `weather.grid_cell`; exact PostGIS geometry remains authoritative for regions.

## `geo.airports`

**Status:** ACTIVE / SPECIALIZATION  
**Purpose:** Airport-specific attributes keyed to canonical geo.location records.

| Column | Definition from schema |
|---|---|
| `location_id` | `bigint NOT NULL` |
| `ident` | `text` |
| `iata_code` | `text` |
| `airport_type` | `text` |
| `scheduled_service` | `text` |
| `gps_code` | `text` |
| `local_code` | `text` |
| `home_link` | `text` |
| `wikipedia_link` | `text` |

**Declared constraints**

- `airports_pkey` — `PRIMARY KEY (location_id)`
- `airports_location_id_canonical_fkey` — `FOREIGN KEY (location_id) REFERENCES geo.location(location_id) ON DELETE CASCADE`

**Indexes**

- `idx_geo_airports_gps_code` — `USING btree (gps_code)`
- `idx_geo_airports_iata_code` — `USING btree (iata_code)`
- `idx_geo_airports_ident` — `USING btree (ident)`

## `geo.location`

**Status:** ACTIVE CANONICAL  
**Purpose:** Canonical reusable point-location table for real-world places/assets with PostGIS Point geometry and common metadata.

| Column | Definition from schema |
|---|---|
| `location_id` | `bigint NOT NULL` |
| `location_type` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `short_name` | `text` |
| `country_code` | `character(2)` |
| `subdivision_code` | `text` |
| `municipality` | `text` |
| `position` | `public.geometry(Point,4326) NOT NULL` |
| `elevation_m` | `double precision` |
| `timezone_name` | `text` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `attributes` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `location_pkey` — `PRIMARY KEY (location_id)`

**Indexes**

- `location_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `location_country_subdivision_idx` — `USING btree (country_code, subdivision_code)`
- `location_lower_name_idx` — `USING btree (lower(name))`
- `location_position_gix` — `USING gist ("position")`
- `location_type_idx` — `USING btree (location_type)`

## `geo.location_cell_map`

**Status:** ACTIVE CANONICAL MAPPING  
**Purpose:** Maps canonical geo.location records to canonical weather.grid_cell records.

| Column | Definition from schema |
|---|---|
| `location_cell_map_id` | `bigint NOT NULL` |
| `location_id` | `bigint NOT NULL` |
| `grid_cell_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `location_cell_map_pkey` — `PRIMARY KEY (location_cell_map_id)`
- `location_cell_map_unique` — `UNIQUE (location_id, grid_cell_id)`
- `location_cell_map_grid_cell_fkey` — `FOREIGN KEY (grid_cell_id) REFERENCES weather.grid_cell(grid_cell_id) ON DELETE CASCADE`
- `location_cell_map_location_fkey` — `FOREIGN KEY (location_id) REFERENCES geo.location(location_id) ON DELETE CASCADE`

**Indexes**

- `location_cell_map_grid_cell_idx` — `USING btree (grid_cell_id)`
- `location_cell_map_location_idx` — `USING btree (location_id)`

## `geo.location_identifier`

**Status:** ACTIVE  
**Purpose:** External/alternate identifier registry for canonical locations, including source system, primary flag, validity interval, and metadata.

| Column | Definition from schema |
|---|---|
| `location_identifier_id` | `bigint NOT NULL` |
| `location_id` | `bigint NOT NULL` |
| `identifier_scheme` | `text NOT NULL` |
| `identifier_value` | `text NOT NULL` |
| `source_system` | `text` |
| `is_primary` | `boolean DEFAULT false NOT NULL` |
| `valid_from` | `timestamp with time zone` |
| `valid_to` | `timestamp with time zone` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `location_identifier_external_key_unique` — `UNIQUE NULLS NOT DISTINCT (identifier_scheme, identifier_value, source_system)`
- `location_identifier_pkey` — `PRIMARY KEY (location_identifier_id)`
- `location_identifier_location_fkey` — `FOREIGN KEY (location_id) REFERENCES geo.location(location_id) ON DELETE CASCADE`

**Indexes**

- `location_identifier_location_idx` — `USING btree (location_id)`
- `UNIQUE location_identifier_primary_unique_idx` — `USING btree (location_id, identifier_scheme) WHERE (is_primary = true)`
- `location_identifier_scheme_value_idx` — `USING btree (identifier_scheme, identifier_value)`
- `location_identifier_source_value_idx` — `USING btree (source_system, identifier_value)`

## `geo.locations`

**Status:** LEGACY / EARLIER MODEL  
**Purpose:** Older generic geo location table. Canonical new geography uses geo.location; retain until migration/deprecation is explicitly completed.

| Column | Definition from schema |
|---|---|
| `id` | `bigint NOT NULL` |
| `entity_type` | `text NOT NULL` |
| `name` | `text` |
| `lat` | `double precision NOT NULL` |
| `lng` | `double precision NOT NULL` |
| `elevation_ft` | `integer` |
| `country_code` | `text` |
| `region_code` | `text` |
| `municipality` | `text` |
| `source_system` | `text` |
| `source_id` | `text` |
| `details` | `jsonb DEFAULT '{}'::jsonb` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `locations_pkey` — `PRIMARY KEY (id)`

**Indexes**

- `UNIQUE idx_geo_locations_source_unique` — `USING btree (source_system, source_id) WHERE (source_id IS NOT NULL)`

## `geo.ourairports_import`

**Status:** STAGING  
**Purpose:** Raw/staging import structure for OurAirports source data.

| Column | Definition from schema |
|---|---|
| `id` | `integer` |
| `ident` | `text` |
| `type` | `text` |
| `name` | `text` |
| `latitude_deg` | `double precision` |
| `longitude_deg` | `double precision` |
| `elevation_ft` | `integer` |
| `continent` | `text` |
| `iso_country` | `text` |
| `iso_region` | `text` |
| `municipality` | `text` |
| `scheduled_service` | `text` |
| `gps_code` | `text` |
| `iata_code` | `text` |
| `local_code` | `text` |
| `home_link` | `text` |
| `wikipedia_link` | `text` |
| `keywords` | `text` |

No post-create constraint/index statements were found in the export for this table.

## `geo.ports`

**Status:** ACTIVE / LEGACY-SPECIALIZED  
**Purpose:** Port catalogue with coordinates, source identifiers, physical/operational characteristics and capacity fields. Separate from canonical geo.location model at present.

| Column | Definition from schema |
|---|---|
| `id` | `uuid DEFAULT gen_random_uuid() NOT NULL` |
| `source` | `text DEFAULT 'wpi'::text NOT NULL` |
| `source_id` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `alt_name` | `text` |
| `unlocode` | `text` |
| `country_code` | `text` |
| `water_body` | `text` |
| `latitude` | `double precision NOT NULL` |
| `longitude` | `double precision NOT NULL` |
| `port_type` | `text` |
| `size_class` | `text` |
| `harbor_use` | `text` |
| `tidal_range` | `numeric` |
| `channel_depth` | `numeric` |
| `anchorage_depth` | `numeric` |
| `cargo_pier_depth` | `numeric` |
| `max_vessel_length` | `numeric` |
| `max_vessel_beam` | `numeric` |
| `max_vessel_draft` | `numeric` |
| `shelter_afforded` | `text` |
| `has_container` | `boolean` |
| `has_oil_terminal` | `boolean` |
| `has_lng_terminal` | `boolean` |
| `significance_scc` | `integer` |
| `capacity_teu` | `bigint` |
| `raw_json` | `jsonb` |
| `created_at` | `timestamp with time zone DEFAULT now()` |
| `updated_at` | `timestamp with time zone DEFAULT now()` |

**Declared constraints**

- `ports_pkey` — `PRIMARY KEY (id)`
- `ports_source_id_unique` — `UNIQUE (source, source_id)`

**Indexes**

- `idx_ports_country` — `USING btree (country_code)`
- `idx_ports_draft` — `USING btree (max_vessel_draft)`
- `idx_ports_name` — `USING gin (name public.gin_trgm_ops)`
- `idx_ports_source_id` — `USING btree (source, source_id)`

## `geo.region`

**Status:** ACTIVE CANONICAL  
**Purpose:** Stable identity for reusable real-world regions independent of any one geometry version.

| Column | Definition from schema |
|---|---|
| `region_id` | `bigint NOT NULL` |
| `region_type_id` | `bigint NOT NULL` |
| `name` | `text NOT NULL` |
| `short_name` | `text` |
| `country_code` | `character(2)` |
| `subdivision_code` | `text` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `attributes` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `region_pkey` — `PRIMARY KEY (region_id)`
- `region_region_type_fkey` — `FOREIGN KEY (region_type_id) REFERENCES geo.region_type(region_type_id) ON DELETE RESTRICT`

**Indexes**

- `region_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `region_country_idx` — `USING btree (country_code)`
- `region_country_subdivision_idx` — `USING btree (country_code, subdivision_code)`
- `region_lower_name_idx` — `USING btree (lower(name))`
- `region_type_idx` — `USING btree (region_type_id)`

## `geo.region_cell_map`

**Status:** ACTIVE CANONICAL MAPPING  
**Purpose:** Maps a specific geo.region_version to canonical weather.grid_cell rows.

| Column | Definition from schema |
|---|---|
| `region_cell_map_id` | `bigint NOT NULL` |
| `region_version_id` | `bigint NOT NULL` |
| `grid_cell_id` | `bigint NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `region_cell_map_pkey` — `PRIMARY KEY (region_cell_map_id)`
- `region_cell_map_unique` — `UNIQUE (region_version_id, grid_cell_id)`
- `region_cell_map_grid_cell_fkey` — `FOREIGN KEY (grid_cell_id) REFERENCES weather.grid_cell(grid_cell_id) ON DELETE CASCADE`
- `region_cell_map_region_version_fkey` — `FOREIGN KEY (region_version_id) REFERENCES geo.region_version(region_version_id) ON DELETE CASCADE`

**Indexes**

- `region_cell_map_grid_cell_idx` — `USING btree (grid_cell_id)`
- `region_cell_map_region_version_idx` — `USING btree (region_version_id)`

## `geo.region_identifier`

**Status:** ACTIVE  
**Purpose:** External/alternate identifier registry for canonical regions.

| Column | Definition from schema |
|---|---|
| `region_identifier_id` | `bigint NOT NULL` |
| `region_id` | `bigint NOT NULL` |
| `identifier_scheme` | `text NOT NULL` |
| `identifier_value` | `text NOT NULL` |
| `source_system` | `text` |
| `is_primary` | `boolean DEFAULT false NOT NULL` |
| `valid_from` | `timestamp with time zone` |
| `valid_to` | `timestamp with time zone` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `region_identifier_external_key_unique` — `UNIQUE NULLS NOT DISTINCT (identifier_scheme, identifier_value, source_system)`
- `region_identifier_pkey` — `PRIMARY KEY (region_identifier_id)`
- `region_identifier_region_fkey` — `FOREIGN KEY (region_id) REFERENCES geo.region(region_id) ON DELETE CASCADE`

**Indexes**

- `UNIQUE region_identifier_primary_unique_idx` — `USING btree (region_id, identifier_scheme) WHERE (is_primary = true)`
- `region_identifier_region_idx` — `USING btree (region_id)`
- `region_identifier_scheme_value_idx` — `USING btree (identifier_scheme, identifier_value)`
- `region_identifier_source_value_idx` — `USING btree (source_system, identifier_value)`

## `geo.region_relationship`

**Status:** ACTIVE  
**Purpose:** Version-aware parent/child or other typed relationships among canonical regions.

| Column | Definition from schema |
|---|---|
| `region_relationship_id` | `bigint NOT NULL` |
| `parent_region_id` | `bigint NOT NULL` |
| `child_region_id` | `bigint NOT NULL` |
| `relationship_type` | `text NOT NULL` |
| `spatial_dataset_version_id` | `bigint` |
| `valid_from` | `date` |
| `valid_to` | `date` |
| `is_current` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `region_relationship_pkey` — `PRIMARY KEY (region_relationship_id)`
- `region_relationship_unique` — `UNIQUE NULLS NOT DISTINCT (parent_region_id, child_region_id, relationship_type, spatial_dataset_version_id)`
- `region_relationship_child_fkey` — `FOREIGN KEY (child_region_id) REFERENCES geo.region(region_id) ON DELETE CASCADE`
- `region_relationship_dataset_version_fkey` — `FOREIGN KEY (spatial_dataset_version_id) REFERENCES geo.spatial_dataset_version(spatial_dataset_version_id) ON DELETE RESTRICT`
- `region_relationship_parent_fkey` — `FOREIGN KEY (parent_region_id) REFERENCES geo.region(region_id) ON DELETE CASCADE`

**Indexes**

- `region_relationship_child_idx` — `USING btree (child_region_id)`
- `region_relationship_current_parent_idx` — `USING btree (child_region_id, relationship_type) WHERE (is_current = true)`
- `region_relationship_parent_idx` — `USING btree (parent_region_id)`
- `region_relationship_type_idx` — `USING btree (relationship_type)`

## `geo.region_type`

**Status:** ACTIVE  
**Purpose:** Controlled catalogue of region types such as country, state, province, territory, county, municipality, climate region, forecast zone, and federal district.

| Column | Definition from schema |
|---|---|
| `region_type_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `region_type_code_unique` — `UNIQUE (code)`
- `region_type_pkey` — `PRIMARY KEY (region_type_id)`

**Indexes**

- `region_type_active_idx` — `USING btree (is_active) WHERE (is_active = true)`

## `geo.region_version`

**Status:** ACTIVE CANONICAL  
**Purpose:** Versioned authoritative geometry for a stable geo.region identity; exact PostGIS geometry remains authoritative.

| Column | Definition from schema |
|---|---|
| `region_version_id` | `bigint NOT NULL` |
| `region_id` | `bigint NOT NULL` |
| `spatial_dataset_version_id` | `bigint` |
| `version_name` | `text` |
| `valid_from` | `date` |
| `valid_to` | `date` |
| `geometry` | `public.geometry(MultiPolygon,4326) NOT NULL` |
| `is_current` | `boolean DEFAULT false NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `region_version_pkey` — `PRIMARY KEY (region_version_id)`
- `region_version_dataset_version_fkey` — `FOREIGN KEY (spatial_dataset_version_id) REFERENCES geo.spatial_dataset_version(spatial_dataset_version_id) ON DELETE RESTRICT`
- `region_version_region_fkey` — `FOREIGN KEY (region_id) REFERENCES geo.region(region_id) ON DELETE CASCADE`

**Indexes**

- `UNIQUE region_version_current_unique_idx` — `USING btree (region_id) WHERE (is_current = true)`
- `region_version_dataset_version_idx` — `USING btree (spatial_dataset_version_id)`
- `region_version_geometry_gix` — `USING gist (geometry)`
- `region_version_region_idx` — `USING btree (region_id)`

## `geo.spatial_dataset`

**Status:** ACTIVE PROVENANCE  
**Purpose:** Catalogue of external spatial datasets/providers/licences used to build canonical geography.

| Column | Definition from schema |
|---|---|
| `spatial_dataset_id` | `bigint NOT NULL` |
| `provider_name` | `text NOT NULL` |
| `dataset_name` | `text NOT NULL` |
| `dataset_code` | `text` |
| `description` | `text` |
| `source_url` | `text` |
| `licence_name` | `text` |
| `licence_url` | `text` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `spatial_dataset_pkey` — `PRIMARY KEY (spatial_dataset_id)`
- `spatial_dataset_provider_name_unique` — `UNIQUE (provider_name, dataset_name)`

**Indexes**

- `spatial_dataset_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `spatial_dataset_provider_idx` — `USING btree (provider_name)`

## `geo.spatial_dataset_version`

**Status:** ACTIVE PROVENANCE  
**Purpose:** Version/release-level provenance for spatial datasets, including validity, checksum/source URI, SRID, and current flag.

| Column | Definition from schema |
|---|---|
| `spatial_dataset_version_id` | `bigint NOT NULL` |
| `spatial_dataset_id` | `bigint NOT NULL` |
| `version_name` | `text NOT NULL` |
| `release_date` | `date` |
| `valid_from` | `date` |
| `valid_to` | `date` |
| `source_uri` | `text` |
| `checksum` | `text` |
| `srid` | `integer` |
| `is_current` | `boolean DEFAULT false NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `spatial_dataset_version_pkey` — `PRIMARY KEY (spatial_dataset_version_id)`
- `spatial_dataset_version_unique` — `UNIQUE (spatial_dataset_id, version_name)`
- `spatial_dataset_version_dataset_fkey` — `FOREIGN KEY (spatial_dataset_id) REFERENCES geo.spatial_dataset(spatial_dataset_id) ON DELETE RESTRICT`

**Indexes**

- `UNIQUE spatial_dataset_version_current_unique_idx` — `USING btree (spatial_dataset_id) WHERE (is_current = true)`
- `spatial_dataset_version_dataset_idx` — `USING btree (spatial_dataset_id)`
- `spatial_dataset_version_release_date_idx` — `USING btree (release_date)`

## `geo.stage_country_name_iso2`

**Status:** STAGING  
**Purpose:** Staging/review mapping from source country names to ISO-2 codes.

| Column | Definition from schema |
|---|---|
| `source_country_name` | `text NOT NULL` |
| `iso2` | `character(2)` |
| `match_method` | `text` |
| `reviewed` | `boolean DEFAULT false NOT NULL` |

**Declared constraints**

- `stage_country_name_iso2_pkey` — `PRIMARY KEY (source_country_name)`

## `geo.stage_tiger_2025_county`

**Status:** STAGING  
**Purpose:** TIGER/Line 2025 county staging table.

| Column | Definition from schema |
|---|---|
| `gid` | `integer NOT NULL` |
| `statefp` | `character varying(2)` |
| `countyfp` | `character varying(3)` |
| `countyns` | `character varying(8)` |
| `geoid` | `character varying(5)` |
| `geoidfq` | `character varying(14)` |
| `name` | `character varying(100)` |
| `namelsad` | `character varying(100)` |
| `lsad` | `character varying(2)` |
| `classfp` | `character varying(2)` |
| `mtfcc` | `character varying(5)` |
| `csafp` | `character varying(3)` |
| `cbsafp` | `character varying(5)` |
| `metdivfp` | `character varying(5)` |
| `funcstat` | `character varying(1)` |
| `aland` | `double precision` |
| `awater` | `double precision` |
| `intptlat` | `character varying(11)` |
| `intptlon` | `character varying(12)` |
| `geom` | `public.geometry(MultiPolygon,4326)` |

**Declared constraints**

- `stage_tiger_2025_county_pkey` — `PRIMARY KEY (gid)`

**Indexes**

- `stage_tiger_2025_county_geom_idx` — `USING gist (geom)`

## `geo.stage_tiger_2025_county_utf8`

**Status:** STAGING  
**Purpose:** UTF-8 county staging variant used during TIGER import/cleanup.

| Column | Definition from schema |
|---|---|
| `gid` | `integer NOT NULL` |
| `statefp` | `character varying(2)` |
| `countyfp` | `character varying(3)` |
| `countyns` | `character varying(8)` |
| `geoid` | `character varying(5)` |
| `geoidfq` | `character varying(14)` |
| `name` | `character varying(100)` |
| `namelsad` | `character varying(100)` |
| `lsad` | `character varying(2)` |
| `classfp` | `character varying(2)` |
| `mtfcc` | `character varying(5)` |
| `csafp` | `character varying(3)` |
| `cbsafp` | `character varying(5)` |
| `metdivfp` | `character varying(5)` |
| `funcstat` | `character varying(1)` |
| `aland` | `double precision` |
| `awater` | `double precision` |
| `intptlat` | `character varying(11)` |
| `intptlon` | `character varying(12)` |
| `geom` | `public.geometry(MultiPolygon,4326)` |

**Declared constraints**

- `stage_tiger_2025_county_utf8_pkey` — `PRIMARY KEY (gid)`

**Indexes**

- `stage_tiger_2025_county_utf8_geom_idx` — `USING gist (geom)`

## `geo.stage_tiger_2025_state`

**Status:** STAGING  
**Purpose:** TIGER/Line 2025 state staging table.

| Column | Definition from schema |
|---|---|
| `gid` | `integer NOT NULL` |
| `region` | `character varying(2)` |
| `division` | `character varying(2)` |
| `statefp` | `character varying(2)` |
| `statens` | `character varying(8)` |
| `geoid` | `character varying(2)` |
| `geoidfq` | `character varying(11)` |
| `stusps` | `character varying(2)` |
| `name` | `character varying(100)` |
| `lsad` | `character varying(2)` |
| `mtfcc` | `character varying(5)` |
| `funcstat` | `character varying(1)` |
| `aland` | `double precision` |
| `awater` | `double precision` |
| `intptlat` | `character varying(11)` |
| `intptlon` | `character varying(12)` |
| `geom` | `public.geometry(MultiPolygon,4326)` |

**Declared constraints**

- `stage_tiger_2025_state_pkey` — `PRIMARY KEY (gid)`

**Indexes**

- `stage_tiger_2025_state_geom_idx` — `USING gist (geom)`
