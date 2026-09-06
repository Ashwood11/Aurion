# `public` Schema

**Tables in snapshot:** 14

This file currently provides exact structural inventory. Additional narrative semantics should be expanded when this schema becomes an active implementation focus.

## `public.locations`

| Column | Definition from schema |
|---|---|
| `id` | `integer NOT NULL` |
| `type` | `text NOT NULL` |
| `name` | `text` |
| `lat` | `double precision NOT NULL` |
| `lng` | `double precision NOT NULL` |
| `details` | `jsonb` |
| `created_at` | `timestamp without time zone DEFAULT now()` |

**Declared constraints**

- `locations_pkey` — `PRIMARY KEY (id)`

## `public.signals`

| Column | Definition from schema |
|---|---|
| `id` | `integer NOT NULL` |
| `module` | `character varying` |
| `signal_type` | `character varying` |
| `name` | `character varying` |
| `value` | `double precision` |
| `baseline` | `double precision` |
| `deviation` | `double precision` |
| `severity` | `character varying` |
| `timestamp` | `timestamp without time zone` |
| `expires_at` | `timestamp without time zone` |
| `source` | `character varying` |
| `extra_metadata` | `json` |
| `tags` | `json` |
| `confidence` | `double precision` |

**Declared constraints**

- `signals_pkey` — `PRIMARY KEY (id)`

**Indexes**

- `ix_signals_id` — `USING btree (id)`
- `ix_signals_module` — `USING btree (module)`
- `ix_signals_name` — `USING btree (name)`
- `ix_signals_signal_type` — `USING btree (signal_type)`
- `ix_signals_timestamp` — `USING btree ("timestamp")`

## `public.strategic_point`

| Column | Definition from schema |
|---|---|
| `id` | `uuid DEFAULT gen_random_uuid() NOT NULL` |
| `name` | `text NOT NULL` |
| `point_type` | `text NOT NULL` |
| `subtype` | `text` |
| `country_code` | `text` |
| `region_name` | `text` |
| `latitude` | `double precision NOT NULL` |
| `longitude` | `double precision NOT NULL` |
| `importance_score` | `numeric(10,4)` |
| `source_system` | `text` |
| `external_ref` | `text` |
| `metadata` | `jsonb` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `strategic_point_pkey` — `PRIMARY KEY (id)`

**Indexes**

- `idx_strategic_point_lat_lon` — `USING btree (latitude, longitude)`
- `idx_strategic_point_type` — `USING btree (point_type)`

## `public.strategic_point_grid_map`

| Column | Definition from schema |
|---|---|
| `strategic_point_id` | `uuid NOT NULL` |
| `grid_point_id` | `uuid NOT NULL` |
| `distance_km` | `double precision` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `strategic_point_grid_map_pkey` — `PRIMARY KEY (strategic_point_id, grid_point_id)`
- `strategic_point_grid_map_grid_point_id_fkey` — `FOREIGN KEY (grid_point_id) REFERENCES public.weather_grid_point(id) ON DELETE CASCADE`
- `strategic_point_grid_map_strategic_point_id_fkey` — `FOREIGN KEY (strategic_point_id) REFERENCES public.strategic_point(id) ON DELETE CASCADE`

## `public.weather_climatology_daily`

