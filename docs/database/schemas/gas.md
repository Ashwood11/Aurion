# `gas` Schema

**Tables in snapshot:** 11

The `gas` schema owns natural-gas fundamentals, gas-market data and gas-specific interpretation/derived products. It may consume canonical Weather and Geo data, but physical weather and reusable geography remain owned by `weather` and `geo`.

## Current table catalogue

## `gas.consumption_monthly`

**Status:** ACTIVE  
**Purpose:** Monthly aggregate natural-gas consumption by region and end-use sector, with source/status metadata.

| Column | Definition from schema |
|---|---|
| `id` | `uuid DEFAULT gen_random_uuid() NOT NULL` |
| `region` | `text DEFAULT 'United States'::text NOT NULL` |
| `report_month` | `date NOT NULL` |
| `total_consumption_bcf` | `numeric(14,3)` |
| `residential_bcf` | `numeric(14,3)` |
| `commercial_bcf` | `numeric(14,3)` |
| `industrial_bcf` | `numeric(14,3)` |
| `electric_power_bcf` | `numeric(14,3)` |
| `vehicle_fuel_bcf` | `numeric(14,3)` |
| `data_status` | `text DEFAULT 'official'::text NOT NULL` |
| `source_system` | `text DEFAULT 'EIA'::text NOT NULL` |
| `source_series` | `text` |
| `source_url` | `text` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `ingested_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `consumption_monthly_pkey` — `PRIMARY KEY (id)`
- `consumption_monthly_region_report_month_key` — `UNIQUE (region, report_month)`

**Indexes**

- `idx_consumption_monthly_region_month` — `USING btree (region, report_month DESC)`
- `idx_consumption_monthly_region_report_month` — `USING btree (region, report_month DESC)`
- `idx_consumption_monthly_report_month` — `USING btree (report_month DESC)`

## `gas.ingestion_log`

**Status:** ACTIVE / OPERATIONAL  
**Purpose:** Lightweight ingestion-run log for gas datasets: source, dataset, processed rows, latest date, status, and message.

| Column | Definition from schema |
|---|---|
| `id` | `integer NOT NULL` |
| `run_time` | `timestamp with time zone DEFAULT now()` |
| `source_system` | `text` |
| `dataset_name` | `text` |
| `rows_processed` | `integer` |
| `latest_date` | `date` |
| `status` | `text` |
| `message` | `text` |

**Declared constraints**

- `ingestion_log_pkey` — `PRIMARY KEY (id)`

## `gas.lng_exports_daily`

**Status:** STRUCTURE PRESENT; DATA STATUS TO VERIFY  
**Purpose:** Daily LNG terminal/export activity structure, including export/feedgas volumes, utilization, destinations, cargo count, and outage markers.

| Column | Definition from schema |
|---|---|
| `id` | `uuid DEFAULT gen_random_uuid() NOT NULL` |
| `report_date` | `date NOT NULL` |
| `terminal_name` | `text NOT NULL` |
| `terminal_code` | `text` |
| `region` | `text DEFAULT 'USA'::text` |
| `export_bcf` | `numeric` |
| `feedgas_bcf` | `numeric` |
| `utilization_percent` | `numeric` |
| `destination_region` | `text` |
| `destination_country` | `text` |
| `cargo_count` | `integer` |
| `outage_flag` | `boolean DEFAULT false` |
| `outage_notes` | `text` |
| `source_system` | `text DEFAULT 'EIA'::text NOT NULL` |
| `source_series` | `text` |
| `ingested_at` | `timestamp with time zone DEFAULT now()` |

**Declared constraints**

- `lng_exports_daily_pkey` — `PRIMARY KEY (id)`
- `lng_exports_daily_report_date_terminal_name_key` — `UNIQUE (report_date, terminal_name)`

**Indexes**

- `idx_lng_exports_date` — `USING btree (report_date DESC)`
- `idx_lng_exports_region` — `USING btree (destination_region)`
- `idx_lng_exports_terminal` — `USING btree (terminal_name)`

## `gas.lng_monthly`

**Status:** ACTIVE  
**Purpose:** Monthly LNG import/export aggregates by region.

| Column | Definition from schema |
|---|---|
| `id` | `bigint NOT NULL` |
| `month` | `date NOT NULL` |
| `region` | `text DEFAULT 'United States'::text NOT NULL` |
| `lng_exports_bcf` | `numeric(12,3)` |
| `lng_imports_bcf` | `numeric(12,3)` |
| `net_lng_exports_bcf` | `numeric(12,3)` |
| `lng_exports_bcfd` | `numeric(10,3)` |
| `lng_imports_bcfd` | `numeric(10,3)` |
| `net_lng_exports_bcfd` | `numeric(10,3)` |
| `source_system` | `text DEFAULT 'EIA'::text NOT NULL` |
| `source_series` | `text` |
| `ingested_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `lng_monthly_pkey` — `PRIMARY KEY (id)`
- `ux_lng_monthly_month_region` — `UNIQUE (month, region)`

