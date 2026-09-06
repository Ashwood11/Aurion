# `aviation` Schema

**Tables in snapshot:** 4

This file currently provides exact structural inventory. Additional narrative semantics should be expanded when this schema becomes an active implementation focus.

## `aviation.flight_enrichment`

| Column | Definition from schema |
|---|---|
| `enrichment_id` | `bigint NOT NULL` |
| `icao24` | `text` |
| `callsign` | `text` |
| `flight_number` | `text` |
| `provider` | `text NOT NULL` |
| `provider_record_id` | `text` |
| `operator_code` | `text` |
| `operator_name` | `text` |
| `registration` | `text` |
| `aircraft_icao_type` | `text` |
| `aircraft_name` | `text` |
| `origin_airport_code` | `text` |
| `destination_airport_code` | `text` |
| `diverted_airport_code` | `text` |
| `route_status` | `text` |
| `scheduled_departure_utc` | `timestamp with time zone` |
| `scheduled_arrival_utc` | `timestamp with time zone` |
| `confidence` | `numeric(5,2)` |
| `payload` | `jsonb` |
| `fetched_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `flight_enrichment_pkey` — `PRIMARY KEY (enrichment_id)`

**Indexes**

- `idx_flight_enrichment_lookup` — `USING btree (icao24, callsign, flight_number)`

## `aviation.flight_history`

| Column | Definition from schema |
|---|---|
| `history_id` | `bigint NOT NULL` |
| `flight_id` | `text` |
| `icao24` | `text` |
| `callsign` | `text` |
| `flight_number` | `text` |
| `registration` | `text` |
| `operator_code` | `text` |
| `operator_name` | `text` |
| `aircraft_icao_type` | `text` |
| `aircraft_name` | `text` |
| `aircraft_category` | `integer` |
| `latitude` | `double precision` |
| `longitude` | `double precision` |
| `baro_altitude_m` | `double precision` |
| `geo_altitude_m` | `double precision` |
| `altitude_ft` | `integer` |
| `ground_speed_mps` | `double precision` |
| `ground_speed_kts` | `double precision` |
| `heading_deg` | `double precision` |
| `vertical_rate_mps` | `double precision` |
| `vertical_rate_fpm` | `double precision` |
| `on_ground` | `boolean` |
| `squawk` | `text` |
| `spi` | `boolean` |
| `position_source` | `integer` |
| `origin_airport_code` | `text` |
| `destination_airport_code` | `text` |
| `diverted_airport_code` | `text` |
| `route_status` | `text` |
| `status` | `text` |
| `source_live` | `text` |
| `source_route` | `text` |
| `source_aircraft` | `text` |
| `source_operator` | `text` |
| `source` | `text` |
| `route_confidence` | `numeric(5,2)` |
| `aircraft_confidence` | `numeric(5,2)` |
| `opensky_time_position` | `timestamp with time zone` |
| `opensky_last_contact` | `timestamp with time zone` |
| `first_seen_at` | `timestamp with time zone` |
| `last_seen_at` | `timestamp with time zone` |
| `updated_at` | `timestamp with time zone` |
| `archived_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `flight_history_pkey` — `PRIMARY KEY (history_id)`

**Indexes**

- `idx_flight_history_archived_at` — `USING btree (archived_at)`
- `idx_flight_history_callsign` — `USING btree (callsign)`
- `idx_flight_history_icao24` — `USING btree (icao24)`
- `idx_flight_history_last_seen_at` — `USING btree (last_seen_at)`

## `aviation.flight_ingest_raw`

| Column | Definition from schema |
|---|---|
| `raw_id` | `bigint NOT NULL` |
| `provider` | `text DEFAULT 'opensky'::text NOT NULL` |
| `batch_time` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `icao24` | `text` |
| `callsign` | `text` |
| `payload` | `jsonb NOT NULL` |

**Declared constraints**

- `flight_ingest_raw_pkey` — `PRIMARY KEY (raw_id)`

**Indexes**

- `idx_flight_ingest_raw_batch_time` — `USING btree (batch_time)`
- `idx_flight_ingest_raw_icao24` — `USING btree (icao24)`

## `aviation.flight_live`

| Column | Definition from schema |
|---|---|
| `live_id` | `bigint NOT NULL` |
| `flight_id` | `text` |
| `icao24` | `text` |
| `callsign` | `text` |
| `flight_number` | `text` |
| `registration` | `text` |
| `operator_code` | `text` |
| `operator_name` | `text` |
| `aircraft_icao_type` | `text` |
| `aircraft_name` | `text` |
| `aircraft_category` | `integer` |
| `latitude` | `double precision NOT NULL` |
| `longitude` | `double precision NOT NULL` |
| `baro_altitude_m` | `double precision` |
| `geo_altitude_m` | `double precision` |
| `altitude_ft` | `integer` |
| `ground_speed_mps` | `double precision` |
| `ground_speed_kts` | `double precision` |
| `heading_deg` | `double precision` |
| `vertical_rate_mps` | `double precision` |
| `vertical_rate_fpm` | `double precision` |
| `on_ground` | `boolean` |
| `squawk` | `text` |
| `spi` | `boolean` |
| `position_source` | `integer` |
| `origin_airport_code` | `text` |
| `destination_airport_code` | `text` |
| `diverted_airport_code` | `text` |
| `route_status` | `text` |
| `status` | `text` |
| `source_live` | `text DEFAULT 'opensky'::text NOT NULL` |
| `source_route` | `text` |
| `source_aircraft` | `text` |
| `source_operator` | `text` |
| `source` | `text` |
| `route_confidence` | `numeric(5,2)` |
| `aircraft_confidence` | `numeric(5,2)` |
| `opensky_time_position` | `timestamp with time zone` |
| `opensky_last_contact` | `timestamp with time zone` |
| `first_seen_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `last_seen_at` | `timestamp with time zone DEFAULT now() NOT NULL` |
| `updated_at` | `timestamp with time zone DEFAULT now() NOT NULL` |

**Declared constraints**

- `flight_live_pkey` — `PRIMARY KEY (live_id)`

**Indexes**

- `idx_flight_live_callsign` — `USING btree (callsign)`
- `idx_flight_live_last_seen_at` — `USING btree (last_seen_at)`
- `idx_flight_live_status` — `USING btree (status)`
- `UNIQUE ux_flight_live_icao24` — `USING btree (icao24) WHERE (icao24 IS NOT NULL)`