| Column | Definition from schema |
|---|---|
| `location_id` | `uuid NOT NULL` |
| `day_of_year` | `integer NOT NULL` |
| `baseline_temp_c` | `double precision` |
| `baseline_precip_mm` | `double precision` |
| `baseline_humidity_pct` | `double precision` |
| `baseline_wind_mps` | `double precision` |
| `sample_count` | `integer DEFAULT 0 NOT NULL` |
| `computed_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `weather_climatology_daily_pkey` — `PRIMARY KEY (location_id, day_of_year)`
- `weather_climatology_daily_location_id_fkey` — `FOREIGN KEY (location_id) REFERENCES public.weather_location(id) ON DELETE CASCADE`

## `public.weather_data`

| Column | Definition from schema |
|---|---|
| `id` | `integer NOT NULL` |
| `location` | `character varying(100) NOT NULL` |
| `timestamp` | `timestamp without time zone` |
| `temperature_2m` | `double precision` |
| `apparent_temperature` | `double precision` |
| `relative_humidity` | `double precision` |
| `precipitation` | `double precision` |
| `wind_speed_10m` | `double precision` |
| `wind_direction_10m` | `double precision` |
| `cloud_cover` | `double precision` |
| `soil_temperature_0cm` | `double precision` |
| `soil_moisture_index` | `double precision` |
| `et0_evapotranspiration` | `double precision` |
| `dew_point` | `double precision` |
| `weather_code` | `integer` |
| `source` | `character varying(50)` |
| `extra_metadata` | `json` |

**Declared constraints**

- `weather_data_pkey` — `PRIMARY KEY (id)`

**Indexes**

- `ix_weather_data_id` — `USING btree (id)`
- `ix_weather_data_location` — `USING btree (location)`
- `ix_weather_data_timestamp` — `USING btree ("timestamp")`

## `public.weather_forecast_run`

| Column | Definition from schema |
|---|---|
| `id` | `uuid DEFAULT gen_random_uuid() NOT NULL` |
| `provider` | `text NOT NULL` |
| `model_name` | `text` |
| `product_name` | `text` |
| `issued_at` | `timestamp with time zone NOT NULL` |
| `ingested_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `source_version` | `text` |
| `run_metadata` | `jsonb` |
| `raw_payload` | `jsonb` |

**Declared constraints**

- `weather_forecast_run_pkey` — `PRIMARY KEY (id)`

**Indexes**

- `ix_weather_forecast_run_issued_at_desc` — `USING btree (issued_at DESC)`
- `UNIQUE ux_weather_forecast_run_unique` — `USING btree (provider, COALESCE(model_name, ''::text), COALESCE(product_name, ''::text), issued_at)`

## `public.weather_forecast_value`

| Column | Definition from schema |
|---|---|
| `forecast_run_id` | `uuid NOT NULL` |
| `location_id` | `uuid NOT NULL` |
| `valid_time` | `timestamp with time zone NOT NULL` |
| `lead_hours` | `integer NOT NULL` |
| `temperature_c` | `double precision` |
| `feels_like_c` | `double precision` |
| `dew_point_c` | `double precision` |
| `humidity_pct` | `double precision` |
| `pressure_hpa` | `double precision` |
| `wind_speed_mps` | `double precision` |
| `wind_gust_mps` | `double precision` |
| `wind_dir_deg` | `integer` |
| `precip_mm` | `double precision` |
| `snow_mm` | `double precision` |
| `cloud_cover_pct` | `double precision` |
| `visibility_km` | `double precision` |
| `uv_index` | `double precision` |
| `condition_code` | `text` |
| `condition_text` | `text` |
| `provider_field_map` | `jsonb` |

**Declared constraints**

- `weather_forecast_value_pkey` — `PRIMARY KEY (forecast_run_id, location_id, valid_time)`
- `weather_forecast_value_forecast_run_id_fkey` — `FOREIGN KEY (forecast_run_id) REFERENCES public.weather_forecast_run(id) ON DELETE CASCADE`
- `weather_forecast_value_location_id_fkey` — `FOREIGN KEY (location_id) REFERENCES public.weather_location(id) ON DELETE CASCADE`

**Indexes**

- `ix_weather_forecast_value_location_lead` — `USING btree (location_id, lead_hours, valid_time DESC)`
- `ix_weather_forecast_value_location_valid_desc` — `USING btree (location_id, valid_time DESC)`
- `ix_weather_forecast_value_run_location_valid` — `USING btree (forecast_run_id, location_id, valid_time)`

## `public.weather_gas_signal`