## `gas.market_signals`

**Status:** DERIVED / AURION  
**Purpose:** Aurion-produced gas-market signal records with direction, score, confidence, and explanation.

| Column | Definition from schema |
|---|---|
| `id` | `integer NOT NULL` |
| `signal_date` | `date NOT NULL` |
| `region` | `text NOT NULL` |
| `signal_type` | `text NOT NULL` |
| `direction` | `text NOT NULL` |
| `score` | `numeric` |
| `confidence` | `text` |
| `explanation` | `text` |
| `source_system` | `text DEFAULT 'aurion'::text` |
| `created_at` | `timestamp with time zone DEFAULT now()` |

**Declared constraints**

- `market_signals_pkey` — `PRIMARY KEY (id)`
- `market_signals_signal_date_region_signal_type_source_system_key` — `UNIQUE (signal_date, region, signal_type, source_system)`

## `gas.pipeline_flows_daily`

**Status:** STRUCTURE PRESENT; DATA STATUS TO VERIFY  
**Purpose:** Daily pipeline-flow structure for named pipelines and origin/destination regions, including capacity, utilization, constraint, and maintenance flags.

| Column | Definition from schema |
|---|---|
| `id` | `uuid DEFAULT gen_random_uuid() NOT NULL` |
| `report_date` | `date NOT NULL` |
| `pipeline_name` | `text NOT NULL` |
| `pipeline_code` | `text` |
| `origin_region` | `text` |
| `destination_region` | `text` |
| `flow_direction` | `text` |
| `flow_bcf` | `numeric` |
| `capacity_bcf` | `numeric` |
| `utilization_percent` | `numeric` |
| `constraint_flag` | `boolean DEFAULT false` |
| `maintenance_flag` | `boolean DEFAULT false` |
| `gas_type` | `text DEFAULT 'Natural Gas'::text` |
| `source_system` | `text NOT NULL` |
| `source_series` | `text` |
| `ingested_at` | `timestamp with time zone DEFAULT now()` |

**Declared constraints**

- `pipeline_flows_daily_pkey` — `PRIMARY KEY (id)`
- `pipeline_flows_daily_report_date_pipeline_name_origin_regio_key` — `UNIQUE (report_date, pipeline_name, origin_region, destination_region)`

**Indexes**

- `idx_pipeline_flows_date` — `USING btree (report_date DESC)`
- `idx_pipeline_flows_pipeline` — `USING btree (pipeline_name)`
- `idx_pipeline_flows_regions` — `USING btree (origin_region, destination_region)`

## `gas.prices_daily`

**Status:** ACTIVE  
**Purpose:** Daily natural-gas market prices with daily change metrics and source/status metadata.

| Column | Definition from schema |
|---|---|
| `id` | `uuid DEFAULT gen_random_uuid() NOT NULL` |
| `market` | `text NOT NULL` |
| `region` | `text NOT NULL` |
| `price_date` | `date NOT NULL` |
| `price_usd_per_mmbtu` | `numeric(10,4)` |
| `change_usd` | `numeric(10,4)` |
| `change_pct` | `numeric(10,4)` |
| `data_status` | `text DEFAULT 'official'::text NOT NULL` |
| `source_system` | `text DEFAULT 'EIA'::text NOT NULL` |
| `source_series` | `text` |
| `source_url` | `text` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `ingested_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `prices_daily_pkey` — `PRIMARY KEY (id)`
- `uq_prices_daily_market_date` — `UNIQUE (market, price_date)`

**Indexes**

- `idx_prices_daily_market_price_date` — `USING btree (market, price_date DESC)`
- `idx_prices_daily_price_date` — `USING btree (price_date DESC)`

## `gas.production_monthly`

**Status:** ACTIVE  
**Purpose:** Monthly US/regional natural-gas production measures, including dry, marketed, and gross-withdrawal volumes and daily-rate equivalents.

| Column | Definition from schema |
|---|---|
| `id` | `bigint NOT NULL` |
| `month` | `date NOT NULL` |
| `region` | `text DEFAULT 'United States'::text NOT NULL` |
| `dry_production_bcf` | `numeric(12,3)` |
| `marketed_production_bcf` | `numeric(12,3)` |
| `gross_withdrawals_bcf` | `numeric(12,3)` |
| `dry_production_bcfd` | `numeric(10,3)` |
| `marketed_production_bcfd` | `numeric(10,3)` |
| `gross_withdrawals_bcfd` | `numeric(10,3)` |
| `source_system` | `text DEFAULT 'EIA'::text NOT NULL` |
| `source_series` | `text` |
| `ingested_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `production_monthly_pkey` — `PRIMARY KEY (id)`
- `ux_production_monthly_month_region` — `UNIQUE (month, region)`

