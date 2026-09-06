# `weather` Schema

**Tables in snapshot:** 72

The `weather` schema is the universal physical-weather subsystem. It owns provider/source lineage, canonical spatial grids, observations, forecasts, ensembles, revisions/corrections, verification, station data and derivation lineage. Consumer schemas must not place gas/aviation/energy interpretation into canonical Weather tables.

## Locked implementation rules

- Provider grids are source support; `weather.grid_cell` determines canonical targets.
- Continuous scalar GFS remapping currently uses `bilinear_to_h3_center`.
- Wind components use `bilinear_components_to_h3_center`.
- Precipitation currently uses `nearest_native_point_provisional` and remains explicitly provisional.
- F000 has no preceding accumulation interval; precipitation is not fabricated.
- Relative humidity is clamped at the remapping boundary to the physical [0,100] range to absorb floating-point interpolation noise while keeping DB constraints strict.
- One logical forecast run may have multiple source windows/artifacts, but artifact-level provenance must remain traceable.
- Current controlled tests proved 38,463 50-state H3-R5 targets/step and 307,704 rows across eight steps with no duplicate canonical rows; this was a stress test, not the intended production footprint.

## Functional groups

### Canonical spatial grid

- `weather.grid_system`
- `weather.grid_cell`

### Provider / dataset / source lineage

- `weather.provider`
- `weather.dataset`
- `weather.dataset_version`
- `weather.source_artifact`
- `weather.ingestion_run`

### Physical variable semantics

- `weather.variable`
- `weather.unit`
- `weather.vertical_level`
- `weather.temporal_semantics`
- `weather.statistic`
- `weather.accumulation_period`
- `weather.daily_period_definition`
- `weather.condition_code`
- `weather.quality_flag`

### Dataset mappings

- `weather.dataset_variable_mapping`
- `weather.dataset_condition_mapping`

### Forecast model & product identity

- `weather.forecast_model`
- `weather.forecast_model_version`
- `weather.forecast_product`
- `weather.forecast_member`
- `weather.forecast_run`
- `weather.forecast_run_ingestion`

### Forecast expectation / completeness

- `weather.forecast_run_expectation`
- `weather.forecast_run_expectation_item`

### Canonical forecasts

- `weather.cell_forecast`
- `weather.cell_forecast_default`
- `weather.cell_forecast_value`

### Forecast corrections / revisions

- `weather.forecast_correction_reason`
- `weather.forecast_revision_definition`
- `weather.cell_forecast_correction`
- `weather.cell_forecast_revision`

### Ensembles / consensus

- `weather.ensemble_summary`
- `weather.ensemble_probability`
- `weather.consensus_definition`
- `weather.consensus_definition_member`

### Forecast verification

- `weather.verification_definition`
- `weather.forecast_verification`
- `weather.forecast_verification_summary`

### Derivation lineage

- `weather.derivation`
- `weather.derivation_version`
- `weather.derivation_run`
- `weather.derivation_run_input`

### Observation products & status

- `weather.observation_product`
- `weather.observation_record_status`
- `weather.observation_correction_reason`

### Canonical cell observations

- `weather.cell_observation_hourly`
- `weather.cell_observation_hourly_default`
- `weather.cell_observation_daily`
- `weather.cell_observation_daily_default`
- `weather.cell_observation_value`
- `weather.cell_observation_correction`
- `weather.cell_observation_daily_correction`
- `weather.cell_observation_quality_exception`
- `weather.cell_observation_daily_quality_exception`

### Stations & station geography

- `weather.station`
- `weather.station_history`
- `weather.station_identifier`
- `weather.station_network`
- `weather.station_network_membership`
- `weather.station_h3_map`
- `weather.station_region_map`

### Station observations

- `weather.station_observation_hourly`
- `weather.station_observation_daily`
- `weather.station_observation_daily_default`
- `weather.station_observation_value`
- `weather.station_observation_correction`
- `weather.station_observation_quality_exception`
- `weather.station_observation_daily_quality_exception`

### Bias correction

- `weather.bias_correction_definition`
- `weather.bias_correction_input_product`

## Table catalogue

## `weather.accumulation_period`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `accumulation_period_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `duration_seconds` | `bigint` |
| `description` | `text` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `accumulation_period_code_unique` — `UNIQUE (code)`
- `accumulation_period_pkey` — `PRIMARY KEY (accumulation_period_id)`

## `weather.bias_correction_definition`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Definition of a bias-correction method/product.

| Column | Definition from schema |
|---|---|
| `bias_correction_definition_id` | `bigint CONSTRAINT bias_correction_definition_bias_correction_definition__not_null NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `target_variable_id` | `bigint NOT NULL` |
| `training_observation_product_id` | `bigint CONSTRAINT bias_correction_definition_training_observation_produc_not_null NOT NULL` |
| `correction_method` | `text NOT NULL` |
| `algorithm_version` | `text NOT NULL` |
| `training_period_start` | `timestamp with time zone NOT NULL` |
| `training_period_end` | `timestamp with time zone NOT NULL` |
| `lead_minutes_start` | `integer` |
| `lead_minutes_end` | `integer` |
| `valid_from` | `timestamp with time zone` |
| `valid_to` | `timestamp with time zone` |
| `season_code` | `text` |
| `month_number` | `smallint` |
| `geography_scope` | `text` |
| `derivation_version_id` | `bigint` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `is_current` | `boolean DEFAULT false NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `bias_correction_definition_code_unique` — `UNIQUE (code)`
- `bias_correction_definition_pkey` — `PRIMARY KEY (bias_correction_definition_id)`
- `bias_correction_definition_derivation_version_fkey` — `FOREIGN KEY (derivation_version_id) REFERENCES weather.derivation_version(derivation_version_id) ON DELETE RESTRICT`
- `bias_correction_definition_observation_product_fkey` — `FOREIGN KEY (training_observation_product_id) REFERENCES weather.observation_product(observation_product_id) ON DELETE RESTRICT`
- `bias_correction_definition_variable_fkey` — `FOREIGN KEY (target_variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT`

**Indexes**

- `bias_correction_definition_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `bias_correction_definition_current_idx` — `USING btree (is_current) WHERE (is_current = true)`
- `bias_correction_definition_observation_product_idx` — `USING btree (training_observation_product_id)`
- `bias_correction_definition_variable_idx` — `USING btree (target_variable_id)`

## `weather.bias_correction_input_product`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Links bias-correction definitions to their source products.

| Column | Definition from schema |
|---|---|
| `bias_correction_input_product_id` | `bigint CONSTRAINT bias_correction_input_produ_bias_correction_input_prod_not_null NOT NULL` |
| `bias_correction_definition_id` | `bigint CONSTRAINT bias_correction_input_produ_bias_correction_definition_not_null NOT NULL` |
| `forecast_product_id` | `bigint NOT NULL` |
| `role` | `text DEFAULT 'input'::text NOT NULL` |
| `weight` | `double precision` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `bias_correction_input_product_pkey` — `PRIMARY KEY (bias_correction_input_product_id)`
- `bias_correction_input_product_unique` — `UNIQUE (bias_correction_definition_id, forecast_product_id, role)`
- `bias_correction_input_product_definition_fkey` — `FOREIGN KEY (bias_correction_definition_id) REFERENCES weather.bias_correction_definition(bias_correction_definition_id) ON DELETE CASCADE`
- `bias_correction_input_product_forecast_product_fkey` — `FOREIGN KEY (forecast_product_id) REFERENCES weather.forecast_product(forecast_product_id) ON DELETE RESTRICT`

**Indexes**

- `bias_correction_input_product_definition_idx` — `USING btree (bias_correction_definition_id)`
- `bias_correction_input_product_forecast_product_idx` — `USING btree (forecast_product_id)`

## `weather.cell_forecast`

**Status:** ACTIVE / CANONICAL  
**Purpose:** Partitioned canonical cell-level forecast table. This is hot operational forecast storage; current test data has been landing in the default partition.

| Column | Definition from schema |
|---|---|
| `cell_forecast_id` | `bigint NOT NULL` |
| `forecast_run_id` | `bigint NOT NULL` |
| `forecast_member_id` | `bigint NOT NULL` |
| `forecast_product_id` | `bigint NOT NULL` |
| `grid_cell_id` | `bigint NOT NULL` |
| `valid_time` | `timestamp with time zone NOT NULL` |
| `period_start` | `timestamp with time zone` |
| `period_end` | `timestamp with time zone` |
| `lead_minutes` | `integer NOT NULL` |
| `observation_record_status_id` | `smallint NOT NULL` |
| `ingestion_run_id` | `bigint` |
| `derivation_run_id` | `bigint NOT NULL` |
| `provider_published_at` | `timestamp with time zone` |
| `received_at` | `timestamp with time zone` |
| `processed_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `revision_no` | `integer DEFAULT 1 NOT NULL` |
| `is_preferred` | `boolean DEFAULT true NOT NULL` |
| `supersedes_cell_forecast_id` | `bigint` |
| `supersedes_valid_time` | `timestamp with time zone` |
| `air_temperature_2m_c` | `double precision` |
| `apparent_temperature_2m_c` | `double precision` |
| `dew_point_2m_c` | `double precision` |
| `relative_humidity_2m_pct` | `double precision` |
| `surface_pressure_hpa` | `double precision` |
| `precipitation_mm` | `double precision` |
| `rainfall_mm` | `double precision` |
| `snowfall_mm` | `double precision` |
| `snow_depth_mm` | `double precision` |
| `wind_u_10m_ms` | `double precision` |
| `wind_v_10m_ms` | `double precision` |
| `wind_gust_10m_ms` | `double precision` |
| `cloud_cover_pct` | `double precision` |
| `visibility_m` | `double precision` |
| `solar_radiation_w_m2` | `double precision` |
| `condition_code_id` | `smallint` |
| `coverage_fraction` | `double precision` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `PARTITION` | `BY RANGE (valid_time);` |
| `ALTER` | `TABLE weather.cell_forecast OWNER TO postgres;` |
| `ALTER` | `TABLE weather.cell_forecast ALTER COLUMN cell_forecast_id ADD GENERATED BY DEFAULT AS IDENTITY (` |
| `SEQUENCE` | `NAME weather.cell_forecast_cell_forecast_id_seq` |
| `START` | `WITH 1` |
| `INCREMENT` | `BY 1` |
| `NO` | `MINVALUE` |
| `NO` | `MAXVALUE` |
| `CACHE` | `1` |

**Declared constraints**

- `cell_forecast_natural_revision_unique` — `UNIQUE (forecast_run_id, forecast_member_id, forecast_product_id, grid_cell_id, valid_time, revision_no)`
- `cell_forecast_pkey` — `PRIMARY KEY (cell_forecast_id, valid_time)`

## `weather.cell_forecast_correction`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `cell_forecast_correction_id` | `bigint NOT NULL` |
| `original_cell_forecast_id` | `bigint NOT NULL` |
| `original_valid_time` | `timestamp with time zone NOT NULL` |
| `replacement_cell_forecast_id` | `bigint NOT NULL` |
| `replacement_valid_time` | `timestamp with time zone NOT NULL` |
| `forecast_correction_reason_id` | `smallint NOT NULL` |
| `source_artifact_id` | `bigint` |
| `ingestion_run_id` | `bigint` |
| `derivation_run_id` | `bigint` |
| `provider_revision` | `text` |
| `correction_time` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `notes` | `text` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `cell_forecast_correction_pkey` — `PRIMARY KEY (cell_forecast_correction_id)`
- `cell_forecast_correction_unique` — `UNIQUE (original_cell_forecast_id, original_valid_time, replacement_cell_forecast_id, replacement_valid_time)`
- `cell_forecast_correction_artifact_fkey` — `FOREIGN KEY (source_artifact_id) REFERENCES weather.source_artifact(source_artifact_id) ON DELETE RESTRICT`
- `cell_forecast_correction_derivation_fkey` — `FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT`
- `cell_forecast_correction_ingestion_fkey` — `FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT`
- `cell_forecast_correction_original_fkey` — `FOREIGN KEY (original_cell_forecast_id, original_valid_time) REFERENCES weather.cell_forecast(cell_forecast_id, valid_time) ON DELETE RESTRICT`
- `cell_forecast_correction_reason_fkey` — `FOREIGN KEY (forecast_correction_reason_id) REFERENCES weather.forecast_correction_reason(forecast_correction_reason_id) ON DELETE RESTRICT`
- `cell_forecast_correction_replacement_fkey` — `FOREIGN KEY (replacement_cell_forecast_id, replacement_valid_time) REFERENCES weather.cell_forecast(cell_forecast_id, valid_time) ON DELETE RESTRICT`

**Indexes**

- `cell_forecast_correction_artifact_idx` — `USING btree (source_artifact_id) WHERE (source_artifact_id IS NOT NULL)`
- `cell_forecast_correction_original_idx` — `USING btree (original_cell_forecast_id, original_valid_time)`
- `cell_forecast_correction_reason_idx` — `USING btree (forecast_correction_reason_id)`
- `cell_forecast_correction_replacement_idx` — `USING btree (replacement_cell_forecast_id, replacement_valid_time)`

## `weather.cell_forecast_default`

**Status:** PHYSICAL DEFAULT PARTITION  
**Purpose:** Default physical partition for weather.cell_forecast. Acceptable for controlled tests; deliberate production partitioning is required before continuous high-volume scheduling.