| Column | Definition from schema |
|---|---|
| `location_id` | `uuid NOT NULL` |
| `signal_time` | `timestamp with time zone NOT NULL` |
| `computed_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `temp_anomaly_c` | `double precision` |
| `hdd` | `double precision` |
| `wind_anomaly_pct` | `double precision` |
| `gas_score` | `double precision NOT NULL` |
| `confidence` | `double precision` |
| `explanation` | `text` |
| `signal_payload` | `jsonb` |

**Declared constraints**

- `weather_gas_signal_pkey` — `PRIMARY KEY (location_id, signal_time)`
- `weather_gas_signal_location_id_fkey` — `FOREIGN KEY (location_id) REFERENCES public.weather_location(id) ON DELETE CASCADE`

## `public.weather_grid_point`

| Column | Definition from schema |
|---|---|
| `id` | `uuid DEFAULT gen_random_uuid() NOT NULL` |
| `grid_code` | `text NOT NULL` |
| `latitude` | `double precision NOT NULL` |
| `longitude` | `double precision NOT NULL` |
| `resolution_deg` | `double precision NOT NULL` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `weather_grid_point_grid_code_key` — `UNIQUE (grid_code)`
- `weather_grid_point_pkey` — `PRIMARY KEY (id)`

**Indexes**

- `idx_weather_grid_point_lat_lon` — `USING btree (latitude, longitude)`

## `public.weather_grid_point_import`

| Column | Definition from schema |
|---|---|
| `grid_code` | `text` |
| `latitude` | `double precision` |
| `longitude` | `double precision` |
| `resolution_deg` | `double precision` |

No post-create constraint/index statements were found in the export for this table.

## `public.weather_ingestion_run`

| Column | Definition from schema |
|---|---|
| `id` | `uuid DEFAULT gen_random_uuid() NOT NULL` |
| `provider` | `text NOT NULL` |
| `location_id` | `uuid` |
| `requested_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `response_status` | `integer` |
| `raw_file_path` | `text` |
| `notes` | `text` |

**Declared constraints**

- `weather_ingestion_run_pkey` — `PRIMARY KEY (id)`
- `weather_ingestion_run_location_id_fkey` — `FOREIGN KEY (location_id) REFERENCES public.weather_location(id) ON DELETE SET NULL`

## `public.weather_location`

| Column | Definition from schema |
|---|---|
| `id` | `uuid DEFAULT gen_random_uuid() NOT NULL` |
| `source_system` | `text DEFAULT 'visual_crossing'::text NOT NULL` |
| `provider_location_key` | `text` |
| `name` | `text NOT NULL` |
| `country_code` | `text` |
| `region_name` | `text` |
| `latitude` | `double precision NOT NULL` |
| `longitude` | `double precision NOT NULL` |
| `elevation_m` | `double precision` |
| `timezone_name` | `text` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `location_code` | `text` |

**Declared constraints**

- `weather_location_pkey` — `PRIMARY KEY (id)`

**Indexes**

- `ix_weather_location_name` — `USING btree (name)`
- `UNIQUE ux_weather_location_code` — `USING btree (location_code)`
- `UNIQUE ux_weather_location_provider_key` — `USING btree (source_system, provider_location_key)`

## `public.weather_observation`

| Column | Definition from schema |
|---|---|
| `id` | `uuid DEFAULT gen_random_uuid() NOT NULL` |
| `grid_point_id` | `uuid NOT NULL` |
| `observation_time` | `timestamp with time zone NOT NULL` |
| `data_type` | `text NOT NULL` |
| `source_system` | `text DEFAULT 'visual_crossing'::text NOT NULL` |
| `temp_c` | `double precision` |
| `feels_like_c` | `double precision` |
| `humidity_pct` | `double precision` |
| `dew_point_c` | `double precision` |
| `pressure_mb` | `double precision` |
| `wind_speed_kph` | `double precision` |
| `wind_gust_kph` | `double precision` |
| `wind_dir_deg` | `double precision` |
| `precip_mm` | `double precision` |
| `snow_mm` | `double precision` |
| `cloud_cover_pct` | `double precision` |
| `visibility_km` | `double precision` |
| `solar_radiation_wm2` | `double precision` |
| `uv_index` | `double precision` |
| `conditions_text` | `text` |
| `icon` | `text` |
| `raw_payload` | `jsonb` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `weather_observation_pkey` — `PRIMARY KEY (id)`
- `weather_observation_unique` — `UNIQUE (grid_point_id, observation_time, data_type, source_system)`
- `weather_observation_grid_point_id_fkey` — `FOREIGN KEY (grid_point_id) REFERENCES public.weather_grid_point(id) ON DELETE CASCADE`

**Indexes**

- `idx_weather_observation_grid_time` — `USING btree (grid_point_id, observation_time)`
- `idx_weather_observation_time` — `USING btree (observation_time)`