## `gas.states_consumption_monthly`

**Status:** ACTIVE  
**Purpose:** Monthly state-level gas consumption by major end-use sector. This is a key authoritative input candidate for future demand-region weighting/validation.

| Column | Definition from schema |
|---|---|
| `month` | `date NOT NULL` |
| `state_code` | `text NOT NULL` |
| `state_name` | `text` |
| `residential_bcf` | `numeric` |
| `commercial_bcf` | `numeric` |
| `industrial_bcf` | `numeric` |
| `electric_power_bcf` | `numeric` |
| `total_delivered_bcf` | `numeric` |
| `source_system` | `text DEFAULT 'EIA'::text` |
| `ingested_at` | `timestamp with time zone DEFAULT now()` |

**Declared constraints**

- `states_consumption_monthly_pkey` — `PRIMARY KEY (month, state_code)`

**Future role:** State-level EIA consumption history is a strong candidate input for validating and deriving sector-aware demand-region weights, especially residential/commercial weather-sensitive demand. It does not by itself define the final cell-weight methodology.

## `gas.storage_weekly`

**Status:** ACTIVE  
**Purpose:** Weekly natural-gas storage levels and comparisons to prior year and five-year average, with seasonal/calendar helper fields.

| Column | Definition from schema |
|---|---|
| `id` | `integer NOT NULL` |
| `region` | `text NOT NULL` |
| `report_date` | `date NOT NULL` |
| `total_bcf` | `numeric` |
| `change_bcf` | `numeric` |
| `year_ago_bcf` | `numeric` |
| `five_year_avg_bcf` | `numeric` |
| `surplus_vs_year_ago_bcf` | `numeric` |
| `surplus_vs_five_year_avg_bcf` | `numeric` |
| `source_system` | `text DEFAULT 'eia'::text` |
| `source_series` | `text` |
| `ingested_at` | `timestamp with time zone DEFAULT now()` |
| `storage_year` | `integer` |
| `storage_week` | `integer` |
| `storage_month` | `integer` |
| `storage_season` | `text` |

**Declared constraints**

- `storage_weekly_pkey` — `PRIMARY KEY (id)`
- `storage_weekly_region_report_date_source_system_key` — `UNIQUE (region, report_date, source_system)`

## `gas.weather_demand_regions`

**Status:** PROVISIONAL / LEGACY SEED MODEL  
**Purpose:** Twelve manually seeded representative US weather-demand hubs used for early prototyping. Audit found no source/method/version metadata; population weights sum to 0.73 and gas-demand weights to 0.815. Do not treat as authoritative production demand geography.

| Column | Definition from schema |
|---|---|
| `id` | `uuid DEFAULT gen_random_uuid() NOT NULL` |
| `region_code` | `text NOT NULL` |
| `region_name` | `text NOT NULL` |
| `country_code` | `text DEFAULT 'US'::text NOT NULL` |
| `latitude` | `numeric(9,6) NOT NULL` |
| `longitude` | `numeric(9,6) NOT NULL` |
| `population_weight` | `numeric(10,6) DEFAULT 1.0 NOT NULL` |
| `gas_demand_weight` | `numeric(10,6)` |
| `is_active` | `boolean DEFAULT true NOT NULL` |
| `created_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `weather_demand_regions_pkey` — `PRIMARY KEY (id)`
- `weather_demand_regions_region_code_key` — `UNIQUE (region_code)`

**Important project decision:** This table is retained as provisional/legacy seed data. Do not normalize its current weights, expand its points into authoritative metro footprints, or use it as the production demand-region model without an explicit migration/design decision.

## Planned production gas-weather demand model

The approved direction is to separate:

1. stable demand-region identity;
2. versioned geographic membership referencing canonical `geo.region`;
3. weight-set identity/methodology/provenance/effective period;
4. canonical `weather.grid_cell` weights;
5. downstream HDD/CDD products that record which methodology/weight set produced them.

The exact DDL has not yet been created and should not be inferred from the provisional 12-hub table.