| Column | Definition from schema |
|---|---|
| `cell_forecast_id` | `bigint CONSTRAINT cell_forecast_cell_forecast_id_not_null NOT NULL` |
| `forecast_run_id` | `bigint CONSTRAINT cell_forecast_forecast_run_id_not_null NOT NULL` |
| `forecast_member_id` | `bigint CONSTRAINT cell_forecast_forecast_member_id_not_null NOT NULL` |
| `forecast_product_id` | `bigint CONSTRAINT cell_forecast_forecast_product_id_not_null NOT NULL` |
| `grid_cell_id` | `bigint CONSTRAINT cell_forecast_grid_cell_id_not_null NOT NULL` |
| `valid_time` | `timestamp with time zone CONSTRAINT cell_forecast_valid_time_not_null NOT NULL` |
| `period_start` | `timestamp with time zone` |
| `period_end` | `timestamp with time zone` |
| `lead_minutes` | `integer CONSTRAINT cell_forecast_lead_minutes_not_null NOT NULL` |
| `observation_record_status_id` | `smallint CONSTRAINT cell_forecast_observation_record_status_id_not_null NOT NULL` |
| `ingestion_run_id` | `bigint` |
| `derivation_run_id` | `bigint CONSTRAINT cell_forecast_derivation_run_id_not_null NOT NULL` |
| `provider_published_at` | `timestamp with time zone` |
| `received_at` | `timestamp with time zone` |
| `processed_at` | `timestamp with time zone DEFAULT now() CONSTRAINT cell_forecast_processed_at_not_null NOT NULL` |
| `revision_no` | `integer DEFAULT 1 CONSTRAINT cell_forecast_revision_no_not_null NOT NULL` |
| `is_preferred` | `boolean DEFAULT true CONSTRAINT cell_forecast_is_preferred_not_null NOT NULL` |
| `supersedes_cell_forecast_id` | `bigint` |
| `supersedes_valid_time` | `timestamp with time zone` |
| `air_temperature_2m_c` | `double precision` |
| `apparent_temperature_2m_c` | `double precision` |
| `dew_point_2m_c` | `double precision` |
| `relative_humidity_2m_pct` | `double precision` |
| `surface_pressure_hpa` | `double precision` |
| `precipitation_mm` | `double precision` |
| `rainfall_mm` | `double precision` |
| `snowfall_mm` | `double precision` |
| `snow_depth_mm` | `double precision` |
| `wind_u_10m_ms` | `double precision` |
| `wind_v_10m_ms` | `double precision` |
| `wind_gust_10m_ms` | `double precision` |
| `cloud_cover_pct` | `double precision` |
| `visibility_m` | `double precision` |
| `solar_radiation_w_m2` | `double precision` |
| `condition_code_id` | `smallint` |
| `coverage_fraction` | `double precision` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb CONSTRAINT cell_forecast_metadata_not_null NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() CONSTRAINT cell_forecast_created_at_not_null NOT NULL` |

**Declared constraints**

- `cell_forecast_default_forecast_run_id_forecast_member_id_fo_key` — `UNIQUE (forecast_run_id, forecast_member_id, forecast_product_id, grid_cell_id, valid_time, revision_no)`
- `cell_forecast_default_pkey` — `PRIMARY KEY (cell_forecast_id, valid_time)`

**Indexes**

- `cell_forecast_default_derivation_run_id_idx` — `USING btree (derivation_run_id)`
- `cell_forecast_default_forecast_member_id_valid_time_idx` — `USING btree (forecast_member_id, valid_time)`
- `cell_forecast_default_forecast_product_id_valid_time_idx` — `USING btree (forecast_product_id, valid_time)`
- `cell_forecast_default_forecast_run_id_valid_time_idx` — `USING btree (forecast_run_id, valid_time)`
- `cell_forecast_default_grid_cell_id_forecast_product_id_vali_idx` — `USING btree (grid_cell_id, forecast_product_id, valid_time) WHERE (is_preferred = true)`
- `cell_forecast_default_grid_cell_id_valid_time_idx` — `USING btree (grid_cell_id, valid_time)`
- `cell_forecast_default_ingestion_run_id_idx` — `USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL)`
- `cell_forecast_default_valid_time_grid_cell_id_idx` — `USING btree (valid_time, grid_cell_id)`

## `weather.cell_forecast_revision`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `cell_forecast_revision_id` | `bigint NOT NULL` |
| `forecast_revision_definition_id` | `bigint NOT NULL` |
| `comparison_cell_forecast_id` | `bigint NOT NULL` |
| `comparison_valid_time` | `timestamp with time zone NOT NULL` |
| `newer_cell_forecast_id` | `bigint NOT NULL` |
| `newer_valid_time` | `timestamp with time zone NOT NULL` |
| `variable_id` | `bigint NOT NULL` |
| `comparison_value` | `double precision NOT NULL` |
| `newer_value` | `double precision NOT NULL` |
| `absolute_change` | `double precision NOT NULL` |
| `percentage_change` | `double precision` |
| `change_direction` | `text` |
| `change_category` | `text` |
| `derivation_run_id` | `bigint` |
| `calculated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `cell_forecast_revision_pkey` — `PRIMARY KEY (cell_forecast_revision_id)`
- `cell_forecast_revision_unique` — `UNIQUE (forecast_revision_definition_id, comparison_cell_forecast_id, comparison_valid_time, newer_cell_forecast_id, newer_valid_time, variable_id)`
- `cell_forecast_revision_comparison_fkey` — `FOREIGN KEY (comparison_cell_forecast_id, comparison_valid_time) REFERENCES weather.cell_forecast(cell_forecast_id, valid_time) ON DELETE RESTRICT`
- `cell_forecast_revision_definition_fkey` — `FOREIGN KEY (forecast_revision_definition_id) REFERENCES weather.forecast_revision_definition(forecast_revision_definition_id) ON DELETE RESTRICT`
- `cell_forecast_revision_derivation_fkey` — `FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT`
- `cell_forecast_revision_newer_fkey` — `FOREIGN KEY (newer_cell_forecast_id, newer_valid_time) REFERENCES weather.cell_forecast(cell_forecast_id, valid_time) ON DELETE RESTRICT`
- `cell_forecast_revision_variable_fkey` — `FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT`

**Indexes**

- `cell_forecast_revision_calculated_at_idx` — `USING btree (calculated_at DESC)`
- `cell_forecast_revision_comparison_idx` — `USING btree (comparison_cell_forecast_id, comparison_valid_time)`
- `cell_forecast_revision_definition_idx` — `USING btree (forecast_revision_definition_id)`
- `cell_forecast_revision_newer_idx` — `USING btree (newer_cell_forecast_id, newer_valid_time)`
- `cell_forecast_revision_variable_idx` — `USING btree (variable_id)`

## `weather.cell_forecast_value`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `cell_forecast_value_id` | `bigint NOT NULL` |
| `cell_forecast_id` | `bigint NOT NULL` |
| `valid_time` | `timestamp with time zone NOT NULL` |
| `variable_id` | `bigint NOT NULL` |
| `value_double` | `double precision` |
| `value_text` | `text` |
| `observation_record_status_id` | `smallint` |
| `ingestion_run_id` | `bigint` |
| `derivation_run_id` | `bigint NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `cell_forecast_value_pkey` — `PRIMARY KEY (cell_forecast_value_id)`
- `cell_forecast_value_unique` — `UNIQUE (cell_forecast_id, valid_time, variable_id)`
- `cell_forecast_value_derivation_fkey` — `FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT`
- `cell_forecast_value_forecast_fkey` — `FOREIGN KEY (cell_forecast_id, valid_time) REFERENCES weather.cell_forecast(cell_forecast_id, valid_time) ON DELETE CASCADE`
- `cell_forecast_value_ingestion_fkey` — `FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT`
- `cell_forecast_value_status_fkey` — `FOREIGN KEY (observation_record_status_id) REFERENCES weather.observation_record_status(observation_record_status_id) ON DELETE RESTRICT`
- `cell_forecast_value_variable_fkey` — `FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT`

**Indexes**

- `cell_forecast_value_derivation_idx` — `USING btree (derivation_run_id)`
- `cell_forecast_value_forecast_idx` — `USING btree (cell_forecast_id, valid_time)`
- `cell_forecast_value_ingestion_idx` — `USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL)`
- `cell_forecast_value_variable_idx` — `USING btree (variable_id, valid_time)`

## `weather.cell_observation_correction`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `cell_observation_correction_id` | `bigint CONSTRAINT cell_observation_correction_cell_observation_correctio_not_null NOT NULL` |
| `original_observation_id` | `bigint NOT NULL` |
| `original_observation_time` | `timestamp with time zone NOT NULL` |
| `replacement_observation_id` | `bigint NOT NULL` |
| `replacement_observation_time` | `timestamp with time zone CONSTRAINT cell_observation_correction_replacement_observation_ti_not_null NOT NULL` |
| `observation_correction_reason_id` | `smallint CONSTRAINT cell_observation_correction_observation_correction_rea_not_null NOT NULL` |
| `source_artifact_id` | `bigint` |
| `derivation_run_id` | `bigint` |
| `correction_time` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `notes` | `text` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `cell_observation_correction_pkey` — `PRIMARY KEY (cell_observation_correction_id)`
- `cell_observation_correction_unique` — `UNIQUE (original_observation_id, original_observation_time, replacement_observation_id, replacement_observation_time)`
- `cell_observation_correction_artifact_fkey` — `FOREIGN KEY (source_artifact_id) REFERENCES weather.source_artifact(source_artifact_id) ON DELETE RESTRICT`
- `cell_observation_correction_derivation_fkey` — `FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT`
- `cell_observation_correction_original_fkey` — `FOREIGN KEY (original_observation_id, original_observation_time) REFERENCES weather.cell_observation_hourly(cell_observation_id, observation_time) ON DELETE RESTRICT`
- `cell_observation_correction_reason_fkey` — `FOREIGN KEY (observation_correction_reason_id) REFERENCES weather.observation_correction_reason(observation_correction_reason_id) ON DELETE RESTRICT`
- `cell_observation_correction_replacement_fkey` — `FOREIGN KEY (replacement_observation_id, replacement_observation_time) REFERENCES weather.cell_observation_hourly(cell_observation_id, observation_time) ON DELETE RESTRICT`

**Indexes**

- `cell_observation_correction_original_idx` — `USING btree (original_observation_id, original_observation_time)`
- `cell_observation_correction_replacement_idx` — `USING btree (replacement_observation_id, replacement_observation_time)`

## `weather.cell_observation_daily`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Partitioned canonical daily cell observations.

| Column | Definition from schema |
|---|---|
| `cell_observation_daily_id` | `bigint NOT NULL` |
| `observation_date` | `date NOT NULL` |
| `grid_cell_id` | `bigint NOT NULL` |
| `observation_product_id` | `bigint NOT NULL` |
| `observation_record_status_id` | `smallint NOT NULL` |
| `ingestion_run_id` | `bigint` |
| `derivation_run_id` | `bigint NOT NULL` |
| `period_start` | `timestamp with time zone NOT NULL` |
| `period_end` | `timestamp with time zone NOT NULL` |
| `provider_published_at` | `timestamp with time zone` |
| `received_at` | `timestamp with time zone` |
| `ingested_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `revision_no` | `integer DEFAULT 1 NOT NULL` |
| `is_preferred` | `boolean DEFAULT true NOT NULL` |
| `supersedes_observation_daily_id` | `bigint` |
| `supersedes_observation_date` | `date` |
| `air_temperature_2m_min_c` | `double precision` |
| `air_temperature_2m_max_c` | `double precision` |
| `air_temperature_2m_mean_c` | `double precision` |
| `apparent_temperature_2m_min_c` | `double precision` |
| `apparent_temperature_2m_max_c` | `double precision` |
| `apparent_temperature_2m_mean_c` | `double precision` |
| `dew_point_2m_min_c` | `double precision` |
| `dew_point_2m_max_c` | `double precision` |
| `dew_point_2m_mean_c` | `double precision` |
| `relative_humidity_2m_min_pct` | `double precision` |
| `relative_humidity_2m_max_pct` | `double precision` |
| `relative_humidity_2m_mean_pct` | `double precision` |
| `surface_pressure_mean_hpa` | `double precision` |
| `precipitation_total_mm` | `double precision` |
| `rainfall_total_mm` | `double precision` |
| `snowfall_total_mm` | `double precision` |
| `snow_depth_max_mm` | `double precision` |
| `wind_u_10m_mean_ms` | `double precision` |
| `wind_v_10m_mean_ms` | `double precision` |
| `wind_gust_10m_max_ms` | `double precision` |
| `cloud_cover_mean_pct` | `double precision` |
| `visibility_mean_m` | `double precision` |
| `solar_radiation_mean_w_m2` | `double precision` |
| `sample_count` | `integer` |
| `coverage_fraction` | `double precision` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `PARTITION` | `BY RANGE (observation_date);` |
| `ALTER` | `TABLE weather.cell_observation_daily OWNER TO postgres;` |
| `ALTER` | `TABLE weather.cell_observation_daily ALTER COLUMN cell_observation_daily_id ADD GENERATED BY DEFAULT AS IDENTITY (` |
| `SEQUENCE` | `NAME weather.cell_observation_daily_cell_observation_daily_id_seq` |
| `START` | `WITH 1` |
| `INCREMENT` | `BY 1` |
| `NO` | `MINVALUE` |
| `NO` | `MAXVALUE` |
| `CACHE` | `1` |

**Declared constraints**

- `cell_observation_daily_natural_revision_unique` — `UNIQUE (grid_cell_id, observation_product_id, observation_date, revision_no)`
- `cell_observation_daily_pkey` — `PRIMARY KEY (cell_observation_daily_id, observation_date)`

## `weather.cell_observation_daily_correction`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `cell_observation_daily_correction_id` | `bigint CONSTRAINT cell_observation_daily_corr_cell_observation_daily_cor_not_null NOT NULL` |
| `original_observation_daily_id` | `bigint CONSTRAINT cell_observation_daily_corr_original_observation_daily_not_null NOT NULL` |
| `original_observation_date` | `date CONSTRAINT cell_observation_daily_corre_original_observation_date_not_null NOT NULL` |
| `replacement_observation_daily_id` | `bigint CONSTRAINT cell_observation_daily_corr_replacement_observation_da_not_null NOT NULL` |
| `replacement_observation_date` | `date CONSTRAINT cell_observation_daily_cor_replacement_observation_da_not_null1 NOT NULL` |
| `observation_correction_reason_id` | `smallint CONSTRAINT cell_observation_daily_corr_observation_correction_rea_not_null NOT NULL` |
| `source_artifact_id` | `bigint` |
| `derivation_run_id` | `bigint` |
| `correction_time` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `notes` | `text` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `cell_observation_daily_correction_pkey` — `PRIMARY KEY (cell_observation_daily_correction_id)`
- `cell_observation_daily_correction_unique` — `UNIQUE (original_observation_daily_id, original_observation_date, replacement_observation_daily_id, replacement_observation_date)`
- `cell_observation_daily_correction_artifact_fkey` — `FOREIGN KEY (source_artifact_id) REFERENCES weather.source_artifact(source_artifact_id) ON DELETE RESTRICT`
- `cell_observation_daily_correction_derivation_fkey` — `FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT`
- `cell_observation_daily_correction_original_fkey` — `FOREIGN KEY (original_observation_daily_id, original_observation_date) REFERENCES weather.cell_observation_daily(cell_observation_daily_id, observation_date) ON DELETE RESTRICT`
- `cell_observation_daily_correction_reason_fkey` — `FOREIGN KEY (observation_correction_reason_id) REFERENCES weather.observation_correction_reason(observation_correction_reason_id) ON DELETE RESTRICT`
- `cell_observation_daily_correction_replacement_fkey` — `FOREIGN KEY (replacement_observation_daily_id, replacement_observation_date) REFERENCES weather.cell_observation_daily(cell_observation_daily_id, observation_date) ON DELETE RESTRICT`

**Indexes**

- `cell_observation_daily_correction_original_idx` — `USING btree (original_observation_daily_id, original_observation_date)`
- `cell_observation_daily_correction_replacement_idx` — `USING btree (replacement_observation_daily_id, replacement_observation_date)`

## `weather.cell_observation_daily_default`

**Status:** PHYSICAL DEFAULT PARTITION  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `cell_observation_daily_id` | `bigint CONSTRAINT cell_observation_daily_cell_observation_daily_id_not_null NOT NULL` |
| `observation_date` | `date CONSTRAINT cell_observation_daily_observation_date_not_null NOT NULL` |
| `grid_cell_id` | `bigint CONSTRAINT cell_observation_daily_grid_cell_id_not_null NOT NULL` |
| `observation_product_id` | `bigint CONSTRAINT cell_observation_daily_observation_product_id_not_null NOT NULL` |
| `observation_record_status_id` | `smallint CONSTRAINT cell_observation_daily_observation_record_status_id_not_null NOT NULL` |
| `ingestion_run_id` | `bigint` |
| `derivation_run_id` | `bigint CONSTRAINT cell_observation_daily_derivation_run_id_not_null NOT NULL` |
| `period_start` | `timestamp with time zone CONSTRAINT cell_observation_daily_period_start_not_null NOT NULL` |
| `period_end` | `timestamp with time zone CONSTRAINT cell_observation_daily_period_end_not_null NOT NULL` |
| `provider_published_at` | `timestamp with time zone` |
| `received_at` | `timestamp with time zone` |
| `ingested_at` | `timestamp with time zone DEFAULT now() CONSTRAINT cell_observation_daily_ingested_at_not_null NOT NULL` |
| `revision_no` | `integer DEFAULT 1 CONSTRAINT cell_observation_daily_revision_no_not_null NOT NULL` |
| `is_preferred` | `boolean DEFAULT true CONSTRAINT cell_observation_daily_is_preferred_not_null NOT NULL` |
| `supersedes_observation_daily_id` | `bigint` |
| `supersedes_observation_date` | `date` |
| `air_temperature_2m_min_c` | `double precision` |
| `air_temperature_2m_max_c` | `double precision` |
| `air_temperature_2m_mean_c` | `double precision` |
| `apparent_temperature_2m_min_c` | `double precision` |
| `apparent_temperature_2m_max_c` | `double precision` |
| `apparent_temperature_2m_mean_c` | `double precision` |
| `dew_point_2m_min_c` | `double precision` |
| `dew_point_2m_max_c` | `double precision` |
| `dew_point_2m_mean_c` | `double precision` |
| `relative_humidity_2m_min_pct` | `double precision` |
| `relative_humidity_2m_max_pct` | `double precision` |
| `relative_humidity_2m_mean_pct` | `double precision` |
| `surface_pressure_mean_hpa` | `double precision` |
| `precipitation_total_mm` | `double precision` |
| `rainfall_total_mm` | `double precision` |
| `snowfall_total_mm` | `double precision` |
| `snow_depth_max_mm` | `double precision` |
| `wind_u_10m_mean_ms` | `double precision` |
| `wind_v_10m_mean_ms` | `double precision` |
| `wind_gust_10m_max_ms` | `double precision` |
| `cloud_cover_mean_pct` | `double precision` |
| `visibility_mean_m` | `double precision` |
| `solar_radiation_mean_w_m2` | `double precision` |
| `sample_count` | `integer` |
| `coverage_fraction` | `double precision` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb CONSTRAINT cell_observation_daily_metadata_not_null NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() CONSTRAINT cell_observation_daily_created_at_not_null NOT NULL` |

**Declared constraints**

- `cell_observation_daily_defaul_grid_cell_id_observation_prod_key` — `UNIQUE (grid_cell_id, observation_product_id, observation_date, revision_no)`
- `cell_observation_daily_default_pkey` — `PRIMARY KEY (cell_observation_daily_id, observation_date)`

**Indexes**

- `cell_observation_daily_defaul_grid_cell_id_observation_date_idx` — `USING btree (grid_cell_id, observation_date DESC)`
- `cell_observation_daily_defaul_grid_cell_id_observation_prod_idx` — `USING btree (grid_cell_id, observation_product_id, observation_date DESC) WHERE (is_preferred = true)`
- `cell_observation_daily_defaul_observation_date_grid_cell_id_idx` — `USING btree (observation_date, grid_cell_id)`
- `cell_observation_daily_defaul_observation_product_id_observ_idx` — `USING btree (observation_product_id, observation_date DESC)`
- `cell_observation_daily_default_derivation_run_id_idx` — `USING btree (derivation_run_id)`
- `cell_observation_daily_default_ingestion_run_id_idx` — `USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL)`

## `weather.cell_observation_daily_quality_exception`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `cell_observation_daily_quality_exception_id` | `bigint CONSTRAINT cell_observation_daily_qual_cell_observation_daily_qua_not_null NOT NULL` |
| `cell_observation_daily_id` | `bigint CONSTRAINT cell_observation_daily_quali_cell_observation_daily_id_not_null NOT NULL` |
| `observation_date` | `date CONSTRAINT cell_observation_daily_quality_except_observation_date_not_null NOT NULL` |
| `variable_id` | `bigint NOT NULL` |
| `quality_flag_id` | `smallint CONSTRAINT cell_observation_daily_quality_excepti_quality_flag_id_not_null NOT NULL` |
| `detected_by` | `text` |
| `derivation_run_id` | `bigint` |
| `details` | `text` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `detected_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `cell_observation_daily_quality_exception_pkey` — `PRIMARY KEY (cell_observation_daily_quality_exception_id)`
- `cell_observation_daily_quality_exception_unique` — `UNIQUE (cell_observation_daily_id, observation_date, variable_id, quality_flag_id)`
- `cell_observation_daily_quality_exception_derivation_fkey` — `FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT`
- `cell_observation_daily_quality_exception_flag_fkey` — `FOREIGN KEY (quality_flag_id) REFERENCES weather.quality_flag(quality_flag_id) ON DELETE RESTRICT`
- `cell_observation_daily_quality_exception_observation_fkey` — `FOREIGN KEY (cell_observation_daily_id, observation_date) REFERENCES weather.cell_observation_daily(cell_observation_daily_id, observation_date) ON DELETE CASCADE`
- `cell_observation_daily_quality_exception_variable_fkey` — `FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT`

**Indexes**

- `cell_observation_daily_quality_exception_derivation_idx` — `USING btree (derivation_run_id) WHERE (derivation_run_id IS NOT NULL)`
- `cell_observation_daily_quality_exception_flag_idx` — `USING btree (quality_flag_id)`
- `cell_observation_daily_quality_exception_observation_idx` — `USING btree (cell_observation_daily_id, observation_date)`
- `cell_observation_daily_quality_exception_variable_idx` — `USING btree (variable_id)`

## `weather.cell_observation_hourly`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Partitioned canonical hourly cell observations.

| Column | Definition from schema |
|---|---|
| `cell_observation_id` | `bigint NOT NULL` |
| `observation_time` | `timestamp with time zone NOT NULL` |
| `grid_cell_id` | `bigint NOT NULL` |
| `observation_product_id` | `bigint NOT NULL` |
| `observation_record_status_id` | `smallint NOT NULL` |
| `ingestion_run_id` | `bigint` |
| `derivation_run_id` | `bigint NOT NULL` |
| `period_start` | `timestamp with time zone` |
| `period_end` | `timestamp with time zone` |
| `provider_published_at` | `timestamp with time zone` |
| `received_at` | `timestamp with time zone` |
| `ingested_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `revision_no` | `integer DEFAULT 1 NOT NULL` |
| `is_preferred` | `boolean DEFAULT true NOT NULL` |
| `supersedes_observation_id` | `bigint` |
| `supersedes_observation_time` | `timestamp with time zone` |
| `air_temperature_2m_c` | `double precision` |
| `apparent_temperature_2m_c` | `double precision` |
| `dew_point_2m_c` | `double precision` |
| `relative_humidity_2m_pct` | `double precision` |
| `surface_pressure_hpa` | `double precision` |
| `precipitation_1h_mm` | `double precision` |
| `rainfall_1h_mm` | `double precision` |
| `snowfall_1h_mm` | `double precision` |
| `snow_depth_mm` | `double precision` |
| `wind_u_10m_ms` | `double precision` |
| `wind_v_10m_ms` | `double precision` |
| `wind_gust_10m_max_1h_ms` | `double precision` |
| `cloud_cover_pct` | `double precision` |
| `visibility_m` | `double precision` |
| `solar_radiation_w_m2` | `double precision` |
| `coverage_fraction` | `double precision` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `condition_code_id` | `smallint` |
| `PARTITION` | `BY RANGE (observation_time);` |
| `ALTER` | `TABLE weather.cell_observation_hourly OWNER TO postgres;` |
| `COMMENT` | `ON COLUMN weather.cell_observation_hourly.air_temperature_2m_c IS 'Canonical H3-cell 2 m air temperature in degrees Celsius.';` |
| `COMMENT` | `ON COLUMN weather.cell_observation_hourly.apparent_temperature_2m_c IS 'Canonical H3-cell 2 m apparent temperature in degrees Celsius.';` |
| `COMMENT` | `ON COLUMN weather.cell_observation_hourly.dew_point_2m_c IS 'Canonical H3-cell 2 m dew point in degrees Celsius.';` |
| `COMMENT` | `ON COLUMN weather.cell_observation_hourly.relative_humidity_2m_pct IS 'Canonical H3-cell 2 m relative humidity in percent.';` |
| `COMMENT` | `ON COLUMN weather.cell_observation_hourly.surface_pressure_hpa IS 'Canonical H3-cell surface pressure in hectopascals.';` |
| `COMMENT` | `ON COLUMN weather.cell_observation_hourly.precipitation_1h_mm IS 'Canonical H3-cell total precipitation over the explicit one-hour period in millimetres.';` |
| `COMMENT` | `ON COLUMN weather.cell_observation_hourly.rainfall_1h_mm IS 'Canonical H3-cell liquid rainfall over the explicit one-hour period in millimetres.';` |
| `COMMENT` | `ON COLUMN weather.cell_observation_hourly.snowfall_1h_mm IS 'Canonical H3-cell snowfall over the explicit one-hour period in millimetres.';` |
| `COMMENT` | `ON COLUMN weather.cell_observation_hourly.snow_depth_mm IS 'Canonical H3-cell snow depth in millimetres.';` |
| `COMMENT` | `ON COLUMN weather.cell_observation_hourly.wind_u_10m_ms IS 'Canonical H3-cell east-west wind component at 10 m in metres per second.';` |
| `COMMENT` | `ON COLUMN weather.cell_observation_hourly.wind_v_10m_ms IS 'Canonical H3-cell north-south wind component at 10 m in metres per second.';` |
| `COMMENT` | `ON COLUMN weather.cell_observation_hourly.wind_gust_10m_max_1h_ms IS 'Canonical H3-cell maximum 10 m wind gust over one hour in metres per second.';` |
| `COMMENT` | `ON COLUMN weather.cell_observation_hourly.cloud_cover_pct IS 'Canonical H3-cell total cloud cover in percent.';` |
| `COMMENT` | `ON COLUMN weather.cell_observation_hourly.visibility_m IS 'Canonical H3-cell horizontal visibility in metres.';` |
| `COMMENT` | `ON COLUMN weather.cell_observation_hourly.solar_radiation_w_m2 IS 'Canonical H3-cell surface solar radiation flux in watts per square metre.';` |
| `COMMENT` | `ON COLUMN weather.cell_observation_hourly.coverage_fraction IS 'Fraction from 0 to 1 representing source/derivation coverage of the target H3 cell where applicable.';` |
| `ALTER` | `TABLE weather.cell_observation_hourly ALTER COLUMN cell_observation_id ADD GENERATED BY DEFAULT AS IDENTITY (` |
| `SEQUENCE` | `NAME weather.cell_observation_hourly_cell_observation_id_seq` |
| `START` | `WITH 1` |
| `INCREMENT` | `BY 1` |
| `NO` | `MINVALUE` |
| `NO` | `MAXVALUE` |
| `CACHE` | `1` |

**Declared constraints**

- `cell_observation_hourly_natural_revision_unique` — `UNIQUE (grid_cell_id, observation_product_id, observation_time, revision_no)`
- `cell_observation_hourly_pkey` — `PRIMARY KEY (cell_observation_id, observation_time)`

## `weather.cell_observation_hourly_default`

**Status:** PHYSICAL DEFAULT PARTITION  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `cell_observation_id` | `bigint CONSTRAINT cell_observation_hourly_cell_observation_id_not_null NOT NULL` |
| `observation_time` | `timestamp with time zone CONSTRAINT cell_observation_hourly_observation_time_not_null NOT NULL` |
| `grid_cell_id` | `bigint CONSTRAINT cell_observation_hourly_grid_cell_id_not_null NOT NULL` |
| `observation_product_id` | `bigint CONSTRAINT cell_observation_hourly_observation_product_id_not_null NOT NULL` |
| `observation_record_status_id` | `smallint CONSTRAINT cell_observation_hourly_observation_record_status_id_not_null NOT NULL` |
| `ingestion_run_id` | `bigint` |
| `derivation_run_id` | `bigint CONSTRAINT cell_observation_hourly_derivation_run_id_not_null NOT NULL` |
| `period_start` | `timestamp with time zone` |
| `period_end` | `timestamp with time zone` |
| `provider_published_at` | `timestamp with time zone` |
| `received_at` | `timestamp with time zone` |
| `ingested_at` | `timestamp with time zone DEFAULT now() CONSTRAINT cell_observation_hourly_ingested_at_not_null NOT NULL` |
| `revision_no` | `integer DEFAULT 1 CONSTRAINT cell_observation_hourly_revision_no_not_null NOT NULL` |
| `is_preferred` | `boolean DEFAULT true CONSTRAINT cell_observation_hourly_is_preferred_not_null NOT NULL` |
| `supersedes_observation_id` | `bigint` |
| `supersedes_observation_time` | `timestamp with time zone` |
| `air_temperature_2m_c` | `double precision` |
| `apparent_temperature_2m_c` | `double precision` |
| `dew_point_2m_c` | `double precision` |
| `relative_humidity_2m_pct` | `double precision` |
| `surface_pressure_hpa` | `double precision` |
| `precipitation_1h_mm` | `double precision` |
| `rainfall_1h_mm` | `double precision` |
| `snowfall_1h_mm` | `double precision` |
| `snow_depth_mm` | `double precision` |
| `wind_u_10m_ms` | `double precision` |
| `wind_v_10m_ms` | `double precision` |
| `wind_gust_10m_max_1h_ms` | `double precision` |
| `cloud_cover_pct` | `double precision` |
| `visibility_m` | `double precision` |
| `solar_radiation_w_m2` | `double precision` |
| `coverage_fraction` | `double precision` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb CONSTRAINT cell_observation_hourly_metadata_not_null NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() CONSTRAINT cell_observation_hourly_created_at_not_null NOT NULL` |
| `condition_code_id` | `smallint` |

**Declared constraints**

- `cell_observation_hourly_defau_grid_cell_id_observation_prod_key` — `UNIQUE (grid_cell_id, observation_product_id, observation_time, revision_no)`
- `cell_observation_hourly_default_pkey` — `PRIMARY KEY (cell_observation_id, observation_time)`

**Indexes**

- `cell_observation_hourly_defau_grid_cell_id_observation_prod_idx` — `USING btree (grid_cell_id, observation_product_id, observation_time DESC) WHERE (is_preferred = true)`
- `cell_observation_hourly_defau_grid_cell_id_observation_time_idx` — `USING btree (grid_cell_id, observation_time DESC)`
- `cell_observation_hourly_defau_observation_product_id_observ_idx` — `USING btree (observation_product_id, observation_time DESC)`
- `cell_observation_hourly_defau_observation_time_grid_cell_id_idx` — `USING btree (observation_time, grid_cell_id)`
- `cell_observation_hourly_default_condition_code_id_idx` — `USING btree (condition_code_id) WHERE (condition_code_id IS NOT NULL)`
- `cell_observation_hourly_default_derivation_run_id_idx` — `USING btree (derivation_run_id)`
- `cell_observation_hourly_default_ingestion_run_id_idx` — `USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL)`

## `weather.cell_observation_quality_exception`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `cell_observation_quality_exception_id` | `bigint CONSTRAINT cell_observation_quality_ex_cell_observation_quality_e_not_null NOT NULL` |
| `cell_observation_id` | `bigint NOT NULL` |
| `observation_time` | `timestamp with time zone NOT NULL` |
| `variable_id` | `bigint NOT NULL` |
| `quality_flag_id` | `smallint NOT NULL` |
| `detected_by` | `text` |
| `derivation_run_id` | `bigint` |
| `details` | `text` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `detected_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `cell_observation_quality_exception_pkey` — `PRIMARY KEY (cell_observation_quality_exception_id)`
- `cell_observation_quality_exception_unique` — `UNIQUE (cell_observation_id, observation_time, variable_id, quality_flag_id)`
- `cell_observation_quality_exception_derivation_fkey` — `FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT`
- `cell_observation_quality_exception_flag_fkey` — `FOREIGN KEY (quality_flag_id) REFERENCES weather.quality_flag(quality_flag_id) ON DELETE RESTRICT`
- `cell_observation_quality_exception_observation_fkey` — `FOREIGN KEY (cell_observation_id, observation_time) REFERENCES weather.cell_observation_hourly(cell_observation_id, observation_time) ON DELETE CASCADE`
- `cell_observation_quality_exception_variable_fkey` — `FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT`

**Indexes**

- `cell_observation_quality_exception_derivation_idx` — `USING btree (derivation_run_id) WHERE (derivation_run_id IS NOT NULL)`
- `cell_observation_quality_exception_flag_idx` — `USING btree (quality_flag_id)`
- `cell_observation_quality_exception_observation_idx` — `USING btree (cell_observation_id, observation_time)`
- `cell_observation_quality_exception_variable_idx` — `USING btree (variable_id)`

## `weather.cell_observation_value`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `cell_observation_value_id` | `bigint NOT NULL` |
| `cell_observation_id` | `bigint NOT NULL` |
| `observation_time` | `timestamp with time zone NOT NULL` |
| `variable_id` | `bigint NOT NULL` |
| `value_double` | `double precision` |
| `value_text` | `text` |
| `observation_record_status_id` | `smallint` |
| `ingestion_run_id` | `bigint` |
| `derivation_run_id` | `bigint NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `cell_observation_value_pkey` — `PRIMARY KEY (cell_observation_value_id)`
- `cell_observation_value_unique` — `UNIQUE (cell_observation_id, observation_time, variable_id)`
- `cell_observation_value_derivation_fkey` — `FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT`
- `cell_observation_value_ingestion_fkey` — `FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT`
- `cell_observation_value_observation_fkey` — `FOREIGN KEY (cell_observation_id, observation_time) REFERENCES weather.cell_observation_hourly(cell_observation_id, observation_time) ON DELETE CASCADE`
- `cell_observation_value_status_fkey` — `FOREIGN KEY (observation_record_status_id) REFERENCES weather.observation_record_status(observation_record_status_id) ON DELETE RESTRICT`
- `cell_observation_value_variable_fkey` — `FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT`

**Indexes**

- `cell_observation_value_derivation_idx` — `USING btree (derivation_run_id)`
- `cell_observation_value_ingestion_idx` — `USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL)`
- `cell_observation_value_observation_idx` — `USING btree (cell_observation_id, observation_time)`
- `cell_observation_value_variable_idx` — `USING btree (variable_id, observation_time)`

## `weather.condition_code`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `condition_code_id` | `smallint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `category` | `text NOT NULL` |
| `severity_rank` | `smallint` |
| `is_precipitating` | `boolean DEFAULT false NOT NULL` |
| `is_convective` | `boolean DEFAULT false NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `condition_code_code_unique` — `UNIQUE (code)`
- `condition_code_pkey` — `PRIMARY KEY (condition_code_id)`

**Indexes**

- `condition_code_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `condition_code_category_idx` — `USING btree (category)`

## `weather.consensus_definition`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Definition of a derived multi-model/provider consensus product.

| Column | Definition from schema |
|---|---|
| `consensus_definition_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `methodology` | `text NOT NULL` |
| `weighting_method` | `text NOT NULL` |
| `model_set_version` | `text NOT NULL` |
| `valid_from` | `timestamp with time zone` |
| `valid_to` | `timestamp with time zone` |
| `is_current` | `boolean DEFAULT false NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `consensus_definition_code_unique` — `UNIQUE (code)`
- `consensus_definition_pkey` — `PRIMARY KEY (consensus_definition_id)`

**Indexes**

- `consensus_definition_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `consensus_definition_current_idx` — `USING btree (is_current) WHERE (is_current = true)`

## `weather.consensus_definition_member`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Member models/products and configuration participating in a consensus definition.

| Column | Definition from schema |
|---|---|
| `consensus_definition_member_id` | `bigint CONSTRAINT consensus_definition_member_consensus_definition_membe_not_null NOT NULL` |
| `consensus_definition_id` | `bigint NOT NULL` |
| `forecast_product_id` | `bigint NOT NULL` |
| `weight` | `double precision` |
| `priority` | `integer` |
| `lead_minutes_start` | `integer` |
| `lead_minutes_end` | `integer` |
| `is_required` | `boolean DEFAULT false NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `consensus_definition_member_pkey` — `PRIMARY KEY (consensus_definition_member_id)`
- `consensus_definition_member_unique` — `UNIQUE (consensus_definition_id, forecast_product_id, lead_minutes_start, lead_minutes_end)`
- `consensus_definition_member_definition_fkey` — `FOREIGN KEY (consensus_definition_id) REFERENCES weather.consensus_definition(consensus_definition_id) ON DELETE CASCADE`
- `consensus_definition_member_product_fkey` — `FOREIGN KEY (forecast_product_id) REFERENCES weather.forecast_product(forecast_product_id) ON DELETE RESTRICT`

**Indexes**

- `consensus_definition_member_active_idx` — `USING btree (consensus_definition_id) WHERE (is_active = true)`
- `consensus_definition_member_definition_idx` — `USING btree (consensus_definition_id)`
- `consensus_definition_member_product_idx` — `USING btree (forecast_product_id)`

## `weather.daily_period_definition`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `daily_period_definition_id` | `smallint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `requires_timezone` | `boolean DEFAULT false NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `daily_period_definition_code_unique` — `UNIQUE (code)`
- `daily_period_definition_pkey` — `PRIMARY KEY (daily_period_definition_id)`

## `weather.dataset`

**Status:** ACTIVE / CANONICAL  
**Purpose:** Logical provider dataset identity.

| Column | Definition from schema |
|---|---|
| `dataset_id` | `bigint NOT NULL` |
| `provider_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `dataset_type` | `text NOT NULL` |
| `source_url` | `text` |
| `documentation_url` | `text` |
| `temporal_resolution` | `text` |
| `spatial_resolution` | `text` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `dataset_pkey` — `PRIMARY KEY (dataset_id)`
- `dataset_provider_code_unique` — `UNIQUE (provider_id, code)`
- `dataset_provider_fkey` — `FOREIGN KEY (provider_id) REFERENCES weather.provider(provider_id) ON DELETE RESTRICT`

**Indexes**

- `dataset_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `dataset_provider_idx` — `USING btree (provider_id)`
- `dataset_type_idx` — `USING btree (dataset_type)`

## `weather.dataset_condition_mapping`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `dataset_condition_mapping_id` | `bigint NOT NULL` |
| `dataset_version_id` | `bigint NOT NULL` |
| `condition_code_id` | `smallint NOT NULL` |
| `provider_condition_code` | `text NOT NULL` |
| `provider_condition_text` | `text` |
| `priority` | `integer DEFAULT 0 NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `dataset_condition_mapping_pkey` — `PRIMARY KEY (dataset_condition_mapping_id)`
- `dataset_condition_mapping_unique` — `UNIQUE (dataset_version_id, provider_condition_code, condition_code_id)`
- `dataset_condition_mapping_condition_fkey` — `FOREIGN KEY (condition_code_id) REFERENCES weather.condition_code(condition_code_id) ON DELETE RESTRICT`
- `dataset_condition_mapping_dataset_version_fkey` — `FOREIGN KEY (dataset_version_id) REFERENCES weather.dataset_version(dataset_version_id) ON DELETE RESTRICT`

**Indexes**

- `dataset_condition_mapping_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `dataset_condition_mapping_condition_idx` — `USING btree (condition_code_id)`
- `dataset_condition_mapping_dataset_idx` — `USING btree (dataset_version_id)`
- `dataset_condition_mapping_provider_code_idx` — `USING btree (dataset_version_id, provider_condition_code)`

## `weather.dataset_variable_mapping`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `dataset_variable_mapping_id` | `bigint NOT NULL` |
| `dataset_version_id` | `bigint NOT NULL` |
| `variable_id` | `bigint NOT NULL` |
| `provider_field_name` | `text NOT NULL` |
| `provider_field_path` | `text` |
| `source_unit_text` | `text` |
| `conversion_method` | `text` |
| `scale_factor` | `double precision` |
| `add_offset` | `double precision` |
| `missing_values` | `jsonb DEFAULT '[]'::jsonb NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `dataset_variable_mapping_pkey` — `PRIMARY KEY (dataset_variable_mapping_id)`
- `dataset_variable_mapping_unique` — `UNIQUE (dataset_version_id, provider_field_name, variable_id)`
- `dataset_variable_mapping_dataset_version_fkey` — `FOREIGN KEY (dataset_version_id) REFERENCES weather.dataset_version(dataset_version_id) ON DELETE RESTRICT`
- `dataset_variable_mapping_variable_fkey` — `FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT`

**Indexes**

- `dataset_variable_mapping_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `dataset_variable_mapping_dataset_version_idx` — `USING btree (dataset_version_id)`
- `dataset_variable_mapping_provider_field_idx` — `USING btree (dataset_version_id, provider_field_name)`
- `dataset_variable_mapping_variable_idx` — `USING btree (variable_id)`

## `weather.dataset_version`

**Status:** ACTIVE / CANONICAL  
**Purpose:** Versioned provider-dataset definition used for reproducible ingestion.

| Column | Definition from schema |
|---|---|
| `dataset_version_id` | `bigint NOT NULL` |
| `dataset_id` | `bigint NOT NULL` |
| `version_name` | `text NOT NULL` |
| `release_date` | `date` |
| `valid_from` | `timestamp with time zone` |
| `valid_to` | `timestamp with time zone` |
| `schema_version` | `text` |
| `source_url` | `text` |
| `is_current` | `boolean DEFAULT false NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `dataset_version_pkey` — `PRIMARY KEY (dataset_version_id)`
- `dataset_version_unique` — `UNIQUE (dataset_id, version_name)`
- `dataset_version_dataset_fkey` — `FOREIGN KEY (dataset_id) REFERENCES weather.dataset(dataset_id) ON DELETE RESTRICT`

**Indexes**

- `UNIQUE dataset_version_current_unique_idx` — `USING btree (dataset_id) WHERE (is_current = true)`
- `dataset_version_dataset_idx` — `USING btree (dataset_id)`

## `weather.derivation`

**Status:** ACTIVE / CANONICAL  
**Purpose:** Logical derived-product/remapping definition.

| Column | Definition from schema |
|---|---|
| `derivation_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `derivation_type` | `text NOT NULL` |
| `software_name` | `text` |
| `software_version` | `text` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `derivation_code_unique` — `UNIQUE (code)`
- `derivation_pkey` — `PRIMARY KEY (derivation_id)`

**Indexes**

- `derivation_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `derivation_type_idx` — `USING btree (derivation_type)`

## `weather.derivation_run`

**Status:** ACTIVE / CANONICAL  
**Purpose:** Execution of a derivation version.

| Column | Definition from schema |
|---|---|
| `derivation_run_id` | `bigint NOT NULL` |
| `derivation_version_id` | `bigint NOT NULL` |
| `ingestion_run_id` | `bigint` |
| `status` | `text NOT NULL` |
| `started_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `completed_at` | `timestamp with time zone` |
| `records_read` | `bigint` |
| `records_written` | `bigint` |
| `records_rejected` | `bigint` |
| `error_message` | `text` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `derivation_run_pkey` — `PRIMARY KEY (derivation_run_id)`
- `derivation_run_ingestion_run_fkey` — `FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT`
- `derivation_run_version_fkey` — `FOREIGN KEY (derivation_version_id) REFERENCES weather.derivation_version(derivation_version_id) ON DELETE RESTRICT`

**Indexes**

- `derivation_run_ingestion_idx` — `USING btree (ingestion_run_id)`
- `derivation_run_started_at_idx` — `USING btree (started_at DESC)`
- `derivation_run_status_idx` — `USING btree (status)`
- `derivation_run_version_idx` — `USING btree (derivation_version_id)`

## `weather.derivation_run_input`

**Status:** ACTIVE / CANONICAL  
**Purpose:** Inputs consumed by a derivation run; central to reproducible multi-artifact lineage.

| Column | Definition from schema |
|---|---|
| `derivation_run_input_id` | `bigint NOT NULL` |
| `derivation_run_id` | `bigint NOT NULL` |
| `ingestion_run_id` | `bigint NOT NULL` |
| `input_role` | `text DEFAULT 'source'::text NOT NULL` |
| `sequence_no` | `integer` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `derivation_run_input_pkey` — `PRIMARY KEY (derivation_run_input_id)`
- `derivation_run_input_unique` — `UNIQUE (derivation_run_id, ingestion_run_id, input_role)`
- `derivation_run_input_derivation_run_fkey` — `FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE CASCADE`
- `derivation_run_input_ingestion_run_fkey` — `FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT`

**Indexes**

- `derivation_run_input_derivation_idx` — `USING btree (derivation_run_id)`
- `derivation_run_input_ingestion_idx` — `USING btree (ingestion_run_id)`

## `weather.derivation_version`

**Status:** ACTIVE / CANONICAL  
**Purpose:** Versioned derivation methodology.

| Column | Definition from schema |
|---|---|
| `derivation_version_id` | `bigint NOT NULL` |
| `derivation_id` | `bigint NOT NULL` |
| `version_name` | `text NOT NULL` |
| `valid_from` | `timestamp with time zone` |
| `valid_to` | `timestamp with time zone` |
| `code_version` | `text` |
| `configuration` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `is_current` | `boolean DEFAULT false NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `derivation_version_pkey` — `PRIMARY KEY (derivation_version_id)`
- `derivation_version_unique` — `UNIQUE (derivation_id, version_name)`
- `derivation_version_derivation_fkey` — `FOREIGN KEY (derivation_id) REFERENCES weather.derivation(derivation_id) ON DELETE RESTRICT`

**Indexes**

- `UNIQUE derivation_version_current_unique_idx` — `USING btree (derivation_id) WHERE (is_current = true)`
- `derivation_version_derivation_idx` — `USING btree (derivation_id)`

## `weather.ensemble_probability`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `ensemble_probability_id` | `bigint NOT NULL` |
| `ensemble_summary_id` | `bigint NOT NULL` |
| `valid_time` | `timestamp with time zone NOT NULL` |
| `threshold_operator` | `text NOT NULL` |
| `threshold_value` | `double precision NOT NULL` |
| `probability` | `double precision NOT NULL` |
| `member_count` | `integer` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `ensemble_probability_pkey` — `PRIMARY KEY (ensemble_probability_id)`
- `ensemble_probability_unique` — `UNIQUE (ensemble_summary_id, valid_time, threshold_operator, threshold_value)`
- `ensemble_probability_summary_fkey` — `FOREIGN KEY (ensemble_summary_id, valid_time) REFERENCES weather.ensemble_summary(ensemble_summary_id, valid_time) ON DELETE CASCADE`

**Indexes**

- `ensemble_probability_summary_idx` — `USING btree (ensemble_summary_id, valid_time)`
- `ensemble_probability_threshold_idx` — `USING btree (threshold_operator, threshold_value)`

## `weather.ensemble_summary`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `ensemble_summary_id` | `bigint NOT NULL` |
| `forecast_run_id` | `bigint NOT NULL` |
| `forecast_product_id` | `bigint NOT NULL` |
| `grid_cell_id` | `bigint NOT NULL` |
| `variable_id` | `bigint NOT NULL` |
| `valid_time` | `timestamp with time zone NOT NULL` |
| `period_start` | `timestamp with time zone` |
| `period_end` | `timestamp with time zone` |
| `lead_minutes` | `integer NOT NULL` |
| `expected_member_count` | `integer` |
| `available_member_count` | `integer` |
| `mean_value` | `double precision` |
| `median_value` | `double precision` |
| `stddev_value` | `double precision` |
| `min_value` | `double precision` |
| `max_value` | `double precision` |
| `p10_value` | `double precision` |
| `p25_value` | `double precision` |
| `p75_value` | `double precision` |
| `p90_value` | `double precision` |
| `interquartile_range` | `double precision` |
| `ensemble_range` | `double precision` |
| `control_value` | `double precision` |
| `coverage_fraction` | `double precision` |
| `derivation_run_id` | `bigint NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `PARTITION` | `BY RANGE (valid_time);` |
| `ALTER` | `TABLE weather.ensemble_summary OWNER TO postgres;` |
| `CREATE` | `TABLE weather.ensemble_summary_default (` |
| `ensemble_summary_id` | `bigint CONSTRAINT ensemble_summary_ensemble_summary_id_not_null NOT NULL` |
| `forecast_run_id` | `bigint CONSTRAINT ensemble_summary_forecast_run_id_not_null NOT NULL` |
| `forecast_product_id` | `bigint CONSTRAINT ensemble_summary_forecast_product_id_not_null NOT NULL` |
| `grid_cell_id` | `bigint CONSTRAINT ensemble_summary_grid_cell_id_not_null NOT NULL` |
| `variable_id` | `bigint CONSTRAINT ensemble_summary_variable_id_not_null NOT NULL` |
| `valid_time` | `timestamp with time zone CONSTRAINT ensemble_summary_valid_time_not_null NOT NULL` |
| `period_start` | `timestamp with time zone` |
| `period_end` | `timestamp with time zone` |
| `lead_minutes` | `integer CONSTRAINT ensemble_summary_lead_minutes_not_null NOT NULL` |
| `expected_member_count` | `integer` |
| `available_member_count` | `integer` |
| `mean_value` | `double precision` |
| `median_value` | `double precision` |
| `stddev_value` | `double precision` |
| `min_value` | `double precision` |
| `max_value` | `double precision` |
| `p10_value` | `double precision` |
| `p25_value` | `double precision` |
| `p75_value` | `double precision` |
| `p90_value` | `double precision` |
| `interquartile_range` | `double precision` |
| `ensemble_range` | `double precision` |
| `control_value` | `double precision` |
| `coverage_fraction` | `double precision` |
| `derivation_run_id` | `bigint CONSTRAINT ensemble_summary_derivation_run_id_not_null NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb CONSTRAINT ensemble_summary_metadata_not_null NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() CONSTRAINT ensemble_summary_created_at_not_null NOT NULL` |

**Declared constraints**

- `ensemble_summary_unique` — `UNIQUE (forecast_run_id, forecast_product_id, grid_cell_id, variable_id, valid_time)`
- `ensemble_summary_pkey` — `PRIMARY KEY (ensemble_summary_id, valid_time)`

## `weather.forecast_correction_reason`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `forecast_correction_reason_id` | `smallint CONSTRAINT forecast_correction_reason_forecast_correction_reason__not_null NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `correction_source` | `text NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `forecast_correction_reason_code_unique` — `UNIQUE (code)`
- `forecast_correction_reason_pkey` — `PRIMARY KEY (forecast_correction_reason_id)`

## `weather.forecast_member`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `forecast_member_id` | `bigint NOT NULL` |
| `forecast_run_id` | `bigint NOT NULL` |
| `member_type` | `text NOT NULL` |
| `member_number` | `integer` |
| `member_code` | `text` |
| `name` | `text` |
| `is_control` | `boolean DEFAULT false NOT NULL` |
| `is_deterministic` | `boolean DEFAULT false NOT NULL` |
| `is_available` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `forecast_member_id_run_unique` — `UNIQUE (forecast_member_id, forecast_run_id)`
- `forecast_member_pkey` — `PRIMARY KEY (forecast_member_id)`
- `forecast_member_run_fkey` — `FOREIGN KEY (forecast_run_id) REFERENCES weather.forecast_run(forecast_run_id) ON DELETE CASCADE`

**Indexes**

- `UNIQUE forecast_member_one_control_idx` — `USING btree (forecast_run_id) WHERE (is_control = true)`
- `UNIQUE forecast_member_one_deterministic_idx` — `USING btree (forecast_run_id) WHERE (is_deterministic = true)`
- `UNIQUE forecast_member_run_code_unique_idx` — `USING btree (forecast_run_id, member_code) WHERE (member_code IS NOT NULL)`
- `forecast_member_run_idx` — `USING btree (forecast_run_id)`
- `UNIQUE forecast_member_run_number_unique_idx` — `USING btree (forecast_run_id, member_number) WHERE (member_number IS NOT NULL)`
- `forecast_member_type_idx` — `USING btree (member_type)`

## `weather.forecast_model`

**Status:** ACTIVE / CANONICAL  
**Purpose:** Logical forecast model identity (for example GFS/GEFS/HRRR).

| Column | Definition from schema |
|---|---|
| `forecast_model_id` | `bigint NOT NULL` |
| `provider_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `model_scope` | `text NOT NULL` |
| `model_class` | `text NOT NULL` |
| `supports_deterministic` | `boolean DEFAULT false NOT NULL` |
| `supports_ensemble` | `boolean DEFAULT false NOT NULL` |
| `normal_horizon_minutes` | `integer` |
| `scheduled_cycle_minutes` | `integer` |
| `operational_status` | `text` |
| `operating_from` | `date` |
| `operating_to` | `date` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `forecast_model_pkey` — `PRIMARY KEY (forecast_model_id)`
- `forecast_model_provider_code_unique` — `UNIQUE (provider_id, code)`
- `forecast_model_provider_fkey` — `FOREIGN KEY (provider_id) REFERENCES weather.provider(provider_id) ON DELETE RESTRICT`

**Indexes**

- `forecast_model_provider_idx` — `USING btree (provider_id)`
- `forecast_model_scope_idx` — `USING btree (model_scope)`
- `forecast_model_status_idx` — `USING btree (operational_status)`

## `weather.forecast_model_version`

**Status:** ACTIVE / CANONICAL  
**Purpose:** Version/configuration of a forecast model.

| Column | Definition from schema |
|---|---|
| `forecast_model_version_id` | `bigint NOT NULL` |
| `forecast_model_id` | `bigint NOT NULL` |
| `version_code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `provider_version` | `text` |
| `grid_version` | `text` |
| `physics_version` | `text` |
| `ensemble_configuration` | `text` |
| `vertical_configuration` | `text` |
| `operational_from` | `timestamp with time zone` |
| `operational_to` | `timestamp with time zone` |
| `documentation_url` | `text` |
| `is_current` | `boolean DEFAULT false NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `forecast_model_version_pkey` — `PRIMARY KEY (forecast_model_version_id)`
- `forecast_model_version_unique` — `UNIQUE (forecast_model_id, version_code)`
- `forecast_model_version_model_fkey` — `FOREIGN KEY (forecast_model_id) REFERENCES weather.forecast_model(forecast_model_id) ON DELETE RESTRICT`

**Indexes**

- `UNIQUE forecast_model_version_current_unique_idx` — `USING btree (forecast_model_id) WHERE (is_current = true)`
- `forecast_model_version_model_idx` — `USING btree (forecast_model_id)`

## `weather.forecast_product`

**Status:** ACTIVE / CANONICAL  
**Purpose:** Logical forecast product definition.

| Column | Definition from schema |
|---|---|
| `forecast_product_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `product_type` | `text NOT NULL` |
| `forecast_model_version_id` | `bigint` |
| `dataset_version_id` | `bigint` |
| `derivation_version_id` | `bigint` |
| `forecast_class` | `text NOT NULL` |
| `temporal_grain` | `text` |
| `is_native_provider_product` | `boolean DEFAULT false NOT NULL` |
| `is_canonical_h3_product` | `boolean DEFAULT false NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `forecast_product_code_unique` — `UNIQUE (code)`
- `forecast_product_pkey` — `PRIMARY KEY (forecast_product_id)`
- `forecast_product_dataset_version_fkey` — `FOREIGN KEY (dataset_version_id) REFERENCES weather.dataset_version(dataset_version_id) ON DELETE RESTRICT`
- `forecast_product_derivation_version_fkey` — `FOREIGN KEY (derivation_version_id) REFERENCES weather.derivation_version(derivation_version_id) ON DELETE RESTRICT`
- `forecast_product_model_version_fkey` — `FOREIGN KEY (forecast_model_version_id) REFERENCES weather.forecast_model_version(forecast_model_version_id) ON DELETE RESTRICT`

**Indexes**

- `forecast_product_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `forecast_product_class_idx` — `USING btree (forecast_class)`
- `forecast_product_dataset_version_idx` — `USING btree (dataset_version_id)`
- `forecast_product_derivation_version_idx` — `USING btree (derivation_version_id)`
- `forecast_product_model_version_idx` — `USING btree (forecast_model_version_id)`

## `weather.forecast_revision_definition`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `forecast_revision_definition_id` | `bigint CONSTRAINT forecast_revision_definitio_forecast_revision_definiti_not_null NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `comparison_type` | `text NOT NULL` |
| `calculation_version` | `text NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `forecast_revision_definition_code_unique` — `UNIQUE (code)`
- `forecast_revision_definition_pkey` — `PRIMARY KEY (forecast_revision_definition_id)`

## `weather.forecast_run`

**Status:** ACTIVE / CANONICAL  
**Purpose:** One logical forecast initialization/run. Historical forecast vintages are immutable; revisions/corrections are preserved rather than overwritten.

| Column | Definition from schema |
|---|---|
| `forecast_run_id` | `bigint NOT NULL` |
| `forecast_product_id` | `bigint NOT NULL` |
| `forecast_model_version_id` | `bigint NOT NULL` |
| `initialization_time` | `timestamp with time zone NOT NULL` |
| `cycle_code` | `text` |
| `run_kind` | `text NOT NULL` |
| `provider_revision` | `text` |
| `provider_published_at` | `timestamp with time zone` |
| `first_retrieved_at` | `timestamp with time zone` |
| `horizon_minutes` | `integer` |
| `expected_member_count` | `integer` |
| `received_member_count` | `integer` |
| `expected_step_count` | `integer` |
| `received_step_count` | `integer` |
| `completeness_fraction` | `double precision` |
| `run_status` | `text NOT NULL` |
| `operational_status` | `text` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `forecast_run_expectation_id` | `bigint` |

**Declared constraints**

- `forecast_run_id_product_unique` — `UNIQUE (forecast_run_id, forecast_product_id)`
- `forecast_run_identity_unique` — `UNIQUE NULLS NOT DISTINCT (forecast_product_id, forecast_model_version_id, initialization_time, provider_revision)`
- `forecast_run_pkey` — `PRIMARY KEY (forecast_run_id)`
- `forecast_run_expectation_fkey` — `FOREIGN KEY (forecast_run_expectation_id) REFERENCES weather.forecast_run_expectation(forecast_run_expectation_id) ON DELETE RESTRICT`
- `forecast_run_model_version_fkey` — `FOREIGN KEY (forecast_model_version_id) REFERENCES weather.forecast_model_version(forecast_model_version_id) ON DELETE RESTRICT`
- `forecast_run_product_fkey` — `FOREIGN KEY (forecast_product_id) REFERENCES weather.forecast_product(forecast_product_id) ON DELETE RESTRICT`

**Indexes**

- `forecast_run_expectation_idx` — `USING btree (forecast_run_expectation_id) WHERE (forecast_run_expectation_id IS NOT NULL)`
- `forecast_run_initialization_time_idx` — `USING btree (initialization_time DESC)`
- `forecast_run_model_version_time_idx` — `USING btree (forecast_model_version_id, initialization_time DESC)`
- `forecast_run_product_time_idx` — `USING btree (forecast_product_id, initialization_time DESC)`
- `forecast_run_status_idx` — `USING btree (run_status)`

## `weather.forecast_run_expectation`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Defines expected contents/completeness scope for a forecast run.

| Column | Definition from schema |
|---|---|
| `forecast_run_expectation_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `forecast_product_id` | `bigint` |
| `forecast_model_version_id` | `bigint` |
| `expectation_version` | `text NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `forecast_run_expectation_code_unique` — `UNIQUE (code)`
- `forecast_run_expectation_pkey` — `PRIMARY KEY (forecast_run_expectation_id)`
- `forecast_run_expectation_model_version_fkey` — `FOREIGN KEY (forecast_model_version_id) REFERENCES weather.forecast_model_version(forecast_model_version_id) ON DELETE RESTRICT`
- `forecast_run_expectation_product_fkey` — `FOREIGN KEY (forecast_product_id) REFERENCES weather.forecast_product(forecast_product_id) ON DELETE RESTRICT`

**Indexes**

- `forecast_run_expectation_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `forecast_run_expectation_model_version_idx` — `USING btree (forecast_model_version_id)`
- `forecast_run_expectation_product_idx` — `USING btree (forecast_product_id)`

## `weather.forecast_run_expectation_item`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Individual expectation items; future completeness must account for step, target population, required variables and source windows/target-set version.

| Column | Definition from schema |
|---|---|
| `forecast_run_expectation_item_id` | `bigint CONSTRAINT forecast_run_expectation_it_forecast_run_expectation_i_not_null NOT NULL` |
| `forecast_run_expectation_id` | `bigint CONSTRAINT forecast_run_expectation_i_forecast_run_expectation_i_not_null1 NOT NULL` |
| `item_type` | `text NOT NULL` |
| `item_code` | `text NOT NULL` |
| `member_type` | `text` |
| `member_number` | `integer` |
| `lead_minutes` | `integer` |
| `variable_id` | `bigint` |
| `is_required` | `boolean DEFAULT true NOT NULL` |
| `expected_count` | `integer DEFAULT 1 NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `forecast_run_expectation_item_pkey` — `PRIMARY KEY (forecast_run_expectation_item_id)`
- `forecast_run_expectation_item_expectation_fkey` — `FOREIGN KEY (forecast_run_expectation_id) REFERENCES weather.forecast_run_expectation(forecast_run_expectation_id) ON DELETE CASCADE`
- `forecast_run_expectation_item_variable_fkey` — `FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT`

**Indexes**

- `forecast_run_expectation_item_expectation_idx` — `USING btree (forecast_run_expectation_id)`
- `forecast_run_expectation_item_lead_idx` — `USING btree (lead_minutes) WHERE (lead_minutes IS NOT NULL)`
- `forecast_run_expectation_item_type_idx` — `USING btree (item_type)`
- `forecast_run_expectation_item_variable_idx` — `USING btree (variable_id) WHERE (variable_id IS NOT NULL)`

## `weather.forecast_run_ingestion`

**Status:** ACTIVE / CANONICAL  
**Purpose:** Links one logical forecast run to the ingestion runs that supplied it; essential for multi-window acquisition.

| Column | Definition from schema |
|---|---|
| `forecast_run_ingestion_id` | `bigint NOT NULL` |
| `forecast_run_id` | `bigint NOT NULL` |
| `ingestion_run_id` | `bigint NOT NULL` |
| `input_role` | `text DEFAULT 'source'::text NOT NULL` |
| `sequence_no` | `integer` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `forecast_run_ingestion_pkey` — `PRIMARY KEY (forecast_run_ingestion_id)`
- `forecast_run_ingestion_unique` — `UNIQUE (forecast_run_id, ingestion_run_id, input_role)`
- `forecast_run_ingestion_ingestion_fkey` — `FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT`
- `forecast_run_ingestion_run_fkey` — `FOREIGN KEY (forecast_run_id) REFERENCES weather.forecast_run(forecast_run_id) ON DELETE CASCADE`

**Indexes**

- `forecast_run_ingestion_ingestion_idx` — `USING btree (ingestion_run_id)`
- `forecast_run_ingestion_run_idx` — `USING btree (forecast_run_id)`

## `weather.forecast_verification`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Forecast-vs-observation verification results.

| Column | Definition from schema |
|---|---|
| `forecast_verification_id` | `bigint NOT NULL` |
| `verification_definition_id` | `bigint NOT NULL` |
| `cell_forecast_id` | `bigint NOT NULL` |
| `forecast_valid_time` | `timestamp with time zone NOT NULL` |
| `cell_observation_id` | `bigint NOT NULL` |
| `observation_time` | `timestamp with time zone NOT NULL` |
| `forecast_run_id` | `bigint NOT NULL` |
| `forecast_product_id` | `bigint NOT NULL` |
| `observation_product_id` | `bigint NOT NULL` |
| `grid_cell_id` | `bigint NOT NULL` |
| `variable_id` | `bigint NOT NULL` |
| `lead_minutes` | `integer NOT NULL` |
| `period_start` | `timestamp with time zone` |
| `period_end` | `timestamp with time zone` |
| `forecast_value` | `double precision NOT NULL` |
| `observed_value` | `double precision NOT NULL` |
| `error` | `double precision NOT NULL` |
| `absolute_error` | `double precision NOT NULL` |
| `squared_error` | `double precision NOT NULL` |
| `derivation_run_id` | `bigint` |
| `verified_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `forecast_verification_pkey` — `PRIMARY KEY (forecast_verification_id)`
- `forecast_verification_unique` — `UNIQUE (verification_definition_id, cell_forecast_id, forecast_valid_time, cell_observation_id, observation_time, variable_id)`
- `forecast_verification_definition_fkey` — `FOREIGN KEY (verification_definition_id) REFERENCES weather.verification_definition(verification_definition_id) ON DELETE RESTRICT`
- `forecast_verification_derivation_fkey` — `FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT`
- `forecast_verification_forecast_fkey` — `FOREIGN KEY (cell_forecast_id, forecast_valid_time) REFERENCES weather.cell_forecast(cell_forecast_id, valid_time) ON DELETE RESTRICT`
- `forecast_verification_forecast_product_fkey` — `FOREIGN KEY (forecast_product_id) REFERENCES weather.forecast_product(forecast_product_id) ON DELETE RESTRICT`
- `forecast_verification_grid_cell_fkey` — `FOREIGN KEY (grid_cell_id) REFERENCES weather.grid_cell(grid_cell_id) ON DELETE RESTRICT`
- `forecast_verification_observation_fkey` — `FOREIGN KEY (cell_observation_id, observation_time) REFERENCES weather.cell_observation_hourly(cell_observation_id, observation_time) ON DELETE RESTRICT`
- `forecast_verification_observation_product_fkey` — `FOREIGN KEY (observation_product_id) REFERENCES weather.observation_product(observation_product_id) ON DELETE RESTRICT`
- `forecast_verification_run_fkey` — `FOREIGN KEY (forecast_run_id) REFERENCES weather.forecast_run(forecast_run_id) ON DELETE RESTRICT`
- `forecast_verification_variable_fkey` — `FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT`

**Indexes**

- `forecast_verification_cell_time_idx` — `USING btree (grid_cell_id, forecast_valid_time)`
- `forecast_verification_definition_idx` — `USING btree (verification_definition_id)`
- `forecast_verification_forecast_product_idx` — `USING btree (forecast_product_id)`
- `forecast_verification_observation_product_idx` — `USING btree (observation_product_id)`
- `forecast_verification_run_idx` — `USING btree (forecast_run_id)`
- `forecast_verification_variable_lead_idx` — `USING btree (variable_id, lead_minutes)`
- `forecast_verification_verified_at_idx` — `USING btree (verified_at DESC)`

## `weather.forecast_verification_summary`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Aggregated forecast skill/verification statistics.

| Column | Definition from schema |
|---|---|
| `forecast_verification_summary_id` | `bigint CONSTRAINT forecast_verification_summa_forecast_verification_summ_not_null NOT NULL` |
| `verification_definition_id` | `bigint CONSTRAINT forecast_verification_summa_verification_definition_id_not_null NOT NULL` |
| `forecast_product_id` | `bigint NOT NULL` |
| `observation_product_id` | `bigint NOT NULL` |
| `variable_id` | `bigint NOT NULL` |
| `grid_cell_id` | `bigint` |
| `lead_band_minutes_start` | `integer` |
| `lead_band_minutes_end` | `integer` |
| `verification_period_start` | `timestamp with time zone CONSTRAINT forecast_verification_summar_verification_period_start_not_null NOT NULL` |
| `verification_period_end` | `timestamp with time zone NOT NULL` |
| `sample_count` | `bigint NOT NULL` |
| `mean_error` | `double precision` |
| `mean_absolute_error` | `double precision` |
| `root_mean_squared_error` | `double precision` |
| `correlation` | `double precision` |
| `mean_forecast_value` | `double precision` |
| `mean_observed_value` | `double precision` |
| `min_error` | `double precision` |
| `max_error` | `double precision` |
| `derivation_run_id` | `bigint` |
| `calculation_version` | `text NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `calculated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `forecast_verification_summary_pkey` — `PRIMARY KEY (forecast_verification_summary_id)`
- `forecast_verification_summary_definition_fkey` — `FOREIGN KEY (verification_definition_id) REFERENCES weather.verification_definition(verification_definition_id) ON DELETE RESTRICT`
- `forecast_verification_summary_derivation_fkey` — `FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT`
- `forecast_verification_summary_forecast_product_fkey` — `FOREIGN KEY (forecast_product_id) REFERENCES weather.forecast_product(forecast_product_id) ON DELETE RESTRICT`
- `forecast_verification_summary_grid_cell_fkey` — `FOREIGN KEY (grid_cell_id) REFERENCES weather.grid_cell(grid_cell_id) ON DELETE RESTRICT`
- `forecast_verification_summary_observation_product_fkey` — `FOREIGN KEY (observation_product_id) REFERENCES weather.observation_product(observation_product_id) ON DELETE RESTRICT`
- `forecast_verification_summary_variable_fkey` — `FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT`

**Indexes**

- `forecast_verification_summary_cell_idx` — `USING btree (grid_cell_id) WHERE (grid_cell_id IS NOT NULL)`
- `forecast_verification_summary_definition_idx` — `USING btree (verification_definition_id)`
- `forecast_verification_summary_lead_idx` — `USING btree (lead_band_minutes_start, lead_band_minutes_end)`
- `forecast_verification_summary_observation_product_idx` — `USING btree (observation_product_id)`
- `forecast_verification_summary_period_idx` — `USING btree (verification_period_start, verification_period_end)`
- `forecast_verification_summary_product_variable_idx` — `USING btree (forecast_product_id, variable_id)`

## `weather.grid_cell`

**Status:** ACTIVE / CANONICAL  
**Purpose:** Canonical weather analysis cells. Provider-native grids do not define Aurion target geography. Each row stores H3 index/resolution, centre Point and boundary MultiPolygon.

| Column | Definition from schema |
|---|---|
| `grid_cell_id` | `bigint NOT NULL` |
| `grid_system_id` | `bigint NOT NULL` |
| `h3_index` | `public.h3index NOT NULL` |
| `resolution` | `smallint NOT NULL` |
| `center` | `public.geometry(Point,4326) NOT NULL` |
| `boundary` | `public.geometry(MultiPolygon,4326) NOT NULL` |
| `is_pentagon` | `boolean DEFAULT false NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `grid_cell_h3_unique` — `UNIQUE (grid_system_id, h3_index)`
- `grid_cell_pkey` — `PRIMARY KEY (grid_cell_id)`
- `grid_cell_grid_system_fkey` — `FOREIGN KEY (grid_system_id) REFERENCES weather.grid_system(grid_system_id) ON DELETE RESTRICT`

**Indexes**

- `grid_cell_boundary_gix` — `USING gist (boundary)`
- `grid_cell_center_gix` — `USING gist (center)`
- `grid_cell_grid_system_idx` — `USING btree (grid_system_id)`
- `grid_cell_resolution_idx` — `USING btree (resolution)`

## `weather.grid_system`

**Status:** ACTIVE / CANONICAL  
**Purpose:** Catalogue of canonical spatial grid systems used by Weather. Current implementation uses H3; this separates grid identity/version metadata from individual cells.

| Column | Definition from schema |
|---|---|
| `grid_system_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `provider_name` | `text` |
| `version` | `text` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `grid_system_code_unique` — `UNIQUE (code)`
- `grid_system_pkey` — `PRIMARY KEY (grid_system_id)`

**Indexes**

- `grid_system_active_idx` — `USING btree (is_active) WHERE (is_active = true)`

## `weather.ingestion_run`

**Status:** ACTIVE / CANONICAL  
**Purpose:** Execution-level ingestion provenance.

| Column | Definition from schema |
|---|---|
| `ingestion_run_id` | `bigint NOT NULL` |
| `dataset_version_id` | `bigint NOT NULL` |
| `source_artifact_id` | `bigint` |
| `run_type` | `text NOT NULL` |
| `status` | `text NOT NULL` |
| `started_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `completed_at` | `timestamp with time zone` |
| `records_read` | `bigint` |
| `records_written` | `bigint` |
| `records_rejected` | `bigint` |
| `error_message` | `text` |
| `software_version` | `text` |
| `pipeline_version` | `text` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `ingestion_run_pkey` — `PRIMARY KEY (ingestion_run_id)`
- `ingestion_run_dataset_version_fkey` — `FOREIGN KEY (dataset_version_id) REFERENCES weather.dataset_version(dataset_version_id) ON DELETE RESTRICT`
- `ingestion_run_source_artifact_fkey` — `FOREIGN KEY (source_artifact_id) REFERENCES weather.source_artifact(source_artifact_id) ON DELETE RESTRICT`

**Indexes**

- `ingestion_run_dataset_version_idx` — `USING btree (dataset_version_id)`
- `ingestion_run_source_artifact_idx` — `USING btree (source_artifact_id)`
- `ingestion_run_started_at_idx` — `USING btree (started_at DESC)`
- `ingestion_run_status_idx` — `USING btree (status)`

## `weather.observation_correction_reason`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `observation_correction_reason_id` | `smallint CONSTRAINT observation_correction_reas_observation_correction_rea_not_null NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `correction_source` | `text NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `observation_correction_reason_code_unique` — `UNIQUE (code)`
- `observation_correction_reason_pkey` — `PRIMARY KEY (observation_correction_reason_id)`

## `weather.observation_product`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `observation_product_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `product_type` | `text NOT NULL` |
| `dataset_version_id` | `bigint` |
| `derivation_version_id` | `bigint` |
| `temporal_grain` | `text` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `daily_period_definition_id` | `smallint` |
| `calendar_timezone` | `text` |

**Declared constraints**

- `observation_product_code_unique` — `UNIQUE (code)`
- `observation_product_pkey` — `PRIMARY KEY (observation_product_id)`
- `observation_product_daily_period_definition_fkey` — `FOREIGN KEY (daily_period_definition_id) REFERENCES weather.daily_period_definition(daily_period_definition_id) ON DELETE RESTRICT`
- `observation_product_dataset_version_fkey` — `FOREIGN KEY (dataset_version_id) REFERENCES weather.dataset_version(dataset_version_id) ON DELETE RESTRICT`
- `observation_product_derivation_version_fkey` — `FOREIGN KEY (derivation_version_id) REFERENCES weather.derivation_version(derivation_version_id) ON DELETE RESTRICT`

**Indexes**

- `observation_product_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `observation_product_daily_period_definition_idx` — `USING btree (daily_period_definition_id)`
- `observation_product_dataset_version_idx` — `USING btree (dataset_version_id)`
- `observation_product_derivation_version_idx` — `USING btree (derivation_version_id)`
- `observation_product_type_idx` — `USING btree (product_type)`

## `weather.observation_record_status`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `observation_record_status_id` | `smallint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `is_preferred` | `boolean DEFAULT true NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `observation_record_status_code_unique` — `UNIQUE (code)`
- `observation_record_status_pkey` — `PRIMARY KEY (observation_record_status_id)`

## `weather.provider`

**Status:** ACTIVE / CANONICAL  
**Purpose:** Weather data provider identity.

| Column | Definition from schema |
|---|---|
| `provider_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `organisation_url` | `text` |
| `country_code` | `character(2)` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `provider_code_unique` — `UNIQUE (code)`
- `provider_pkey` — `PRIMARY KEY (provider_id)`

**Indexes**

- `provider_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `provider_lower_name_idx` — `USING btree (lower(name))`

## `weather.quality_flag`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `quality_flag_id` | `smallint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `severity` | `text` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `quality_flag_code_unique` — `UNIQUE (code)`
- `quality_flag_pkey` — `PRIMARY KEY (quality_flag_id)`

## `weather.source_artifact`

**Status:** ACTIVE / CANONICAL  
**Purpose:** Physical/source artifact provenance record (for example a downloaded native model subset/file). Large native artifacts need not be expanded into raw PostgreSQL rows.

| Column | Definition from schema |
|---|---|
| `source_artifact_id` | `bigint NOT NULL` |
| `dataset_version_id` | `bigint NOT NULL` |
| `artifact_type` | `text NOT NULL` |
| `source_uri` | `text` |
| `filename` | `text` |
| `content_type` | `text` |
| `compression_type` | `text` |
| `size_bytes` | `bigint` |
| `checksum_sha256` | `text` |
| `provider_created_at` | `timestamp with time zone` |
| `discovered_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `storage_tier` | `text` |
| `storage_uri` | `text` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `source_artifact_pkey` — `PRIMARY KEY (source_artifact_id)`
- `source_artifact_dataset_version_fkey` — `FOREIGN KEY (dataset_version_id) REFERENCES weather.dataset_version(dataset_version_id) ON DELETE RESTRICT`

**Indexes**

- `source_artifact_checksum_idx` — `USING btree (checksum_sha256) WHERE (checksum_sha256 IS NOT NULL)`
- `source_artifact_dataset_version_idx` — `USING btree (dataset_version_id)`
- `source_artifact_provider_created_at_idx` — `USING btree (provider_created_at)`

## `weather.station`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Stable station identity.

| Column | Definition from schema |
|---|---|
| `station_id` | `bigint NOT NULL` |
| `canonical_name` | `text NOT NULL` |
| `station_type` | `text` |
| `country_code` | `character(2)` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `station_pkey` — `PRIMARY KEY (station_id)`

**Indexes**

- `station_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `station_country_idx` — `USING btree (country_code)`
- `station_lower_name_idx` — `USING btree (lower(canonical_name))`

## `weather.station_h3_map`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Maps stations to canonical H3/grid cells.

| Column | Definition from schema |
|---|---|
| `station_h3_map_id` | `bigint NOT NULL` |
| `station_history_id` | `bigint NOT NULL` |
| `grid_cell_id` | `bigint NOT NULL` |
| `mapping_method` | `text DEFAULT 'point_to_cell'::text NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `station_h3_map_pkey` — `PRIMARY KEY (station_h3_map_id)`
- `station_h3_map_unique` — `UNIQUE (station_history_id, grid_cell_id)`
- `station_h3_map_grid_cell_fkey` — `FOREIGN KEY (grid_cell_id) REFERENCES weather.grid_cell(grid_cell_id) ON DELETE RESTRICT`
- `station_h3_map_station_history_fkey` — `FOREIGN KEY (station_history_id) REFERENCES weather.station_history(station_history_id) ON DELETE CASCADE`

**Indexes**

- `station_h3_map_grid_cell_idx` — `USING btree (grid_cell_id)`
- `station_h3_map_station_history_idx` — `USING btree (station_history_id)`

## `weather.station_history`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Version/history of station metadata and location over time.

| Column | Definition from schema |
|---|---|
| `station_history_id` | `bigint NOT NULL` |
| `station_id` | `bigint NOT NULL` |
| `valid_from` | `timestamp with time zone NOT NULL` |
| `valid_to` | `timestamp with time zone` |
| `position` | `public.geometry(Point,4326) NOT NULL` |
| `elevation_m` | `double precision` |
| `timezone_name` | `text` |
| `operating_status` | `text` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `station_history_id_station_unique` — `UNIQUE (station_history_id, station_id)`
- `station_history_pkey` — `PRIMARY KEY (station_history_id)`
- `station_history_station_fkey` — `FOREIGN KEY (station_id) REFERENCES weather.station(station_id) ON DELETE CASCADE`

**Indexes**

- `station_history_position_gix` — `USING gist ("position")`
- `station_history_station_idx` — `USING btree (station_id)`
- `station_history_validity_idx` — `USING btree (station_id, valid_from, valid_to)`

## `weather.station_identifier`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `station_identifier_id` | `bigint NOT NULL` |
| `station_id` | `bigint NOT NULL` |
| `identifier_scheme` | `text NOT NULL` |
| `identifier_value` | `text NOT NULL` |
| `provider_id` | `bigint` |
| `station_network_id` | `bigint` |
| `is_primary` | `boolean DEFAULT false NOT NULL` |
| `valid_from` | `timestamp with time zone` |
| `valid_to` | `timestamp with time zone` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `station_identifier_external_unique` — `UNIQUE NULLS NOT DISTINCT (identifier_scheme, identifier_value, provider_id, station_network_id)`
- `station_identifier_pkey` — `PRIMARY KEY (station_identifier_id)`
- `station_identifier_network_fkey` — `FOREIGN KEY (station_network_id) REFERENCES weather.station_network(station_network_id) ON DELETE RESTRICT`
- `station_identifier_provider_fkey` — `FOREIGN KEY (provider_id) REFERENCES weather.provider(provider_id) ON DELETE RESTRICT`
- `station_identifier_station_fkey` — `FOREIGN KEY (station_id) REFERENCES weather.station(station_id) ON DELETE CASCADE`

**Indexes**

- `UNIQUE station_identifier_primary_unique_idx` — `USING btree (station_id, identifier_scheme) WHERE (is_primary = true)`
- `station_identifier_scheme_value_idx` — `USING btree (identifier_scheme, identifier_value)`
- `station_identifier_station_idx` — `USING btree (station_id)`

## `weather.station_network`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `station_network_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `provider_id` | `bigint` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `station_network_code_unique` — `UNIQUE (code)`
- `station_network_pkey` — `PRIMARY KEY (station_network_id)`
- `station_network_provider_fkey` — `FOREIGN KEY (provider_id) REFERENCES weather.provider(provider_id) ON DELETE RESTRICT`

**Indexes**

- `station_network_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `station_network_provider_idx` — `USING btree (provider_id)`

## `weather.station_network_membership`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `station_network_membership_id` | `bigint CONSTRAINT station_network_membership_station_network_membership__not_null NOT NULL` |
| `station_id` | `bigint NOT NULL` |
| `station_network_id` | `bigint NOT NULL` |
| `valid_from` | `timestamp with time zone` |
| `valid_to` | `timestamp with time zone` |
| `is_primary` | `boolean DEFAULT false NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `station_network_membership_pkey` — `PRIMARY KEY (station_network_membership_id)`
- `station_network_membership_unique` — `UNIQUE NULLS NOT DISTINCT (station_id, station_network_id, valid_from)`
- `station_network_membership_network_fkey` — `FOREIGN KEY (station_network_id) REFERENCES weather.station_network(station_network_id) ON DELETE RESTRICT`
- `station_network_membership_station_fkey` — `FOREIGN KEY (station_id) REFERENCES weather.station(station_id) ON DELETE CASCADE`

## `weather.station_observation_correction`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `station_observation_correction_id` | `bigint CONSTRAINT station_observation_correct_station_observation_correc_not_null NOT NULL` |
| `original_observation_id` | `bigint NOT NULL` |
| `original_observation_time` | `timestamp with time zone CONSTRAINT station_observation_correcti_original_observation_time_not_null NOT NULL` |
| `replacement_observation_id` | `bigint CONSTRAINT station_observation_correct_replacement_observation_id_not_null NOT NULL` |
| `replacement_observation_time` | `timestamp with time zone CONSTRAINT station_observation_correct_replacement_observation_ti_not_null NOT NULL` |
| `observation_correction_reason_id` | `smallint CONSTRAINT station_observation_correct_observation_correction_rea_not_null NOT NULL` |
| `source_artifact_id` | `bigint` |
| `derivation_run_id` | `bigint` |
| `correction_time` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `notes` | `text` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `station_observation_correction_pkey` — `PRIMARY KEY (station_observation_correction_id)`
- `station_observation_correction_unique` — `UNIQUE (original_observation_id, original_observation_time, replacement_observation_id, replacement_observation_time)`
- `station_observation_correction_artifact_fkey` — `FOREIGN KEY (source_artifact_id) REFERENCES weather.source_artifact(source_artifact_id) ON DELETE RESTRICT`
- `station_observation_correction_derivation_fkey` — `FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT`
- `station_observation_correction_original_fkey` — `FOREIGN KEY (original_observation_id, original_observation_time) REFERENCES weather.station_observation_hourly(station_observation_id, observation_time) ON DELETE RESTRICT`
- `station_observation_correction_reason_fkey` — `FOREIGN KEY (observation_correction_reason_id) REFERENCES weather.observation_correction_reason(observation_correction_reason_id) ON DELETE RESTRICT`
- `station_observation_correction_replacement_fkey` — `FOREIGN KEY (replacement_observation_id, replacement_observation_time) REFERENCES weather.station_observation_hourly(station_observation_id, observation_time) ON DELETE RESTRICT`

**Indexes**

- `station_observation_correction_original_idx` — `USING btree (original_observation_id, original_observation_time)`
- `station_observation_correction_replacement_idx` — `USING btree (replacement_observation_id, replacement_observation_time)`

## `weather.station_observation_daily`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `station_observation_daily_id` | `bigint NOT NULL` |
| `observation_date` | `date NOT NULL` |
| `station_id` | `bigint NOT NULL` |
| `station_history_id` | `bigint NOT NULL` |
| `observation_product_id` | `bigint NOT NULL` |
| `observation_record_status_id` | `smallint NOT NULL` |
| `ingestion_run_id` | `bigint` |
| `derivation_run_id` | `bigint` |
| `period_start` | `timestamp with time zone NOT NULL` |
| `period_end` | `timestamp with time zone NOT NULL` |
| `provider_published_at` | `timestamp with time zone` |
| `received_at` | `timestamp with time zone` |
| `ingested_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `revision_no` | `integer DEFAULT 1 NOT NULL` |
| `is_preferred` | `boolean DEFAULT true NOT NULL` |
| `supersedes_observation_daily_id` | `bigint` |
| `supersedes_observation_date` | `date` |
| `air_temperature_2m_min_c` | `double precision` |
| `air_temperature_2m_max_c` | `double precision` |
| `air_temperature_2m_mean_c` | `double precision` |
| `apparent_temperature_2m_min_c` | `double precision` |
| `apparent_temperature_2m_max_c` | `double precision` |
| `apparent_temperature_2m_mean_c` | `double precision` |
| `dew_point_2m_min_c` | `double precision` |
| `dew_point_2m_max_c` | `double precision` |
| `dew_point_2m_mean_c` | `double precision` |
| `relative_humidity_2m_min_pct` | `double precision` |
| `relative_humidity_2m_max_pct` | `double precision` |
| `relative_humidity_2m_mean_pct` | `double precision` |
| `surface_pressure_mean_hpa` | `double precision` |
| `precipitation_total_mm` | `double precision` |
| `rainfall_total_mm` | `double precision` |
| `snowfall_total_mm` | `double precision` |
| `snow_depth_max_mm` | `double precision` |
| `wind_u_10m_mean_ms` | `double precision` |
| `wind_v_10m_mean_ms` | `double precision` |
| `wind_gust_10m_max_ms` | `double precision` |
| `cloud_cover_mean_pct` | `double precision` |
| `visibility_mean_m` | `double precision` |
| `solar_radiation_mean_w_m2` | `double precision` |
| `sample_count` | `integer` |
| `coverage_fraction` | `double precision` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `PARTITION` | `BY RANGE (observation_date);` |
| `ALTER` | `TABLE weather.station_observation_daily OWNER TO postgres;` |
| `CREATE` | `TABLE weather.station_observation_daily_correction (` |
| `station_observation_daily_correction_id` | `bigint CONSTRAINT station_observation_daily_c_station_observation_daily__not_null NOT NULL` |
| `original_observation_daily_id` | `bigint CONSTRAINT station_observation_daily_c_original_observation_daily_not_null NOT NULL` |
| `original_observation_date` | `date CONSTRAINT station_observation_daily_co_original_observation_date_not_null NOT NULL` |
| `replacement_observation_daily_id` | `bigint CONSTRAINT station_observation_daily_c_replacement_observation_da_not_null NOT NULL` |
| `replacement_observation_date` | `date CONSTRAINT station_observation_daily__replacement_observation_da_not_null1 NOT NULL` |
| `observation_correction_reason_id` | `smallint CONSTRAINT station_observation_daily_c_observation_correction_rea_not_null NOT NULL` |
| `source_artifact_id` | `bigint` |
| `derivation_run_id` | `bigint` |
| `correction_time` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `notes` | `text` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `station_observation_daily_natural_revision_unique` — `UNIQUE (station_id, observation_product_id, observation_date, revision_no)`
- `station_observation_daily_pkey` — `PRIMARY KEY (station_observation_daily_id, observation_date)`

## `weather.station_observation_daily_default`

**Status:** PHYSICAL DEFAULT PARTITION  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `station_observation_daily_id` | `bigint CONSTRAINT station_observation_daily_station_observation_daily_id_not_null NOT NULL` |
| `observation_date` | `date CONSTRAINT station_observation_daily_observation_date_not_null NOT NULL` |
| `station_id` | `bigint CONSTRAINT station_observation_daily_station_id_not_null NOT NULL` |
| `station_history_id` | `bigint CONSTRAINT station_observation_daily_station_history_id_not_null NOT NULL` |
| `observation_product_id` | `bigint CONSTRAINT station_observation_daily_observation_product_id_not_null NOT NULL` |
| `observation_record_status_id` | `smallint CONSTRAINT station_observation_daily_observation_record_status_id_not_null NOT NULL` |
| `ingestion_run_id` | `bigint` |
| `derivation_run_id` | `bigint` |
| `period_start` | `timestamp with time zone CONSTRAINT station_observation_daily_period_start_not_null NOT NULL` |
| `period_end` | `timestamp with time zone CONSTRAINT station_observation_daily_period_end_not_null NOT NULL` |
| `provider_published_at` | `timestamp with time zone` |
| `received_at` | `timestamp with time zone` |
| `ingested_at` | `timestamp with time zone DEFAULT now() CONSTRAINT station_observation_daily_ingested_at_not_null NOT NULL` |
| `revision_no` | `integer DEFAULT 1 CONSTRAINT station_observation_daily_revision_no_not_null NOT NULL` |
| `is_preferred` | `boolean DEFAULT true CONSTRAINT station_observation_daily_is_preferred_not_null NOT NULL` |
| `supersedes_observation_daily_id` | `bigint` |
| `supersedes_observation_date` | `date` |
| `air_temperature_2m_min_c` | `double precision` |
| `air_temperature_2m_max_c` | `double precision` |
| `air_temperature_2m_mean_c` | `double precision` |
| `apparent_temperature_2m_min_c` | `double precision` |
| `apparent_temperature_2m_max_c` | `double precision` |
| `apparent_temperature_2m_mean_c` | `double precision` |
| `dew_point_2m_min_c` | `double precision` |
| `dew_point_2m_max_c` | `double precision` |
| `dew_point_2m_mean_c` | `double precision` |
| `relative_humidity_2m_min_pct` | `double precision` |
| `relative_humidity_2m_max_pct` | `double precision` |
| `relative_humidity_2m_mean_pct` | `double precision` |
| `surface_pressure_mean_hpa` | `double precision` |
| `precipitation_total_mm` | `double precision` |
| `rainfall_total_mm` | `double precision` |
| `snowfall_total_mm` | `double precision` |
| `snow_depth_max_mm` | `double precision` |
| `wind_u_10m_mean_ms` | `double precision` |
| `wind_v_10m_mean_ms` | `double precision` |
| `wind_gust_10m_max_ms` | `double precision` |
| `cloud_cover_mean_pct` | `double precision` |
| `visibility_mean_m` | `double precision` |
| `solar_radiation_mean_w_m2` | `double precision` |
| `sample_count` | `integer` |
| `coverage_fraction` | `double precision` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb CONSTRAINT station_observation_daily_metadata_not_null NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() CONSTRAINT station_observation_daily_created_at_not_null NOT NULL` |

**Declared constraints**

- `station_observation_daily_def_station_id_observation_produc_key` — `UNIQUE (station_id, observation_product_id, observation_date, revision_no)`
- `station_observation_daily_default_pkey` — `PRIMARY KEY (station_observation_daily_id, observation_date)`

**Indexes**

- `station_observation_daily_def_observation_product_id_observ_idx` — `USING btree (observation_product_id, observation_date DESC)`
- `station_observation_daily_def_station_id_observation_produc_idx` — `USING btree (station_id, observation_product_id, observation_date DESC) WHERE (is_preferred = true)`
- `station_observation_daily_defau_observation_date_station_id_idx` — `USING btree (observation_date, station_id)`
- `station_observation_daily_defau_station_id_observation_date_idx` — `USING btree (station_id, observation_date DESC)`
- `station_observation_daily_default_derivation_run_id_idx` — `USING btree (derivation_run_id) WHERE (derivation_run_id IS NOT NULL)`
- `station_observation_daily_default_ingestion_run_id_idx` — `USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL)`

## `weather.station_observation_daily_quality_exception`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `station_observation_daily_quality_exception_id` | `bigint CONSTRAINT station_observation_daily_q_station_observation_daily__not_null NOT NULL` |
| `station_observation_daily_id` | `bigint CONSTRAINT station_observation_daily__station_observation_daily__not_null1 NOT NULL` |
| `observation_date` | `date CONSTRAINT station_observation_daily_quality_exc_observation_date_not_null NOT NULL` |
| `variable_id` | `bigint CONSTRAINT station_observation_daily_quality_exceptio_variable_id_not_null NOT NULL` |
| `quality_flag_id` | `smallint CONSTRAINT station_observation_daily_quality_exce_quality_flag_id_not_null NOT NULL` |
| `detected_by` | `text` |
| `derivation_run_id` | `bigint` |
| `details` | `text` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `detected_at` | `timestamp with time zone DEFAULT now() CONSTRAINT station_observation_daily_quality_exceptio_detected_at_not_null NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `station_observation_daily_quality_exception_pkey` — `PRIMARY KEY (station_observation_daily_quality_exception_id)`
- `station_observation_daily_quality_exception_unique` — `UNIQUE (station_observation_daily_id, observation_date, variable_id, quality_flag_id)`
- `station_observation_daily_quality_exception_derivation_fkey` — `FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT`
- `station_observation_daily_quality_exception_flag_fkey` — `FOREIGN KEY (quality_flag_id) REFERENCES weather.quality_flag(quality_flag_id) ON DELETE RESTRICT`
- `station_observation_daily_quality_exception_observation_fkey` — `FOREIGN KEY (station_observation_daily_id, observation_date) REFERENCES weather.station_observation_daily(station_observation_daily_id, observation_date) ON DELETE CASCADE`
- `station_observation_daily_quality_exception_variable_fkey` — `FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT`

**Indexes**

- `station_observation_daily_quality_exception_derivation_idx` — `USING btree (derivation_run_id) WHERE (derivation_run_id IS NOT NULL)`
- `station_observation_daily_quality_exception_flag_idx` — `USING btree (quality_flag_id)`
- `station_observation_daily_quality_exception_observation_idx` — `USING btree (station_observation_daily_id, observation_date)`
- `station_observation_daily_quality_exception_variable_idx` — `USING btree (variable_id)`

## `weather.station_observation_hourly`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `station_observation_id` | `bigint NOT NULL` |
| `observation_time` | `timestamp with time zone NOT NULL` |
| `station_id` | `bigint NOT NULL` |
| `station_history_id` | `bigint NOT NULL` |
| `observation_product_id` | `bigint NOT NULL` |
| `observation_record_status_id` | `smallint CONSTRAINT station_observation_hourly_observation_record_status_i_not_null NOT NULL` |
| `ingestion_run_id` | `bigint` |
| `derivation_run_id` | `bigint` |
| `period_start` | `timestamp with time zone` |
| `period_end` | `timestamp with time zone` |
| `provider_published_at` | `timestamp with time zone` |
| `received_at` | `timestamp with time zone` |
| `ingested_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `revision_no` | `integer DEFAULT 1 NOT NULL` |
| `is_preferred` | `boolean DEFAULT true NOT NULL` |
| `supersedes_observation_id` | `bigint` |
| `supersedes_observation_time` | `timestamp with time zone` |
| `air_temperature_2m_c` | `double precision` |
| `apparent_temperature_2m_c` | `double precision` |
| `dew_point_2m_c` | `double precision` |
| `relative_humidity_2m_pct` | `double precision` |
| `surface_pressure_hpa` | `double precision` |
| `precipitation_1h_mm` | `double precision` |
| `rainfall_1h_mm` | `double precision` |
| `snowfall_1h_mm` | `double precision` |
| `snow_depth_mm` | `double precision` |
| `wind_u_10m_ms` | `double precision` |
| `wind_v_10m_ms` | `double precision` |
| `wind_gust_10m_max_1h_ms` | `double precision` |
| `cloud_cover_pct` | `double precision` |
| `visibility_m` | `double precision` |
| `solar_radiation_w_m2` | `double precision` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `condition_code_id` | `smallint` |
| `PARTITION` | `BY RANGE (observation_time);` |
| `ALTER` | `TABLE weather.station_observation_hourly OWNER TO postgres;` |
| `COMMENT` | `ON COLUMN weather.station_observation_hourly.air_temperature_2m_c IS 'Canonical 2 m air temperature in degrees Celsius.';` |
| `COMMENT` | `ON COLUMN weather.station_observation_hourly.apparent_temperature_2m_c IS 'Canonical 2 m apparent temperature in degrees Celsius.';` |
| `COMMENT` | `ON COLUMN weather.station_observation_hourly.dew_point_2m_c IS 'Canonical 2 m dew point in degrees Celsius.';` |
| `COMMENT` | `ON COLUMN weather.station_observation_hourly.relative_humidity_2m_pct IS 'Canonical 2 m relative humidity in percent.';` |
| `COMMENT` | `ON COLUMN weather.station_observation_hourly.surface_pressure_hpa IS 'Canonical surface atmospheric pressure in hectopascals.';` |
| `COMMENT` | `ON COLUMN weather.station_observation_hourly.precipitation_1h_mm IS 'Canonical total precipitation accumulated over the explicit one-hour period, in millimetres.';` |
| `COMMENT` | `ON COLUMN weather.station_observation_hourly.rainfall_1h_mm IS 'Canonical liquid rainfall accumulated over the explicit one-hour period, in millimetres.';` |
| `COMMENT` | `ON COLUMN weather.station_observation_hourly.snowfall_1h_mm IS 'Canonical snowfall accumulated over the explicit one-hour period, in millimetres.';` |
| `COMMENT` | `ON COLUMN weather.station_observation_hourly.snow_depth_mm IS 'Canonical instantaneous snow depth in millimetres.';` |
| `COMMENT` | `ON COLUMN weather.station_observation_hourly.wind_u_10m_ms IS 'Canonical east-west wind vector component at 10 m in metres per second.';` |
| `COMMENT` | `ON COLUMN weather.station_observation_hourly.wind_v_10m_ms IS 'Canonical north-south wind vector component at 10 m in metres per second.';` |
| `COMMENT` | `ON COLUMN weather.station_observation_hourly.wind_gust_10m_max_1h_ms IS 'Maximum 10 m wind gust over the explicit one-hour period in metres per second.';` |
| `COMMENT` | `ON COLUMN weather.station_observation_hourly.cloud_cover_pct IS 'Canonical total cloud cover in percent.';` |
| `COMMENT` | `ON COLUMN weather.station_observation_hourly.visibility_m IS 'Canonical horizontal visibility in metres.';` |
| `COMMENT` | `ON COLUMN weather.station_observation_hourly.solar_radiation_w_m2 IS 'Canonical surface solar radiation flux in watts per square metre.';` |
| `CREATE` | `TABLE weather.station_observation_hourly_default (` |
| `station_observation_id` | `bigint CONSTRAINT station_observation_hourly_station_observation_id_not_null NOT NULL` |
| `observation_time` | `timestamp with time zone CONSTRAINT station_observation_hourly_observation_time_not_null NOT NULL` |
| `station_id` | `bigint CONSTRAINT station_observation_hourly_station_id_not_null NOT NULL` |
| `station_history_id` | `bigint CONSTRAINT station_observation_hourly_station_history_id_not_null NOT NULL` |
| `observation_product_id` | `bigint CONSTRAINT station_observation_hourly_observation_product_id_not_null NOT NULL` |
| `observation_record_status_id` | `smallint CONSTRAINT station_observation_hourly_observation_record_status_i_not_null NOT NULL` |
| `ingestion_run_id` | `bigint` |
| `derivation_run_id` | `bigint` |
| `period_start` | `timestamp with time zone` |
| `period_end` | `timestamp with time zone` |
| `provider_published_at` | `timestamp with time zone` |
| `received_at` | `timestamp with time zone` |
| `ingested_at` | `timestamp with time zone DEFAULT now() CONSTRAINT station_observation_hourly_ingested_at_not_null NOT NULL` |
| `revision_no` | `integer DEFAULT 1 CONSTRAINT station_observation_hourly_revision_no_not_null NOT NULL` |
| `is_preferred` | `boolean DEFAULT true CONSTRAINT station_observation_hourly_is_preferred_not_null NOT NULL` |
| `supersedes_observation_id` | `bigint` |
| `supersedes_observation_time` | `timestamp with time zone` |
| `air_temperature_2m_c` | `double precision` |
| `apparent_temperature_2m_c` | `double precision` |
| `dew_point_2m_c` | `double precision` |
| `relative_humidity_2m_pct` | `double precision` |
| `surface_pressure_hpa` | `double precision` |
| `precipitation_1h_mm` | `double precision` |
| `rainfall_1h_mm` | `double precision` |
| `snowfall_1h_mm` | `double precision` |
| `snow_depth_mm` | `double precision` |
| `wind_u_10m_ms` | `double precision` |
| `wind_v_10m_ms` | `double precision` |
| `wind_gust_10m_max_1h_ms` | `double precision` |
| `cloud_cover_pct` | `double precision` |
| `visibility_m` | `double precision` |
| `solar_radiation_w_m2` | `double precision` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb CONSTRAINT station_observation_hourly_metadata_not_null NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() CONSTRAINT station_observation_hourly_created_at_not_null NOT NULL` |
| `condition_code_id` | `smallint` |

**Declared constraints**

- `station_observation_hourly_natural_revision_unique` — `UNIQUE (station_id, observation_product_id, observation_time, revision_no)`
- `station_observation_hourly_pkey` — `PRIMARY KEY (station_observation_id, observation_time)`

## `weather.station_observation_quality_exception`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `station_observation_quality_exception_id` | `bigint CONSTRAINT station_observation_quality_station_observation_qualit_not_null NOT NULL` |
| `station_observation_id` | `bigint CONSTRAINT station_observation_quality_exc_station_observation_id_not_null NOT NULL` |
| `observation_time` | `timestamp with time zone NOT NULL` |
| `variable_id` | `bigint NOT NULL` |
| `quality_flag_id` | `smallint NOT NULL` |
| `detected_by` | `text` |
| `derivation_run_id` | `bigint` |
| `details` | `text` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `detected_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `station_observation_quality_exception_pkey` — `PRIMARY KEY (station_observation_quality_exception_id)`
- `station_observation_quality_exception_unique` — `UNIQUE (station_observation_id, observation_time, variable_id, quality_flag_id)`
- `station_observation_quality_exception_derivation_fkey` — `FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT`
- `station_observation_quality_exception_flag_fkey` — `FOREIGN KEY (quality_flag_id) REFERENCES weather.quality_flag(quality_flag_id) ON DELETE RESTRICT`
- `station_observation_quality_exception_observation_fkey` — `FOREIGN KEY (station_observation_id, observation_time) REFERENCES weather.station_observation_hourly(station_observation_id, observation_time) ON DELETE CASCADE`
- `station_observation_quality_exception_variable_fkey` — `FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT`

**Indexes**

- `station_observation_quality_exception_derivation_idx` — `USING btree (derivation_run_id) WHERE (derivation_run_id IS NOT NULL)`
- `station_observation_quality_exception_flag_idx` — `USING btree (quality_flag_id)`
- `station_observation_quality_exception_observation_idx` — `USING btree (station_observation_id, observation_time)`
- `station_observation_quality_exception_variable_idx` — `USING btree (variable_id)`

## `weather.station_observation_value`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `station_observation_value_id` | `bigint NOT NULL` |
| `station_observation_id` | `bigint NOT NULL` |
| `observation_time` | `timestamp with time zone NOT NULL` |
| `variable_id` | `bigint NOT NULL` |
| `value_double` | `double precision` |
| `value_text` | `text` |
| `observation_record_status_id` | `smallint` |
| `ingestion_run_id` | `bigint` |
| `derivation_run_id` | `bigint` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `station_observation_value_pkey` — `PRIMARY KEY (station_observation_value_id)`
- `station_observation_value_unique` — `UNIQUE (station_observation_id, observation_time, variable_id)`
- `station_observation_value_derivation_fkey` — `FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT`
- `station_observation_value_ingestion_fkey` — `FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT`
- `station_observation_value_observation_fkey` — `FOREIGN KEY (station_observation_id, observation_time) REFERENCES weather.station_observation_hourly(station_observation_id, observation_time) ON DELETE CASCADE`
- `station_observation_value_status_fkey` — `FOREIGN KEY (observation_record_status_id) REFERENCES weather.observation_record_status(observation_record_status_id) ON DELETE RESTRICT`
- `station_observation_value_variable_fkey` — `FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT`

**Indexes**

- `station_observation_value_derivation_idx` — `USING btree (derivation_run_id) WHERE (derivation_run_id IS NOT NULL)`
- `station_observation_value_ingestion_idx` — `USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL)`
- `station_observation_value_observation_idx` — `USING btree (station_observation_id, observation_time)`
- `station_observation_value_variable_idx` — `USING btree (variable_id, observation_time)`

## `weather.station_region_map`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Maps stations to canonical geographic regions.

| Column | Definition from schema |
|---|---|
| `station_region_map_id` | `bigint NOT NULL` |
| `station_history_id` | `bigint NOT NULL` |
| `region_version_id` | `bigint NOT NULL` |
| `mapping_method` | `text DEFAULT 'point_in_polygon'::text NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `station_region_map_pkey` — `PRIMARY KEY (station_region_map_id)`
- `station_region_map_unique` — `UNIQUE (station_history_id, region_version_id)`
- `station_region_map_region_version_fkey` — `FOREIGN KEY (region_version_id) REFERENCES geo.region_version(region_version_id) ON DELETE RESTRICT`
- `station_region_map_station_history_fkey` — `FOREIGN KEY (station_history_id) REFERENCES weather.station_history(station_history_id) ON DELETE CASCADE`

**Indexes**

- `station_region_map_region_version_idx` — `USING btree (region_version_id)`
- `station_region_map_station_history_idx` — `USING btree (station_history_id)`

## `weather.statistic`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `statistic_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `statistic_code_unique` — `UNIQUE (code)`
- `statistic_pkey` — `PRIMARY KEY (statistic_id)`

## `weather.temporal_semantics`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `temporal_semantics_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `requires_period` | `boolean DEFAULT false NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `temporal_semantics_code_unique` — `UNIQUE (code)`
- `temporal_semantics_pkey` — `PRIMARY KEY (temporal_semantics_id)`

## `weather.unit`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `unit_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `symbol` | `text` |
| `quantity_type` | `text NOT NULL` |
| `description` | `text` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `unit_code_unique` — `UNIQUE (code)`
- `unit_pkey` — `PRIMARY KEY (unit_id)`

**Indexes**

- `unit_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `unit_quantity_type_idx` — `USING btree (quantity_type)`

## `weather.variable`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `variable_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `quantity_type` | `text NOT NULL` |
| `canonical_unit_id` | `bigint NOT NULL` |
| `statistic_id` | `bigint` |
| `temporal_semantics_id` | `bigint NOT NULL` |
| `accumulation_period_id` | `bigint` |
| `vertical_level_id` | `bigint` |
| `is_core` | `boolean DEFAULT false NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `variable_code_unique` — `UNIQUE (code)`
- `variable_pkey` — `PRIMARY KEY (variable_id)`
- `variable_accumulation_period_fkey` — `FOREIGN KEY (accumulation_period_id) REFERENCES weather.accumulation_period(accumulation_period_id) ON DELETE RESTRICT`
- `variable_statistic_fkey` — `FOREIGN KEY (statistic_id) REFERENCES weather.statistic(statistic_id) ON DELETE RESTRICT`
- `variable_temporal_semantics_fkey` — `FOREIGN KEY (temporal_semantics_id) REFERENCES weather.temporal_semantics(temporal_semantics_id) ON DELETE RESTRICT`
- `variable_unit_fkey` — `FOREIGN KEY (canonical_unit_id) REFERENCES weather.unit(unit_id) ON DELETE RESTRICT`
- `variable_vertical_level_fkey` — `FOREIGN KEY (vertical_level_id) REFERENCES weather.vertical_level(vertical_level_id) ON DELETE RESTRICT`

**Indexes**

- `variable_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `variable_core_idx` — `USING btree (is_core) WHERE (is_core = true)`
- `variable_quantity_type_idx` — `USING btree (quantity_type)`
- `variable_unit_idx` — `USING btree (canonical_unit_id)`

## `weather.verification_definition`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `verification_definition_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `description` | `text` |
| `verification_type` | `text NOT NULL` |
| `observation_product_id` | `bigint NOT NULL` |
| `time_matching_method` | `text NOT NULL` |
| `spatial_matching_method` | `text NOT NULL` |
| `lead_band_minutes_start` | `integer` |
| `lead_band_minutes_end` | `integer` |
| `calculation_version` | `text NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `verification_definition_code_unique` — `UNIQUE (code)`
- `verification_definition_pkey` — `PRIMARY KEY (verification_definition_id)`
- `verification_definition_observation_product_fkey` — `FOREIGN KEY (observation_product_id) REFERENCES weather.observation_product(observation_product_id) ON DELETE RESTRICT`

**Indexes**

- `verification_definition_active_idx` — `USING btree (is_active) WHERE (is_active = true)`
- `verification_definition_observation_product_idx` — `USING btree (observation_product_id)`

## `weather.vertical_level`

**Status:** ACTIVE STRUCTURE / SEMANTICS AS DEFINED BY SCHEMA  
**Purpose:** Structural purpose is indicated by the table name and relationships, but no additional project-specific semantic description is locked in this document yet. Review code/usage before changing semantics.

| Column | Definition from schema |
|---|---|
| `vertical_level_id` | `bigint NOT NULL` |
| `code` | `text NOT NULL` |
| `name` | `text NOT NULL` |
| `level_type` | `text NOT NULL` |
| `level_value` | `double precision` |
| `level_value_2` | `double precision` |
| `unit_id` | `bigint` |
| `description` | `text` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `metadata` | `jsonb DEFAULT '{}'::jsonb NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `vertical_level_code_unique` — `UNIQUE (code)`
- `vertical_level_pkey` — `PRIMARY KEY (vertical_level_id)`
- `vertical_level_unit_fkey` — `FOREIGN KEY (unit_id) REFERENCES weather.unit(unit_id) ON DELETE RESTRICT`
