--
-- PostgreSQL database dump
--

\restrict zzzDLqKc1wa5e7eOkVozJ94KEQyEh6SDslJzIAacgctNjQWIvngqIvqBMsI4LZq

-- Dumped from database version 18.3
-- Dumped by pg_dump version 18.3

-- Started on 2026-09-06 01:59:38

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- TOC entry 20 (class 2615 OID 57582)
-- Name: aviation; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA aviation;


ALTER SCHEMA aviation OWNER TO postgres;

--
-- TOC entry 17 (class 2615 OID 40989)
-- Name: core; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA core;


ALTER SCHEMA core OWNER TO postgres;

--
-- TOC entry 16 (class 2615 OID 40988)
-- Name: energy; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA energy;


ALTER SCHEMA energy OWNER TO postgres;

--
-- TOC entry 21 (class 2615 OID 78019)
-- Name: gas; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA gas;


ALTER SCHEMA gas OWNER TO postgres;

--
-- TOC entry 19 (class 2615 OID 57511)
-- Name: geo; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA geo;


ALTER SCHEMA geo OWNER TO postgres;

--
-- TOC entry 18 (class 2615 OID 57344)
-- Name: locations; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA locations;


ALTER SCHEMA locations OWNER TO postgres;

--
-- TOC entry 14 (class 2615 OID 40986)
-- Name: mining; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA mining;


ALTER SCHEMA mining OWNER TO postgres;

--
-- TOC entry 15 (class 2615 OID 40987)
-- Name: weather; Type: SCHEMA; Schema: -; Owner: postgres
--

CREATE SCHEMA weather;


ALTER SCHEMA weather OWNER TO postgres;

--
-- TOC entry 3 (class 3079 OID 57390)
-- Name: cube; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS cube WITH SCHEMA public;


--
-- TOC entry 9274 (class 0 OID 0)
-- Dependencies: 3
-- Name: EXTENSION cube; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION cube IS 'data type for multidimensional cubes';


--
-- TOC entry 4 (class 3079 OID 57479)
-- Name: earthdistance; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS earthdistance WITH SCHEMA public;


--
-- TOC entry 9275 (class 0 OID 0)
-- Dependencies: 4
-- Name: EXTENSION earthdistance; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION earthdistance IS 'calculate great-circle distances on the surface of the Earth';


--
-- TOC entry 8 (class 3079 OID 220126)
-- Name: h3; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS h3 WITH SCHEMA public;


--
-- TOC entry 9276 (class 0 OID 0)
-- Dependencies: 8
-- Name: EXTENSION h3; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION h3 IS 'H3 bindings for PostgreSQL';


--
-- TOC entry 6 (class 3079 OID 218483)
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- TOC entry 9277 (class 0 OID 0)
-- Dependencies: 6
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- TOC entry 7 (class 3079 OID 219565)
-- Name: postgis_raster; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_raster WITH SCHEMA public;


--
-- TOC entry 9278 (class 0 OID 0)
-- Dependencies: 7
-- Name: EXTENSION postgis_raster; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_raster IS 'PostGIS raster types and functions';


--
-- TOC entry 9 (class 3079 OID 220242)
-- Name: h3_postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS h3_postgis WITH SCHEMA public;


--
-- TOC entry 9279 (class 0 OID 0)
-- Dependencies: 9
-- Name: EXTENSION h3_postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION h3_postgis IS 'H3 PostGIS integration';


--
-- TOC entry 5 (class 3079 OID 61860)
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- TOC entry 9280 (class 0 OID 0)
-- Dependencies: 5
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- TOC entry 2 (class 3079 OID 24779)
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;


--
-- TOC entry 9281 (class 0 OID 0)
-- Dependencies: 2
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- TOC entry 262 (class 1259 OID 57734)
-- Name: flight_enrichment; Type: TABLE; Schema: aviation; Owner: postgres
--

CREATE TABLE aviation.flight_enrichment (
    enrichment_id bigint NOT NULL,
    icao24 text,
    callsign text,
    flight_number text,
    provider text NOT NULL,
    provider_record_id text,
    operator_code text,
    operator_name text,
    registration text,
    aircraft_icao_type text,
    aircraft_name text,
    origin_airport_code text,
    destination_airport_code text,
    diverted_airport_code text,
    route_status text,
    scheduled_departure_utc timestamp with time zone,
    scheduled_arrival_utc timestamp with time zone,
    confidence numeric(5,2),
    payload jsonb,
    fetched_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE aviation.flight_enrichment OWNER TO postgres;

--
-- TOC entry 261 (class 1259 OID 57733)
-- Name: flight_enrichment_enrichment_id_seq; Type: SEQUENCE; Schema: aviation; Owner: postgres
--

CREATE SEQUENCE aviation.flight_enrichment_enrichment_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE aviation.flight_enrichment_enrichment_id_seq OWNER TO postgres;

--
-- TOC entry 9282 (class 0 OID 0)
-- Dependencies: 261
-- Name: flight_enrichment_enrichment_id_seq; Type: SEQUENCE OWNED BY; Schema: aviation; Owner: postgres
--

ALTER SEQUENCE aviation.flight_enrichment_enrichment_id_seq OWNED BY aviation.flight_enrichment.enrichment_id;


--
-- TOC entry 260 (class 1259 OID 57718)
-- Name: flight_history; Type: TABLE; Schema: aviation; Owner: postgres
--

CREATE TABLE aviation.flight_history (
    history_id bigint NOT NULL,
    flight_id text,
    icao24 text,
    callsign text,
    flight_number text,
    registration text,
    operator_code text,
    operator_name text,
    aircraft_icao_type text,
    aircraft_name text,
    aircraft_category integer,
    latitude double precision,
    longitude double precision,
    baro_altitude_m double precision,
    geo_altitude_m double precision,
    altitude_ft integer,
    ground_speed_mps double precision,
    ground_speed_kts double precision,
    heading_deg double precision,
    vertical_rate_mps double precision,
    vertical_rate_fpm double precision,
    on_ground boolean,
    squawk text,
    spi boolean,
    position_source integer,
    origin_airport_code text,
    destination_airport_code text,
    diverted_airport_code text,
    route_status text,
    status text,
    source_live text,
    source_route text,
    source_aircraft text,
    source_operator text,
    source text,
    route_confidence numeric(5,2),
    aircraft_confidence numeric(5,2),
    opensky_time_position timestamp with time zone,
    opensky_last_contact timestamp with time zone,
    first_seen_at timestamp with time zone,
    last_seen_at timestamp with time zone,
    updated_at timestamp with time zone,
    archived_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE aviation.flight_history OWNER TO postgres;

--
-- TOC entry 259 (class 1259 OID 57717)
-- Name: flight_history_history_id_seq; Type: SEQUENCE; Schema: aviation; Owner: postgres
--

CREATE SEQUENCE aviation.flight_history_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE aviation.flight_history_history_id_seq OWNER TO postgres;

--
-- TOC entry 9283 (class 0 OID 0)
-- Dependencies: 259
-- Name: flight_history_history_id_seq; Type: SEQUENCE OWNED BY; Schema: aviation; Owner: postgres
--

ALTER SEQUENCE aviation.flight_history_history_id_seq OWNED BY aviation.flight_history.history_id;


--
-- TOC entry 264 (class 1259 OID 57748)
-- Name: flight_ingest_raw; Type: TABLE; Schema: aviation; Owner: postgres
--

CREATE TABLE aviation.flight_ingest_raw (
    raw_id bigint NOT NULL,
    provider text DEFAULT 'opensky'::text NOT NULL,
    batch_time timestamp with time zone DEFAULT now() NOT NULL,
    icao24 text,
    callsign text,
    payload jsonb NOT NULL
);


ALTER TABLE aviation.flight_ingest_raw OWNER TO postgres;

--
-- TOC entry 263 (class 1259 OID 57747)
-- Name: flight_ingest_raw_raw_id_seq; Type: SEQUENCE; Schema: aviation; Owner: postgres
--

CREATE SEQUENCE aviation.flight_ingest_raw_raw_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE aviation.flight_ingest_raw_raw_id_seq OWNER TO postgres;

--
-- TOC entry 9284 (class 0 OID 0)
-- Dependencies: 263
-- Name: flight_ingest_raw_raw_id_seq; Type: SEQUENCE OWNED BY; Schema: aviation; Owner: postgres
--

ALTER SEQUENCE aviation.flight_ingest_raw_raw_id_seq OWNED BY aviation.flight_ingest_raw.raw_id;


--
-- TOC entry 258 (class 1259 OID 57693)
-- Name: flight_live; Type: TABLE; Schema: aviation; Owner: postgres
--

CREATE TABLE aviation.flight_live (
    live_id bigint NOT NULL,
    flight_id text,
    icao24 text,
    callsign text,
    flight_number text,
    registration text,
    operator_code text,
    operator_name text,
    aircraft_icao_type text,
    aircraft_name text,
    aircraft_category integer,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    baro_altitude_m double precision,
    geo_altitude_m double precision,
    altitude_ft integer,
    ground_speed_mps double precision,
    ground_speed_kts double precision,
    heading_deg double precision,
    vertical_rate_mps double precision,
    vertical_rate_fpm double precision,
    on_ground boolean,
    squawk text,
    spi boolean,
    position_source integer,
    origin_airport_code text,
    destination_airport_code text,
    diverted_airport_code text,
    route_status text,
    status text,
    source_live text DEFAULT 'opensky'::text NOT NULL,
    source_route text,
    source_aircraft text,
    source_operator text,
    source text,
    route_confidence numeric(5,2),
    aircraft_confidence numeric(5,2),
    opensky_time_position timestamp with time zone,
    opensky_last_contact timestamp with time zone,
    first_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    last_seen_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE aviation.flight_live OWNER TO postgres;

--
-- TOC entry 257 (class 1259 OID 57692)
-- Name: flight_live_live_id_seq; Type: SEQUENCE; Schema: aviation; Owner: postgres
--

CREATE SEQUENCE aviation.flight_live_live_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE aviation.flight_live_live_id_seq OWNER TO postgres;

--
-- TOC entry 9285 (class 0 OID 0)
-- Dependencies: 257
-- Name: flight_live_live_id_seq; Type: SEQUENCE OWNED BY; Schema: aviation; Owner: postgres
--

ALTER SEQUENCE aviation.flight_live_live_id_seq OWNED BY aviation.flight_live.live_id;


--
-- TOC entry 277 (class 1259 OID 86320)
-- Name: consumption_monthly; Type: TABLE; Schema: gas; Owner: postgres
--

CREATE TABLE gas.consumption_monthly (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    region text DEFAULT 'United States'::text NOT NULL,
    report_month date NOT NULL,
    total_consumption_bcf numeric(14,3),
    residential_bcf numeric(14,3),
    commercial_bcf numeric(14,3),
    industrial_bcf numeric(14,3),
    electric_power_bcf numeric(14,3),
    vehicle_fuel_bcf numeric(14,3),
    data_status text DEFAULT 'official'::text NOT NULL,
    source_system text DEFAULT 'EIA'::text NOT NULL,
    source_series text,
    source_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE gas.consumption_monthly OWNER TO postgres;

--
-- TOC entry 272 (class 1259 OID 78037)
-- Name: ingestion_log; Type: TABLE; Schema: gas; Owner: postgres
--

CREATE TABLE gas.ingestion_log (
    id integer NOT NULL,
    run_time timestamp with time zone DEFAULT now(),
    source_system text,
    dataset_name text,
    rows_processed integer,
    latest_date date,
    status text,
    message text
);


ALTER TABLE gas.ingestion_log OWNER TO postgres;

--
-- TOC entry 271 (class 1259 OID 78036)
-- Name: ingestion_log_id_seq; Type: SEQUENCE; Schema: gas; Owner: postgres
--

CREATE SEQUENCE gas.ingestion_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE gas.ingestion_log_id_seq OWNER TO postgres;

--
-- TOC entry 9286 (class 0 OID 0)
-- Dependencies: 271
-- Name: ingestion_log_id_seq; Type: SEQUENCE OWNED BY; Schema: gas; Owner: postgres
--

ALTER SEQUENCE gas.ingestion_log_id_seq OWNED BY gas.ingestion_log.id;


--
-- TOC entry 275 (class 1259 OID 86254)
-- Name: lng_exports_daily; Type: TABLE; Schema: gas; Owner: postgres
--

CREATE TABLE gas.lng_exports_daily (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    report_date date NOT NULL,
    terminal_name text NOT NULL,
    terminal_code text,
    region text DEFAULT 'USA'::text,
    export_bcf numeric,
    feedgas_bcf numeric,
    utilization_percent numeric,
    destination_region text,
    destination_country text,
    cargo_count integer,
    outage_flag boolean DEFAULT false,
    outage_notes text,
    source_system text DEFAULT 'EIA'::text NOT NULL,
    source_series text,
    ingested_at timestamp with time zone DEFAULT now()
);


ALTER TABLE gas.lng_exports_daily OWNER TO postgres;

--
-- TOC entry 281 (class 1259 OID 94402)
-- Name: lng_monthly; Type: TABLE; Schema: gas; Owner: postgres
--

CREATE TABLE gas.lng_monthly (
    id bigint NOT NULL,
    month date NOT NULL,
    region text DEFAULT 'United States'::text NOT NULL,
    lng_exports_bcf numeric(12,3),
    lng_imports_bcf numeric(12,3),
    net_lng_exports_bcf numeric(12,3),
    lng_exports_bcfd numeric(10,3),
    lng_imports_bcfd numeric(10,3),
    net_lng_exports_bcfd numeric(10,3),
    source_system text DEFAULT 'EIA'::text NOT NULL,
    source_series text,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE gas.lng_monthly OWNER TO postgres;

--
-- TOC entry 280 (class 1259 OID 94401)
-- Name: lng_monthly_id_seq; Type: SEQUENCE; Schema: gas; Owner: postgres
--

CREATE SEQUENCE gas.lng_monthly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE gas.lng_monthly_id_seq OWNER TO postgres;

--
-- TOC entry 9287 (class 0 OID 0)
-- Dependencies: 280
-- Name: lng_monthly_id_seq; Type: SEQUENCE OWNED BY; Schema: gas; Owner: postgres
--

ALTER SEQUENCE gas.lng_monthly_id_seq OWNED BY gas.lng_monthly.id;


--
-- TOC entry 274 (class 1259 OID 78048)
-- Name: market_signals; Type: TABLE; Schema: gas; Owner: postgres
--

CREATE TABLE gas.market_signals (
    id integer NOT NULL,
    signal_date date NOT NULL,
    region text NOT NULL,
    signal_type text NOT NULL,
    direction text NOT NULL,
    score numeric,
    confidence text,
    explanation text,
    source_system text DEFAULT 'aurion'::text,
    created_at timestamp with time zone DEFAULT now()
);


ALTER TABLE gas.market_signals OWNER TO postgres;

--
-- TOC entry 273 (class 1259 OID 78047)
-- Name: market_signals_id_seq; Type: SEQUENCE; Schema: gas; Owner: postgres
--

CREATE SEQUENCE gas.market_signals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE gas.market_signals_id_seq OWNER TO postgres;

--
-- TOC entry 9288 (class 0 OID 0)
-- Dependencies: 273
-- Name: market_signals_id_seq; Type: SEQUENCE OWNED BY; Schema: gas; Owner: postgres
--

ALTER SEQUENCE gas.market_signals_id_seq OWNED BY gas.market_signals.id;


--
-- TOC entry 276 (class 1259 OID 86272)
-- Name: pipeline_flows_daily; Type: TABLE; Schema: gas; Owner: postgres
--

CREATE TABLE gas.pipeline_flows_daily (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    report_date date NOT NULL,
    pipeline_name text NOT NULL,
    pipeline_code text,
    origin_region text,
    destination_region text,
    flow_direction text,
    flow_bcf numeric,
    capacity_bcf numeric,
    utilization_percent numeric,
    constraint_flag boolean DEFAULT false,
    maintenance_flag boolean DEFAULT false,
    gas_type text DEFAULT 'Natural Gas'::text,
    source_system text NOT NULL,
    source_series text,
    ingested_at timestamp with time zone DEFAULT now()
);


ALTER TABLE gas.pipeline_flows_daily OWNER TO postgres;

--
-- TOC entry 279 (class 1259 OID 86370)
-- Name: prices_daily; Type: TABLE; Schema: gas; Owner: postgres
--

CREATE TABLE gas.prices_daily (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    market text NOT NULL,
    region text NOT NULL,
    price_date date NOT NULL,
    price_usd_per_mmbtu numeric(10,4),
    change_usd numeric(10,4),
    change_pct numeric(10,4),
    data_status text DEFAULT 'official'::text NOT NULL,
    source_system text DEFAULT 'EIA'::text NOT NULL,
    source_series text,
    source_url text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE gas.prices_daily OWNER TO postgres;

--
-- TOC entry 283 (class 1259 OID 94421)
-- Name: production_monthly; Type: TABLE; Schema: gas; Owner: postgres
--

CREATE TABLE gas.production_monthly (
    id bigint NOT NULL,
    month date NOT NULL,
    region text DEFAULT 'United States'::text NOT NULL,
    dry_production_bcf numeric(12,3),
    marketed_production_bcf numeric(12,3),
    gross_withdrawals_bcf numeric(12,3),
    dry_production_bcfd numeric(10,3),
    marketed_production_bcfd numeric(10,3),
    gross_withdrawals_bcfd numeric(10,3),
    source_system text DEFAULT 'EIA'::text NOT NULL,
    source_series text,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE gas.production_monthly OWNER TO postgres;

--
-- TOC entry 282 (class 1259 OID 94420)
-- Name: production_monthly_id_seq; Type: SEQUENCE; Schema: gas; Owner: postgres
--

CREATE SEQUENCE gas.production_monthly_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE gas.production_monthly_id_seq OWNER TO postgres;

--
-- TOC entry 9289 (class 0 OID 0)
-- Dependencies: 282
-- Name: production_monthly_id_seq; Type: SEQUENCE OWNED BY; Schema: gas; Owner: postgres
--

ALTER SEQUENCE gas.production_monthly_id_seq OWNED BY gas.production_monthly.id;


--
-- TOC entry 284 (class 1259 OID 94439)
-- Name: states_consumption_monthly; Type: TABLE; Schema: gas; Owner: postgres
--

CREATE TABLE gas.states_consumption_monthly (
    month date NOT NULL,
    state_code text NOT NULL,
    state_name text,
    residential_bcf numeric,
    commercial_bcf numeric,
    industrial_bcf numeric,
    electric_power_bcf numeric,
    total_delivered_bcf numeric,
    source_system text DEFAULT 'EIA'::text,
    ingested_at timestamp with time zone DEFAULT now()
);


ALTER TABLE gas.states_consumption_monthly OWNER TO postgres;

--
-- TOC entry 270 (class 1259 OID 78021)
-- Name: storage_weekly; Type: TABLE; Schema: gas; Owner: postgres
--

CREATE TABLE gas.storage_weekly (
    id integer NOT NULL,
    region text NOT NULL,
    report_date date NOT NULL,
    total_bcf numeric,
    change_bcf numeric,
    year_ago_bcf numeric,
    five_year_avg_bcf numeric,
    surplus_vs_year_ago_bcf numeric,
    surplus_vs_five_year_avg_bcf numeric,
    source_system text DEFAULT 'eia'::text,
    source_series text,
    ingested_at timestamp with time zone DEFAULT now(),
    storage_year integer,
    storage_week integer,
    storage_month integer,
    storage_season text
);


ALTER TABLE gas.storage_weekly OWNER TO postgres;

--
-- TOC entry 269 (class 1259 OID 78020)
-- Name: storage_weekly_id_seq; Type: SEQUENCE; Schema: gas; Owner: postgres
--

CREATE SEQUENCE gas.storage_weekly_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE gas.storage_weekly_id_seq OWNER TO postgres;

--
-- TOC entry 9290 (class 0 OID 0)
-- Dependencies: 269
-- Name: storage_weekly_id_seq; Type: SEQUENCE OWNED BY; Schema: gas; Owner: postgres
--

ALTER SEQUENCE gas.storage_weekly_id_seq OWNED BY gas.storage_weekly.id;


--
-- TOC entry 278 (class 1259 OID 86346)
-- Name: weather_demand_regions; Type: TABLE; Schema: gas; Owner: postgres
--

CREATE TABLE gas.weather_demand_regions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    region_code text NOT NULL,
    region_name text NOT NULL,
    country_code text DEFAULT 'US'::text NOT NULL,
    latitude numeric(9,6) NOT NULL,
    longitude numeric(9,6) NOT NULL,
    population_weight numeric(10,6) DEFAULT 1.0 NOT NULL,
    gas_demand_weight numeric(10,6),
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE gas.weather_demand_regions OWNER TO postgres;

--
-- TOC entry 256 (class 1259 OID 57561)
-- Name: airports; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.airports (
    location_id bigint NOT NULL,
    ident text,
    iata_code text,
    airport_type text,
    scheduled_service text,
    gps_code text,
    local_code text,
    home_link text,
    wikipedia_link text
);


ALTER TABLE geo.airports OWNER TO postgres;

--
-- TOC entry 303 (class 1259 OID 225478)
-- Name: location; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.location (
    location_id bigint NOT NULL,
    location_type text NOT NULL,
    name text NOT NULL,
    short_name text,
    country_code character(2),
    subdivision_code text,
    municipality text,
    "position" public.geometry(Point,4326) NOT NULL,
    elevation_m double precision,
    timezone_name text,
    is_active boolean DEFAULT true NOT NULL,
    attributes jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT location_attributes_object_chk CHECK ((jsonb_typeof(attributes) = 'object'::text)),
    CONSTRAINT location_country_code_chk CHECK (((country_code IS NULL) OR (country_code ~ '^[A-Z]{2}$'::text))),
    CONSTRAINT location_elevation_m_chk CHECK (((elevation_m IS NULL) OR ((elevation_m >= ('-500'::integer)::double precision) AND (elevation_m <= (10000)::double precision)))),
    CONSTRAINT location_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT location_position_latitude_chk CHECK (((public.st_y("position") >= ('-90'::integer)::double precision) AND (public.st_y("position") <= (90)::double precision))),
    CONSTRAINT location_position_longitude_chk CHECK (((public.st_x("position") >= ('-180'::integer)::double precision) AND (public.st_x("position") <= (180)::double precision))),
    CONSTRAINT location_position_not_empty_chk CHECK ((NOT public.st_isempty("position"))),
    CONSTRAINT location_position_srid_chk CHECK ((public.st_srid("position") = 4326)),
    CONSTRAINT location_position_type_chk CHECK ((public.geometrytype("position") = 'POINT'::text)),
    CONSTRAINT location_subdivision_code_chk CHECK (((subdivision_code IS NULL) OR (btrim(subdivision_code) <> ''::text))),
    CONSTRAINT location_timezone_name_chk CHECK (((timezone_name IS NULL) OR (btrim(timezone_name) <> ''::text))),
    CONSTRAINT location_type_not_blank_chk CHECK ((btrim(location_type) <> ''::text))
);


ALTER TABLE geo.location OWNER TO postgres;

--
-- TOC entry 323 (class 1259 OID 225804)
-- Name: location_cell_map; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.location_cell_map (
    location_cell_map_id bigint NOT NULL,
    location_id bigint NOT NULL,
    grid_cell_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE geo.location_cell_map OWNER TO postgres;

--
-- TOC entry 322 (class 1259 OID 225803)
-- Name: location_cell_map_location_cell_map_id_seq; Type: SEQUENCE; Schema: geo; Owner: postgres
--

ALTER TABLE geo.location_cell_map ALTER COLUMN location_cell_map_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME geo.location_cell_map_location_cell_map_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 305 (class 1259 OID 225515)
-- Name: location_identifier; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.location_identifier (
    location_identifier_id bigint NOT NULL,
    location_id bigint NOT NULL,
    identifier_scheme text NOT NULL,
    identifier_value text NOT NULL,
    source_system text,
    is_primary boolean DEFAULT false NOT NULL,
    valid_from timestamp with time zone,
    valid_to timestamp with time zone,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT location_identifier_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT location_identifier_scheme_not_blank_chk CHECK ((btrim(identifier_scheme) <> ''::text)),
    CONSTRAINT location_identifier_source_system_chk CHECK (((source_system IS NULL) OR (btrim(source_system) <> ''::text))),
    CONSTRAINT location_identifier_validity_chk CHECK (((valid_to IS NULL) OR (valid_from IS NULL) OR (valid_to > valid_from))),
    CONSTRAINT location_identifier_value_not_blank_chk CHECK ((btrim(identifier_value) <> ''::text))
);


ALTER TABLE geo.location_identifier OWNER TO postgres;

--
-- TOC entry 304 (class 1259 OID 225514)
-- Name: location_identifier_location_identifier_id_seq; Type: SEQUENCE; Schema: geo; Owner: postgres
--

ALTER TABLE geo.location_identifier ALTER COLUMN location_identifier_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME geo.location_identifier_location_identifier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 302 (class 1259 OID 225477)
-- Name: location_location_id_seq; Type: SEQUENCE; Schema: geo; Owner: postgres
--

ALTER TABLE geo.location ALTER COLUMN location_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME geo.location_location_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 255 (class 1259 OID 57513)
-- Name: locations; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.locations (
    id bigint NOT NULL,
    entity_type text NOT NULL,
    name text,
    lat double precision NOT NULL,
    lng double precision NOT NULL,
    elevation_ft integer,
    country_code text,
    region_code text,
    municipality text,
    source_system text,
    source_id text,
    details jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE geo.locations OWNER TO postgres;

--
-- TOC entry 254 (class 1259 OID 57512)
-- Name: locations_id_seq; Type: SEQUENCE; Schema: geo; Owner: postgres
--

CREATE SEQUENCE geo.locations_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geo.locations_id_seq OWNER TO postgres;

--
-- TOC entry 9291 (class 0 OID 0)
-- Dependencies: 254
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: geo; Owner: postgres
--

ALTER SEQUENCE geo.locations_id_seq OWNED BY geo.locations.id;


--
-- TOC entry 268 (class 1259 OID 69937)
-- Name: ourairports_import; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.ourairports_import (
    id integer,
    ident text,
    type text,
    name text,
    latitude_deg double precision,
    longitude_deg double precision,
    elevation_ft integer,
    continent text,
    iso_country text,
    iso_region text,
    municipality text,
    scheduled_service text,
    gps_code text,
    iata_code text,
    local_code text,
    home_link text,
    wikipedia_link text,
    keywords text
);


ALTER TABLE geo.ourairports_import OWNER TO postgres;

--
-- TOC entry 265 (class 1259 OID 61941)
-- Name: ports; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.ports (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    source text DEFAULT 'wpi'::text NOT NULL,
    source_id text NOT NULL,
    name text NOT NULL,
    alt_name text,
    unlocode text,
    country_code text,
    water_body text,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    port_type text,
    size_class text,
    harbor_use text,
    tidal_range numeric,
    channel_depth numeric,
    anchorage_depth numeric,
    cargo_pier_depth numeric,
    max_vessel_length numeric,
    max_vessel_beam numeric,
    max_vessel_draft numeric,
    shelter_afforded text,
    has_container boolean,
    has_oil_terminal boolean,
    has_lng_terminal boolean,
    significance_scc integer,
    capacity_teu bigint,
    raw_json jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE geo.ports OWNER TO postgres;

--
-- TOC entry 313 (class 1259 OID 225632)
-- Name: region; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.region (
    region_id bigint NOT NULL,
    region_type_id bigint NOT NULL,
    name text NOT NULL,
    short_name text,
    country_code character(2),
    subdivision_code text,
    is_active boolean DEFAULT true NOT NULL,
    attributes jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT region_attributes_object_chk CHECK ((jsonb_typeof(attributes) = 'object'::text)),
    CONSTRAINT region_country_code_chk CHECK (((country_code IS NULL) OR (country_code ~ '^[A-Z]{2}$'::text))),
    CONSTRAINT region_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT region_subdivision_code_chk CHECK (((subdivision_code IS NULL) OR (btrim(subdivision_code) <> ''::text)))
);


ALTER TABLE geo.region OWNER TO postgres;

--
-- TOC entry 325 (class 1259 OID 225829)
-- Name: region_cell_map; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.region_cell_map (
    region_cell_map_id bigint NOT NULL,
    region_version_id bigint NOT NULL,
    grid_cell_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE geo.region_cell_map OWNER TO postgres;

--
-- TOC entry 324 (class 1259 OID 225828)
-- Name: region_cell_map_region_cell_map_id_seq; Type: SEQUENCE; Schema: geo; Owner: postgres
--

ALTER TABLE geo.region_cell_map ALTER COLUMN region_cell_map_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME geo.region_cell_map_region_cell_map_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 315 (class 1259 OID 225665)
-- Name: region_identifier; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.region_identifier (
    region_identifier_id bigint NOT NULL,
    region_id bigint NOT NULL,
    identifier_scheme text NOT NULL,
    identifier_value text NOT NULL,
    source_system text,
    is_primary boolean DEFAULT false NOT NULL,
    valid_from timestamp with time zone,
    valid_to timestamp with time zone,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT region_identifier_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT region_identifier_scheme_not_blank_chk CHECK ((btrim(identifier_scheme) <> ''::text)),
    CONSTRAINT region_identifier_source_system_chk CHECK (((source_system IS NULL) OR (btrim(source_system) <> ''::text))),
    CONSTRAINT region_identifier_validity_chk CHECK (((valid_to IS NULL) OR (valid_from IS NULL) OR (valid_to > valid_from))),
    CONSTRAINT region_identifier_value_not_blank_chk CHECK ((btrim(identifier_value) <> ''::text))
);


ALTER TABLE geo.region_identifier OWNER TO postgres;

--
-- TOC entry 314 (class 1259 OID 225664)
-- Name: region_identifier_region_identifier_id_seq; Type: SEQUENCE; Schema: geo; Owner: postgres
--

ALTER TABLE geo.region_identifier ALTER COLUMN region_identifier_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME geo.region_identifier_region_identifier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 312 (class 1259 OID 225631)
-- Name: region_region_id_seq; Type: SEQUENCE; Schema: geo; Owner: postgres
--

ALTER TABLE geo.region ALTER COLUMN region_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME geo.region_region_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 331 (class 1259 OID 229252)
-- Name: region_relationship; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.region_relationship (
    region_relationship_id bigint NOT NULL,
    parent_region_id bigint NOT NULL,
    child_region_id bigint NOT NULL,
    relationship_type text NOT NULL,
    spatial_dataset_version_id bigint,
    valid_from date,
    valid_to date,
    is_current boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT region_relationship_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT region_relationship_not_self_chk CHECK ((parent_region_id <> child_region_id)),
    CONSTRAINT region_relationship_type_not_blank_chk CHECK ((btrim(relationship_type) <> ''::text)),
    CONSTRAINT region_relationship_validity_chk CHECK (((valid_to IS NULL) OR (valid_from IS NULL) OR (valid_to > valid_from)))
);


ALTER TABLE geo.region_relationship OWNER TO postgres;

--
-- TOC entry 330 (class 1259 OID 229251)
-- Name: region_relationship_region_relationship_id_seq; Type: SEQUENCE; Schema: geo; Owner: postgres
--

ALTER TABLE geo.region_relationship ALTER COLUMN region_relationship_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME geo.region_relationship_region_relationship_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 311 (class 1259 OID 225607)
-- Name: region_type; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.region_type (
    region_type_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT region_type_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT region_type_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT region_type_name_not_blank_chk CHECK ((btrim(name) <> ''::text))
);


ALTER TABLE geo.region_type OWNER TO postgres;

--
-- TOC entry 310 (class 1259 OID 225606)
-- Name: region_type_region_type_id_seq; Type: SEQUENCE; Schema: geo; Owner: postgres
--

ALTER TABLE geo.region_type ALTER COLUMN region_type_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME geo.region_type_region_type_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 317 (class 1259 OID 225699)
-- Name: region_version; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.region_version (
    region_version_id bigint NOT NULL,
    region_id bigint NOT NULL,
    spatial_dataset_version_id bigint,
    version_name text,
    valid_from date,
    valid_to date,
    geometry public.geometry(MultiPolygon,4326) NOT NULL,
    is_current boolean DEFAULT false NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT region_version_geometry_not_empty_chk CHECK ((NOT public.st_isempty(geometry))),
    CONSTRAINT region_version_geometry_srid_chk CHECK ((public.st_srid(geometry) = 4326)),
    CONSTRAINT region_version_geometry_valid_chk CHECK (public.st_isvalid(geometry)),
    CONSTRAINT region_version_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT region_version_validity_chk CHECK (((valid_to IS NULL) OR (valid_from IS NULL) OR (valid_to > valid_from))),
    CONSTRAINT region_version_version_name_chk CHECK (((version_name IS NULL) OR (btrim(version_name) <> ''::text)))
);


ALTER TABLE geo.region_version OWNER TO postgres;

--
-- TOC entry 316 (class 1259 OID 225698)
-- Name: region_version_region_version_id_seq; Type: SEQUENCE; Schema: geo; Owner: postgres
--

ALTER TABLE geo.region_version ALTER COLUMN region_version_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME geo.region_version_region_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 307 (class 1259 OID 225549)
-- Name: spatial_dataset; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.spatial_dataset (
    spatial_dataset_id bigint NOT NULL,
    provider_name text NOT NULL,
    dataset_name text NOT NULL,
    dataset_code text,
    description text,
    source_url text,
    licence_name text,
    licence_url text,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT spatial_dataset_code_not_blank_chk CHECK (((dataset_code IS NULL) OR (btrim(dataset_code) <> ''::text))),
    CONSTRAINT spatial_dataset_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT spatial_dataset_name_not_blank_chk CHECK ((btrim(dataset_name) <> ''::text)),
    CONSTRAINT spatial_dataset_provider_name_not_blank_chk CHECK ((btrim(provider_name) <> ''::text))
);


ALTER TABLE geo.spatial_dataset OWNER TO postgres;

--
-- TOC entry 306 (class 1259 OID 225548)
-- Name: spatial_dataset_spatial_dataset_id_seq; Type: SEQUENCE; Schema: geo; Owner: postgres
--

ALTER TABLE geo.spatial_dataset ALTER COLUMN spatial_dataset_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME geo.spatial_dataset_spatial_dataset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 309 (class 1259 OID 225576)
-- Name: spatial_dataset_version; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.spatial_dataset_version (
    spatial_dataset_version_id bigint NOT NULL,
    spatial_dataset_id bigint NOT NULL,
    version_name text NOT NULL,
    release_date date,
    valid_from date,
    valid_to date,
    source_uri text,
    checksum text,
    srid integer,
    is_current boolean DEFAULT false NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT spatial_dataset_version_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT spatial_dataset_version_name_not_blank_chk CHECK ((btrim(version_name) <> ''::text)),
    CONSTRAINT spatial_dataset_version_srid_chk CHECK (((srid IS NULL) OR (srid > 0))),
    CONSTRAINT spatial_dataset_version_validity_chk CHECK (((valid_to IS NULL) OR (valid_from IS NULL) OR (valid_to > valid_from)))
);


ALTER TABLE geo.spatial_dataset_version OWNER TO postgres;

--
-- TOC entry 308 (class 1259 OID 225575)
-- Name: spatial_dataset_version_spatial_dataset_version_id_seq; Type: SEQUENCE; Schema: geo; Owner: postgres
--

ALTER TABLE geo.spatial_dataset_version ALTER COLUMN spatial_dataset_version_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME geo.spatial_dataset_version_spatial_dataset_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 334 (class 1259 OID 242084)
-- Name: stage_country_name_iso2; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.stage_country_name_iso2 (
    source_country_name text NOT NULL,
    iso2 character(2),
    match_method text,
    reviewed boolean DEFAULT false NOT NULL,
    CONSTRAINT stage_country_name_iso2_iso_chk CHECK (((iso2 IS NULL) OR (iso2 ~ '^[A-Z]{2}$'::text)))
);


ALTER TABLE geo.stage_country_name_iso2 OWNER TO postgres;

--
-- TOC entry 329 (class 1259 OID 226046)
-- Name: stage_tiger_2025_county; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.stage_tiger_2025_county (
    gid integer NOT NULL,
    statefp character varying(2),
    countyfp character varying(3),
    countyns character varying(8),
    geoid character varying(5),
    geoidfq character varying(14),
    name character varying(100),
    namelsad character varying(100),
    lsad character varying(2),
    classfp character varying(2),
    mtfcc character varying(5),
    csafp character varying(3),
    cbsafp character varying(5),
    metdivfp character varying(5),
    funcstat character varying(1),
    aland double precision,
    awater double precision,
    intptlat character varying(11),
    intptlon character varying(12),
    geom public.geometry(MultiPolygon,4326)
);


ALTER TABLE geo.stage_tiger_2025_county OWNER TO postgres;

--
-- TOC entry 328 (class 1259 OID 226045)
-- Name: stage_tiger_2025_county_gid_seq; Type: SEQUENCE; Schema: geo; Owner: postgres
--

CREATE SEQUENCE geo.stage_tiger_2025_county_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geo.stage_tiger_2025_county_gid_seq OWNER TO postgres;

--
-- TOC entry 9292 (class 0 OID 0)
-- Dependencies: 328
-- Name: stage_tiger_2025_county_gid_seq; Type: SEQUENCE OWNED BY; Schema: geo; Owner: postgres
--

ALTER SEQUENCE geo.stage_tiger_2025_county_gid_seq OWNED BY geo.stage_tiger_2025_county.gid;


--
-- TOC entry 333 (class 1259 OID 238882)
-- Name: stage_tiger_2025_county_utf8; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.stage_tiger_2025_county_utf8 (
    gid integer NOT NULL,
    statefp character varying(2),
    countyfp character varying(3),
    countyns character varying(8),
    geoid character varying(5),
    geoidfq character varying(14),
    name character varying(100),
    namelsad character varying(100),
    lsad character varying(2),
    classfp character varying(2),
    mtfcc character varying(5),
    csafp character varying(3),
    cbsafp character varying(5),
    metdivfp character varying(5),
    funcstat character varying(1),
    aland double precision,
    awater double precision,
    intptlat character varying(11),
    intptlon character varying(12),
    geom public.geometry(MultiPolygon,4326)
);


ALTER TABLE geo.stage_tiger_2025_county_utf8 OWNER TO postgres;

--
-- TOC entry 332 (class 1259 OID 238881)
-- Name: stage_tiger_2025_county_utf8_gid_seq; Type: SEQUENCE; Schema: geo; Owner: postgres
--

CREATE SEQUENCE geo.stage_tiger_2025_county_utf8_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geo.stage_tiger_2025_county_utf8_gid_seq OWNER TO postgres;

--
-- TOC entry 9293 (class 0 OID 0)
-- Dependencies: 332
-- Name: stage_tiger_2025_county_utf8_gid_seq; Type: SEQUENCE OWNED BY; Schema: geo; Owner: postgres
--

ALTER SEQUENCE geo.stage_tiger_2025_county_utf8_gid_seq OWNED BY geo.stage_tiger_2025_county_utf8.gid;


--
-- TOC entry 327 (class 1259 OID 225854)
-- Name: stage_tiger_2025_state; Type: TABLE; Schema: geo; Owner: postgres
--

CREATE TABLE geo.stage_tiger_2025_state (
    gid integer NOT NULL,
    region character varying(2),
    division character varying(2),
    statefp character varying(2),
    statens character varying(8),
    geoid character varying(2),
    geoidfq character varying(11),
    stusps character varying(2),
    name character varying(100),
    lsad character varying(2),
    mtfcc character varying(5),
    funcstat character varying(1),
    aland double precision,
    awater double precision,
    intptlat character varying(11),
    intptlon character varying(12),
    geom public.geometry(MultiPolygon,4326)
);


ALTER TABLE geo.stage_tiger_2025_state OWNER TO postgres;

--
-- TOC entry 326 (class 1259 OID 225853)
-- Name: stage_tiger_2025_state_gid_seq; Type: SEQUENCE; Schema: geo; Owner: postgres
--

CREATE SEQUENCE geo.stage_tiger_2025_state_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE geo.stage_tiger_2025_state_gid_seq OWNER TO postgres;

--
-- TOC entry 9294 (class 0 OID 0)
-- Dependencies: 326
-- Name: stage_tiger_2025_state_gid_seq; Type: SEQUENCE OWNED BY; Schema: geo; Owner: postgres
--

ALTER SEQUENCE geo.stage_tiger_2025_state_gid_seq OWNED BY geo.stage_tiger_2025_state.gid;


--
-- TOC entry 253 (class 1259 OID 57496)
-- Name: locations; Type: TABLE; Schema: locations; Owner: postgres
--

CREATE TABLE locations.locations (
    id integer NOT NULL,
    type text NOT NULL,
    name text,
    lat double precision NOT NULL,
    lng double precision NOT NULL,
    elevation_ft integer,
    code text,
    details jsonb,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE locations.locations OWNER TO postgres;

--
-- TOC entry 252 (class 1259 OID 57495)
-- Name: locations_id_seq; Type: SEQUENCE; Schema: locations; Owner: postgres
--

CREATE SEQUENCE locations.locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE locations.locations_id_seq OWNER TO postgres;

--
-- TOC entry 9295 (class 0 OID 0)
-- Dependencies: 252
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: locations; Owner: postgres
--

ALTER SEQUENCE locations.locations_id_seq OWNED BY locations.locations.id;


--
-- TOC entry 267 (class 1259 OID 69871)
-- Name: assets; Type: TABLE; Schema: mining; Owner: postgres
--

CREATE TABLE mining.assets (
    id bigint CONSTRAINT mines_id_not_null NOT NULL,
    location_id bigint CONSTRAINT mines_location_id_not_null NOT NULL,
    source_system text DEFAULT 'icmm'::text CONSTRAINT mines_source_system_not_null NOT NULL,
    source_id text,
    mine_name text,
    confidence_factor text,
    asset_type_raw text,
    primary_commodity text CONSTRAINT mines_primary_commodity_not_null NOT NULL,
    primary_commodity_group text,
    secondary_commodity text,
    other_commodities text[] DEFAULT '{}'::text[],
    all_commodities text[] DEFAULT '{}'::text[],
    group_names text,
    importance_score double precision DEFAULT 0.9,
    details jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);


ALTER TABLE mining.assets OWNER TO postgres;

--
-- TOC entry 266 (class 1259 OID 69870)
-- Name: mines_id_seq; Type: SEQUENCE; Schema: mining; Owner: postgres
--

CREATE SEQUENCE mining.mines_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE mining.mines_id_seq OWNER TO postgres;

--
-- TOC entry 9296 (class 0 OID 0)
-- Dependencies: 266
-- Name: mines_id_seq; Type: SEQUENCE OWNED BY; Schema: mining; Owner: postgres
--

ALTER SEQUENCE mining.mines_id_seq OWNED BY mining.assets.id;


--
-- TOC entry 251 (class 1259 OID 57346)
-- Name: locations; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.locations (
    id integer NOT NULL,
    type text NOT NULL,
    name text,
    lat double precision NOT NULL,
    lng double precision NOT NULL,
    details jsonb,
    created_at timestamp without time zone DEFAULT now()
);


ALTER TABLE public.locations OWNER TO postgres;

--
-- TOC entry 250 (class 1259 OID 57345)
-- Name: locations_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.locations_id_seq OWNER TO postgres;

--
-- TOC entry 9297 (class 0 OID 0)
-- Dependencies: 250
-- Name: locations_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.locations_id_seq OWNED BY public.locations.id;


--
-- TOC entry 247 (class 1259 OID 49153)
-- Name: signals; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.signals (
    id integer NOT NULL,
    module character varying,
    signal_type character varying,
    name character varying,
    value double precision,
    baseline double precision,
    deviation double precision,
    severity character varying,
    "timestamp" timestamp without time zone,
    expires_at timestamp without time zone,
    source character varying,
    extra_metadata json,
    tags json,
    confidence double precision
);


ALTER TABLE public.signals OWNER TO postgres;

--
-- TOC entry 246 (class 1259 OID 49152)
-- Name: signals_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.signals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.signals_id_seq OWNER TO postgres;

--
-- TOC entry 9298 (class 0 OID 0)
-- Dependencies: 246
-- Name: signals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.signals_id_seq OWNED BY public.signals.id;


--
-- TOC entry 241 (class 1259 OID 32769)
-- Name: strategic_point; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.strategic_point (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name text NOT NULL,
    point_type text NOT NULL,
    subtype text,
    country_code text,
    region_name text,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    importance_score numeric(10,4),
    source_system text,
    external_ref text,
    metadata jsonb,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT strategic_point_lat_chk CHECK (((latitude >= ('-90'::integer)::double precision) AND (latitude <= (90)::double precision))),
    CONSTRAINT strategic_point_lon_chk CHECK (((longitude >= ('-180'::integer)::double precision) AND (longitude <= (180)::double precision)))
);


ALTER TABLE public.strategic_point OWNER TO postgres;

--
-- TOC entry 243 (class 1259 OID 32841)
-- Name: strategic_point_grid_map; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.strategic_point_grid_map (
    strategic_point_id uuid NOT NULL,
    grid_point_id uuid NOT NULL,
    distance_km double precision,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.strategic_point_grid_map OWNER TO postgres;

--
-- TOC entry 238 (class 1259 OID 24904)
-- Name: weather_climatology_daily; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weather_climatology_daily (
    location_id uuid NOT NULL,
    day_of_year integer NOT NULL,
    baseline_temp_c double precision,
    baseline_precip_mm double precision,
    baseline_humidity_pct double precision,
    baseline_wind_mps double precision,
    sample_count integer DEFAULT 0 NOT NULL,
    computed_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT weather_climatology_doy_chk CHECK (((day_of_year >= 1) AND (day_of_year <= 366)))
);


ALTER TABLE public.weather_climatology_daily OWNER TO postgres;

--
-- TOC entry 249 (class 1259 OID 49168)
-- Name: weather_data; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weather_data (
    id integer NOT NULL,
    location character varying(100) NOT NULL,
    "timestamp" timestamp without time zone,
    temperature_2m double precision,
    apparent_temperature double precision,
    relative_humidity double precision,
    precipitation double precision,
    wind_speed_10m double precision,
    wind_direction_10m double precision,
    cloud_cover double precision,
    soil_temperature_0cm double precision,
    soil_moisture_index double precision,
    et0_evapotranspiration double precision,
    dew_point double precision,
    weather_code integer,
    source character varying(50),
    extra_metadata json
);


ALTER TABLE public.weather_data OWNER TO postgres;

--
-- TOC entry 248 (class 1259 OID 49167)
-- Name: weather_data_id_seq; Type: SEQUENCE; Schema: public; Owner: postgres
--

CREATE SEQUENCE public.weather_data_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER SEQUENCE public.weather_data_id_seq OWNER TO postgres;

--
-- TOC entry 9299 (class 0 OID 0)
-- Dependencies: 248
-- Name: weather_data_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: postgres
--

ALTER SEQUENCE public.weather_data_id_seq OWNED BY public.weather_data.id;


--
-- TOC entry 236 (class 1259 OID 24861)
-- Name: weather_forecast_run; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weather_forecast_run (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider text NOT NULL,
    model_name text,
    product_name text,
    issued_at timestamp with time zone NOT NULL,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    source_version text,
    run_metadata jsonb,
    raw_payload jsonb
);


ALTER TABLE public.weather_forecast_run OWNER TO postgres;

--
-- TOC entry 237 (class 1259 OID 24876)
-- Name: weather_forecast_value; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weather_forecast_value (
    forecast_run_id uuid NOT NULL,
    location_id uuid NOT NULL,
    valid_time timestamp with time zone NOT NULL,
    lead_hours integer NOT NULL,
    temperature_c double precision,
    feels_like_c double precision,
    dew_point_c double precision,
    humidity_pct double precision,
    pressure_hpa double precision,
    wind_speed_mps double precision,
    wind_gust_mps double precision,
    wind_dir_deg integer,
    precip_mm double precision,
    snow_mm double precision,
    cloud_cover_pct double precision,
    visibility_km double precision,
    uv_index double precision,
    condition_code text,
    condition_text text,
    provider_field_map jsonb,
    CONSTRAINT weather_forecast_value_cloud_chk CHECK (((cloud_cover_pct IS NULL) OR ((cloud_cover_pct >= (0)::double precision) AND (cloud_cover_pct <= (100)::double precision)))),
    CONSTRAINT weather_forecast_value_humidity_chk CHECK (((humidity_pct IS NULL) OR ((humidity_pct >= (0)::double precision) AND (humidity_pct <= (100)::double precision)))),
    CONSTRAINT weather_forecast_value_lead_chk CHECK ((lead_hours >= 0)),
    CONSTRAINT weather_forecast_value_winddir_chk CHECK (((wind_dir_deg IS NULL) OR ((wind_dir_deg >= 0) AND (wind_dir_deg <= 360))))
);


ALTER TABLE public.weather_forecast_value OWNER TO postgres;

--
-- TOC entry 240 (class 1259 OID 24944)
-- Name: weather_gas_signal; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weather_gas_signal (
    location_id uuid NOT NULL,
    signal_time timestamp with time zone NOT NULL,
    computed_at timestamp with time zone DEFAULT now() NOT NULL,
    temp_anomaly_c double precision,
    hdd double precision,
    wind_anomaly_pct double precision,
    gas_score double precision NOT NULL,
    confidence double precision,
    explanation text,
    signal_payload jsonb
);


ALTER TABLE public.weather_gas_signal OWNER TO postgres;

--
-- TOC entry 242 (class 1259 OID 32818)
-- Name: weather_grid_point; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weather_grid_point (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    grid_code text NOT NULL,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    resolution_deg double precision NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT weather_grid_point_lat_chk CHECK (((latitude >= ('-90'::integer)::double precision) AND (latitude <= (90)::double precision))),
    CONSTRAINT weather_grid_point_lon_chk CHECK (((longitude >= ('-180'::integer)::double precision) AND (longitude <= (180)::double precision))),
    CONSTRAINT weather_grid_point_resolution_chk CHECK ((resolution_deg > (0)::double precision))
);


ALTER TABLE public.weather_grid_point OWNER TO postgres;

--
-- TOC entry 244 (class 1259 OID 32860)
-- Name: weather_grid_point_import; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weather_grid_point_import (
    grid_code text,
    latitude double precision,
    longitude double precision,
    resolution_deg double precision
);


ALTER TABLE public.weather_grid_point_import OWNER TO postgres;

--
-- TOC entry 239 (class 1259 OID 24926)
-- Name: weather_ingestion_run; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weather_ingestion_run (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    provider text NOT NULL,
    location_id uuid,
    requested_at timestamp with time zone DEFAULT now() NOT NULL,
    response_status integer,
    raw_file_path text,
    notes text
);


ALTER TABLE public.weather_ingestion_run OWNER TO postgres;

--
-- TOC entry 235 (class 1259 OID 24817)
-- Name: weather_location; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weather_location (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    source_system text DEFAULT 'visual_crossing'::text NOT NULL,
    provider_location_key text,
    name text NOT NULL,
    country_code text,
    region_name text,
    latitude double precision NOT NULL,
    longitude double precision NOT NULL,
    elevation_m double precision,
    timezone_name text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    location_code text,
    CONSTRAINT weather_location_lat_chk CHECK (((latitude >= ('-90'::integer)::double precision) AND (latitude <= (90)::double precision))),
    CONSTRAINT weather_location_lon_chk CHECK (((longitude >= ('-180'::integer)::double precision) AND (longitude <= (180)::double precision)))
);


ALTER TABLE public.weather_location OWNER TO postgres;

--
-- TOC entry 245 (class 1259 OID 40960)
-- Name: weather_observation; Type: TABLE; Schema: public; Owner: postgres
--

CREATE TABLE public.weather_observation (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    grid_point_id uuid NOT NULL,
    observation_time timestamp with time zone NOT NULL,
    data_type text NOT NULL,
    source_system text DEFAULT 'visual_crossing'::text NOT NULL,
    temp_c double precision,
    feels_like_c double precision,
    humidity_pct double precision,
    dew_point_c double precision,
    pressure_mb double precision,
    wind_speed_kph double precision,
    wind_gust_kph double precision,
    wind_dir_deg double precision,
    precip_mm double precision,
    snow_mm double precision,
    cloud_cover_pct double precision,
    visibility_km double precision,
    solar_radiation_wm2 double precision,
    uv_index double precision,
    conditions_text text,
    icon text,
    raw_payload jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.weather_observation OWNER TO postgres;

--
-- TOC entry 376 (class 1259 OID 242774)
-- Name: accumulation_period; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.accumulation_period (
    accumulation_period_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    duration_seconds bigint,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT accumulation_period_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT accumulation_period_duration_chk CHECK (((duration_seconds IS NULL) OR (duration_seconds > 0))),
    CONSTRAINT accumulation_period_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT accumulation_period_name_not_blank_chk CHECK ((btrim(name) <> ''::text))
);


ALTER TABLE weather.accumulation_period OWNER TO postgres;

--
-- TOC entry 375 (class 1259 OID 242773)
-- Name: accumulation_period_accumulation_period_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.accumulation_period ALTER COLUMN accumulation_period_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.accumulation_period_accumulation_period_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 468 (class 1259 OID 245393)
-- Name: bias_correction_definition; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.bias_correction_definition (
    bias_correction_definition_id bigint CONSTRAINT bias_correction_definition_bias_correction_definition__not_null NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    target_variable_id bigint NOT NULL,
    training_observation_product_id bigint CONSTRAINT bias_correction_definition_training_observation_produc_not_null NOT NULL,
    correction_method text NOT NULL,
    algorithm_version text NOT NULL,
    training_period_start timestamp with time zone NOT NULL,
    training_period_end timestamp with time zone NOT NULL,
    lead_minutes_start integer,
    lead_minutes_end integer,
    valid_from timestamp with time zone,
    valid_to timestamp with time zone,
    season_code text,
    month_number smallint,
    geography_scope text,
    derivation_version_id bigint,
    is_active boolean DEFAULT true NOT NULL,
    is_current boolean DEFAULT false NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT bias_correction_definition_algorithm_version_chk CHECK ((btrim(algorithm_version) <> ''::text)),
    CONSTRAINT bias_correction_definition_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT bias_correction_definition_geography_scope_chk CHECK (((geography_scope IS NULL) OR (btrim(geography_scope) <> ''::text))),
    CONSTRAINT bias_correction_definition_lead_band_chk CHECK (((lead_minutes_start IS NULL) OR (lead_minutes_end IS NULL) OR (lead_minutes_end >= lead_minutes_start))),
    CONSTRAINT bias_correction_definition_lead_end_chk CHECK (((lead_minutes_end IS NULL) OR (lead_minutes_end >= 0))),
    CONSTRAINT bias_correction_definition_lead_start_chk CHECK (((lead_minutes_start IS NULL) OR (lead_minutes_start >= 0))),
    CONSTRAINT bias_correction_definition_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT bias_correction_definition_method_not_blank_chk CHECK ((btrim(correction_method) <> ''::text)),
    CONSTRAINT bias_correction_definition_month_chk CHECK (((month_number IS NULL) OR ((month_number >= 1) AND (month_number <= 12)))),
    CONSTRAINT bias_correction_definition_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT bias_correction_definition_season_chk CHECK (((season_code IS NULL) OR (btrim(season_code) <> ''::text))),
    CONSTRAINT bias_correction_definition_training_period_chk CHECK ((training_period_end > training_period_start)),
    CONSTRAINT bias_correction_definition_validity_chk CHECK (((valid_to IS NULL) OR (valid_from IS NULL) OR (valid_to > valid_from)))
);


ALTER TABLE weather.bias_correction_definition OWNER TO postgres;

--
-- TOC entry 467 (class 1259 OID 245392)
-- Name: bias_correction_definition_bias_correction_definition_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.bias_correction_definition ALTER COLUMN bias_correction_definition_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.bias_correction_definition_bias_correction_definition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 470 (class 1259 OID 245454)
-- Name: bias_correction_input_product; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.bias_correction_input_product (
    bias_correction_input_product_id bigint CONSTRAINT bias_correction_input_produ_bias_correction_input_prod_not_null NOT NULL,
    bias_correction_definition_id bigint CONSTRAINT bias_correction_input_produ_bias_correction_definition_not_null NOT NULL,
    forecast_product_id bigint NOT NULL,
    role text DEFAULT 'input'::text NOT NULL,
    weight double precision,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT bias_correction_input_product_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT bias_correction_input_product_role_chk CHECK ((btrim(role) <> ''::text)),
    CONSTRAINT bias_correction_input_product_weight_chk CHECK (((weight IS NULL) OR (weight >= (0)::double precision)))
);


ALTER TABLE weather.bias_correction_input_product OWNER TO postgres;

--
-- TOC entry 469 (class 1259 OID 245453)
-- Name: bias_correction_input_product_bias_correction_input_product_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.bias_correction_input_product ALTER COLUMN bias_correction_input_product_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.bias_correction_input_product_bias_correction_input_product_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 440 (class 1259 OID 244533)
-- Name: cell_forecast; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.cell_forecast (
    cell_forecast_id bigint NOT NULL,
    forecast_run_id bigint NOT NULL,
    forecast_member_id bigint NOT NULL,
    forecast_product_id bigint NOT NULL,
    grid_cell_id bigint NOT NULL,
    valid_time timestamp with time zone NOT NULL,
    period_start timestamp with time zone,
    period_end timestamp with time zone,
    lead_minutes integer NOT NULL,
    observation_record_status_id smallint NOT NULL,
    ingestion_run_id bigint,
    derivation_run_id bigint NOT NULL,
    provider_published_at timestamp with time zone,
    received_at timestamp with time zone,
    processed_at timestamp with time zone DEFAULT now() NOT NULL,
    revision_no integer DEFAULT 1 NOT NULL,
    is_preferred boolean DEFAULT true NOT NULL,
    supersedes_cell_forecast_id bigint,
    supersedes_valid_time timestamp with time zone,
    air_temperature_2m_c double precision,
    apparent_temperature_2m_c double precision,
    dew_point_2m_c double precision,
    relative_humidity_2m_pct double precision,
    surface_pressure_hpa double precision,
    precipitation_mm double precision,
    rainfall_mm double precision,
    snowfall_mm double precision,
    snow_depth_mm double precision,
    wind_u_10m_ms double precision,
    wind_v_10m_ms double precision,
    wind_gust_10m_ms double precision,
    cloud_cover_pct double precision,
    visibility_m double precision,
    solar_radiation_w_m2 double precision,
    condition_code_id smallint,
    coverage_fraction double precision,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cell_forecast_cloud_cover_chk CHECK (((cloud_cover_pct IS NULL) OR ((cloud_cover_pct >= (0)::double precision) AND (cloud_cover_pct <= (100)::double precision)))),
    CONSTRAINT cell_forecast_coverage_chk CHECK (((coverage_fraction IS NULL) OR ((coverage_fraction >= (0)::double precision) AND (coverage_fraction <= (1)::double precision)))),
    CONSTRAINT cell_forecast_lead_minutes_chk CHECK ((lead_minutes >= 0)),
    CONSTRAINT cell_forecast_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT cell_forecast_period_chk CHECK ((((period_start IS NULL) AND (period_end IS NULL)) OR ((period_start IS NOT NULL) AND (period_end IS NOT NULL) AND (period_end > period_start)))),
    CONSTRAINT cell_forecast_precipitation_chk CHECK (((precipitation_mm IS NULL) OR (precipitation_mm >= (0)::double precision))),
    CONSTRAINT cell_forecast_rainfall_chk CHECK (((rainfall_mm IS NULL) OR (rainfall_mm >= (0)::double precision))),
    CONSTRAINT cell_forecast_relative_humidity_chk CHECK (((relative_humidity_2m_pct IS NULL) OR ((relative_humidity_2m_pct >= (0)::double precision) AND (relative_humidity_2m_pct <= (100)::double precision)))),
    CONSTRAINT cell_forecast_revision_chk CHECK ((revision_no >= 1)),
    CONSTRAINT cell_forecast_snow_depth_chk CHECK (((snow_depth_mm IS NULL) OR (snow_depth_mm >= (0)::double precision))),
    CONSTRAINT cell_forecast_snowfall_chk CHECK (((snowfall_mm IS NULL) OR (snowfall_mm >= (0)::double precision))),
    CONSTRAINT cell_forecast_supersession_chk CHECK ((((supersedes_cell_forecast_id IS NULL) AND (supersedes_valid_time IS NULL)) OR ((supersedes_cell_forecast_id IS NOT NULL) AND (supersedes_valid_time IS NOT NULL)))),
    CONSTRAINT cell_forecast_visibility_chk CHECK (((visibility_m IS NULL) OR (visibility_m >= (0)::double precision)))
)
PARTITION BY RANGE (valid_time);


ALTER TABLE weather.cell_forecast OWNER TO postgres;

--
-- TOC entry 439 (class 1259 OID 244532)
-- Name: cell_forecast_cell_forecast_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_forecast ALTER COLUMN cell_forecast_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME weather.cell_forecast_cell_forecast_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 452 (class 1259 OID 244944)
-- Name: cell_forecast_correction; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.cell_forecast_correction (
    cell_forecast_correction_id bigint NOT NULL,
    original_cell_forecast_id bigint NOT NULL,
    original_valid_time timestamp with time zone NOT NULL,
    replacement_cell_forecast_id bigint NOT NULL,
    replacement_valid_time timestamp with time zone NOT NULL,
    forecast_correction_reason_id smallint NOT NULL,
    source_artifact_id bigint,
    ingestion_run_id bigint,
    derivation_run_id bigint,
    provider_revision text,
    correction_time timestamp with time zone DEFAULT now() NOT NULL,
    notes text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cell_forecast_correction_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT cell_forecast_correction_not_self_chk CHECK (((original_cell_forecast_id <> replacement_cell_forecast_id) OR (original_valid_time <> replacement_valid_time))),
    CONSTRAINT cell_forecast_correction_notes_chk CHECK (((notes IS NULL) OR (btrim(notes) <> ''::text))),
    CONSTRAINT cell_forecast_correction_provider_revision_chk CHECK (((provider_revision IS NULL) OR (btrim(provider_revision) <> ''::text)))
);


ALTER TABLE weather.cell_forecast_correction OWNER TO postgres;

--
-- TOC entry 451 (class 1259 OID 244943)
-- Name: cell_forecast_correction_cell_forecast_correction_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_forecast_correction ALTER COLUMN cell_forecast_correction_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.cell_forecast_correction_cell_forecast_correction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 441 (class 1259 OID 244632)
-- Name: cell_forecast_default; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.cell_forecast_default (
    cell_forecast_id bigint CONSTRAINT cell_forecast_cell_forecast_id_not_null NOT NULL,
    forecast_run_id bigint CONSTRAINT cell_forecast_forecast_run_id_not_null NOT NULL,
    forecast_member_id bigint CONSTRAINT cell_forecast_forecast_member_id_not_null NOT NULL,
    forecast_product_id bigint CONSTRAINT cell_forecast_forecast_product_id_not_null NOT NULL,
    grid_cell_id bigint CONSTRAINT cell_forecast_grid_cell_id_not_null NOT NULL,
    valid_time timestamp with time zone CONSTRAINT cell_forecast_valid_time_not_null NOT NULL,
    period_start timestamp with time zone,
    period_end timestamp with time zone,
    lead_minutes integer CONSTRAINT cell_forecast_lead_minutes_not_null NOT NULL,
    observation_record_status_id smallint CONSTRAINT cell_forecast_observation_record_status_id_not_null NOT NULL,
    ingestion_run_id bigint,
    derivation_run_id bigint CONSTRAINT cell_forecast_derivation_run_id_not_null NOT NULL,
    provider_published_at timestamp with time zone,
    received_at timestamp with time zone,
    processed_at timestamp with time zone DEFAULT now() CONSTRAINT cell_forecast_processed_at_not_null NOT NULL,
    revision_no integer DEFAULT 1 CONSTRAINT cell_forecast_revision_no_not_null NOT NULL,
    is_preferred boolean DEFAULT true CONSTRAINT cell_forecast_is_preferred_not_null NOT NULL,
    supersedes_cell_forecast_id bigint,
    supersedes_valid_time timestamp with time zone,
    air_temperature_2m_c double precision,
    apparent_temperature_2m_c double precision,
    dew_point_2m_c double precision,
    relative_humidity_2m_pct double precision,
    surface_pressure_hpa double precision,
    precipitation_mm double precision,
    rainfall_mm double precision,
    snowfall_mm double precision,
    snow_depth_mm double precision,
    wind_u_10m_ms double precision,
    wind_v_10m_ms double precision,
    wind_gust_10m_ms double precision,
    cloud_cover_pct double precision,
    visibility_m double precision,
    solar_radiation_w_m2 double precision,
    condition_code_id smallint,
    coverage_fraction double precision,
    metadata jsonb DEFAULT '{}'::jsonb CONSTRAINT cell_forecast_metadata_not_null NOT NULL,
    created_at timestamp with time zone DEFAULT now() CONSTRAINT cell_forecast_created_at_not_null NOT NULL,
    CONSTRAINT cell_forecast_cloud_cover_chk CHECK (((cloud_cover_pct IS NULL) OR ((cloud_cover_pct >= (0)::double precision) AND (cloud_cover_pct <= (100)::double precision)))),
    CONSTRAINT cell_forecast_coverage_chk CHECK (((coverage_fraction IS NULL) OR ((coverage_fraction >= (0)::double precision) AND (coverage_fraction <= (1)::double precision)))),
    CONSTRAINT cell_forecast_lead_minutes_chk CHECK ((lead_minutes >= 0)),
    CONSTRAINT cell_forecast_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT cell_forecast_period_chk CHECK ((((period_start IS NULL) AND (period_end IS NULL)) OR ((period_start IS NOT NULL) AND (period_end IS NOT NULL) AND (period_end > period_start)))),
    CONSTRAINT cell_forecast_precipitation_chk CHECK (((precipitation_mm IS NULL) OR (precipitation_mm >= (0)::double precision))),
    CONSTRAINT cell_forecast_rainfall_chk CHECK (((rainfall_mm IS NULL) OR (rainfall_mm >= (0)::double precision))),
    CONSTRAINT cell_forecast_relative_humidity_chk CHECK (((relative_humidity_2m_pct IS NULL) OR ((relative_humidity_2m_pct >= (0)::double precision) AND (relative_humidity_2m_pct <= (100)::double precision)))),
    CONSTRAINT cell_forecast_revision_chk CHECK ((revision_no >= 1)),
    CONSTRAINT cell_forecast_snow_depth_chk CHECK (((snow_depth_mm IS NULL) OR (snow_depth_mm >= (0)::double precision))),
    CONSTRAINT cell_forecast_snowfall_chk CHECK (((snowfall_mm IS NULL) OR (snowfall_mm >= (0)::double precision))),
    CONSTRAINT cell_forecast_supersession_chk CHECK ((((supersedes_cell_forecast_id IS NULL) AND (supersedes_valid_time IS NULL)) OR ((supersedes_cell_forecast_id IS NOT NULL) AND (supersedes_valid_time IS NOT NULL)))),
    CONSTRAINT cell_forecast_visibility_chk CHECK (((visibility_m IS NULL) OR (visibility_m >= (0)::double precision)))
);


ALTER TABLE weather.cell_forecast_default OWNER TO postgres;

--
-- TOC entry 456 (class 1259 OID 245039)
-- Name: cell_forecast_revision; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.cell_forecast_revision (
    cell_forecast_revision_id bigint NOT NULL,
    forecast_revision_definition_id bigint NOT NULL,
    comparison_cell_forecast_id bigint NOT NULL,
    comparison_valid_time timestamp with time zone NOT NULL,
    newer_cell_forecast_id bigint NOT NULL,
    newer_valid_time timestamp with time zone NOT NULL,
    variable_id bigint NOT NULL,
    comparison_value double precision NOT NULL,
    newer_value double precision NOT NULL,
    absolute_change double precision NOT NULL,
    percentage_change double precision,
    change_direction text,
    change_category text,
    derivation_run_id bigint,
    calculated_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cell_forecast_revision_category_chk CHECK (((change_category IS NULL) OR (btrim(change_category) <> ''::text))),
    CONSTRAINT cell_forecast_revision_direction_chk CHECK (((change_direction IS NULL) OR (change_direction = ANY (ARRAY['increase'::text, 'decrease'::text, 'unchanged'::text])))),
    CONSTRAINT cell_forecast_revision_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT cell_forecast_revision_not_self_chk CHECK (((comparison_cell_forecast_id <> newer_cell_forecast_id) OR (comparison_valid_time <> newer_valid_time))),
    CONSTRAINT cell_forecast_revision_valid_time_chk CHECK ((comparison_valid_time = newer_valid_time))
);


ALTER TABLE weather.cell_forecast_revision OWNER TO postgres;

--
-- TOC entry 455 (class 1259 OID 245038)
-- Name: cell_forecast_revision_cell_forecast_revision_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_forecast_revision ALTER COLUMN cell_forecast_revision_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.cell_forecast_revision_cell_forecast_revision_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 443 (class 1259 OID 244718)
-- Name: cell_forecast_value; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.cell_forecast_value (
    cell_forecast_value_id bigint NOT NULL,
    cell_forecast_id bigint NOT NULL,
    valid_time timestamp with time zone NOT NULL,
    variable_id bigint NOT NULL,
    value_double double precision,
    value_text text,
    observation_record_status_id smallint,
    ingestion_run_id bigint,
    derivation_run_id bigint NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cell_forecast_value_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT cell_forecast_value_text_chk CHECK (((value_text IS NULL) OR (btrim(value_text) <> ''::text))),
    CONSTRAINT cell_forecast_value_value_chk CHECK ((((value_double IS NOT NULL) AND (value_text IS NULL)) OR ((value_double IS NULL) AND (value_text IS NOT NULL))))
);


ALTER TABLE weather.cell_forecast_value OWNER TO postgres;

--
-- TOC entry 442 (class 1259 OID 244717)
-- Name: cell_forecast_value_cell_forecast_value_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_forecast_value ALTER COLUMN cell_forecast_value_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.cell_forecast_value_cell_forecast_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 422 (class 1259 OID 244104)
-- Name: cell_observation_correction; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.cell_observation_correction (
    cell_observation_correction_id bigint CONSTRAINT cell_observation_correction_cell_observation_correctio_not_null NOT NULL,
    original_observation_id bigint NOT NULL,
    original_observation_time timestamp with time zone NOT NULL,
    replacement_observation_id bigint NOT NULL,
    replacement_observation_time timestamp with time zone CONSTRAINT cell_observation_correction_replacement_observation_ti_not_null NOT NULL,
    observation_correction_reason_id smallint CONSTRAINT cell_observation_correction_observation_correction_rea_not_null NOT NULL,
    source_artifact_id bigint,
    derivation_run_id bigint,
    correction_time timestamp with time zone DEFAULT now() NOT NULL,
    notes text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cell_observation_correction_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT cell_observation_correction_not_self_chk CHECK (((original_observation_id <> replacement_observation_id) OR (original_observation_time <> replacement_observation_time))),
    CONSTRAINT cell_observation_correction_notes_chk CHECK (((notes IS NULL) OR (btrim(notes) <> ''::text)))
);


ALTER TABLE weather.cell_observation_correction OWNER TO postgres;

--
-- TOC entry 421 (class 1259 OID 244103)
-- Name: cell_observation_correction_cell_observation_correction_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_correction ALTER COLUMN cell_observation_correction_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.cell_observation_correction_cell_observation_correction_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 403 (class 1259 OID 243560)
-- Name: cell_observation_daily; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.cell_observation_daily (
    cell_observation_daily_id bigint NOT NULL,
    observation_date date NOT NULL,
    grid_cell_id bigint NOT NULL,
    observation_product_id bigint NOT NULL,
    observation_record_status_id smallint NOT NULL,
    ingestion_run_id bigint,
    derivation_run_id bigint NOT NULL,
    period_start timestamp with time zone NOT NULL,
    period_end timestamp with time zone NOT NULL,
    provider_published_at timestamp with time zone,
    received_at timestamp with time zone,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    revision_no integer DEFAULT 1 NOT NULL,
    is_preferred boolean DEFAULT true NOT NULL,
    supersedes_observation_daily_id bigint,
    supersedes_observation_date date,
    air_temperature_2m_min_c double precision,
    air_temperature_2m_max_c double precision,
    air_temperature_2m_mean_c double precision,
    apparent_temperature_2m_min_c double precision,
    apparent_temperature_2m_max_c double precision,
    apparent_temperature_2m_mean_c double precision,
    dew_point_2m_min_c double precision,
    dew_point_2m_max_c double precision,
    dew_point_2m_mean_c double precision,
    relative_humidity_2m_min_pct double precision,
    relative_humidity_2m_max_pct double precision,
    relative_humidity_2m_mean_pct double precision,
    surface_pressure_mean_hpa double precision,
    precipitation_total_mm double precision,
    rainfall_total_mm double precision,
    snowfall_total_mm double precision,
    snow_depth_max_mm double precision,
    wind_u_10m_mean_ms double precision,
    wind_v_10m_mean_ms double precision,
    wind_gust_10m_max_ms double precision,
    cloud_cover_mean_pct double precision,
    visibility_mean_m double precision,
    solar_radiation_mean_w_m2 double precision,
    sample_count integer,
    coverage_fraction double precision,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cell_observation_daily_apparent_temperature_order_chk CHECK (((apparent_temperature_2m_min_c IS NULL) OR (apparent_temperature_2m_max_c IS NULL) OR (apparent_temperature_2m_min_c <= apparent_temperature_2m_max_c))),
    CONSTRAINT cell_observation_daily_cloud_cover_chk CHECK (((cloud_cover_mean_pct IS NULL) OR ((cloud_cover_mean_pct >= (0)::double precision) AND (cloud_cover_mean_pct <= (100)::double precision)))),
    CONSTRAINT cell_observation_daily_coverage_chk CHECK (((coverage_fraction IS NULL) OR ((coverage_fraction >= (0)::double precision) AND (coverage_fraction <= (1)::double precision)))),
    CONSTRAINT cell_observation_daily_dew_point_order_chk CHECK (((dew_point_2m_min_c IS NULL) OR (dew_point_2m_max_c IS NULL) OR (dew_point_2m_min_c <= dew_point_2m_max_c))),
    CONSTRAINT cell_observation_daily_humidity_max_chk CHECK (((relative_humidity_2m_max_pct IS NULL) OR ((relative_humidity_2m_max_pct >= (0)::double precision) AND (relative_humidity_2m_max_pct <= (100)::double precision)))),
    CONSTRAINT cell_observation_daily_humidity_mean_chk CHECK (((relative_humidity_2m_mean_pct IS NULL) OR ((relative_humidity_2m_mean_pct >= (0)::double precision) AND (relative_humidity_2m_mean_pct <= (100)::double precision)))),
    CONSTRAINT cell_observation_daily_humidity_min_chk CHECK (((relative_humidity_2m_min_pct IS NULL) OR ((relative_humidity_2m_min_pct >= (0)::double precision) AND (relative_humidity_2m_min_pct <= (100)::double precision)))),
    CONSTRAINT cell_observation_daily_humidity_order_chk CHECK (((relative_humidity_2m_min_pct IS NULL) OR (relative_humidity_2m_max_pct IS NULL) OR (relative_humidity_2m_min_pct <= relative_humidity_2m_max_pct))),
    CONSTRAINT cell_observation_daily_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT cell_observation_daily_period_chk CHECK ((period_end > period_start)),
    CONSTRAINT cell_observation_daily_precipitation_chk CHECK (((precipitation_total_mm IS NULL) OR (precipitation_total_mm >= (0)::double precision))),
    CONSTRAINT cell_observation_daily_rainfall_chk CHECK (((rainfall_total_mm IS NULL) OR (rainfall_total_mm >= (0)::double precision))),
    CONSTRAINT cell_observation_daily_revision_chk CHECK ((revision_no >= 1)),
    CONSTRAINT cell_observation_daily_sample_count_chk CHECK (((sample_count IS NULL) OR (sample_count >= 0))),
    CONSTRAINT cell_observation_daily_snow_depth_chk CHECK (((snow_depth_max_mm IS NULL) OR (snow_depth_max_mm >= (0)::double precision))),
    CONSTRAINT cell_observation_daily_snowfall_chk CHECK (((snowfall_total_mm IS NULL) OR (snowfall_total_mm >= (0)::double precision))),
    CONSTRAINT cell_observation_daily_supersession_chk CHECK ((((supersedes_observation_daily_id IS NULL) AND (supersedes_observation_date IS NULL)) OR ((supersedes_observation_daily_id IS NOT NULL) AND (supersedes_observation_date IS NOT NULL)))),
    CONSTRAINT cell_observation_daily_temperature_order_chk CHECK (((air_temperature_2m_min_c IS NULL) OR (air_temperature_2m_max_c IS NULL) OR (air_temperature_2m_min_c <= air_temperature_2m_max_c))),
    CONSTRAINT cell_observation_daily_visibility_chk CHECK (((visibility_mean_m IS NULL) OR (visibility_mean_m >= (0)::double precision)))
)
PARTITION BY RANGE (observation_date);


ALTER TABLE weather.cell_observation_daily OWNER TO postgres;

--
-- TOC entry 402 (class 1259 OID 243559)
-- Name: cell_observation_daily_cell_observation_daily_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_daily ALTER COLUMN cell_observation_daily_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME weather.cell_observation_daily_cell_observation_daily_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 426 (class 1259 OID 244224)
-- Name: cell_observation_daily_correction; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.cell_observation_daily_correction (
    cell_observation_daily_correction_id bigint CONSTRAINT cell_observation_daily_corr_cell_observation_daily_cor_not_null NOT NULL,
    original_observation_daily_id bigint CONSTRAINT cell_observation_daily_corr_original_observation_daily_not_null NOT NULL,
    original_observation_date date CONSTRAINT cell_observation_daily_corre_original_observation_date_not_null NOT NULL,
    replacement_observation_daily_id bigint CONSTRAINT cell_observation_daily_corr_replacement_observation_da_not_null NOT NULL,
    replacement_observation_date date CONSTRAINT cell_observation_daily_cor_replacement_observation_da_not_null1 NOT NULL,
    observation_correction_reason_id smallint CONSTRAINT cell_observation_daily_corr_observation_correction_rea_not_null NOT NULL,
    source_artifact_id bigint,
    derivation_run_id bigint,
    correction_time timestamp with time zone DEFAULT now() NOT NULL,
    notes text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cell_observation_daily_correction_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT cell_observation_daily_correction_not_self_chk CHECK (((original_observation_daily_id <> replacement_observation_daily_id) OR (original_observation_date <> replacement_observation_date))),
    CONSTRAINT cell_observation_daily_correction_notes_chk CHECK (((notes IS NULL) OR (btrim(notes) <> ''::text)))
);


ALTER TABLE weather.cell_observation_daily_correction OWNER TO postgres;

--
-- TOC entry 425 (class 1259 OID 244223)
-- Name: cell_observation_daily_correc_cell_observation_daily_correc_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_daily_correction ALTER COLUMN cell_observation_daily_correction_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.cell_observation_daily_correc_cell_observation_daily_correc_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 404 (class 1259 OID 243640)
-- Name: cell_observation_daily_default; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.cell_observation_daily_default (
    cell_observation_daily_id bigint CONSTRAINT cell_observation_daily_cell_observation_daily_id_not_null NOT NULL,
    observation_date date CONSTRAINT cell_observation_daily_observation_date_not_null NOT NULL,
    grid_cell_id bigint CONSTRAINT cell_observation_daily_grid_cell_id_not_null NOT NULL,
    observation_product_id bigint CONSTRAINT cell_observation_daily_observation_product_id_not_null NOT NULL,
    observation_record_status_id smallint CONSTRAINT cell_observation_daily_observation_record_status_id_not_null NOT NULL,
    ingestion_run_id bigint,
    derivation_run_id bigint CONSTRAINT cell_observation_daily_derivation_run_id_not_null NOT NULL,
    period_start timestamp with time zone CONSTRAINT cell_observation_daily_period_start_not_null NOT NULL,
    period_end timestamp with time zone CONSTRAINT cell_observation_daily_period_end_not_null NOT NULL,
    provider_published_at timestamp with time zone,
    received_at timestamp with time zone,
    ingested_at timestamp with time zone DEFAULT now() CONSTRAINT cell_observation_daily_ingested_at_not_null NOT NULL,
    revision_no integer DEFAULT 1 CONSTRAINT cell_observation_daily_revision_no_not_null NOT NULL,
    is_preferred boolean DEFAULT true CONSTRAINT cell_observation_daily_is_preferred_not_null NOT NULL,
    supersedes_observation_daily_id bigint,
    supersedes_observation_date date,
    air_temperature_2m_min_c double precision,
    air_temperature_2m_max_c double precision,
    air_temperature_2m_mean_c double precision,
    apparent_temperature_2m_min_c double precision,
    apparent_temperature_2m_max_c double precision,
    apparent_temperature_2m_mean_c double precision,
    dew_point_2m_min_c double precision,
    dew_point_2m_max_c double precision,
    dew_point_2m_mean_c double precision,
    relative_humidity_2m_min_pct double precision,
    relative_humidity_2m_max_pct double precision,
    relative_humidity_2m_mean_pct double precision,
    surface_pressure_mean_hpa double precision,
    precipitation_total_mm double precision,
    rainfall_total_mm double precision,
    snowfall_total_mm double precision,
    snow_depth_max_mm double precision,
    wind_u_10m_mean_ms double precision,
    wind_v_10m_mean_ms double precision,
    wind_gust_10m_max_ms double precision,
    cloud_cover_mean_pct double precision,
    visibility_mean_m double precision,
    solar_radiation_mean_w_m2 double precision,
    sample_count integer,
    coverage_fraction double precision,
    metadata jsonb DEFAULT '{}'::jsonb CONSTRAINT cell_observation_daily_metadata_not_null NOT NULL,
    created_at timestamp with time zone DEFAULT now() CONSTRAINT cell_observation_daily_created_at_not_null NOT NULL,
    CONSTRAINT cell_observation_daily_apparent_temperature_order_chk CHECK (((apparent_temperature_2m_min_c IS NULL) OR (apparent_temperature_2m_max_c IS NULL) OR (apparent_temperature_2m_min_c <= apparent_temperature_2m_max_c))),
    CONSTRAINT cell_observation_daily_cloud_cover_chk CHECK (((cloud_cover_mean_pct IS NULL) OR ((cloud_cover_mean_pct >= (0)::double precision) AND (cloud_cover_mean_pct <= (100)::double precision)))),
    CONSTRAINT cell_observation_daily_coverage_chk CHECK (((coverage_fraction IS NULL) OR ((coverage_fraction >= (0)::double precision) AND (coverage_fraction <= (1)::double precision)))),
    CONSTRAINT cell_observation_daily_dew_point_order_chk CHECK (((dew_point_2m_min_c IS NULL) OR (dew_point_2m_max_c IS NULL) OR (dew_point_2m_min_c <= dew_point_2m_max_c))),
    CONSTRAINT cell_observation_daily_humidity_max_chk CHECK (((relative_humidity_2m_max_pct IS NULL) OR ((relative_humidity_2m_max_pct >= (0)::double precision) AND (relative_humidity_2m_max_pct <= (100)::double precision)))),
    CONSTRAINT cell_observation_daily_humidity_mean_chk CHECK (((relative_humidity_2m_mean_pct IS NULL) OR ((relative_humidity_2m_mean_pct >= (0)::double precision) AND (relative_humidity_2m_mean_pct <= (100)::double precision)))),
    CONSTRAINT cell_observation_daily_humidity_min_chk CHECK (((relative_humidity_2m_min_pct IS NULL) OR ((relative_humidity_2m_min_pct >= (0)::double precision) AND (relative_humidity_2m_min_pct <= (100)::double precision)))),
    CONSTRAINT cell_observation_daily_humidity_order_chk CHECK (((relative_humidity_2m_min_pct IS NULL) OR (relative_humidity_2m_max_pct IS NULL) OR (relative_humidity_2m_min_pct <= relative_humidity_2m_max_pct))),
    CONSTRAINT cell_observation_daily_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT cell_observation_daily_period_chk CHECK ((period_end > period_start)),
    CONSTRAINT cell_observation_daily_precipitation_chk CHECK (((precipitation_total_mm IS NULL) OR (precipitation_total_mm >= (0)::double precision))),
    CONSTRAINT cell_observation_daily_rainfall_chk CHECK (((rainfall_total_mm IS NULL) OR (rainfall_total_mm >= (0)::double precision))),
    CONSTRAINT cell_observation_daily_revision_chk CHECK ((revision_no >= 1)),
    CONSTRAINT cell_observation_daily_sample_count_chk CHECK (((sample_count IS NULL) OR (sample_count >= 0))),
    CONSTRAINT cell_observation_daily_snow_depth_chk CHECK (((snow_depth_max_mm IS NULL) OR (snow_depth_max_mm >= (0)::double precision))),
    CONSTRAINT cell_observation_daily_snowfall_chk CHECK (((snowfall_total_mm IS NULL) OR (snowfall_total_mm >= (0)::double precision))),
    CONSTRAINT cell_observation_daily_supersession_chk CHECK ((((supersedes_observation_daily_id IS NULL) AND (supersedes_observation_date IS NULL)) OR ((supersedes_observation_daily_id IS NOT NULL) AND (supersedes_observation_date IS NOT NULL)))),
    CONSTRAINT cell_observation_daily_temperature_order_chk CHECK (((air_temperature_2m_min_c IS NULL) OR (air_temperature_2m_max_c IS NULL) OR (air_temperature_2m_min_c <= air_temperature_2m_max_c))),
    CONSTRAINT cell_observation_daily_visibility_chk CHECK (((visibility_mean_m IS NULL) OR (visibility_mean_m >= (0)::double precision)))
);


ALTER TABLE weather.cell_observation_daily_default OWNER TO postgres;

--
-- TOC entry 408 (class 1259 OID 243768)
-- Name: cell_observation_daily_quality_exception; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.cell_observation_daily_quality_exception (
    cell_observation_daily_quality_exception_id bigint CONSTRAINT cell_observation_daily_qual_cell_observation_daily_qua_not_null NOT NULL,
    cell_observation_daily_id bigint CONSTRAINT cell_observation_daily_quali_cell_observation_daily_id_not_null NOT NULL,
    observation_date date CONSTRAINT cell_observation_daily_quality_except_observation_date_not_null NOT NULL,
    variable_id bigint NOT NULL,
    quality_flag_id smallint CONSTRAINT cell_observation_daily_quality_excepti_quality_flag_id_not_null NOT NULL,
    detected_by text,
    derivation_run_id bigint,
    details text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    detected_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cell_observation_daily_quality_exception_details_chk CHECK (((details IS NULL) OR (btrim(details) <> ''::text))),
    CONSTRAINT cell_observation_daily_quality_exception_detected_by_chk CHECK (((detected_by IS NULL) OR (btrim(detected_by) <> ''::text))),
    CONSTRAINT cell_observation_daily_quality_exception_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text))
);


ALTER TABLE weather.cell_observation_daily_quality_exception OWNER TO postgres;

--
-- TOC entry 407 (class 1259 OID 243767)
-- Name: cell_observation_daily_qualit_cell_observation_daily_qualit_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_daily_quality_exception ALTER COLUMN cell_observation_daily_quality_exception_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.cell_observation_daily_qualit_cell_observation_daily_qualit_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 393 (class 1259 OID 243175)
-- Name: cell_observation_hourly; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.cell_observation_hourly (
    cell_observation_id bigint NOT NULL,
    observation_time timestamp with time zone NOT NULL,
    grid_cell_id bigint NOT NULL,
    observation_product_id bigint NOT NULL,
    observation_record_status_id smallint NOT NULL,
    ingestion_run_id bigint,
    derivation_run_id bigint NOT NULL,
    period_start timestamp with time zone,
    period_end timestamp with time zone,
    provider_published_at timestamp with time zone,
    received_at timestamp with time zone,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    revision_no integer DEFAULT 1 NOT NULL,
    is_preferred boolean DEFAULT true NOT NULL,
    supersedes_observation_id bigint,
    supersedes_observation_time timestamp with time zone,
    air_temperature_2m_c double precision,
    apparent_temperature_2m_c double precision,
    dew_point_2m_c double precision,
    relative_humidity_2m_pct double precision,
    surface_pressure_hpa double precision,
    precipitation_1h_mm double precision,
    rainfall_1h_mm double precision,
    snowfall_1h_mm double precision,
    snow_depth_mm double precision,
    wind_u_10m_ms double precision,
    wind_v_10m_ms double precision,
    wind_gust_10m_max_1h_ms double precision,
    cloud_cover_pct double precision,
    visibility_m double precision,
    solar_radiation_w_m2 double precision,
    coverage_fraction double precision,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    condition_code_id smallint,
    CONSTRAINT cell_observation_hourly_cloud_cover_chk CHECK (((cloud_cover_pct IS NULL) OR ((cloud_cover_pct >= (0)::double precision) AND (cloud_cover_pct <= (100)::double precision)))),
    CONSTRAINT cell_observation_hourly_coverage_chk CHECK (((coverage_fraction IS NULL) OR ((coverage_fraction >= (0)::double precision) AND (coverage_fraction <= (1)::double precision)))),
    CONSTRAINT cell_observation_hourly_interval_values_chk CHECK ((((precipitation_1h_mm IS NULL) AND (rainfall_1h_mm IS NULL) AND (snowfall_1h_mm IS NULL) AND (wind_gust_10m_max_1h_ms IS NULL)) OR ((period_start IS NOT NULL) AND (period_end IS NOT NULL)))),
    CONSTRAINT cell_observation_hourly_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT cell_observation_hourly_period_chk CHECK ((((period_start IS NULL) AND (period_end IS NULL)) OR ((period_start IS NOT NULL) AND (period_end IS NOT NULL) AND (period_end > period_start)))),
    CONSTRAINT cell_observation_hourly_precipitation_chk CHECK (((precipitation_1h_mm IS NULL) OR (precipitation_1h_mm >= (0)::double precision))),
    CONSTRAINT cell_observation_hourly_rainfall_chk CHECK (((rainfall_1h_mm IS NULL) OR (rainfall_1h_mm >= (0)::double precision))),
    CONSTRAINT cell_observation_hourly_relative_humidity_chk CHECK (((relative_humidity_2m_pct IS NULL) OR ((relative_humidity_2m_pct >= (0)::double precision) AND (relative_humidity_2m_pct <= (100)::double precision)))),
    CONSTRAINT cell_observation_hourly_revision_chk CHECK ((revision_no >= 1)),
    CONSTRAINT cell_observation_hourly_snow_depth_chk CHECK (((snow_depth_mm IS NULL) OR (snow_depth_mm >= (0)::double precision))),
    CONSTRAINT cell_observation_hourly_snowfall_chk CHECK (((snowfall_1h_mm IS NULL) OR (snowfall_1h_mm >= (0)::double precision))),
    CONSTRAINT cell_observation_hourly_supersession_chk CHECK ((((supersedes_observation_id IS NULL) AND (supersedes_observation_time IS NULL)) OR ((supersedes_observation_id IS NOT NULL) AND (supersedes_observation_time IS NOT NULL)))),
    CONSTRAINT cell_observation_hourly_visibility_chk CHECK (((visibility_m IS NULL) OR (visibility_m >= (0)::double precision)))
)
PARTITION BY RANGE (observation_time);


ALTER TABLE weather.cell_observation_hourly OWNER TO postgres;

--
-- TOC entry 9300 (class 0 OID 0)
-- Dependencies: 393
-- Name: COLUMN cell_observation_hourly.air_temperature_2m_c; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.cell_observation_hourly.air_temperature_2m_c IS 'Canonical H3-cell 2 m air temperature in degrees Celsius.';


--
-- TOC entry 9301 (class 0 OID 0)
-- Dependencies: 393
-- Name: COLUMN cell_observation_hourly.apparent_temperature_2m_c; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.cell_observation_hourly.apparent_temperature_2m_c IS 'Canonical H3-cell 2 m apparent temperature in degrees Celsius.';


--
-- TOC entry 9302 (class 0 OID 0)
-- Dependencies: 393
-- Name: COLUMN cell_observation_hourly.dew_point_2m_c; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.cell_observation_hourly.dew_point_2m_c IS 'Canonical H3-cell 2 m dew point in degrees Celsius.';


--
-- TOC entry 9303 (class 0 OID 0)
-- Dependencies: 393
-- Name: COLUMN cell_observation_hourly.relative_humidity_2m_pct; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.cell_observation_hourly.relative_humidity_2m_pct IS 'Canonical H3-cell 2 m relative humidity in percent.';


--
-- TOC entry 9304 (class 0 OID 0)
-- Dependencies: 393
-- Name: COLUMN cell_observation_hourly.surface_pressure_hpa; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.cell_observation_hourly.surface_pressure_hpa IS 'Canonical H3-cell surface pressure in hectopascals.';


--
-- TOC entry 9305 (class 0 OID 0)
-- Dependencies: 393
-- Name: COLUMN cell_observation_hourly.precipitation_1h_mm; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.cell_observation_hourly.precipitation_1h_mm IS 'Canonical H3-cell total precipitation over the explicit one-hour period in millimetres.';


--
-- TOC entry 9306 (class 0 OID 0)
-- Dependencies: 393
-- Name: COLUMN cell_observation_hourly.rainfall_1h_mm; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.cell_observation_hourly.rainfall_1h_mm IS 'Canonical H3-cell liquid rainfall over the explicit one-hour period in millimetres.';


--
-- TOC entry 9307 (class 0 OID 0)
-- Dependencies: 393
-- Name: COLUMN cell_observation_hourly.snowfall_1h_mm; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.cell_observation_hourly.snowfall_1h_mm IS 'Canonical H3-cell snowfall over the explicit one-hour period in millimetres.';


--
-- TOC entry 9308 (class 0 OID 0)
-- Dependencies: 393
-- Name: COLUMN cell_observation_hourly.snow_depth_mm; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.cell_observation_hourly.snow_depth_mm IS 'Canonical H3-cell snow depth in millimetres.';


--
-- TOC entry 9309 (class 0 OID 0)
-- Dependencies: 393
-- Name: COLUMN cell_observation_hourly.wind_u_10m_ms; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.cell_observation_hourly.wind_u_10m_ms IS 'Canonical H3-cell east-west wind component at 10 m in metres per second.';


--
-- TOC entry 9310 (class 0 OID 0)
-- Dependencies: 393
-- Name: COLUMN cell_observation_hourly.wind_v_10m_ms; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.cell_observation_hourly.wind_v_10m_ms IS 'Canonical H3-cell north-south wind component at 10 m in metres per second.';


--
-- TOC entry 9311 (class 0 OID 0)
-- Dependencies: 393
-- Name: COLUMN cell_observation_hourly.wind_gust_10m_max_1h_ms; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.cell_observation_hourly.wind_gust_10m_max_1h_ms IS 'Canonical H3-cell maximum 10 m wind gust over one hour in metres per second.';


--
-- TOC entry 9312 (class 0 OID 0)
-- Dependencies: 393
-- Name: COLUMN cell_observation_hourly.cloud_cover_pct; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.cell_observation_hourly.cloud_cover_pct IS 'Canonical H3-cell total cloud cover in percent.';


--
-- TOC entry 9313 (class 0 OID 0)
-- Dependencies: 393
-- Name: COLUMN cell_observation_hourly.visibility_m; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.cell_observation_hourly.visibility_m IS 'Canonical H3-cell horizontal visibility in metres.';


--
-- TOC entry 9314 (class 0 OID 0)
-- Dependencies: 393
-- Name: COLUMN cell_observation_hourly.solar_radiation_w_m2; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.cell_observation_hourly.solar_radiation_w_m2 IS 'Canonical H3-cell surface solar radiation flux in watts per square metre.';


--
-- TOC entry 9315 (class 0 OID 0)
-- Dependencies: 393
-- Name: COLUMN cell_observation_hourly.coverage_fraction; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.cell_observation_hourly.coverage_fraction IS 'Fraction from 0 to 1 representing source/derivation coverage of the target H3 cell where applicable.';


--
-- TOC entry 392 (class 1259 OID 243174)
-- Name: cell_observation_hourly_cell_observation_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_hourly ALTER COLUMN cell_observation_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME weather.cell_observation_hourly_cell_observation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 394 (class 1259 OID 243247)
-- Name: cell_observation_hourly_default; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.cell_observation_hourly_default (
    cell_observation_id bigint CONSTRAINT cell_observation_hourly_cell_observation_id_not_null NOT NULL,
    observation_time timestamp with time zone CONSTRAINT cell_observation_hourly_observation_time_not_null NOT NULL,
    grid_cell_id bigint CONSTRAINT cell_observation_hourly_grid_cell_id_not_null NOT NULL,
    observation_product_id bigint CONSTRAINT cell_observation_hourly_observation_product_id_not_null NOT NULL,
    observation_record_status_id smallint CONSTRAINT cell_observation_hourly_observation_record_status_id_not_null NOT NULL,
    ingestion_run_id bigint,
    derivation_run_id bigint CONSTRAINT cell_observation_hourly_derivation_run_id_not_null NOT NULL,
    period_start timestamp with time zone,
    period_end timestamp with time zone,
    provider_published_at timestamp with time zone,
    received_at timestamp with time zone,
    ingested_at timestamp with time zone DEFAULT now() CONSTRAINT cell_observation_hourly_ingested_at_not_null NOT NULL,
    revision_no integer DEFAULT 1 CONSTRAINT cell_observation_hourly_revision_no_not_null NOT NULL,
    is_preferred boolean DEFAULT true CONSTRAINT cell_observation_hourly_is_preferred_not_null NOT NULL,
    supersedes_observation_id bigint,
    supersedes_observation_time timestamp with time zone,
    air_temperature_2m_c double precision,
    apparent_temperature_2m_c double precision,
    dew_point_2m_c double precision,
    relative_humidity_2m_pct double precision,
    surface_pressure_hpa double precision,
    precipitation_1h_mm double precision,
    rainfall_1h_mm double precision,
    snowfall_1h_mm double precision,
    snow_depth_mm double precision,
    wind_u_10m_ms double precision,
    wind_v_10m_ms double precision,
    wind_gust_10m_max_1h_ms double precision,
    cloud_cover_pct double precision,
    visibility_m double precision,
    solar_radiation_w_m2 double precision,
    coverage_fraction double precision,
    metadata jsonb DEFAULT '{}'::jsonb CONSTRAINT cell_observation_hourly_metadata_not_null NOT NULL,
    created_at timestamp with time zone DEFAULT now() CONSTRAINT cell_observation_hourly_created_at_not_null NOT NULL,
    condition_code_id smallint,
    CONSTRAINT cell_observation_hourly_cloud_cover_chk CHECK (((cloud_cover_pct IS NULL) OR ((cloud_cover_pct >= (0)::double precision) AND (cloud_cover_pct <= (100)::double precision)))),
    CONSTRAINT cell_observation_hourly_coverage_chk CHECK (((coverage_fraction IS NULL) OR ((coverage_fraction >= (0)::double precision) AND (coverage_fraction <= (1)::double precision)))),
    CONSTRAINT cell_observation_hourly_interval_values_chk CHECK ((((precipitation_1h_mm IS NULL) AND (rainfall_1h_mm IS NULL) AND (snowfall_1h_mm IS NULL) AND (wind_gust_10m_max_1h_ms IS NULL)) OR ((period_start IS NOT NULL) AND (period_end IS NOT NULL)))),
    CONSTRAINT cell_observation_hourly_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT cell_observation_hourly_period_chk CHECK ((((period_start IS NULL) AND (period_end IS NULL)) OR ((period_start IS NOT NULL) AND (period_end IS NOT NULL) AND (period_end > period_start)))),
    CONSTRAINT cell_observation_hourly_precipitation_chk CHECK (((precipitation_1h_mm IS NULL) OR (precipitation_1h_mm >= (0)::double precision))),
    CONSTRAINT cell_observation_hourly_rainfall_chk CHECK (((rainfall_1h_mm IS NULL) OR (rainfall_1h_mm >= (0)::double precision))),
    CONSTRAINT cell_observation_hourly_relative_humidity_chk CHECK (((relative_humidity_2m_pct IS NULL) OR ((relative_humidity_2m_pct >= (0)::double precision) AND (relative_humidity_2m_pct <= (100)::double precision)))),
    CONSTRAINT cell_observation_hourly_revision_chk CHECK ((revision_no >= 1)),
    CONSTRAINT cell_observation_hourly_snow_depth_chk CHECK (((snow_depth_mm IS NULL) OR (snow_depth_mm >= (0)::double precision))),
    CONSTRAINT cell_observation_hourly_snowfall_chk CHECK (((snowfall_1h_mm IS NULL) OR (snowfall_1h_mm >= (0)::double precision))),
    CONSTRAINT cell_observation_hourly_supersession_chk CHECK ((((supersedes_observation_id IS NULL) AND (supersedes_observation_time IS NULL)) OR ((supersedes_observation_id IS NOT NULL) AND (supersedes_observation_time IS NOT NULL)))),
    CONSTRAINT cell_observation_hourly_visibility_chk CHECK (((visibility_m IS NULL) OR (visibility_m >= (0)::double precision)))
);


ALTER TABLE weather.cell_observation_hourly_default OWNER TO postgres;

--
-- TOC entry 396 (class 1259 OID 243316)
-- Name: cell_observation_quality_exception; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.cell_observation_quality_exception (
    cell_observation_quality_exception_id bigint CONSTRAINT cell_observation_quality_ex_cell_observation_quality_e_not_null NOT NULL,
    cell_observation_id bigint NOT NULL,
    observation_time timestamp with time zone NOT NULL,
    variable_id bigint NOT NULL,
    quality_flag_id smallint NOT NULL,
    detected_by text,
    derivation_run_id bigint,
    details text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    detected_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cell_observation_quality_exception_details_chk CHECK (((details IS NULL) OR (btrim(details) <> ''::text))),
    CONSTRAINT cell_observation_quality_exception_detected_by_chk CHECK (((detected_by IS NULL) OR (btrim(detected_by) <> ''::text))),
    CONSTRAINT cell_observation_quality_exception_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text))
);


ALTER TABLE weather.cell_observation_quality_exception OWNER TO postgres;

--
-- TOC entry 395 (class 1259 OID 243315)
-- Name: cell_observation_quality_exce_cell_observation_quality_exce_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_quality_exception ALTER COLUMN cell_observation_quality_exception_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.cell_observation_quality_exce_cell_observation_quality_exce_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 412 (class 1259 OID 243872)
-- Name: cell_observation_value; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.cell_observation_value (
    cell_observation_value_id bigint NOT NULL,
    cell_observation_id bigint NOT NULL,
    observation_time timestamp with time zone NOT NULL,
    variable_id bigint NOT NULL,
    value_double double precision,
    value_text text,
    observation_record_status_id smallint,
    ingestion_run_id bigint,
    derivation_run_id bigint NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT cell_observation_value_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT cell_observation_value_text_chk CHECK (((value_text IS NULL) OR (btrim(value_text) <> ''::text))),
    CONSTRAINT cell_observation_value_value_chk CHECK ((((value_double IS NOT NULL) AND (value_text IS NULL)) OR ((value_double IS NULL) AND (value_text IS NOT NULL))))
);


ALTER TABLE weather.cell_observation_value OWNER TO postgres;

--
-- TOC entry 411 (class 1259 OID 243871)
-- Name: cell_observation_value_cell_observation_value_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_value ALTER COLUMN cell_observation_value_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.cell_observation_value_cell_observation_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 414 (class 1259 OID 243926)
-- Name: condition_code; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.condition_code (
    condition_code_id smallint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    category text NOT NULL,
    severity_rank smallint,
    is_precipitating boolean DEFAULT false NOT NULL,
    is_convective boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT condition_code_category_not_blank_chk CHECK ((btrim(category) <> ''::text)),
    CONSTRAINT condition_code_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT condition_code_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT condition_code_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT condition_code_severity_rank_chk CHECK (((severity_rank IS NULL) OR (severity_rank >= 0)))
);


ALTER TABLE weather.condition_code OWNER TO postgres;

--
-- TOC entry 413 (class 1259 OID 243925)
-- Name: condition_code_condition_code_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.condition_code ALTER COLUMN condition_code_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME weather.condition_code_condition_code_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 464 (class 1259 OID 245317)
-- Name: consensus_definition; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.consensus_definition (
    consensus_definition_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    methodology text NOT NULL,
    weighting_method text NOT NULL,
    model_set_version text NOT NULL,
    valid_from timestamp with time zone,
    valid_to timestamp with time zone,
    is_current boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT consensus_definition_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT consensus_definition_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT consensus_definition_methodology_not_blank_chk CHECK ((btrim(methodology) <> ''::text)),
    CONSTRAINT consensus_definition_model_set_version_not_blank_chk CHECK ((btrim(model_set_version) <> ''::text)),
    CONSTRAINT consensus_definition_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT consensus_definition_validity_chk CHECK (((valid_to IS NULL) OR (valid_from IS NULL) OR (valid_to > valid_from))),
    CONSTRAINT consensus_definition_weighting_method_not_blank_chk CHECK ((btrim(weighting_method) <> ''::text))
);


ALTER TABLE weather.consensus_definition OWNER TO postgres;

--
-- TOC entry 463 (class 1259 OID 245316)
-- Name: consensus_definition_consensus_definition_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.consensus_definition ALTER COLUMN consensus_definition_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.consensus_definition_consensus_definition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 466 (class 1259 OID 245353)
-- Name: consensus_definition_member; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.consensus_definition_member (
    consensus_definition_member_id bigint CONSTRAINT consensus_definition_member_consensus_definition_membe_not_null NOT NULL,
    consensus_definition_id bigint NOT NULL,
    forecast_product_id bigint NOT NULL,
    weight double precision,
    priority integer,
    lead_minutes_start integer,
    lead_minutes_end integer,
    is_required boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT consensus_definition_member_lead_band_chk CHECK (((lead_minutes_start IS NULL) OR (lead_minutes_end IS NULL) OR (lead_minutes_end >= lead_minutes_start))),
    CONSTRAINT consensus_definition_member_lead_end_chk CHECK (((lead_minutes_end IS NULL) OR (lead_minutes_end >= 0))),
    CONSTRAINT consensus_definition_member_lead_start_chk CHECK (((lead_minutes_start IS NULL) OR (lead_minutes_start >= 0))),
    CONSTRAINT consensus_definition_member_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT consensus_definition_member_priority_chk CHECK (((priority IS NULL) OR (priority >= 0))),
    CONSTRAINT consensus_definition_member_weight_chk CHECK (((weight IS NULL) OR (weight >= (0)::double precision)))
);


ALTER TABLE weather.consensus_definition_member OWNER TO postgres;

--
-- TOC entry 465 (class 1259 OID 245352)
-- Name: consensus_definition_member_consensus_definition_member_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.consensus_definition_member ALTER COLUMN consensus_definition_member_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.consensus_definition_member_consensus_definition_member_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 398 (class 1259 OID 243367)
-- Name: daily_period_definition; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.daily_period_definition (
    daily_period_definition_id smallint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    requires_timezone boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT daily_period_definition_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT daily_period_definition_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT daily_period_definition_name_not_blank_chk CHECK ((btrim(name) <> ''::text))
);


ALTER TABLE weather.daily_period_definition OWNER TO postgres;

--
-- TOC entry 397 (class 1259 OID 243366)
-- Name: daily_period_definition_daily_period_definition_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.daily_period_definition ALTER COLUMN daily_period_definition_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME weather.daily_period_definition_daily_period_definition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 338 (class 1259 OID 242163)
-- Name: dataset; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.dataset (
    dataset_id bigint NOT NULL,
    provider_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    dataset_type text NOT NULL,
    source_url text,
    documentation_url text,
    temporal_resolution text,
    spatial_resolution text,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT dataset_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT dataset_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT dataset_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT dataset_type_not_blank_chk CHECK ((btrim(dataset_type) <> ''::text))
);


ALTER TABLE weather.dataset OWNER TO postgres;

--
-- TOC entry 416 (class 1259 OID 243959)
-- Name: dataset_condition_mapping; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.dataset_condition_mapping (
    dataset_condition_mapping_id bigint NOT NULL,
    dataset_version_id bigint NOT NULL,
    condition_code_id smallint NOT NULL,
    provider_condition_code text NOT NULL,
    provider_condition_text text,
    priority integer DEFAULT 0 NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT dataset_condition_mapping_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT dataset_condition_mapping_provider_code_not_blank_chk CHECK ((btrim(provider_condition_code) <> ''::text)),
    CONSTRAINT dataset_condition_mapping_provider_text_chk CHECK (((provider_condition_text IS NULL) OR (btrim(provider_condition_text) <> ''::text)))
);


ALTER TABLE weather.dataset_condition_mapping OWNER TO postgres;

--
-- TOC entry 415 (class 1259 OID 243958)
-- Name: dataset_condition_mapping_dataset_condition_mapping_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.dataset_condition_mapping ALTER COLUMN dataset_condition_mapping_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.dataset_condition_mapping_dataset_condition_mapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 337 (class 1259 OID 242162)
-- Name: dataset_dataset_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.dataset ALTER COLUMN dataset_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.dataset_dataset_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 382 (class 1259 OID 242887)
-- Name: dataset_variable_mapping; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.dataset_variable_mapping (
    dataset_variable_mapping_id bigint NOT NULL,
    dataset_version_id bigint NOT NULL,
    variable_id bigint NOT NULL,
    provider_field_name text NOT NULL,
    provider_field_path text,
    source_unit_text text,
    conversion_method text,
    scale_factor double precision,
    add_offset double precision,
    missing_values jsonb DEFAULT '[]'::jsonb NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT dataset_variable_mapping_conversion_method_chk CHECK (((conversion_method IS NULL) OR (btrim(conversion_method) <> ''::text))),
    CONSTRAINT dataset_variable_mapping_field_not_blank_chk CHECK ((btrim(provider_field_name) <> ''::text)),
    CONSTRAINT dataset_variable_mapping_field_path_chk CHECK (((provider_field_path IS NULL) OR (btrim(provider_field_path) <> ''::text))),
    CONSTRAINT dataset_variable_mapping_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT dataset_variable_mapping_missing_values_array_chk CHECK ((jsonb_typeof(missing_values) = 'array'::text)),
    CONSTRAINT dataset_variable_mapping_source_unit_chk CHECK (((source_unit_text IS NULL) OR (btrim(source_unit_text) <> ''::text)))
);


ALTER TABLE weather.dataset_variable_mapping OWNER TO postgres;

--
-- TOC entry 381 (class 1259 OID 242886)
-- Name: dataset_variable_mapping_dataset_variable_mapping_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.dataset_variable_mapping ALTER COLUMN dataset_variable_mapping_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.dataset_variable_mapping_dataset_variable_mapping_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 340 (class 1259 OID 242199)
-- Name: dataset_version; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.dataset_version (
    dataset_version_id bigint NOT NULL,
    dataset_id bigint NOT NULL,
    version_name text NOT NULL,
    release_date date,
    valid_from timestamp with time zone,
    valid_to timestamp with time zone,
    schema_version text,
    source_url text,
    is_current boolean DEFAULT false NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT dataset_version_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT dataset_version_name_not_blank_chk CHECK ((btrim(version_name) <> ''::text)),
    CONSTRAINT dataset_version_validity_chk CHECK (((valid_to IS NULL) OR (valid_from IS NULL) OR (valid_to > valid_from)))
);


ALTER TABLE weather.dataset_version OWNER TO postgres;

--
-- TOC entry 339 (class 1259 OID 242198)
-- Name: dataset_version_dataset_version_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.dataset_version ALTER COLUMN dataset_version_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.dataset_version_dataset_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 346 (class 1259 OID 242297)
-- Name: derivation; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.derivation (
    derivation_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    derivation_type text NOT NULL,
    software_name text,
    software_version text,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT derivation_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT derivation_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT derivation_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT derivation_type_not_blank_chk CHECK ((btrim(derivation_type) <> ''::text))
);


ALTER TABLE weather.derivation OWNER TO postgres;

--
-- TOC entry 345 (class 1259 OID 242296)
-- Name: derivation_derivation_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.derivation ALTER COLUMN derivation_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.derivation_derivation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 350 (class 1259 OID 242358)
-- Name: derivation_run; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.derivation_run (
    derivation_run_id bigint NOT NULL,
    derivation_version_id bigint NOT NULL,
    ingestion_run_id bigint,
    status text NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    records_read bigint,
    records_written bigint,
    records_rejected bigint,
    error_message text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT derivation_run_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT derivation_run_records_read_chk CHECK (((records_read IS NULL) OR (records_read >= 0))),
    CONSTRAINT derivation_run_records_rejected_chk CHECK (((records_rejected IS NULL) OR (records_rejected >= 0))),
    CONSTRAINT derivation_run_records_written_chk CHECK (((records_written IS NULL) OR (records_written >= 0))),
    CONSTRAINT derivation_run_status_not_blank_chk CHECK ((btrim(status) <> ''::text)),
    CONSTRAINT derivation_run_time_chk CHECK (((completed_at IS NULL) OR (completed_at >= started_at)))
);


ALTER TABLE weather.derivation_run OWNER TO postgres;

--
-- TOC entry 349 (class 1259 OID 242357)
-- Name: derivation_run_derivation_run_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.derivation_run ALTER COLUMN derivation_run_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.derivation_run_derivation_run_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 352 (class 1259 OID 242395)
-- Name: derivation_run_input; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.derivation_run_input (
    derivation_run_input_id bigint NOT NULL,
    derivation_run_id bigint NOT NULL,
    ingestion_run_id bigint NOT NULL,
    input_role text DEFAULT 'source'::text NOT NULL,
    sequence_no integer,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT derivation_run_input_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT derivation_run_input_role_not_blank_chk CHECK ((btrim(input_role) <> ''::text)),
    CONSTRAINT derivation_run_input_sequence_chk CHECK (((sequence_no IS NULL) OR (sequence_no >= 0)))
);


ALTER TABLE weather.derivation_run_input OWNER TO postgres;

--
-- TOC entry 351 (class 1259 OID 242394)
-- Name: derivation_run_input_derivation_run_input_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.derivation_run_input ALTER COLUMN derivation_run_input_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.derivation_run_input_derivation_run_input_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 348 (class 1259 OID 242326)
-- Name: derivation_version; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.derivation_version (
    derivation_version_id bigint NOT NULL,
    derivation_id bigint NOT NULL,
    version_name text NOT NULL,
    valid_from timestamp with time zone,
    valid_to timestamp with time zone,
    code_version text,
    configuration jsonb DEFAULT '{}'::jsonb NOT NULL,
    is_current boolean DEFAULT false NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT derivation_version_configuration_object_chk CHECK ((jsonb_typeof(configuration) = 'object'::text)),
    CONSTRAINT derivation_version_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT derivation_version_name_not_blank_chk CHECK ((btrim(version_name) <> ''::text)),
    CONSTRAINT derivation_version_validity_chk CHECK (((valid_to IS NULL) OR (valid_from IS NULL) OR (valid_to > valid_from)))
);


ALTER TABLE weather.derivation_version OWNER TO postgres;

--
-- TOC entry 347 (class 1259 OID 242325)
-- Name: derivation_version_derivation_version_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.derivation_version ALTER COLUMN derivation_version_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.derivation_version_derivation_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 448 (class 1259 OID 244885)
-- Name: ensemble_probability; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.ensemble_probability (
    ensemble_probability_id bigint NOT NULL,
    ensemble_summary_id bigint NOT NULL,
    valid_time timestamp with time zone NOT NULL,
    threshold_operator text NOT NULL,
    threshold_value double precision NOT NULL,
    probability double precision NOT NULL,
    member_count integer,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ensemble_probability_member_count_chk CHECK (((member_count IS NULL) OR (member_count >= 0))),
    CONSTRAINT ensemble_probability_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT ensemble_probability_operator_chk CHECK ((threshold_operator = ANY (ARRAY['<'::text, '<='::text, '>'::text, '>='::text]))),
    CONSTRAINT ensemble_probability_probability_chk CHECK (((probability >= (0)::double precision) AND (probability <= (1)::double precision)))
);


ALTER TABLE weather.ensemble_probability OWNER TO postgres;

--
-- TOC entry 447 (class 1259 OID 244884)
-- Name: ensemble_probability_ensemble_probability_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.ensemble_probability ALTER COLUMN ensemble_probability_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.ensemble_probability_ensemble_probability_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 445 (class 1259 OID 244772)
-- Name: ensemble_summary; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.ensemble_summary (
    ensemble_summary_id bigint NOT NULL,
    forecast_run_id bigint NOT NULL,
    forecast_product_id bigint NOT NULL,
    grid_cell_id bigint NOT NULL,
    variable_id bigint NOT NULL,
    valid_time timestamp with time zone NOT NULL,
    period_start timestamp with time zone,
    period_end timestamp with time zone,
    lead_minutes integer NOT NULL,
    expected_member_count integer,
    available_member_count integer,
    mean_value double precision,
    median_value double precision,
    stddev_value double precision,
    min_value double precision,
    max_value double precision,
    p10_value double precision,
    p25_value double precision,
    p75_value double precision,
    p90_value double precision,
    interquartile_range double precision,
    ensemble_range double precision,
    control_value double precision,
    coverage_fraction double precision,
    derivation_run_id bigint NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ensemble_summary_available_members_chk CHECK (((available_member_count IS NULL) OR (available_member_count >= 0))),
    CONSTRAINT ensemble_summary_coverage_chk CHECK (((coverage_fraction IS NULL) OR ((coverage_fraction >= (0)::double precision) AND (coverage_fraction <= (1)::double precision)))),
    CONSTRAINT ensemble_summary_expected_members_chk CHECK (((expected_member_count IS NULL) OR (expected_member_count >= 0))),
    CONSTRAINT ensemble_summary_iqr_chk CHECK (((interquartile_range IS NULL) OR (interquartile_range >= (0)::double precision))),
    CONSTRAINT ensemble_summary_lead_chk CHECK ((lead_minutes >= 0)),
    CONSTRAINT ensemble_summary_member_count_consistency_chk CHECK (((expected_member_count IS NULL) OR (available_member_count IS NULL) OR (available_member_count <= expected_member_count))),
    CONSTRAINT ensemble_summary_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT ensemble_summary_min_max_chk CHECK (((min_value IS NULL) OR (max_value IS NULL) OR (min_value <= max_value))),
    CONSTRAINT ensemble_summary_percentile_order_chk CHECK ((((p10_value IS NULL) OR (p25_value IS NULL) OR (p10_value <= p25_value)) AND ((p25_value IS NULL) OR (p75_value IS NULL) OR (p25_value <= p75_value)) AND ((p75_value IS NULL) OR (p90_value IS NULL) OR (p75_value <= p90_value)))),
    CONSTRAINT ensemble_summary_period_chk CHECK ((((period_start IS NULL) AND (period_end IS NULL)) OR ((period_start IS NOT NULL) AND (period_end IS NOT NULL) AND (period_end > period_start)))),
    CONSTRAINT ensemble_summary_range_chk CHECK (((ensemble_range IS NULL) OR (ensemble_range >= (0)::double precision))),
    CONSTRAINT ensemble_summary_stddev_chk CHECK (((stddev_value IS NULL) OR (stddev_value >= (0)::double precision)))
)
PARTITION BY RANGE (valid_time);


ALTER TABLE weather.ensemble_summary OWNER TO postgres;

--
-- TOC entry 446 (class 1259 OID 244832)
-- Name: ensemble_summary_default; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.ensemble_summary_default (
    ensemble_summary_id bigint CONSTRAINT ensemble_summary_ensemble_summary_id_not_null NOT NULL,
    forecast_run_id bigint CONSTRAINT ensemble_summary_forecast_run_id_not_null NOT NULL,
    forecast_product_id bigint CONSTRAINT ensemble_summary_forecast_product_id_not_null NOT NULL,
    grid_cell_id bigint CONSTRAINT ensemble_summary_grid_cell_id_not_null NOT NULL,
    variable_id bigint CONSTRAINT ensemble_summary_variable_id_not_null NOT NULL,
    valid_time timestamp with time zone CONSTRAINT ensemble_summary_valid_time_not_null NOT NULL,
    period_start timestamp with time zone,
    period_end timestamp with time zone,
    lead_minutes integer CONSTRAINT ensemble_summary_lead_minutes_not_null NOT NULL,
    expected_member_count integer,
    available_member_count integer,
    mean_value double precision,
    median_value double precision,
    stddev_value double precision,
    min_value double precision,
    max_value double precision,
    p10_value double precision,
    p25_value double precision,
    p75_value double precision,
    p90_value double precision,
    interquartile_range double precision,
    ensemble_range double precision,
    control_value double precision,
    coverage_fraction double precision,
    derivation_run_id bigint CONSTRAINT ensemble_summary_derivation_run_id_not_null NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb CONSTRAINT ensemble_summary_metadata_not_null NOT NULL,
    created_at timestamp with time zone DEFAULT now() CONSTRAINT ensemble_summary_created_at_not_null NOT NULL,
    CONSTRAINT ensemble_summary_available_members_chk CHECK (((available_member_count IS NULL) OR (available_member_count >= 0))),
    CONSTRAINT ensemble_summary_coverage_chk CHECK (((coverage_fraction IS NULL) OR ((coverage_fraction >= (0)::double precision) AND (coverage_fraction <= (1)::double precision)))),
    CONSTRAINT ensemble_summary_expected_members_chk CHECK (((expected_member_count IS NULL) OR (expected_member_count >= 0))),
    CONSTRAINT ensemble_summary_iqr_chk CHECK (((interquartile_range IS NULL) OR (interquartile_range >= (0)::double precision))),
    CONSTRAINT ensemble_summary_lead_chk CHECK ((lead_minutes >= 0)),
    CONSTRAINT ensemble_summary_member_count_consistency_chk CHECK (((expected_member_count IS NULL) OR (available_member_count IS NULL) OR (available_member_count <= expected_member_count))),
    CONSTRAINT ensemble_summary_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT ensemble_summary_min_max_chk CHECK (((min_value IS NULL) OR (max_value IS NULL) OR (min_value <= max_value))),
    CONSTRAINT ensemble_summary_percentile_order_chk CHECK ((((p10_value IS NULL) OR (p25_value IS NULL) OR (p10_value <= p25_value)) AND ((p25_value IS NULL) OR (p75_value IS NULL) OR (p25_value <= p75_value)) AND ((p75_value IS NULL) OR (p90_value IS NULL) OR (p75_value <= p90_value)))),
    CONSTRAINT ensemble_summary_period_chk CHECK ((((period_start IS NULL) AND (period_end IS NULL)) OR ((period_start IS NOT NULL) AND (period_end IS NOT NULL) AND (period_end > period_start)))),
    CONSTRAINT ensemble_summary_range_chk CHECK (((ensemble_range IS NULL) OR (ensemble_range >= (0)::double precision))),
    CONSTRAINT ensemble_summary_stddev_chk CHECK (((stddev_value IS NULL) OR (stddev_value >= (0)::double precision)))
);


ALTER TABLE weather.ensemble_summary_default OWNER TO postgres;

--
-- TOC entry 444 (class 1259 OID 244771)
-- Name: ensemble_summary_ensemble_summary_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.ensemble_summary ALTER COLUMN ensemble_summary_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME weather.ensemble_summary_ensemble_summary_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 450 (class 1259 OID 244920)
-- Name: forecast_correction_reason; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.forecast_correction_reason (
    forecast_correction_reason_id smallint CONSTRAINT forecast_correction_reason_forecast_correction_reason__not_null NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    correction_source text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT forecast_correction_reason_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT forecast_correction_reason_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT forecast_correction_reason_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT forecast_correction_reason_source_chk CHECK ((correction_source = ANY (ARRAY['provider'::text, 'aurion'::text])))
);


ALTER TABLE weather.forecast_correction_reason OWNER TO postgres;

--
-- TOC entry 449 (class 1259 OID 244919)
-- Name: forecast_correction_reason_forecast_correction_reason_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.forecast_correction_reason ALTER COLUMN forecast_correction_reason_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME weather.forecast_correction_reason_forecast_correction_reason_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 438 (class 1259 OID 244493)
-- Name: forecast_member; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.forecast_member (
    forecast_member_id bigint NOT NULL,
    forecast_run_id bigint NOT NULL,
    member_type text NOT NULL,
    member_number integer,
    member_code text,
    name text,
    is_control boolean DEFAULT false NOT NULL,
    is_deterministic boolean DEFAULT false NOT NULL,
    is_available boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT forecast_member_code_chk CHECK (((member_code IS NULL) OR (btrim(member_code) <> ''::text))),
    CONSTRAINT forecast_member_control_consistency_chk CHECK (((NOT is_control) OR (member_type = 'control'::text))),
    CONSTRAINT forecast_member_deterministic_consistency_chk CHECK (((NOT is_deterministic) OR (member_type = 'deterministic'::text))),
    CONSTRAINT forecast_member_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT forecast_member_name_chk CHECK (((name IS NULL) OR (btrim(name) <> ''::text))),
    CONSTRAINT forecast_member_not_both_chk CHECK ((NOT ((is_control = true) AND (is_deterministic = true)))),
    CONSTRAINT forecast_member_number_chk CHECK (((member_number IS NULL) OR (member_number >= 0))),
    CONSTRAINT forecast_member_type_chk CHECK ((member_type = ANY (ARRAY['deterministic'::text, 'control'::text, 'perturbed'::text, 'statistical'::text, 'derived'::text])))
);


ALTER TABLE weather.forecast_member OWNER TO postgres;

--
-- TOC entry 437 (class 1259 OID 244492)
-- Name: forecast_member_forecast_member_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.forecast_member ALTER COLUMN forecast_member_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.forecast_member_forecast_member_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 428 (class 1259 OID 244282)
-- Name: forecast_model; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.forecast_model (
    forecast_model_id bigint NOT NULL,
    provider_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    model_scope text NOT NULL,
    model_class text NOT NULL,
    supports_deterministic boolean DEFAULT false NOT NULL,
    supports_ensemble boolean DEFAULT false NOT NULL,
    normal_horizon_minutes integer,
    scheduled_cycle_minutes integer,
    operational_status text,
    operating_from date,
    operating_to date,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT forecast_model_class_not_blank_chk CHECK ((btrim(model_class) <> ''::text)),
    CONSTRAINT forecast_model_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT forecast_model_cycle_chk CHECK (((scheduled_cycle_minutes IS NULL) OR (scheduled_cycle_minutes > 0))),
    CONSTRAINT forecast_model_horizon_chk CHECK (((normal_horizon_minutes IS NULL) OR (normal_horizon_minutes > 0))),
    CONSTRAINT forecast_model_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT forecast_model_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT forecast_model_operating_period_chk CHECK (((operating_to IS NULL) OR (operating_from IS NULL) OR (operating_to >= operating_from))),
    CONSTRAINT forecast_model_scope_not_blank_chk CHECK ((btrim(model_scope) <> ''::text))
);


ALTER TABLE weather.forecast_model OWNER TO postgres;

--
-- TOC entry 427 (class 1259 OID 244281)
-- Name: forecast_model_forecast_model_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.forecast_model ALTER COLUMN forecast_model_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.forecast_model_forecast_model_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 430 (class 1259 OID 244324)
-- Name: forecast_model_version; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.forecast_model_version (
    forecast_model_version_id bigint NOT NULL,
    forecast_model_id bigint NOT NULL,
    version_code text NOT NULL,
    name text NOT NULL,
    description text,
    provider_version text,
    grid_version text,
    physics_version text,
    ensemble_configuration text,
    vertical_configuration text,
    operational_from timestamp with time zone,
    operational_to timestamp with time zone,
    documentation_url text,
    is_current boolean DEFAULT false NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT forecast_model_version_code_not_blank_chk CHECK ((btrim(version_code) <> ''::text)),
    CONSTRAINT forecast_model_version_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT forecast_model_version_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT forecast_model_version_operational_period_chk CHECK (((operational_to IS NULL) OR (operational_from IS NULL) OR (operational_to > operational_from)))
);


ALTER TABLE weather.forecast_model_version OWNER TO postgres;

--
-- TOC entry 429 (class 1259 OID 244323)
-- Name: forecast_model_version_forecast_model_version_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.forecast_model_version ALTER COLUMN forecast_model_version_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.forecast_model_version_forecast_model_version_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 432 (class 1259 OID 244355)
-- Name: forecast_product; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.forecast_product (
    forecast_product_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    product_type text NOT NULL,
    forecast_model_version_id bigint,
    dataset_version_id bigint,
    derivation_version_id bigint,
    forecast_class text NOT NULL,
    temporal_grain text,
    is_native_provider_product boolean DEFAULT false NOT NULL,
    is_canonical_h3_product boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT forecast_product_class_chk CHECK ((forecast_class = ANY (ARRAY['deterministic'::text, 'control'::text, 'ensemble_member'::text, 'provider_ensemble_statistic'::text, 'aurion_ensemble_statistic'::text, 'multi_model_blend'::text, 'bias_corrected'::text, 'derived'::text]))),
    CONSTRAINT forecast_product_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT forecast_product_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT forecast_product_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT forecast_product_provenance_chk CHECK (((dataset_version_id IS NOT NULL) OR (derivation_version_id IS NOT NULL))),
    CONSTRAINT forecast_product_temporal_grain_chk CHECK (((temporal_grain IS NULL) OR (btrim(temporal_grain) <> ''::text))),
    CONSTRAINT forecast_product_type_not_blank_chk CHECK ((btrim(product_type) <> ''::text))
);


ALTER TABLE weather.forecast_product OWNER TO postgres;

--
-- TOC entry 431 (class 1259 OID 244354)
-- Name: forecast_product_forecast_product_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.forecast_product ALTER COLUMN forecast_product_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.forecast_product_forecast_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 454 (class 1259 OID 245011)
-- Name: forecast_revision_definition; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.forecast_revision_definition (
    forecast_revision_definition_id bigint CONSTRAINT forecast_revision_definitio_forecast_revision_definiti_not_null NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    comparison_type text NOT NULL,
    calculation_version text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT forecast_revision_definition_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT forecast_revision_definition_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT forecast_revision_definition_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT forecast_revision_definition_type_chk CHECK ((comparison_type = ANY (ARRAY['previous_scheduled_run'::text, 'previous_day_same_cycle'::text, 'first_vs_latest'::text, 'previous_blend'::text, 'forecast_vs_climatology'::text, 'custom'::text]))),
    CONSTRAINT forecast_revision_definition_version_not_blank_chk CHECK ((btrim(calculation_version) <> ''::text))
);


ALTER TABLE weather.forecast_revision_definition OWNER TO postgres;

--
-- TOC entry 453 (class 1259 OID 245010)
-- Name: forecast_revision_definition_forecast_revision_definition_i_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.forecast_revision_definition ALTER COLUMN forecast_revision_definition_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.forecast_revision_definition_forecast_revision_definition_i_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 434 (class 1259 OID 244409)
-- Name: forecast_run; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.forecast_run (
    forecast_run_id bigint NOT NULL,
    forecast_product_id bigint NOT NULL,
    forecast_model_version_id bigint NOT NULL,
    initialization_time timestamp with time zone NOT NULL,
    cycle_code text,
    run_kind text NOT NULL,
    provider_revision text,
    provider_published_at timestamp with time zone,
    first_retrieved_at timestamp with time zone,
    horizon_minutes integer,
    expected_member_count integer,
    received_member_count integer,
    expected_step_count integer,
    received_step_count integer,
    completeness_fraction double precision,
    run_status text NOT NULL,
    operational_status text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    forecast_run_expectation_id bigint,
    CONSTRAINT forecast_run_completeness_chk CHECK (((completeness_fraction IS NULL) OR ((completeness_fraction >= (0)::double precision) AND (completeness_fraction <= (1)::double precision)))),
    CONSTRAINT forecast_run_cycle_code_chk CHECK (((cycle_code IS NULL) OR (btrim(cycle_code) <> ''::text))),
    CONSTRAINT forecast_run_expected_member_count_chk CHECK (((expected_member_count IS NULL) OR (expected_member_count >= 0))),
    CONSTRAINT forecast_run_expected_step_count_chk CHECK (((expected_step_count IS NULL) OR (expected_step_count >= 0))),
    CONSTRAINT forecast_run_horizon_chk CHECK (((horizon_minutes IS NULL) OR (horizon_minutes >= 0))),
    CONSTRAINT forecast_run_kind_not_blank_chk CHECK ((btrim(run_kind) <> ''::text)),
    CONSTRAINT forecast_run_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT forecast_run_operational_status_chk CHECK (((operational_status IS NULL) OR (btrim(operational_status) <> ''::text))),
    CONSTRAINT forecast_run_provider_revision_chk CHECK (((provider_revision IS NULL) OR (btrim(provider_revision) <> ''::text))),
    CONSTRAINT forecast_run_received_member_count_chk CHECK (((received_member_count IS NULL) OR (received_member_count >= 0))),
    CONSTRAINT forecast_run_received_step_count_chk CHECK (((received_step_count IS NULL) OR (received_step_count >= 0))),
    CONSTRAINT forecast_run_retrieval_time_chk CHECK (((first_retrieved_at IS NULL) OR (first_retrieved_at >= initialization_time))),
    CONSTRAINT forecast_run_status_chk CHECK ((run_status = ANY (ARRAY['expected'::text, 'partial'::text, 'complete'::text, 'failed'::text, 'corrected'::text, 'superseded'::text])))
);


ALTER TABLE weather.forecast_run OWNER TO postgres;

--
-- TOC entry 472 (class 1259 OID 245488)
-- Name: forecast_run_expectation; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.forecast_run_expectation (
    forecast_run_expectation_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    forecast_product_id bigint,
    forecast_model_version_id bigint,
    expectation_version text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT forecast_run_expectation_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT forecast_run_expectation_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT forecast_run_expectation_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT forecast_run_expectation_scope_chk CHECK (((forecast_product_id IS NOT NULL) OR (forecast_model_version_id IS NOT NULL))),
    CONSTRAINT forecast_run_expectation_version_not_blank_chk CHECK ((btrim(expectation_version) <> ''::text))
);


ALTER TABLE weather.forecast_run_expectation OWNER TO postgres;

--
-- TOC entry 471 (class 1259 OID 245487)
-- Name: forecast_run_expectation_forecast_run_expectation_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.forecast_run_expectation ALTER COLUMN forecast_run_expectation_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.forecast_run_expectation_forecast_run_expectation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 474 (class 1259 OID 245528)
-- Name: forecast_run_expectation_item; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.forecast_run_expectation_item (
    forecast_run_expectation_item_id bigint CONSTRAINT forecast_run_expectation_it_forecast_run_expectation_i_not_null NOT NULL,
    forecast_run_expectation_id bigint CONSTRAINT forecast_run_expectation_i_forecast_run_expectation_i_not_null1 NOT NULL,
    item_type text NOT NULL,
    item_code text NOT NULL,
    member_type text,
    member_number integer,
    lead_minutes integer,
    variable_id bigint,
    is_required boolean DEFAULT true NOT NULL,
    expected_count integer DEFAULT 1 NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT forecast_run_expectation_item_code_not_blank_chk CHECK ((btrim(item_code) <> ''::text)),
    CONSTRAINT forecast_run_expectation_item_expected_count_chk CHECK ((expected_count > 0)),
    CONSTRAINT forecast_run_expectation_item_lead_chk CHECK (((lead_minutes IS NULL) OR (lead_minutes >= 0))),
    CONSTRAINT forecast_run_expectation_item_member_number_chk CHECK (((member_number IS NULL) OR (member_number >= 0))),
    CONSTRAINT forecast_run_expectation_item_member_type_chk CHECK (((member_type IS NULL) OR (btrim(member_type) <> ''::text))),
    CONSTRAINT forecast_run_expectation_item_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT forecast_run_expectation_item_type_chk CHECK ((item_type = ANY (ARRAY['artifact'::text, 'member'::text, 'forecast_step'::text, 'variable'::text, 'coverage'::text, 'other'::text])))
);


ALTER TABLE weather.forecast_run_expectation_item OWNER TO postgres;

--
-- TOC entry 473 (class 1259 OID 245527)
-- Name: forecast_run_expectation_item_forecast_run_expectation_item_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.forecast_run_expectation_item ALTER COLUMN forecast_run_expectation_item_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.forecast_run_expectation_item_forecast_run_expectation_item_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 433 (class 1259 OID 244408)
-- Name: forecast_run_forecast_run_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.forecast_run ALTER COLUMN forecast_run_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.forecast_run_forecast_run_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 436 (class 1259 OID 244459)
-- Name: forecast_run_ingestion; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.forecast_run_ingestion (
    forecast_run_ingestion_id bigint NOT NULL,
    forecast_run_id bigint NOT NULL,
    ingestion_run_id bigint NOT NULL,
    input_role text DEFAULT 'source'::text NOT NULL,
    sequence_no integer,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT forecast_run_ingestion_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT forecast_run_ingestion_role_chk CHECK ((btrim(input_role) <> ''::text)),
    CONSTRAINT forecast_run_ingestion_sequence_chk CHECK (((sequence_no IS NULL) OR (sequence_no >= 0)))
);


ALTER TABLE weather.forecast_run_ingestion OWNER TO postgres;

--
-- TOC entry 435 (class 1259 OID 244458)
-- Name: forecast_run_ingestion_forecast_run_ingestion_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.forecast_run_ingestion ALTER COLUMN forecast_run_ingestion_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.forecast_run_ingestion_forecast_run_ingestion_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 460 (class 1259 OID 245149)
-- Name: forecast_verification; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.forecast_verification (
    forecast_verification_id bigint NOT NULL,
    verification_definition_id bigint NOT NULL,
    cell_forecast_id bigint NOT NULL,
    forecast_valid_time timestamp with time zone NOT NULL,
    cell_observation_id bigint NOT NULL,
    observation_time timestamp with time zone NOT NULL,
    forecast_run_id bigint NOT NULL,
    forecast_product_id bigint NOT NULL,
    observation_product_id bigint NOT NULL,
    grid_cell_id bigint NOT NULL,
    variable_id bigint NOT NULL,
    lead_minutes integer NOT NULL,
    period_start timestamp with time zone,
    period_end timestamp with time zone,
    forecast_value double precision NOT NULL,
    observed_value double precision NOT NULL,
    error double precision NOT NULL,
    absolute_error double precision NOT NULL,
    squared_error double precision NOT NULL,
    derivation_run_id bigint,
    verified_at timestamp with time zone DEFAULT now() NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT forecast_verification_absolute_error_chk CHECK ((absolute_error >= (0)::double precision)),
    CONSTRAINT forecast_verification_lead_chk CHECK ((lead_minutes >= 0)),
    CONSTRAINT forecast_verification_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT forecast_verification_period_chk CHECK ((((period_start IS NULL) AND (period_end IS NULL)) OR ((period_start IS NOT NULL) AND (period_end IS NOT NULL) AND (period_end > period_start)))),
    CONSTRAINT forecast_verification_squared_error_chk CHECK ((squared_error >= (0)::double precision))
);


ALTER TABLE weather.forecast_verification OWNER TO postgres;

--
-- TOC entry 459 (class 1259 OID 245148)
-- Name: forecast_verification_forecast_verification_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.forecast_verification ALTER COLUMN forecast_verification_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME weather.forecast_verification_forecast_verification_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 462 (class 1259 OID 245248)
-- Name: forecast_verification_summary; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.forecast_verification_summary (
    forecast_verification_summary_id bigint CONSTRAINT forecast_verification_summa_forecast_verification_summ_not_null NOT NULL,
    verification_definition_id bigint CONSTRAINT forecast_verification_summa_verification_definition_id_not_null NOT NULL,
    forecast_product_id bigint NOT NULL,
    observation_product_id bigint NOT NULL,
    variable_id bigint NOT NULL,
    grid_cell_id bigint,
    lead_band_minutes_start integer,
    lead_band_minutes_end integer,
    verification_period_start timestamp with time zone CONSTRAINT forecast_verification_summar_verification_period_start_not_null NOT NULL,
    verification_period_end timestamp with time zone NOT NULL,
    sample_count bigint NOT NULL,
    mean_error double precision,
    mean_absolute_error double precision,
    root_mean_squared_error double precision,
    correlation double precision,
    mean_forecast_value double precision,
    mean_observed_value double precision,
    min_error double precision,
    max_error double precision,
    derivation_run_id bigint,
    calculation_version text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    calculated_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT forecast_verification_summary_calculation_version_chk CHECK ((btrim(calculation_version) <> ''::text)),
    CONSTRAINT forecast_verification_summary_correlation_chk CHECK (((correlation IS NULL) OR ((correlation >= ('-1'::integer)::double precision) AND (correlation <= (1)::double precision)))),
    CONSTRAINT forecast_verification_summary_lead_band_chk CHECK (((lead_band_minutes_start IS NULL) OR (lead_band_minutes_end IS NULL) OR (lead_band_minutes_end >= lead_band_minutes_start))),
    CONSTRAINT forecast_verification_summary_lead_end_chk CHECK (((lead_band_minutes_end IS NULL) OR (lead_band_minutes_end >= 0))),
    CONSTRAINT forecast_verification_summary_lead_start_chk CHECK (((lead_band_minutes_start IS NULL) OR (lead_band_minutes_start >= 0))),
    CONSTRAINT forecast_verification_summary_mae_chk CHECK (((mean_absolute_error IS NULL) OR (mean_absolute_error >= (0)::double precision))),
    CONSTRAINT forecast_verification_summary_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT forecast_verification_summary_period_chk CHECK ((verification_period_end > verification_period_start)),
    CONSTRAINT forecast_verification_summary_rmse_chk CHECK (((root_mean_squared_error IS NULL) OR (root_mean_squared_error >= (0)::double precision))),
    CONSTRAINT forecast_verification_summary_sample_count_chk CHECK ((sample_count > 0))
);


ALTER TABLE weather.forecast_verification_summary OWNER TO postgres;

--
-- TOC entry 461 (class 1259 OID 245247)
-- Name: forecast_verification_summary_forecast_verification_summary_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.forecast_verification_summary ALTER COLUMN forecast_verification_summary_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.forecast_verification_summary_forecast_verification_summary_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 321 (class 1259 OID 225764)
-- Name: grid_cell; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.grid_cell (
    grid_cell_id bigint NOT NULL,
    grid_system_id bigint NOT NULL,
    h3_index public.h3index NOT NULL,
    resolution smallint NOT NULL,
    center public.geometry(Point,4326) NOT NULL,
    boundary public.geometry(MultiPolygon,4326) NOT NULL,
    is_pentagon boolean DEFAULT false NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT grid_cell_boundary_not_empty_chk CHECK ((NOT public.st_isempty(boundary))),
    CONSTRAINT grid_cell_boundary_srid_chk CHECK ((public.st_srid(boundary) = 4326)),
    CONSTRAINT grid_cell_boundary_valid_chk CHECK (public.st_isvalid(boundary)),
    CONSTRAINT grid_cell_center_not_empty_chk CHECK ((NOT public.st_isempty(center))),
    CONSTRAINT grid_cell_center_srid_chk CHECK ((public.st_srid(center) = 4326)),
    CONSTRAINT grid_cell_h3_resolution_chk CHECK ((public.h3_get_resolution(h3_index) = resolution)),
    CONSTRAINT grid_cell_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT grid_cell_resolution_chk CHECK (((resolution >= 0) AND (resolution <= 15)))
);


ALTER TABLE weather.grid_cell OWNER TO postgres;

--
-- TOC entry 320 (class 1259 OID 225763)
-- Name: grid_cell_grid_cell_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.grid_cell ALTER COLUMN grid_cell_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.grid_cell_grid_cell_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 319 (class 1259 OID 225737)
-- Name: grid_system; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.grid_system (
    grid_system_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    provider_name text,
    version text,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT grid_system_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT grid_system_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT grid_system_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT grid_system_provider_name_chk CHECK (((provider_name IS NULL) OR (btrim(provider_name) <> ''::text))),
    CONSTRAINT grid_system_version_chk CHECK (((version IS NULL) OR (btrim(version) <> ''::text)))
);


ALTER TABLE weather.grid_system OWNER TO postgres;

--
-- TOC entry 318 (class 1259 OID 225736)
-- Name: grid_system_grid_system_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.grid_system ALTER COLUMN grid_system_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.grid_system_grid_system_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 344 (class 1259 OID 242258)
-- Name: ingestion_run; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.ingestion_run (
    ingestion_run_id bigint NOT NULL,
    dataset_version_id bigint NOT NULL,
    source_artifact_id bigint,
    run_type text NOT NULL,
    status text NOT NULL,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    records_read bigint,
    records_written bigint,
    records_rejected bigint,
    error_message text,
    software_version text,
    pipeline_version text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT ingestion_run_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT ingestion_run_records_read_chk CHECK (((records_read IS NULL) OR (records_read >= 0))),
    CONSTRAINT ingestion_run_records_rejected_chk CHECK (((records_rejected IS NULL) OR (records_rejected >= 0))),
    CONSTRAINT ingestion_run_records_written_chk CHECK (((records_written IS NULL) OR (records_written >= 0))),
    CONSTRAINT ingestion_run_status_not_blank_chk CHECK ((btrim(status) <> ''::text)),
    CONSTRAINT ingestion_run_time_chk CHECK (((completed_at IS NULL) OR (completed_at >= started_at))),
    CONSTRAINT ingestion_run_type_not_blank_chk CHECK ((btrim(run_type) <> ''::text))
);


ALTER TABLE weather.ingestion_run OWNER TO postgres;

--
-- TOC entry 343 (class 1259 OID 242257)
-- Name: ingestion_run_ingestion_run_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.ingestion_run ALTER COLUMN ingestion_run_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.ingestion_run_ingestion_run_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 418 (class 1259 OID 244021)
-- Name: observation_correction_reason; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.observation_correction_reason (
    observation_correction_reason_id smallint CONSTRAINT observation_correction_reas_observation_correction_rea_not_null NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    correction_source text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT observation_correction_reason_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT observation_correction_reason_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT observation_correction_reason_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT observation_correction_reason_source_chk CHECK ((correction_source = ANY (ARRAY['provider'::text, 'aurion'::text])))
);


ALTER TABLE weather.observation_correction_reason OWNER TO postgres;

--
-- TOC entry 417 (class 1259 OID 244020)
-- Name: observation_correction_reason_observation_correction_reason_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.observation_correction_reason ALTER COLUMN observation_correction_reason_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME weather.observation_correction_reason_observation_correction_reason_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 364 (class 1259 OID 242590)
-- Name: observation_product; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.observation_product (
    observation_product_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    product_type text NOT NULL,
    dataset_version_id bigint,
    derivation_version_id bigint,
    temporal_grain text,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    daily_period_definition_id smallint,
    calendar_timezone text,
    CONSTRAINT observation_product_calendar_timezone_chk CHECK (((calendar_timezone IS NULL) OR (btrim(calendar_timezone) <> ''::text))),
    CONSTRAINT observation_product_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT observation_product_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT observation_product_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT observation_product_provenance_chk CHECK (((dataset_version_id IS NOT NULL) OR (derivation_version_id IS NOT NULL))),
    CONSTRAINT observation_product_temporal_grain_chk CHECK (((temporal_grain IS NULL) OR (btrim(temporal_grain) <> ''::text))),
    CONSTRAINT observation_product_type_not_blank_chk CHECK ((btrim(product_type) <> ''::text))
);


ALTER TABLE weather.observation_product OWNER TO postgres;

--
-- TOC entry 363 (class 1259 OID 242589)
-- Name: observation_product_observation_product_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.observation_product ALTER COLUMN observation_product_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.observation_product_observation_product_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 384 (class 1259 OID 242931)
-- Name: observation_record_status; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.observation_record_status (
    observation_record_status_id smallint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    is_preferred boolean DEFAULT true NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT observation_record_status_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT observation_record_status_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT observation_record_status_name_not_blank_chk CHECK ((btrim(name) <> ''::text))
);


ALTER TABLE weather.observation_record_status OWNER TO postgres;

--
-- TOC entry 383 (class 1259 OID 242930)
-- Name: observation_record_status_observation_record_status_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.observation_record_status ALTER COLUMN observation_record_status_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME weather.observation_record_status_observation_record_status_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 336 (class 1259 OID 242136)
-- Name: provider; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.provider (
    provider_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    organisation_url text,
    country_code character(2),
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT provider_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT provider_country_code_chk CHECK (((country_code IS NULL) OR (country_code ~ '^[A-Z]{2}$'::text))),
    CONSTRAINT provider_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT provider_name_not_blank_chk CHECK ((btrim(name) <> ''::text))
);


ALTER TABLE weather.provider OWNER TO postgres;

--
-- TOC entry 335 (class 1259 OID 242135)
-- Name: provider_provider_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.provider ALTER COLUMN provider_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.provider_provider_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 389 (class 1259 OID 243101)
-- Name: quality_flag; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.quality_flag (
    quality_flag_id smallint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    severity text,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT quality_flag_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT quality_flag_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT quality_flag_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT quality_flag_severity_chk CHECK (((severity IS NULL) OR (btrim(severity) <> ''::text)))
);


ALTER TABLE weather.quality_flag OWNER TO postgres;

--
-- TOC entry 388 (class 1259 OID 243100)
-- Name: quality_flag_quality_flag_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.quality_flag ALTER COLUMN quality_flag_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME weather.quality_flag_quality_flag_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 342 (class 1259 OID 242229)
-- Name: source_artifact; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.source_artifact (
    source_artifact_id bigint NOT NULL,
    dataset_version_id bigint NOT NULL,
    artifact_type text NOT NULL,
    source_uri text,
    filename text,
    content_type text,
    compression_type text,
    size_bytes bigint,
    checksum_sha256 text,
    provider_created_at timestamp with time zone,
    discovered_at timestamp with time zone DEFAULT now() NOT NULL,
    storage_tier text,
    storage_uri text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT source_artifact_checksum_sha256_chk CHECK (((checksum_sha256 IS NULL) OR (checksum_sha256 ~ '^[0-9A-Fa-f]{64}$'::text))),
    CONSTRAINT source_artifact_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT source_artifact_size_bytes_chk CHECK (((size_bytes IS NULL) OR (size_bytes >= 0))),
    CONSTRAINT source_artifact_type_not_blank_chk CHECK ((btrim(artifact_type) <> ''::text))
);


ALTER TABLE weather.source_artifact OWNER TO postgres;

--
-- TOC entry 341 (class 1259 OID 242228)
-- Name: source_artifact_source_artifact_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.source_artifact ALTER COLUMN source_artifact_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.source_artifact_source_artifact_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 356 (class 1259 OID 242460)
-- Name: station; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.station (
    station_id bigint NOT NULL,
    canonical_name text NOT NULL,
    station_type text,
    country_code character(2),
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT station_country_code_chk CHECK (((country_code IS NULL) OR (country_code ~ '^[A-Z]{2}$'::text))),
    CONSTRAINT station_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT station_name_not_blank_chk CHECK ((btrim(canonical_name) <> ''::text)),
    CONSTRAINT station_type_chk CHECK (((station_type IS NULL) OR (btrim(station_type) <> ''::text)))
);


ALTER TABLE weather.station OWNER TO postgres;

--
-- TOC entry 366 (class 1259 OID 242632)
-- Name: station_h3_map; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.station_h3_map (
    station_h3_map_id bigint NOT NULL,
    station_history_id bigint NOT NULL,
    grid_cell_id bigint NOT NULL,
    mapping_method text DEFAULT 'point_to_cell'::text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT station_h3_map_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT station_h3_map_method_not_blank_chk CHECK ((btrim(mapping_method) <> ''::text))
);


ALTER TABLE weather.station_h3_map OWNER TO postgres;

--
-- TOC entry 365 (class 1259 OID 242631)
-- Name: station_h3_map_station_h3_map_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_h3_map ALTER COLUMN station_h3_map_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.station_h3_map_station_h3_map_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 360 (class 1259 OID 242527)
-- Name: station_history; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.station_history (
    station_history_id bigint NOT NULL,
    station_id bigint NOT NULL,
    valid_from timestamp with time zone NOT NULL,
    valid_to timestamp with time zone,
    "position" public.geometry(Point,4326) NOT NULL,
    elevation_m double precision,
    timezone_name text,
    operating_status text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT station_history_elevation_chk CHECK (((elevation_m IS NULL) OR ((elevation_m >= ('-500'::integer)::double precision) AND (elevation_m <= (10000)::double precision)))),
    CONSTRAINT station_history_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT station_history_position_not_empty_chk CHECK ((NOT public.st_isempty("position"))),
    CONSTRAINT station_history_position_srid_chk CHECK ((public.st_srid("position") = 4326)),
    CONSTRAINT station_history_status_chk CHECK (((operating_status IS NULL) OR (btrim(operating_status) <> ''::text))),
    CONSTRAINT station_history_timezone_chk CHECK (((timezone_name IS NULL) OR (btrim(timezone_name) <> ''::text))),
    CONSTRAINT station_history_validity_chk CHECK (((valid_to IS NULL) OR (valid_to > valid_from)))
);


ALTER TABLE weather.station_history OWNER TO postgres;

--
-- TOC entry 359 (class 1259 OID 242526)
-- Name: station_history_station_history_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_history ALTER COLUMN station_history_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.station_history_station_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 358 (class 1259 OID 242485)
-- Name: station_identifier; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.station_identifier (
    station_identifier_id bigint NOT NULL,
    station_id bigint NOT NULL,
    identifier_scheme text NOT NULL,
    identifier_value text NOT NULL,
    provider_id bigint,
    station_network_id bigint,
    is_primary boolean DEFAULT false NOT NULL,
    valid_from timestamp with time zone,
    valid_to timestamp with time zone,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT station_identifier_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT station_identifier_scheme_not_blank_chk CHECK ((btrim(identifier_scheme) <> ''::text)),
    CONSTRAINT station_identifier_validity_chk CHECK (((valid_to IS NULL) OR (valid_from IS NULL) OR (valid_to > valid_from))),
    CONSTRAINT station_identifier_value_not_blank_chk CHECK ((btrim(identifier_value) <> ''::text))
);


ALTER TABLE weather.station_identifier OWNER TO postgres;

--
-- TOC entry 357 (class 1259 OID 242484)
-- Name: station_identifier_station_identifier_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_identifier ALTER COLUMN station_identifier_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.station_identifier_station_identifier_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 354 (class 1259 OID 242429)
-- Name: station_network; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.station_network (
    station_network_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    provider_id bigint,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT station_network_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT station_network_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT station_network_name_not_blank_chk CHECK ((btrim(name) <> ''::text))
);


ALTER TABLE weather.station_network OWNER TO postgres;

--
-- TOC entry 362 (class 1259 OID 242559)
-- Name: station_network_membership; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.station_network_membership (
    station_network_membership_id bigint CONSTRAINT station_network_membership_station_network_membership__not_null NOT NULL,
    station_id bigint NOT NULL,
    station_network_id bigint NOT NULL,
    valid_from timestamp with time zone,
    valid_to timestamp with time zone,
    is_primary boolean DEFAULT false NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT station_network_membership_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT station_network_membership_validity_chk CHECK (((valid_to IS NULL) OR (valid_from IS NULL) OR (valid_to > valid_from)))
);


ALTER TABLE weather.station_network_membership OWNER TO postgres;

--
-- TOC entry 361 (class 1259 OID 242558)
-- Name: station_network_membership_station_network_membership_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_network_membership ALTER COLUMN station_network_membership_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.station_network_membership_station_network_membership_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 353 (class 1259 OID 242428)
-- Name: station_network_station_network_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_network ALTER COLUMN station_network_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.station_network_station_network_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 420 (class 1259 OID 244045)
-- Name: station_observation_correction; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.station_observation_correction (
    station_observation_correction_id bigint CONSTRAINT station_observation_correct_station_observation_correc_not_null NOT NULL,
    original_observation_id bigint NOT NULL,
    original_observation_time timestamp with time zone CONSTRAINT station_observation_correcti_original_observation_time_not_null NOT NULL,
    replacement_observation_id bigint CONSTRAINT station_observation_correct_replacement_observation_id_not_null NOT NULL,
    replacement_observation_time timestamp with time zone CONSTRAINT station_observation_correct_replacement_observation_ti_not_null NOT NULL,
    observation_correction_reason_id smallint CONSTRAINT station_observation_correct_observation_correction_rea_not_null NOT NULL,
    source_artifact_id bigint,
    derivation_run_id bigint,
    correction_time timestamp with time zone DEFAULT now() NOT NULL,
    notes text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT station_observation_correction_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT station_observation_correction_not_self_chk CHECK (((original_observation_id <> replacement_observation_id) OR (original_observation_time <> replacement_observation_time))),
    CONSTRAINT station_observation_correction_notes_chk CHECK (((notes IS NULL) OR (btrim(notes) <> ''::text)))
);


ALTER TABLE weather.station_observation_correction OWNER TO postgres;

--
-- TOC entry 419 (class 1259 OID 244044)
-- Name: station_observation_correctio_station_observation_correctio_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_correction ALTER COLUMN station_observation_correction_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.station_observation_correctio_station_observation_correctio_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 400 (class 1259 OID 243398)
-- Name: station_observation_daily; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.station_observation_daily (
    station_observation_daily_id bigint NOT NULL,
    observation_date date NOT NULL,
    station_id bigint NOT NULL,
    station_history_id bigint NOT NULL,
    observation_product_id bigint NOT NULL,
    observation_record_status_id smallint NOT NULL,
    ingestion_run_id bigint,
    derivation_run_id bigint,
    period_start timestamp with time zone NOT NULL,
    period_end timestamp with time zone NOT NULL,
    provider_published_at timestamp with time zone,
    received_at timestamp with time zone,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    revision_no integer DEFAULT 1 NOT NULL,
    is_preferred boolean DEFAULT true NOT NULL,
    supersedes_observation_daily_id bigint,
    supersedes_observation_date date,
    air_temperature_2m_min_c double precision,
    air_temperature_2m_max_c double precision,
    air_temperature_2m_mean_c double precision,
    apparent_temperature_2m_min_c double precision,
    apparent_temperature_2m_max_c double precision,
    apparent_temperature_2m_mean_c double precision,
    dew_point_2m_min_c double precision,
    dew_point_2m_max_c double precision,
    dew_point_2m_mean_c double precision,
    relative_humidity_2m_min_pct double precision,
    relative_humidity_2m_max_pct double precision,
    relative_humidity_2m_mean_pct double precision,
    surface_pressure_mean_hpa double precision,
    precipitation_total_mm double precision,
    rainfall_total_mm double precision,
    snowfall_total_mm double precision,
    snow_depth_max_mm double precision,
    wind_u_10m_mean_ms double precision,
    wind_v_10m_mean_ms double precision,
    wind_gust_10m_max_ms double precision,
    cloud_cover_mean_pct double precision,
    visibility_mean_m double precision,
    solar_radiation_mean_w_m2 double precision,
    sample_count integer,
    coverage_fraction double precision,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT station_observation_daily_apparent_temperature_order_chk CHECK (((apparent_temperature_2m_min_c IS NULL) OR (apparent_temperature_2m_max_c IS NULL) OR (apparent_temperature_2m_min_c <= apparent_temperature_2m_max_c))),
    CONSTRAINT station_observation_daily_cloud_cover_chk CHECK (((cloud_cover_mean_pct IS NULL) OR ((cloud_cover_mean_pct >= (0)::double precision) AND (cloud_cover_mean_pct <= (100)::double precision)))),
    CONSTRAINT station_observation_daily_coverage_chk CHECK (((coverage_fraction IS NULL) OR ((coverage_fraction >= (0)::double precision) AND (coverage_fraction <= (1)::double precision)))),
    CONSTRAINT station_observation_daily_dew_point_order_chk CHECK (((dew_point_2m_min_c IS NULL) OR (dew_point_2m_max_c IS NULL) OR (dew_point_2m_min_c <= dew_point_2m_max_c))),
    CONSTRAINT station_observation_daily_humidity_max_chk CHECK (((relative_humidity_2m_max_pct IS NULL) OR ((relative_humidity_2m_max_pct >= (0)::double precision) AND (relative_humidity_2m_max_pct <= (100)::double precision)))),
    CONSTRAINT station_observation_daily_humidity_mean_chk CHECK (((relative_humidity_2m_mean_pct IS NULL) OR ((relative_humidity_2m_mean_pct >= (0)::double precision) AND (relative_humidity_2m_mean_pct <= (100)::double precision)))),
    CONSTRAINT station_observation_daily_humidity_min_chk CHECK (((relative_humidity_2m_min_pct IS NULL) OR ((relative_humidity_2m_min_pct >= (0)::double precision) AND (relative_humidity_2m_min_pct <= (100)::double precision)))),
    CONSTRAINT station_observation_daily_humidity_order_chk CHECK (((relative_humidity_2m_min_pct IS NULL) OR (relative_humidity_2m_max_pct IS NULL) OR (relative_humidity_2m_min_pct <= relative_humidity_2m_max_pct))),
    CONSTRAINT station_observation_daily_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT station_observation_daily_period_chk CHECK ((period_end > period_start)),
    CONSTRAINT station_observation_daily_precipitation_chk CHECK (((precipitation_total_mm IS NULL) OR (precipitation_total_mm >= (0)::double precision))),
    CONSTRAINT station_observation_daily_rainfall_chk CHECK (((rainfall_total_mm IS NULL) OR (rainfall_total_mm >= (0)::double precision))),
    CONSTRAINT station_observation_daily_revision_chk CHECK ((revision_no >= 1)),
    CONSTRAINT station_observation_daily_sample_count_chk CHECK (((sample_count IS NULL) OR (sample_count >= 0))),
    CONSTRAINT station_observation_daily_snow_depth_chk CHECK (((snow_depth_max_mm IS NULL) OR (snow_depth_max_mm >= (0)::double precision))),
    CONSTRAINT station_observation_daily_snowfall_chk CHECK (((snowfall_total_mm IS NULL) OR (snowfall_total_mm >= (0)::double precision))),
    CONSTRAINT station_observation_daily_supersession_chk CHECK ((((supersedes_observation_daily_id IS NULL) AND (supersedes_observation_date IS NULL)) OR ((supersedes_observation_daily_id IS NOT NULL) AND (supersedes_observation_date IS NOT NULL)))),
    CONSTRAINT station_observation_daily_temperature_order_chk CHECK (((air_temperature_2m_min_c IS NULL) OR (air_temperature_2m_max_c IS NULL) OR (air_temperature_2m_min_c <= air_temperature_2m_max_c))),
    CONSTRAINT station_observation_daily_visibility_chk CHECK (((visibility_mean_m IS NULL) OR (visibility_mean_m >= (0)::double precision)))
)
PARTITION BY RANGE (observation_date);


ALTER TABLE weather.station_observation_daily OWNER TO postgres;

--
-- TOC entry 424 (class 1259 OID 244163)
-- Name: station_observation_daily_correction; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.station_observation_daily_correction (
    station_observation_daily_correction_id bigint CONSTRAINT station_observation_daily_c_station_observation_daily__not_null NOT NULL,
    original_observation_daily_id bigint CONSTRAINT station_observation_daily_c_original_observation_daily_not_null NOT NULL,
    original_observation_date date CONSTRAINT station_observation_daily_co_original_observation_date_not_null NOT NULL,
    replacement_observation_daily_id bigint CONSTRAINT station_observation_daily_c_replacement_observation_da_not_null NOT NULL,
    replacement_observation_date date CONSTRAINT station_observation_daily__replacement_observation_da_not_null1 NOT NULL,
    observation_correction_reason_id smallint CONSTRAINT station_observation_daily_c_observation_correction_rea_not_null NOT NULL,
    source_artifact_id bigint,
    derivation_run_id bigint,
    correction_time timestamp with time zone DEFAULT now() NOT NULL,
    notes text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT station_observation_daily_correction_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT station_observation_daily_correction_not_self_chk CHECK (((original_observation_daily_id <> replacement_observation_daily_id) OR (original_observation_date <> replacement_observation_date))),
    CONSTRAINT station_observation_daily_correction_notes_chk CHECK (((notes IS NULL) OR (btrim(notes) <> ''::text)))
);


ALTER TABLE weather.station_observation_daily_correction OWNER TO postgres;

--
-- TOC entry 423 (class 1259 OID 244162)
-- Name: station_observation_daily_cor_station_observation_daily_cor_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_daily_correction ALTER COLUMN station_observation_daily_correction_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.station_observation_daily_cor_station_observation_daily_cor_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 401 (class 1259 OID 243483)
-- Name: station_observation_daily_default; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.station_observation_daily_default (
    station_observation_daily_id bigint CONSTRAINT station_observation_daily_station_observation_daily_id_not_null NOT NULL,
    observation_date date CONSTRAINT station_observation_daily_observation_date_not_null NOT NULL,
    station_id bigint CONSTRAINT station_observation_daily_station_id_not_null NOT NULL,
    station_history_id bigint CONSTRAINT station_observation_daily_station_history_id_not_null NOT NULL,
    observation_product_id bigint CONSTRAINT station_observation_daily_observation_product_id_not_null NOT NULL,
    observation_record_status_id smallint CONSTRAINT station_observation_daily_observation_record_status_id_not_null NOT NULL,
    ingestion_run_id bigint,
    derivation_run_id bigint,
    period_start timestamp with time zone CONSTRAINT station_observation_daily_period_start_not_null NOT NULL,
    period_end timestamp with time zone CONSTRAINT station_observation_daily_period_end_not_null NOT NULL,
    provider_published_at timestamp with time zone,
    received_at timestamp with time zone,
    ingested_at timestamp with time zone DEFAULT now() CONSTRAINT station_observation_daily_ingested_at_not_null NOT NULL,
    revision_no integer DEFAULT 1 CONSTRAINT station_observation_daily_revision_no_not_null NOT NULL,
    is_preferred boolean DEFAULT true CONSTRAINT station_observation_daily_is_preferred_not_null NOT NULL,
    supersedes_observation_daily_id bigint,
    supersedes_observation_date date,
    air_temperature_2m_min_c double precision,
    air_temperature_2m_max_c double precision,
    air_temperature_2m_mean_c double precision,
    apparent_temperature_2m_min_c double precision,
    apparent_temperature_2m_max_c double precision,
    apparent_temperature_2m_mean_c double precision,
    dew_point_2m_min_c double precision,
    dew_point_2m_max_c double precision,
    dew_point_2m_mean_c double precision,
    relative_humidity_2m_min_pct double precision,
    relative_humidity_2m_max_pct double precision,
    relative_humidity_2m_mean_pct double precision,
    surface_pressure_mean_hpa double precision,
    precipitation_total_mm double precision,
    rainfall_total_mm double precision,
    snowfall_total_mm double precision,
    snow_depth_max_mm double precision,
    wind_u_10m_mean_ms double precision,
    wind_v_10m_mean_ms double precision,
    wind_gust_10m_max_ms double precision,
    cloud_cover_mean_pct double precision,
    visibility_mean_m double precision,
    solar_radiation_mean_w_m2 double precision,
    sample_count integer,
    coverage_fraction double precision,
    metadata jsonb DEFAULT '{}'::jsonb CONSTRAINT station_observation_daily_metadata_not_null NOT NULL,
    created_at timestamp with time zone DEFAULT now() CONSTRAINT station_observation_daily_created_at_not_null NOT NULL,
    CONSTRAINT station_observation_daily_apparent_temperature_order_chk CHECK (((apparent_temperature_2m_min_c IS NULL) OR (apparent_temperature_2m_max_c IS NULL) OR (apparent_temperature_2m_min_c <= apparent_temperature_2m_max_c))),
    CONSTRAINT station_observation_daily_cloud_cover_chk CHECK (((cloud_cover_mean_pct IS NULL) OR ((cloud_cover_mean_pct >= (0)::double precision) AND (cloud_cover_mean_pct <= (100)::double precision)))),
    CONSTRAINT station_observation_daily_coverage_chk CHECK (((coverage_fraction IS NULL) OR ((coverage_fraction >= (0)::double precision) AND (coverage_fraction <= (1)::double precision)))),
    CONSTRAINT station_observation_daily_dew_point_order_chk CHECK (((dew_point_2m_min_c IS NULL) OR (dew_point_2m_max_c IS NULL) OR (dew_point_2m_min_c <= dew_point_2m_max_c))),
    CONSTRAINT station_observation_daily_humidity_max_chk CHECK (((relative_humidity_2m_max_pct IS NULL) OR ((relative_humidity_2m_max_pct >= (0)::double precision) AND (relative_humidity_2m_max_pct <= (100)::double precision)))),
    CONSTRAINT station_observation_daily_humidity_mean_chk CHECK (((relative_humidity_2m_mean_pct IS NULL) OR ((relative_humidity_2m_mean_pct >= (0)::double precision) AND (relative_humidity_2m_mean_pct <= (100)::double precision)))),
    CONSTRAINT station_observation_daily_humidity_min_chk CHECK (((relative_humidity_2m_min_pct IS NULL) OR ((relative_humidity_2m_min_pct >= (0)::double precision) AND (relative_humidity_2m_min_pct <= (100)::double precision)))),
    CONSTRAINT station_observation_daily_humidity_order_chk CHECK (((relative_humidity_2m_min_pct IS NULL) OR (relative_humidity_2m_max_pct IS NULL) OR (relative_humidity_2m_min_pct <= relative_humidity_2m_max_pct))),
    CONSTRAINT station_observation_daily_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT station_observation_daily_period_chk CHECK ((period_end > period_start)),
    CONSTRAINT station_observation_daily_precipitation_chk CHECK (((precipitation_total_mm IS NULL) OR (precipitation_total_mm >= (0)::double precision))),
    CONSTRAINT station_observation_daily_rainfall_chk CHECK (((rainfall_total_mm IS NULL) OR (rainfall_total_mm >= (0)::double precision))),
    CONSTRAINT station_observation_daily_revision_chk CHECK ((revision_no >= 1)),
    CONSTRAINT station_observation_daily_sample_count_chk CHECK (((sample_count IS NULL) OR (sample_count >= 0))),
    CONSTRAINT station_observation_daily_snow_depth_chk CHECK (((snow_depth_max_mm IS NULL) OR (snow_depth_max_mm >= (0)::double precision))),
    CONSTRAINT station_observation_daily_snowfall_chk CHECK (((snowfall_total_mm IS NULL) OR (snowfall_total_mm >= (0)::double precision))),
    CONSTRAINT station_observation_daily_supersession_chk CHECK ((((supersedes_observation_daily_id IS NULL) AND (supersedes_observation_date IS NULL)) OR ((supersedes_observation_daily_id IS NOT NULL) AND (supersedes_observation_date IS NOT NULL)))),
    CONSTRAINT station_observation_daily_temperature_order_chk CHECK (((air_temperature_2m_min_c IS NULL) OR (air_temperature_2m_max_c IS NULL) OR (air_temperature_2m_min_c <= air_temperature_2m_max_c))),
    CONSTRAINT station_observation_daily_visibility_chk CHECK (((visibility_mean_m IS NULL) OR (visibility_mean_m >= (0)::double precision)))
);


ALTER TABLE weather.station_observation_daily_default OWNER TO postgres;

--
-- TOC entry 406 (class 1259 OID 243717)
-- Name: station_observation_daily_quality_exception; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.station_observation_daily_quality_exception (
    station_observation_daily_quality_exception_id bigint CONSTRAINT station_observation_daily_q_station_observation_daily__not_null NOT NULL,
    station_observation_daily_id bigint CONSTRAINT station_observation_daily__station_observation_daily__not_null1 NOT NULL,
    observation_date date CONSTRAINT station_observation_daily_quality_exc_observation_date_not_null NOT NULL,
    variable_id bigint CONSTRAINT station_observation_daily_quality_exceptio_variable_id_not_null NOT NULL,
    quality_flag_id smallint CONSTRAINT station_observation_daily_quality_exce_quality_flag_id_not_null NOT NULL,
    detected_by text,
    derivation_run_id bigint,
    details text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    detected_at timestamp with time zone DEFAULT now() CONSTRAINT station_observation_daily_quality_exceptio_detected_at_not_null NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT station_observation_daily_quality_exception_details_chk CHECK (((details IS NULL) OR (btrim(details) <> ''::text))),
    CONSTRAINT station_observation_daily_quality_exception_detected_by_chk CHECK (((detected_by IS NULL) OR (btrim(detected_by) <> ''::text))),
    CONSTRAINT station_observation_daily_quality_exception_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text))
);


ALTER TABLE weather.station_observation_daily_quality_exception OWNER TO postgres;

--
-- TOC entry 405 (class 1259 OID 243716)
-- Name: station_observation_daily_qua_station_observation_daily_qua_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_daily_quality_exception ALTER COLUMN station_observation_daily_quality_exception_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.station_observation_daily_qua_station_observation_daily_qua_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 399 (class 1259 OID 243397)
-- Name: station_observation_daily_station_observation_daily_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_daily ALTER COLUMN station_observation_daily_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME weather.station_observation_daily_station_observation_daily_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 386 (class 1259 OID 242957)
-- Name: station_observation_hourly; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.station_observation_hourly (
    station_observation_id bigint NOT NULL,
    observation_time timestamp with time zone NOT NULL,
    station_id bigint NOT NULL,
    station_history_id bigint NOT NULL,
    observation_product_id bigint NOT NULL,
    observation_record_status_id smallint CONSTRAINT station_observation_hourly_observation_record_status_i_not_null NOT NULL,
    ingestion_run_id bigint,
    derivation_run_id bigint,
    period_start timestamp with time zone,
    period_end timestamp with time zone,
    provider_published_at timestamp with time zone,
    received_at timestamp with time zone,
    ingested_at timestamp with time zone DEFAULT now() NOT NULL,
    revision_no integer DEFAULT 1 NOT NULL,
    is_preferred boolean DEFAULT true NOT NULL,
    supersedes_observation_id bigint,
    supersedes_observation_time timestamp with time zone,
    air_temperature_2m_c double precision,
    apparent_temperature_2m_c double precision,
    dew_point_2m_c double precision,
    relative_humidity_2m_pct double precision,
    surface_pressure_hpa double precision,
    precipitation_1h_mm double precision,
    rainfall_1h_mm double precision,
    snowfall_1h_mm double precision,
    snow_depth_mm double precision,
    wind_u_10m_ms double precision,
    wind_v_10m_ms double precision,
    wind_gust_10m_max_1h_ms double precision,
    cloud_cover_pct double precision,
    visibility_m double precision,
    solar_radiation_w_m2 double precision,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    condition_code_id smallint,
    CONSTRAINT station_observation_hourly_cloud_cover_chk CHECK (((cloud_cover_pct IS NULL) OR ((cloud_cover_pct >= (0)::double precision) AND (cloud_cover_pct <= (100)::double precision)))),
    CONSTRAINT station_observation_hourly_interval_values_chk CHECK ((((precipitation_1h_mm IS NULL) AND (rainfall_1h_mm IS NULL) AND (snowfall_1h_mm IS NULL) AND (wind_gust_10m_max_1h_ms IS NULL)) OR ((period_start IS NOT NULL) AND (period_end IS NOT NULL)))),
    CONSTRAINT station_observation_hourly_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT station_observation_hourly_period_chk CHECK ((((period_start IS NULL) AND (period_end IS NULL)) OR ((period_start IS NOT NULL) AND (period_end IS NOT NULL) AND (period_end > period_start)))),
    CONSTRAINT station_observation_hourly_precipitation_chk CHECK (((precipitation_1h_mm IS NULL) OR (precipitation_1h_mm >= (0)::double precision))),
    CONSTRAINT station_observation_hourly_rainfall_chk CHECK (((rainfall_1h_mm IS NULL) OR (rainfall_1h_mm >= (0)::double precision))),
    CONSTRAINT station_observation_hourly_relative_humidity_chk CHECK (((relative_humidity_2m_pct IS NULL) OR ((relative_humidity_2m_pct >= (0)::double precision) AND (relative_humidity_2m_pct <= (100)::double precision)))),
    CONSTRAINT station_observation_hourly_revision_chk CHECK ((revision_no >= 1)),
    CONSTRAINT station_observation_hourly_snow_depth_chk CHECK (((snow_depth_mm IS NULL) OR (snow_depth_mm >= (0)::double precision))),
    CONSTRAINT station_observation_hourly_snowfall_chk CHECK (((snowfall_1h_mm IS NULL) OR (snowfall_1h_mm >= (0)::double precision))),
    CONSTRAINT station_observation_hourly_supersession_chk CHECK ((((supersedes_observation_id IS NULL) AND (supersedes_observation_time IS NULL)) OR ((supersedes_observation_id IS NOT NULL) AND (supersedes_observation_time IS NOT NULL)))),
    CONSTRAINT station_observation_hourly_visibility_chk CHECK (((visibility_m IS NULL) OR (visibility_m >= (0)::double precision)))
)
PARTITION BY RANGE (observation_time);


ALTER TABLE weather.station_observation_hourly OWNER TO postgres;

--
-- TOC entry 9316 (class 0 OID 0)
-- Dependencies: 386
-- Name: COLUMN station_observation_hourly.air_temperature_2m_c; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.station_observation_hourly.air_temperature_2m_c IS 'Canonical 2 m air temperature in degrees Celsius.';


--
-- TOC entry 9317 (class 0 OID 0)
-- Dependencies: 386
-- Name: COLUMN station_observation_hourly.apparent_temperature_2m_c; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.station_observation_hourly.apparent_temperature_2m_c IS 'Canonical 2 m apparent temperature in degrees Celsius.';


--
-- TOC entry 9318 (class 0 OID 0)
-- Dependencies: 386
-- Name: COLUMN station_observation_hourly.dew_point_2m_c; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.station_observation_hourly.dew_point_2m_c IS 'Canonical 2 m dew point in degrees Celsius.';


--
-- TOC entry 9319 (class 0 OID 0)
-- Dependencies: 386
-- Name: COLUMN station_observation_hourly.relative_humidity_2m_pct; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.station_observation_hourly.relative_humidity_2m_pct IS 'Canonical 2 m relative humidity in percent.';


--
-- TOC entry 9320 (class 0 OID 0)
-- Dependencies: 386
-- Name: COLUMN station_observation_hourly.surface_pressure_hpa; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.station_observation_hourly.surface_pressure_hpa IS 'Canonical surface atmospheric pressure in hectopascals.';


--
-- TOC entry 9321 (class 0 OID 0)
-- Dependencies: 386
-- Name: COLUMN station_observation_hourly.precipitation_1h_mm; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.station_observation_hourly.precipitation_1h_mm IS 'Canonical total precipitation accumulated over the explicit one-hour period, in millimetres.';


--
-- TOC entry 9322 (class 0 OID 0)
-- Dependencies: 386
-- Name: COLUMN station_observation_hourly.rainfall_1h_mm; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.station_observation_hourly.rainfall_1h_mm IS 'Canonical liquid rainfall accumulated over the explicit one-hour period, in millimetres.';


--
-- TOC entry 9323 (class 0 OID 0)
-- Dependencies: 386
-- Name: COLUMN station_observation_hourly.snowfall_1h_mm; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.station_observation_hourly.snowfall_1h_mm IS 'Canonical snowfall accumulated over the explicit one-hour period, in millimetres.';


--
-- TOC entry 9324 (class 0 OID 0)
-- Dependencies: 386
-- Name: COLUMN station_observation_hourly.snow_depth_mm; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.station_observation_hourly.snow_depth_mm IS 'Canonical instantaneous snow depth in millimetres.';


--
-- TOC entry 9325 (class 0 OID 0)
-- Dependencies: 386
-- Name: COLUMN station_observation_hourly.wind_u_10m_ms; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.station_observation_hourly.wind_u_10m_ms IS 'Canonical east-west wind vector component at 10 m in metres per second.';


--
-- TOC entry 9326 (class 0 OID 0)
-- Dependencies: 386
-- Name: COLUMN station_observation_hourly.wind_v_10m_ms; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.station_observation_hourly.wind_v_10m_ms IS 'Canonical north-south wind vector component at 10 m in metres per second.';


--
-- TOC entry 9327 (class 0 OID 0)
-- Dependencies: 386
-- Name: COLUMN station_observation_hourly.wind_gust_10m_max_1h_ms; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.station_observation_hourly.wind_gust_10m_max_1h_ms IS 'Maximum 10 m wind gust over the explicit one-hour period in metres per second.';


--
-- TOC entry 9328 (class 0 OID 0)
-- Dependencies: 386
-- Name: COLUMN station_observation_hourly.cloud_cover_pct; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.station_observation_hourly.cloud_cover_pct IS 'Canonical total cloud cover in percent.';


--
-- TOC entry 9329 (class 0 OID 0)
-- Dependencies: 386
-- Name: COLUMN station_observation_hourly.visibility_m; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.station_observation_hourly.visibility_m IS 'Canonical horizontal visibility in metres.';


--
-- TOC entry 9330 (class 0 OID 0)
-- Dependencies: 386
-- Name: COLUMN station_observation_hourly.solar_radiation_w_m2; Type: COMMENT; Schema: weather; Owner: postgres
--

COMMENT ON COLUMN weather.station_observation_hourly.solar_radiation_w_m2 IS 'Canonical surface solar radiation flux in watts per square metre.';


--
-- TOC entry 387 (class 1259 OID 243033)
-- Name: station_observation_hourly_default; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.station_observation_hourly_default (
    station_observation_id bigint CONSTRAINT station_observation_hourly_station_observation_id_not_null NOT NULL,
    observation_time timestamp with time zone CONSTRAINT station_observation_hourly_observation_time_not_null NOT NULL,
    station_id bigint CONSTRAINT station_observation_hourly_station_id_not_null NOT NULL,
    station_history_id bigint CONSTRAINT station_observation_hourly_station_history_id_not_null NOT NULL,
    observation_product_id bigint CONSTRAINT station_observation_hourly_observation_product_id_not_null NOT NULL,
    observation_record_status_id smallint CONSTRAINT station_observation_hourly_observation_record_status_i_not_null NOT NULL,
    ingestion_run_id bigint,
    derivation_run_id bigint,
    period_start timestamp with time zone,
    period_end timestamp with time zone,
    provider_published_at timestamp with time zone,
    received_at timestamp with time zone,
    ingested_at timestamp with time zone DEFAULT now() CONSTRAINT station_observation_hourly_ingested_at_not_null NOT NULL,
    revision_no integer DEFAULT 1 CONSTRAINT station_observation_hourly_revision_no_not_null NOT NULL,
    is_preferred boolean DEFAULT true CONSTRAINT station_observation_hourly_is_preferred_not_null NOT NULL,
    supersedes_observation_id bigint,
    supersedes_observation_time timestamp with time zone,
    air_temperature_2m_c double precision,
    apparent_temperature_2m_c double precision,
    dew_point_2m_c double precision,
    relative_humidity_2m_pct double precision,
    surface_pressure_hpa double precision,
    precipitation_1h_mm double precision,
    rainfall_1h_mm double precision,
    snowfall_1h_mm double precision,
    snow_depth_mm double precision,
    wind_u_10m_ms double precision,
    wind_v_10m_ms double precision,
    wind_gust_10m_max_1h_ms double precision,
    cloud_cover_pct double precision,
    visibility_m double precision,
    solar_radiation_w_m2 double precision,
    metadata jsonb DEFAULT '{}'::jsonb CONSTRAINT station_observation_hourly_metadata_not_null NOT NULL,
    created_at timestamp with time zone DEFAULT now() CONSTRAINT station_observation_hourly_created_at_not_null NOT NULL,
    condition_code_id smallint,
    CONSTRAINT station_observation_hourly_cloud_cover_chk CHECK (((cloud_cover_pct IS NULL) OR ((cloud_cover_pct >= (0)::double precision) AND (cloud_cover_pct <= (100)::double precision)))),
    CONSTRAINT station_observation_hourly_interval_values_chk CHECK ((((precipitation_1h_mm IS NULL) AND (rainfall_1h_mm IS NULL) AND (snowfall_1h_mm IS NULL) AND (wind_gust_10m_max_1h_ms IS NULL)) OR ((period_start IS NOT NULL) AND (period_end IS NOT NULL)))),
    CONSTRAINT station_observation_hourly_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT station_observation_hourly_period_chk CHECK ((((period_start IS NULL) AND (period_end IS NULL)) OR ((period_start IS NOT NULL) AND (period_end IS NOT NULL) AND (period_end > period_start)))),
    CONSTRAINT station_observation_hourly_precipitation_chk CHECK (((precipitation_1h_mm IS NULL) OR (precipitation_1h_mm >= (0)::double precision))),
    CONSTRAINT station_observation_hourly_rainfall_chk CHECK (((rainfall_1h_mm IS NULL) OR (rainfall_1h_mm >= (0)::double precision))),
    CONSTRAINT station_observation_hourly_relative_humidity_chk CHECK (((relative_humidity_2m_pct IS NULL) OR ((relative_humidity_2m_pct >= (0)::double precision) AND (relative_humidity_2m_pct <= (100)::double precision)))),
    CONSTRAINT station_observation_hourly_revision_chk CHECK ((revision_no >= 1)),
    CONSTRAINT station_observation_hourly_snow_depth_chk CHECK (((snow_depth_mm IS NULL) OR (snow_depth_mm >= (0)::double precision))),
    CONSTRAINT station_observation_hourly_snowfall_chk CHECK (((snowfall_1h_mm IS NULL) OR (snowfall_1h_mm >= (0)::double precision))),
    CONSTRAINT station_observation_hourly_supersession_chk CHECK ((((supersedes_observation_id IS NULL) AND (supersedes_observation_time IS NULL)) OR ((supersedes_observation_id IS NOT NULL) AND (supersedes_observation_time IS NOT NULL)))),
    CONSTRAINT station_observation_hourly_visibility_chk CHECK (((visibility_m IS NULL) OR (visibility_m >= (0)::double precision)))
);


ALTER TABLE weather.station_observation_hourly_default OWNER TO postgres;

--
-- TOC entry 385 (class 1259 OID 242956)
-- Name: station_observation_hourly_station_observation_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_hourly ALTER COLUMN station_observation_id ADD GENERATED BY DEFAULT AS IDENTITY (
    SEQUENCE NAME weather.station_observation_hourly_station_observation_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 391 (class 1259 OID 243124)
-- Name: station_observation_quality_exception; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.station_observation_quality_exception (
    station_observation_quality_exception_id bigint CONSTRAINT station_observation_quality_station_observation_qualit_not_null NOT NULL,
    station_observation_id bigint CONSTRAINT station_observation_quality_exc_station_observation_id_not_null NOT NULL,
    observation_time timestamp with time zone NOT NULL,
    variable_id bigint NOT NULL,
    quality_flag_id smallint NOT NULL,
    detected_by text,
    derivation_run_id bigint,
    details text,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    detected_at timestamp with time zone DEFAULT now() NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT station_observation_quality_exception_details_chk CHECK (((details IS NULL) OR (btrim(details) <> ''::text))),
    CONSTRAINT station_observation_quality_exception_detected_by_chk CHECK (((detected_by IS NULL) OR (btrim(detected_by) <> ''::text))),
    CONSTRAINT station_observation_quality_exception_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text))
);


ALTER TABLE weather.station_observation_quality_exception OWNER TO postgres;

--
-- TOC entry 390 (class 1259 OID 243123)
-- Name: station_observation_quality_e_station_observation_quality_e_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_quality_exception ALTER COLUMN station_observation_quality_exception_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.station_observation_quality_e_station_observation_quality_e_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 410 (class 1259 OID 243819)
-- Name: station_observation_value; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.station_observation_value (
    station_observation_value_id bigint NOT NULL,
    station_observation_id bigint NOT NULL,
    observation_time timestamp with time zone NOT NULL,
    variable_id bigint NOT NULL,
    value_double double precision,
    value_text text,
    observation_record_status_id smallint,
    ingestion_run_id bigint,
    derivation_run_id bigint,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT station_observation_value_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT station_observation_value_text_chk CHECK (((value_text IS NULL) OR (btrim(value_text) <> ''::text))),
    CONSTRAINT station_observation_value_value_chk CHECK ((((value_double IS NOT NULL) AND (value_text IS NULL)) OR ((value_double IS NULL) AND (value_text IS NOT NULL))))
);


ALTER TABLE weather.station_observation_value OWNER TO postgres;

--
-- TOC entry 409 (class 1259 OID 243818)
-- Name: station_observation_value_station_observation_value_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_value ALTER COLUMN station_observation_value_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.station_observation_value_station_observation_value_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 368 (class 1259 OID 242666)
-- Name: station_region_map; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.station_region_map (
    station_region_map_id bigint NOT NULL,
    station_history_id bigint NOT NULL,
    region_version_id bigint NOT NULL,
    mapping_method text DEFAULT 'point_in_polygon'::text NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT station_region_map_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT station_region_map_method_not_blank_chk CHECK ((btrim(mapping_method) <> ''::text))
);


ALTER TABLE weather.station_region_map OWNER TO postgres;

--
-- TOC entry 367 (class 1259 OID 242665)
-- Name: station_region_map_station_region_map_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_region_map ALTER COLUMN station_region_map_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.station_region_map_station_region_map_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 355 (class 1259 OID 242459)
-- Name: station_station_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station ALTER COLUMN station_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.station_station_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 372 (class 1259 OID 242728)
-- Name: statistic; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.statistic (
    statistic_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT statistic_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT statistic_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT statistic_name_not_blank_chk CHECK ((btrim(name) <> ''::text))
);


ALTER TABLE weather.statistic OWNER TO postgres;

--
-- TOC entry 371 (class 1259 OID 242727)
-- Name: statistic_statistic_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.statistic ALTER COLUMN statistic_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.statistic_statistic_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 374 (class 1259 OID 242750)
-- Name: temporal_semantics; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.temporal_semantics (
    temporal_semantics_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    requires_period boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT temporal_semantics_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT temporal_semantics_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT temporal_semantics_name_not_blank_chk CHECK ((btrim(name) <> ''::text))
);


ALTER TABLE weather.temporal_semantics OWNER TO postgres;

--
-- TOC entry 373 (class 1259 OID 242749)
-- Name: temporal_semantics_temporal_semantics_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.temporal_semantics ALTER COLUMN temporal_semantics_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.temporal_semantics_temporal_semantics_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 370 (class 1259 OID 242700)
-- Name: unit; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.unit (
    unit_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    symbol text,
    quantity_type text NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT unit_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT unit_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT unit_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT unit_quantity_type_not_blank_chk CHECK ((btrim(quantity_type) <> ''::text))
);


ALTER TABLE weather.unit OWNER TO postgres;

--
-- TOC entry 369 (class 1259 OID 242699)
-- Name: unit_unit_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.unit ALTER COLUMN unit_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.unit_unit_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 380 (class 1259 OID 242827)
-- Name: variable; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.variable (
    variable_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    quantity_type text NOT NULL,
    canonical_unit_id bigint NOT NULL,
    statistic_id bigint,
    temporal_semantics_id bigint NOT NULL,
    accumulation_period_id bigint,
    vertical_level_id bigint,
    is_core boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT variable_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT variable_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT variable_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT variable_quantity_type_not_blank_chk CHECK ((btrim(quantity_type) <> ''::text))
);


ALTER TABLE weather.variable OWNER TO postgres;

--
-- TOC entry 379 (class 1259 OID 242826)
-- Name: variable_variable_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.variable ALTER COLUMN variable_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.variable_variable_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 458 (class 1259 OID 245106)
-- Name: verification_definition; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.verification_definition (
    verification_definition_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    description text,
    verification_type text NOT NULL,
    observation_product_id bigint NOT NULL,
    time_matching_method text NOT NULL,
    spatial_matching_method text NOT NULL,
    lead_band_minutes_start integer,
    lead_band_minutes_end integer,
    calculation_version text NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT verification_definition_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT verification_definition_lead_band_chk CHECK (((lead_band_minutes_start IS NULL) OR (lead_band_minutes_end IS NULL) OR (lead_band_minutes_end >= lead_band_minutes_start))),
    CONSTRAINT verification_definition_lead_end_chk CHECK (((lead_band_minutes_end IS NULL) OR (lead_band_minutes_end >= 0))),
    CONSTRAINT verification_definition_lead_start_chk CHECK (((lead_band_minutes_start IS NULL) OR (lead_band_minutes_start >= 0))),
    CONSTRAINT verification_definition_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT verification_definition_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT verification_definition_spatial_matching_not_blank_chk CHECK ((btrim(spatial_matching_method) <> ''::text)),
    CONSTRAINT verification_definition_time_matching_not_blank_chk CHECK ((btrim(time_matching_method) <> ''::text)),
    CONSTRAINT verification_definition_type_not_blank_chk CHECK ((btrim(verification_type) <> ''::text)),
    CONSTRAINT verification_definition_version_not_blank_chk CHECK ((btrim(calculation_version) <> ''::text))
);


ALTER TABLE weather.verification_definition OWNER TO postgres;

--
-- TOC entry 457 (class 1259 OID 245105)
-- Name: verification_definition_verification_definition_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.verification_definition ALTER COLUMN verification_definition_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.verification_definition_verification_definition_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 378 (class 1259 OID 242797)
-- Name: vertical_level; Type: TABLE; Schema: weather; Owner: postgres
--

CREATE TABLE weather.vertical_level (
    vertical_level_id bigint NOT NULL,
    code text NOT NULL,
    name text NOT NULL,
    level_type text NOT NULL,
    level_value double precision,
    level_value_2 double precision,
    unit_id bigint,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    metadata jsonb DEFAULT '{}'::jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT vertical_level_code_not_blank_chk CHECK ((btrim(code) <> ''::text)),
    CONSTRAINT vertical_level_metadata_object_chk CHECK ((jsonb_typeof(metadata) = 'object'::text)),
    CONSTRAINT vertical_level_name_not_blank_chk CHECK ((btrim(name) <> ''::text)),
    CONSTRAINT vertical_level_range_chk CHECK (((level_value_2 IS NULL) OR (level_value IS NULL) OR (level_value_2 > level_value))),
    CONSTRAINT vertical_level_type_not_blank_chk CHECK ((btrim(level_type) <> ''::text))
);


ALTER TABLE weather.vertical_level OWNER TO postgres;

--
-- TOC entry 377 (class 1259 OID 242796)
-- Name: vertical_level_vertical_level_id_seq; Type: SEQUENCE; Schema: weather; Owner: postgres
--

ALTER TABLE weather.vertical_level ALTER COLUMN vertical_level_id ADD GENERATED ALWAYS AS IDENTITY (
    SEQUENCE NAME weather.vertical_level_vertical_level_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1
);


--
-- TOC entry 7142 (class 0 OID 0)
-- Name: cell_forecast_default; Type: TABLE ATTACH; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast ATTACH PARTITION weather.cell_forecast_default DEFAULT;


--
-- TOC entry 7141 (class 0 OID 0)
-- Name: cell_observation_daily_default; Type: TABLE ATTACH; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily ATTACH PARTITION weather.cell_observation_daily_default DEFAULT;


--
-- TOC entry 7139 (class 0 OID 0)
-- Name: cell_observation_hourly_default; Type: TABLE ATTACH; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_hourly ATTACH PARTITION weather.cell_observation_hourly_default DEFAULT;


--
-- TOC entry 7143 (class 0 OID 0)
-- Name: ensemble_summary_default; Type: TABLE ATTACH; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.ensemble_summary ATTACH PARTITION weather.ensemble_summary_default DEFAULT;


--
-- TOC entry 7140 (class 0 OID 0)
-- Name: station_observation_daily_default; Type: TABLE ATTACH; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily ATTACH PARTITION weather.station_observation_daily_default DEFAULT;


--
-- TOC entry 7138 (class 0 OID 0)
-- Name: station_observation_hourly_default; Type: TABLE ATTACH; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_hourly ATTACH PARTITION weather.station_observation_hourly_default DEFAULT;


--
-- TOC entry 7182 (class 2604 OID 57737)
-- Name: flight_enrichment enrichment_id; Type: DEFAULT; Schema: aviation; Owner: postgres
--

ALTER TABLE ONLY aviation.flight_enrichment ALTER COLUMN enrichment_id SET DEFAULT nextval('aviation.flight_enrichment_enrichment_id_seq'::regclass);


--
-- TOC entry 7180 (class 2604 OID 57721)
-- Name: flight_history history_id; Type: DEFAULT; Schema: aviation; Owner: postgres
--

ALTER TABLE ONLY aviation.flight_history ALTER COLUMN history_id SET DEFAULT nextval('aviation.flight_history_history_id_seq'::regclass);


--
-- TOC entry 7184 (class 2604 OID 57751)
-- Name: flight_ingest_raw raw_id; Type: DEFAULT; Schema: aviation; Owner: postgres
--

ALTER TABLE ONLY aviation.flight_ingest_raw ALTER COLUMN raw_id SET DEFAULT nextval('aviation.flight_ingest_raw_raw_id_seq'::regclass);


--
-- TOC entry 7175 (class 2604 OID 57696)
-- Name: flight_live live_id; Type: DEFAULT; Schema: aviation; Owner: postgres
--

ALTER TABLE ONLY aviation.flight_live ALTER COLUMN live_id SET DEFAULT nextval('aviation.flight_live_live_id_seq'::regclass);


--
-- TOC entry 7202 (class 2604 OID 78040)
-- Name: ingestion_log id; Type: DEFAULT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.ingestion_log ALTER COLUMN id SET DEFAULT nextval('gas.ingestion_log_id_seq'::regclass);


--
-- TOC entry 7235 (class 2604 OID 94405)
-- Name: lng_monthly id; Type: DEFAULT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.lng_monthly ALTER COLUMN id SET DEFAULT nextval('gas.lng_monthly_id_seq'::regclass);


--
-- TOC entry 7204 (class 2604 OID 78051)
-- Name: market_signals id; Type: DEFAULT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.market_signals ALTER COLUMN id SET DEFAULT nextval('gas.market_signals_id_seq'::regclass);


--
-- TOC entry 7239 (class 2604 OID 94424)
-- Name: production_monthly id; Type: DEFAULT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.production_monthly ALTER COLUMN id SET DEFAULT nextval('gas.production_monthly_id_seq'::regclass);


--
-- TOC entry 7199 (class 2604 OID 78024)
-- Name: storage_weekly id; Type: DEFAULT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.storage_weekly ALTER COLUMN id SET DEFAULT nextval('gas.storage_weekly_id_seq'::regclass);


--
-- TOC entry 7171 (class 2604 OID 57516)
-- Name: locations id; Type: DEFAULT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.locations ALTER COLUMN id SET DEFAULT nextval('geo.locations_id_seq'::regclass);


--
-- TOC entry 7283 (class 2604 OID 226049)
-- Name: stage_tiger_2025_county gid; Type: DEFAULT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.stage_tiger_2025_county ALTER COLUMN gid SET DEFAULT nextval('geo.stage_tiger_2025_county_gid_seq'::regclass);


--
-- TOC entry 7287 (class 2604 OID 238885)
-- Name: stage_tiger_2025_county_utf8 gid; Type: DEFAULT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.stage_tiger_2025_county_utf8 ALTER COLUMN gid SET DEFAULT nextval('geo.stage_tiger_2025_county_utf8_gid_seq'::regclass);


--
-- TOC entry 7282 (class 2604 OID 225857)
-- Name: stage_tiger_2025_state gid; Type: DEFAULT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.stage_tiger_2025_state ALTER COLUMN gid SET DEFAULT nextval('geo.stage_tiger_2025_state_gid_seq'::regclass);


--
-- TOC entry 7169 (class 2604 OID 57499)
-- Name: locations id; Type: DEFAULT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.locations ALTER COLUMN id SET DEFAULT nextval('locations.locations_id_seq'::regclass);


--
-- TOC entry 7191 (class 2604 OID 69874)
-- Name: assets id; Type: DEFAULT; Schema: mining; Owner: postgres
--

ALTER TABLE ONLY mining.assets ALTER COLUMN id SET DEFAULT nextval('mining.mines_id_seq'::regclass);


--
-- TOC entry 7167 (class 2604 OID 57349)
-- Name: locations id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);


--
-- TOC entry 7165 (class 2604 OID 49156)
-- Name: signals id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.signals ALTER COLUMN id SET DEFAULT nextval('public.signals_id_seq'::regclass);


--
-- TOC entry 7166 (class 2604 OID 49171)
-- Name: weather_data id; Type: DEFAULT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_data ALTER COLUMN id SET DEFAULT nextval('public.weather_data_id_seq'::regclass);


--
-- TOC entry 8168 (class 2606 OID 57745)
-- Name: flight_enrichment flight_enrichment_pkey; Type: CONSTRAINT; Schema: aviation; Owner: postgres
--

ALTER TABLE ONLY aviation.flight_enrichment
    ADD CONSTRAINT flight_enrichment_pkey PRIMARY KEY (enrichment_id);


--
-- TOC entry 8162 (class 2606 OID 57728)
-- Name: flight_history flight_history_pkey; Type: CONSTRAINT; Schema: aviation; Owner: postgres
--

ALTER TABLE ONLY aviation.flight_history
    ADD CONSTRAINT flight_history_pkey PRIMARY KEY (history_id);


--
-- TOC entry 8171 (class 2606 OID 57761)
-- Name: flight_ingest_raw flight_ingest_raw_pkey; Type: CONSTRAINT; Schema: aviation; Owner: postgres
--

ALTER TABLE ONLY aviation.flight_ingest_raw
    ADD CONSTRAINT flight_ingest_raw_pkey PRIMARY KEY (raw_id);


--
-- TOC entry 8156 (class 2606 OID 57711)
-- Name: flight_live flight_live_pkey; Type: CONSTRAINT; Schema: aviation; Owner: postgres
--

ALTER TABLE ONLY aviation.flight_live
    ADD CONSTRAINT flight_live_pkey PRIMARY KEY (live_id);


--
-- TOC entry 8215 (class 2606 OID 86341)
-- Name: consumption_monthly consumption_monthly_pkey; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.consumption_monthly
    ADD CONSTRAINT consumption_monthly_pkey PRIMARY KEY (id);


--
-- TOC entry 8217 (class 2606 OID 86343)
-- Name: consumption_monthly consumption_monthly_region_report_month_key; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.consumption_monthly
    ADD CONSTRAINT consumption_monthly_region_report_month_key UNIQUE (region, report_month);


--
-- TOC entry 8195 (class 2606 OID 78046)
-- Name: ingestion_log ingestion_log_pkey; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.ingestion_log
    ADD CONSTRAINT ingestion_log_pkey PRIMARY KEY (id);


--
-- TOC entry 8204 (class 2606 OID 86269)
-- Name: lng_exports_daily lng_exports_daily_pkey; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.lng_exports_daily
    ADD CONSTRAINT lng_exports_daily_pkey PRIMARY KEY (id);


--
-- TOC entry 8206 (class 2606 OID 86271)
-- Name: lng_exports_daily lng_exports_daily_report_date_terminal_name_key; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.lng_exports_daily
    ADD CONSTRAINT lng_exports_daily_report_date_terminal_name_key UNIQUE (report_date, terminal_name);


--
-- TOC entry 8232 (class 2606 OID 94417)
-- Name: lng_monthly lng_monthly_pkey; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.lng_monthly
    ADD CONSTRAINT lng_monthly_pkey PRIMARY KEY (id);


--
-- TOC entry 8197 (class 2606 OID 78062)
-- Name: market_signals market_signals_pkey; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.market_signals
    ADD CONSTRAINT market_signals_pkey PRIMARY KEY (id);


--
-- TOC entry 8199 (class 2606 OID 78064)
-- Name: market_signals market_signals_signal_date_region_signal_type_source_system_key; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.market_signals
    ADD CONSTRAINT market_signals_signal_date_region_signal_type_source_system_key UNIQUE (signal_date, region, signal_type, source_system);


--
-- TOC entry 8211 (class 2606 OID 86287)
-- Name: pipeline_flows_daily pipeline_flows_daily_pkey; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.pipeline_flows_daily
    ADD CONSTRAINT pipeline_flows_daily_pkey PRIMARY KEY (id);


--
-- TOC entry 8213 (class 2606 OID 86289)
-- Name: pipeline_flows_daily pipeline_flows_daily_report_date_pipeline_name_origin_regio_key; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.pipeline_flows_daily
    ADD CONSTRAINT pipeline_flows_daily_report_date_pipeline_name_origin_regio_key UNIQUE (report_date, pipeline_name, origin_region, destination_region);


--
-- TOC entry 8228 (class 2606 OID 86391)
-- Name: prices_daily prices_daily_pkey; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.prices_daily
    ADD CONSTRAINT prices_daily_pkey PRIMARY KEY (id);


--
-- TOC entry 8236 (class 2606 OID 94436)
-- Name: production_monthly production_monthly_pkey; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.production_monthly
    ADD CONSTRAINT production_monthly_pkey PRIMARY KEY (id);


--
-- TOC entry 8240 (class 2606 OID 94449)
-- Name: states_consumption_monthly states_consumption_monthly_pkey; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.states_consumption_monthly
    ADD CONSTRAINT states_consumption_monthly_pkey PRIMARY KEY (month, state_code);


--
-- TOC entry 8191 (class 2606 OID 78033)
-- Name: storage_weekly storage_weekly_pkey; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.storage_weekly
    ADD CONSTRAINT storage_weekly_pkey PRIMARY KEY (id);


--
-- TOC entry 8193 (class 2606 OID 78035)
-- Name: storage_weekly storage_weekly_region_report_date_source_system_key; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.storage_weekly
    ADD CONSTRAINT storage_weekly_region_report_date_source_system_key UNIQUE (region, report_date, source_system);


--
-- TOC entry 8230 (class 2606 OID 86393)
-- Name: prices_daily uq_prices_daily_market_date; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.prices_daily
    ADD CONSTRAINT uq_prices_daily_market_date UNIQUE (market, price_date);


--
-- TOC entry 8234 (class 2606 OID 94419)
-- Name: lng_monthly ux_lng_monthly_month_region; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.lng_monthly
    ADD CONSTRAINT ux_lng_monthly_month_region UNIQUE (month, region);


--
-- TOC entry 8238 (class 2606 OID 94438)
-- Name: production_monthly ux_production_monthly_month_region; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.production_monthly
    ADD CONSTRAINT ux_production_monthly_month_region UNIQUE (month, region);


--
-- TOC entry 8222 (class 2606 OID 86366)
-- Name: weather_demand_regions weather_demand_regions_pkey; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.weather_demand_regions
    ADD CONSTRAINT weather_demand_regions_pkey PRIMARY KEY (id);


--
-- TOC entry 8224 (class 2606 OID 86368)
-- Name: weather_demand_regions weather_demand_regions_region_code_key; Type: CONSTRAINT; Schema: gas; Owner: postgres
--

ALTER TABLE ONLY gas.weather_demand_regions
    ADD CONSTRAINT weather_demand_regions_region_code_key UNIQUE (region_code);


--
-- TOC entry 8151 (class 2606 OID 57568)
-- Name: airports airports_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.airports
    ADD CONSTRAINT airports_pkey PRIMARY KEY (location_id);


--
-- TOC entry 8313 (class 2606 OID 225813)
-- Name: location_cell_map location_cell_map_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.location_cell_map
    ADD CONSTRAINT location_cell_map_pkey PRIMARY KEY (location_cell_map_id);


--
-- TOC entry 8315 (class 2606 OID 225815)
-- Name: location_cell_map location_cell_map_unique; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.location_cell_map
    ADD CONSTRAINT location_cell_map_unique UNIQUE (location_id, grid_cell_id);


--
-- TOC entry 8251 (class 2606 OID 225538)
-- Name: location_identifier location_identifier_external_key_unique; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.location_identifier
    ADD CONSTRAINT location_identifier_external_key_unique UNIQUE NULLS NOT DISTINCT (identifier_scheme, identifier_value, source_system);


--
-- TOC entry 8254 (class 2606 OID 225536)
-- Name: location_identifier location_identifier_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.location_identifier
    ADD CONSTRAINT location_identifier_pkey PRIMARY KEY (location_identifier_id);


--
-- TOC entry 8247 (class 2606 OID 225508)
-- Name: location location_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.location
    ADD CONSTRAINT location_pkey PRIMARY KEY (location_id);


--
-- TOC entry 8149 (class 2606 OID 57529)
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- TOC entry 8179 (class 2606 OID 61957)
-- Name: ports ports_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.ports
    ADD CONSTRAINT ports_pkey PRIMARY KEY (id);


--
-- TOC entry 8181 (class 2606 OID 61959)
-- Name: ports ports_source_id_unique; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.ports
    ADD CONSTRAINT ports_source_id_unique UNIQUE (source, source_id);


--
-- TOC entry 8318 (class 2606 OID 225838)
-- Name: region_cell_map region_cell_map_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_cell_map
    ADD CONSTRAINT region_cell_map_pkey PRIMARY KEY (region_cell_map_id);


--
-- TOC entry 8321 (class 2606 OID 225840)
-- Name: region_cell_map region_cell_map_unique; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_cell_map
    ADD CONSTRAINT region_cell_map_unique UNIQUE (region_version_id, grid_cell_id);


--
-- TOC entry 8284 (class 2606 OID 225688)
-- Name: region_identifier region_identifier_external_key_unique; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_identifier
    ADD CONSTRAINT region_identifier_external_key_unique UNIQUE NULLS NOT DISTINCT (identifier_scheme, identifier_value, source_system);


--
-- TOC entry 8286 (class 2606 OID 225686)
-- Name: region_identifier region_identifier_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_identifier
    ADD CONSTRAINT region_identifier_pkey PRIMARY KEY (region_identifier_id);


--
-- TOC entry 8281 (class 2606 OID 225653)
-- Name: region region_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region
    ADD CONSTRAINT region_pkey PRIMARY KEY (region_id);


--
-- TOC entry 8332 (class 2606 OID 229272)
-- Name: region_relationship region_relationship_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_relationship
    ADD CONSTRAINT region_relationship_pkey PRIMARY KEY (region_relationship_id);


--
-- TOC entry 8335 (class 2606 OID 229274)
-- Name: region_relationship region_relationship_unique; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_relationship
    ADD CONSTRAINT region_relationship_unique UNIQUE NULLS NOT DISTINCT (parent_region_id, child_region_id, relationship_type, spatial_dataset_version_id);


--
-- TOC entry 8273 (class 2606 OID 225629)
-- Name: region_type region_type_code_unique; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_type
    ADD CONSTRAINT region_type_code_unique UNIQUE (code);


--
-- TOC entry 8275 (class 2606 OID 225627)
-- Name: region_type region_type_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_type
    ADD CONSTRAINT region_type_pkey PRIMARY KEY (region_type_id);


--
-- TOC entry 8295 (class 2606 OID 225720)
-- Name: region_version region_version_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_version
    ADD CONSTRAINT region_version_pkey PRIMARY KEY (region_version_id);


--
-- TOC entry 8260 (class 2606 OID 225570)
-- Name: spatial_dataset spatial_dataset_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.spatial_dataset
    ADD CONSTRAINT spatial_dataset_pkey PRIMARY KEY (spatial_dataset_id);


--
-- TOC entry 8263 (class 2606 OID 225572)
-- Name: spatial_dataset spatial_dataset_provider_name_unique; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.spatial_dataset
    ADD CONSTRAINT spatial_dataset_provider_name_unique UNIQUE (provider_name, dataset_name);


--
-- TOC entry 8267 (class 2606 OID 225595)
-- Name: spatial_dataset_version spatial_dataset_version_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.spatial_dataset_version
    ADD CONSTRAINT spatial_dataset_version_pkey PRIMARY KEY (spatial_dataset_version_id);


--
-- TOC entry 8270 (class 2606 OID 225597)
-- Name: spatial_dataset_version spatial_dataset_version_unique; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.spatial_dataset_version
    ADD CONSTRAINT spatial_dataset_version_unique UNIQUE (spatial_dataset_id, version_name);


--
-- TOC entry 8340 (class 2606 OID 242094)
-- Name: stage_country_name_iso2 stage_country_name_iso2_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.stage_country_name_iso2
    ADD CONSTRAINT stage_country_name_iso2_pkey PRIMARY KEY (source_country_name);


--
-- TOC entry 8327 (class 2606 OID 226052)
-- Name: stage_tiger_2025_county stage_tiger_2025_county_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.stage_tiger_2025_county
    ADD CONSTRAINT stage_tiger_2025_county_pkey PRIMARY KEY (gid);


--
-- TOC entry 8338 (class 2606 OID 238888)
-- Name: stage_tiger_2025_county_utf8 stage_tiger_2025_county_utf8_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.stage_tiger_2025_county_utf8
    ADD CONSTRAINT stage_tiger_2025_county_utf8_pkey PRIMARY KEY (gid);


--
-- TOC entry 8324 (class 2606 OID 225860)
-- Name: stage_tiger_2025_state stage_tiger_2025_state_pkey; Type: CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.stage_tiger_2025_state
    ADD CONSTRAINT stage_tiger_2025_state_pkey PRIMARY KEY (gid);


--
-- TOC entry 8146 (class 2606 OID 57508)
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: locations; Owner: postgres
--

ALTER TABLE ONLY locations.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- TOC entry 8189 (class 2606 OID 69889)
-- Name: assets mines_pkey; Type: CONSTRAINT; Schema: mining; Owner: postgres
--

ALTER TABLE ONLY mining.assets
    ADD CONSTRAINT mines_pkey PRIMARY KEY (id);


--
-- TOC entry 8142 (class 2606 OID 57358)
-- Name: locations locations_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);


--
-- TOC entry 8135 (class 2606 OID 49161)
-- Name: signals signals_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.signals
    ADD CONSTRAINT signals_pkey PRIMARY KEY (id);


--
-- TOC entry 8122 (class 2606 OID 32849)
-- Name: strategic_point_grid_map strategic_point_grid_map_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.strategic_point_grid_map
    ADD CONSTRAINT strategic_point_grid_map_pkey PRIMARY KEY (strategic_point_id, grid_point_id);


--
-- TOC entry 8115 (class 2606 OID 32787)
-- Name: strategic_point strategic_point_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.strategic_point
    ADD CONSTRAINT strategic_point_pkey PRIMARY KEY (id);


--
-- TOC entry 8107 (class 2606 OID 24915)
-- Name: weather_climatology_daily weather_climatology_daily_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_climatology_daily
    ADD CONSTRAINT weather_climatology_daily_pkey PRIMARY KEY (location_id, day_of_year);


--
-- TOC entry 8140 (class 2606 OID 49177)
-- Name: weather_data weather_data_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_data
    ADD CONSTRAINT weather_data_pkey PRIMARY KEY (id);


--
-- TOC entry 8100 (class 2606 OID 24873)
-- Name: weather_forecast_run weather_forecast_run_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_forecast_run
    ADD CONSTRAINT weather_forecast_run_pkey PRIMARY KEY (id);


--
-- TOC entry 8105 (class 2606 OID 24890)
-- Name: weather_forecast_value weather_forecast_value_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_forecast_value
    ADD CONSTRAINT weather_forecast_value_pkey PRIMARY KEY (forecast_run_id, location_id, valid_time);


--
-- TOC entry 8111 (class 2606 OID 24955)
-- Name: weather_gas_signal weather_gas_signal_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_gas_signal
    ADD CONSTRAINT weather_gas_signal_pkey PRIMARY KEY (location_id, signal_time);


--
-- TOC entry 8118 (class 2606 OID 32839)
-- Name: weather_grid_point weather_grid_point_grid_code_key; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_grid_point
    ADD CONSTRAINT weather_grid_point_grid_code_key UNIQUE (grid_code);


--
-- TOC entry 8120 (class 2606 OID 32837)
-- Name: weather_grid_point weather_grid_point_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_grid_point
    ADD CONSTRAINT weather_grid_point_pkey PRIMARY KEY (id);


--
-- TOC entry 8109 (class 2606 OID 24937)
-- Name: weather_ingestion_run weather_ingestion_run_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_ingestion_run
    ADD CONSTRAINT weather_ingestion_run_pkey PRIMARY KEY (id);


--
-- TOC entry 8096 (class 2606 OID 24836)
-- Name: weather_location weather_location_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_location
    ADD CONSTRAINT weather_location_pkey PRIMARY KEY (id);


--
-- TOC entry 8126 (class 2606 OID 40975)
-- Name: weather_observation weather_observation_pkey; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_observation
    ADD CONSTRAINT weather_observation_pkey PRIMARY KEY (id);


--
-- TOC entry 8128 (class 2606 OID 40977)
-- Name: weather_observation weather_observation_unique; Type: CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_observation
    ADD CONSTRAINT weather_observation_unique UNIQUE (grid_point_id, observation_time, data_type, source_system);


--
-- TOC entry 8460 (class 2606 OID 242795)
-- Name: accumulation_period accumulation_period_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.accumulation_period
    ADD CONSTRAINT accumulation_period_code_unique UNIQUE (code);


--
-- TOC entry 8462 (class 2606 OID 242793)
-- Name: accumulation_period accumulation_period_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.accumulation_period
    ADD CONSTRAINT accumulation_period_pkey PRIMARY KEY (accumulation_period_id);


--
-- TOC entry 8837 (class 2606 OID 245433)
-- Name: bias_correction_definition bias_correction_definition_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.bias_correction_definition
    ADD CONSTRAINT bias_correction_definition_code_unique UNIQUE (code);


--
-- TOC entry 8841 (class 2606 OID 245431)
-- Name: bias_correction_definition bias_correction_definition_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.bias_correction_definition
    ADD CONSTRAINT bias_correction_definition_pkey PRIMARY KEY (bias_correction_definition_id);


--
-- TOC entry 8846 (class 2606 OID 245472)
-- Name: bias_correction_input_product bias_correction_input_product_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.bias_correction_input_product
    ADD CONSTRAINT bias_correction_input_product_pkey PRIMARY KEY (bias_correction_input_product_id);


--
-- TOC entry 8848 (class 2606 OID 245474)
-- Name: bias_correction_input_product bias_correction_input_product_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.bias_correction_input_product
    ADD CONSTRAINT bias_correction_input_product_unique UNIQUE (bias_correction_definition_id, forecast_product_id, role);


--
-- TOC entry 8779 (class 2606 OID 244966)
-- Name: cell_forecast_correction cell_forecast_correction_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_correction
    ADD CONSTRAINT cell_forecast_correction_pkey PRIMARY KEY (cell_forecast_correction_id);


--
-- TOC entry 8783 (class 2606 OID 244968)
-- Name: cell_forecast_correction cell_forecast_correction_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_correction
    ADD CONSTRAINT cell_forecast_correction_unique UNIQUE (original_cell_forecast_id, original_valid_time, replacement_cell_forecast_id, replacement_valid_time);


--
-- TOC entry 8723 (class 2606 OID 244571)
-- Name: cell_forecast cell_forecast_natural_revision_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast
    ADD CONSTRAINT cell_forecast_natural_revision_unique UNIQUE (forecast_run_id, forecast_member_id, forecast_product_id, grid_cell_id, valid_time, revision_no);


--
-- TOC entry 8734 (class 2606 OID 244656)
-- Name: cell_forecast_default cell_forecast_default_forecast_run_id_forecast_member_id_fo_key; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_default
    ADD CONSTRAINT cell_forecast_default_forecast_run_id_forecast_member_id_fo_key UNIQUE (forecast_run_id, forecast_member_id, forecast_product_id, grid_cell_id, valid_time, revision_no);


--
-- TOC entry 8725 (class 2606 OID 244569)
-- Name: cell_forecast cell_forecast_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast
    ADD CONSTRAINT cell_forecast_pkey PRIMARY KEY (cell_forecast_id, valid_time);


--
-- TOC entry 8740 (class 2606 OID 244654)
-- Name: cell_forecast_default cell_forecast_default_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_default
    ADD CONSTRAINT cell_forecast_default_pkey PRIMARY KEY (cell_forecast_id, valid_time);


--
-- TOC entry 8793 (class 2606 OID 245066)
-- Name: cell_forecast_revision cell_forecast_revision_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_revision
    ADD CONSTRAINT cell_forecast_revision_pkey PRIMARY KEY (cell_forecast_revision_id);


--
-- TOC entry 8795 (class 2606 OID 245068)
-- Name: cell_forecast_revision cell_forecast_revision_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_revision
    ADD CONSTRAINT cell_forecast_revision_unique UNIQUE (forecast_revision_definition_id, comparison_cell_forecast_id, comparison_valid_time, newer_cell_forecast_id, newer_valid_time, variable_id);


--
-- TOC entry 8746 (class 2606 OID 244736)
-- Name: cell_forecast_value cell_forecast_value_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_value
    ADD CONSTRAINT cell_forecast_value_pkey PRIMARY KEY (cell_forecast_value_id);


--
-- TOC entry 8748 (class 2606 OID 244738)
-- Name: cell_forecast_value cell_forecast_value_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_value
    ADD CONSTRAINT cell_forecast_value_unique UNIQUE (cell_forecast_id, valid_time, variable_id);


--
-- TOC entry 8653 (class 2606 OID 244125)
-- Name: cell_observation_correction cell_observation_correction_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_correction
    ADD CONSTRAINT cell_observation_correction_pkey PRIMARY KEY (cell_observation_correction_id);


--
-- TOC entry 8656 (class 2606 OID 244127)
-- Name: cell_observation_correction cell_observation_correction_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_correction
    ADD CONSTRAINT cell_observation_correction_unique UNIQUE (original_observation_id, original_observation_time, replacement_observation_id, replacement_observation_time);


--
-- TOC entry 8665 (class 2606 OID 244245)
-- Name: cell_observation_daily_correction cell_observation_daily_correction_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily_correction
    ADD CONSTRAINT cell_observation_daily_correction_pkey PRIMARY KEY (cell_observation_daily_correction_id);


--
-- TOC entry 8668 (class 2606 OID 244247)
-- Name: cell_observation_daily_correction cell_observation_daily_correction_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily_correction
    ADD CONSTRAINT cell_observation_daily_correction_unique UNIQUE (original_observation_daily_id, original_observation_date, replacement_observation_daily_id, replacement_observation_date);


--
-- TOC entry 8580 (class 2606 OID 243603)
-- Name: cell_observation_daily cell_observation_daily_natural_revision_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily
    ADD CONSTRAINT cell_observation_daily_natural_revision_unique UNIQUE (grid_cell_id, observation_product_id, observation_date, revision_no);


--
-- TOC entry 8588 (class 2606 OID 243670)
-- Name: cell_observation_daily_default cell_observation_daily_defaul_grid_cell_id_observation_prod_key; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily_default
    ADD CONSTRAINT cell_observation_daily_defaul_grid_cell_id_observation_prod_key UNIQUE (grid_cell_id, observation_product_id, observation_date, revision_no);


--
-- TOC entry 8582 (class 2606 OID 243601)
-- Name: cell_observation_daily cell_observation_daily_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily
    ADD CONSTRAINT cell_observation_daily_pkey PRIMARY KEY (cell_observation_daily_id, observation_date);


--
-- TOC entry 8594 (class 2606 OID 243668)
-- Name: cell_observation_daily_default cell_observation_daily_default_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily_default
    ADD CONSTRAINT cell_observation_daily_default_pkey PRIMARY KEY (cell_observation_daily_id, observation_date);


--
-- TOC entry 8607 (class 2606 OID 243788)
-- Name: cell_observation_daily_quality_exception cell_observation_daily_quality_exception_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily_quality_exception
    ADD CONSTRAINT cell_observation_daily_quality_exception_pkey PRIMARY KEY (cell_observation_daily_quality_exception_id);


--
-- TOC entry 8609 (class 2606 OID 243790)
-- Name: cell_observation_daily_quality_exception cell_observation_daily_quality_exception_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily_quality_exception
    ADD CONSTRAINT cell_observation_daily_quality_exception_unique UNIQUE (cell_observation_daily_id, observation_date, variable_id, quality_flag_id);


--
-- TOC entry 8526 (class 2606 OID 243210)
-- Name: cell_observation_hourly cell_observation_hourly_natural_revision_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_hourly
    ADD CONSTRAINT cell_observation_hourly_natural_revision_unique UNIQUE (grid_cell_id, observation_product_id, observation_time, revision_no);


--
-- TOC entry 8534 (class 2606 OID 243271)
-- Name: cell_observation_hourly_default cell_observation_hourly_defau_grid_cell_id_observation_prod_key; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_hourly_default
    ADD CONSTRAINT cell_observation_hourly_defau_grid_cell_id_observation_prod_key UNIQUE (grid_cell_id, observation_product_id, observation_time, revision_no);


--
-- TOC entry 8528 (class 2606 OID 243208)
-- Name: cell_observation_hourly cell_observation_hourly_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_hourly
    ADD CONSTRAINT cell_observation_hourly_pkey PRIMARY KEY (cell_observation_id, observation_time);


--
-- TOC entry 8542 (class 2606 OID 243269)
-- Name: cell_observation_hourly_default cell_observation_hourly_default_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_hourly_default
    ADD CONSTRAINT cell_observation_hourly_default_pkey PRIMARY KEY (cell_observation_id, observation_time);


--
-- TOC entry 8547 (class 2606 OID 243336)
-- Name: cell_observation_quality_exception cell_observation_quality_exception_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_quality_exception
    ADD CONSTRAINT cell_observation_quality_exception_pkey PRIMARY KEY (cell_observation_quality_exception_id);


--
-- TOC entry 8549 (class 2606 OID 243338)
-- Name: cell_observation_quality_exception cell_observation_quality_exception_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_quality_exception
    ADD CONSTRAINT cell_observation_quality_exception_unique UNIQUE (cell_observation_id, observation_time, variable_id, quality_flag_id);


--
-- TOC entry 8623 (class 2606 OID 243890)
-- Name: cell_observation_value cell_observation_value_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_value
    ADD CONSTRAINT cell_observation_value_pkey PRIMARY KEY (cell_observation_value_id);


--
-- TOC entry 8625 (class 2606 OID 243892)
-- Name: cell_observation_value cell_observation_value_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_value
    ADD CONSTRAINT cell_observation_value_unique UNIQUE (cell_observation_id, observation_time, variable_id);


--
-- TOC entry 8630 (class 2606 OID 243955)
-- Name: condition_code condition_code_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.condition_code
    ADD CONSTRAINT condition_code_code_unique UNIQUE (code);


--
-- TOC entry 8632 (class 2606 OID 243953)
-- Name: condition_code condition_code_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.condition_code
    ADD CONSTRAINT condition_code_pkey PRIMARY KEY (condition_code_id);


--
-- TOC entry 8824 (class 2606 OID 245348)
-- Name: consensus_definition consensus_definition_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.consensus_definition
    ADD CONSTRAINT consensus_definition_code_unique UNIQUE (code);


--
-- TOC entry 8831 (class 2606 OID 245376)
-- Name: consensus_definition_member consensus_definition_member_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.consensus_definition_member
    ADD CONSTRAINT consensus_definition_member_pkey PRIMARY KEY (consensus_definition_member_id);


--
-- TOC entry 8834 (class 2606 OID 245378)
-- Name: consensus_definition_member consensus_definition_member_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.consensus_definition_member
    ADD CONSTRAINT consensus_definition_member_unique UNIQUE (consensus_definition_id, forecast_product_id, lead_minutes_start, lead_minutes_end);


--
-- TOC entry 8827 (class 2606 OID 245346)
-- Name: consensus_definition consensus_definition_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.consensus_definition
    ADD CONSTRAINT consensus_definition_pkey PRIMARY KEY (consensus_definition_id);


--
-- TOC entry 8552 (class 2606 OID 243389)
-- Name: daily_period_definition daily_period_definition_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.daily_period_definition
    ADD CONSTRAINT daily_period_definition_code_unique UNIQUE (code);


--
-- TOC entry 8554 (class 2606 OID 243387)
-- Name: daily_period_definition daily_period_definition_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.daily_period_definition
    ADD CONSTRAINT daily_period_definition_pkey PRIMARY KEY (daily_period_definition_id);


--
-- TOC entry 8637 (class 2606 OID 243982)
-- Name: dataset_condition_mapping dataset_condition_mapping_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.dataset_condition_mapping
    ADD CONSTRAINT dataset_condition_mapping_pkey PRIMARY KEY (dataset_condition_mapping_id);


--
-- TOC entry 8640 (class 2606 OID 243984)
-- Name: dataset_condition_mapping dataset_condition_mapping_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.dataset_condition_mapping
    ADD CONSTRAINT dataset_condition_mapping_unique UNIQUE (dataset_version_id, provider_condition_code, condition_code_id);


--
-- TOC entry 8349 (class 2606 OID 242186)
-- Name: dataset dataset_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.dataset
    ADD CONSTRAINT dataset_pkey PRIMARY KEY (dataset_id);


--
-- TOC entry 8351 (class 2606 OID 242188)
-- Name: dataset dataset_provider_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.dataset
    ADD CONSTRAINT dataset_provider_code_unique UNIQUE (provider_id, code);


--
-- TOC entry 8478 (class 2606 OID 242913)
-- Name: dataset_variable_mapping dataset_variable_mapping_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.dataset_variable_mapping
    ADD CONSTRAINT dataset_variable_mapping_pkey PRIMARY KEY (dataset_variable_mapping_id);


--
-- TOC entry 8481 (class 2606 OID 242915)
-- Name: dataset_variable_mapping dataset_variable_mapping_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.dataset_variable_mapping
    ADD CONSTRAINT dataset_variable_mapping_unique UNIQUE (dataset_version_id, provider_field_name, variable_id);


--
-- TOC entry 8357 (class 2606 OID 242217)
-- Name: dataset_version dataset_version_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.dataset_version
    ADD CONSTRAINT dataset_version_pkey PRIMARY KEY (dataset_version_id);


--
-- TOC entry 8359 (class 2606 OID 242219)
-- Name: dataset_version dataset_version_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.dataset_version
    ADD CONSTRAINT dataset_version_unique UNIQUE (dataset_id, version_name);


--
-- TOC entry 8373 (class 2606 OID 242321)
-- Name: derivation derivation_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.derivation
    ADD CONSTRAINT derivation_code_unique UNIQUE (code);


--
-- TOC entry 8375 (class 2606 OID 242319)
-- Name: derivation derivation_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.derivation
    ADD CONSTRAINT derivation_pkey PRIMARY KEY (derivation_id);


--
-- TOC entry 8392 (class 2606 OID 242413)
-- Name: derivation_run_input derivation_run_input_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.derivation_run_input
    ADD CONSTRAINT derivation_run_input_pkey PRIMARY KEY (derivation_run_input_id);


--
-- TOC entry 8394 (class 2606 OID 242415)
-- Name: derivation_run_input derivation_run_input_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.derivation_run_input
    ADD CONSTRAINT derivation_run_input_unique UNIQUE (derivation_run_id, ingestion_run_id, input_role);


--
-- TOC entry 8385 (class 2606 OID 242379)
-- Name: derivation_run derivation_run_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.derivation_run
    ADD CONSTRAINT derivation_run_pkey PRIMARY KEY (derivation_run_id);


--
-- TOC entry 8380 (class 2606 OID 242347)
-- Name: derivation_version derivation_version_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.derivation_version
    ADD CONSTRAINT derivation_version_pkey PRIMARY KEY (derivation_version_id);


--
-- TOC entry 8382 (class 2606 OID 242349)
-- Name: derivation_version derivation_version_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.derivation_version
    ADD CONSTRAINT derivation_version_unique UNIQUE (derivation_id, version_name);


--
-- TOC entry 8767 (class 2606 OID 244905)
-- Name: ensemble_probability ensemble_probability_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.ensemble_probability
    ADD CONSTRAINT ensemble_probability_pkey PRIMARY KEY (ensemble_probability_id);


--
-- TOC entry 8771 (class 2606 OID 244907)
-- Name: ensemble_probability ensemble_probability_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.ensemble_probability
    ADD CONSTRAINT ensemble_probability_unique UNIQUE (ensemble_summary_id, valid_time, threshold_operator, threshold_value);


--
-- TOC entry 8756 (class 2606 OID 244802)
-- Name: ensemble_summary ensemble_summary_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.ensemble_summary
    ADD CONSTRAINT ensemble_summary_unique UNIQUE (forecast_run_id, forecast_product_id, grid_cell_id, variable_id, valid_time);


--
-- TOC entry 8760 (class 2606 OID 244852)
-- Name: ensemble_summary_default ensemble_summary_default_forecast_run_id_forecast_product_i_key; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.ensemble_summary_default
    ADD CONSTRAINT ensemble_summary_default_forecast_run_id_forecast_product_i_key UNIQUE (forecast_run_id, forecast_product_id, grid_cell_id, variable_id, valid_time);


--
-- TOC entry 8752 (class 2606 OID 244800)
-- Name: ensemble_summary ensemble_summary_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.ensemble_summary
    ADD CONSTRAINT ensemble_summary_pkey PRIMARY KEY (ensemble_summary_id, valid_time);


--
-- TOC entry 8764 (class 2606 OID 244850)
-- Name: ensemble_summary_default ensemble_summary_default_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.ensemble_summary_default
    ADD CONSTRAINT ensemble_summary_default_pkey PRIMARY KEY (ensemble_summary_id, valid_time);


--
-- TOC entry 8773 (class 2606 OID 244942)
-- Name: forecast_correction_reason forecast_correction_reason_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_correction_reason
    ADD CONSTRAINT forecast_correction_reason_code_unique UNIQUE (code);


--
-- TOC entry 8775 (class 2606 OID 244940)
-- Name: forecast_correction_reason forecast_correction_reason_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_correction_reason
    ADD CONSTRAINT forecast_correction_reason_pkey PRIMARY KEY (forecast_correction_reason_id);


--
-- TOC entry 8709 (class 2606 OID 244613)
-- Name: forecast_member forecast_member_id_run_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_member
    ADD CONSTRAINT forecast_member_id_run_unique UNIQUE (forecast_member_id, forecast_run_id);


--
-- TOC entry 8713 (class 2606 OID 244520)
-- Name: forecast_member forecast_member_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_member
    ADD CONSTRAINT forecast_member_pkey PRIMARY KEY (forecast_member_id);


--
-- TOC entry 8670 (class 2606 OID 244312)
-- Name: forecast_model forecast_model_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_model
    ADD CONSTRAINT forecast_model_pkey PRIMARY KEY (forecast_model_id);


--
-- TOC entry 8672 (class 2606 OID 244314)
-- Name: forecast_model forecast_model_provider_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_model
    ADD CONSTRAINT forecast_model_provider_code_unique UNIQUE (provider_id, code);


--
-- TOC entry 8679 (class 2606 OID 244344)
-- Name: forecast_model_version forecast_model_version_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_model_version
    ADD CONSTRAINT forecast_model_version_pkey PRIMARY KEY (forecast_model_version_id);


--
-- TOC entry 8681 (class 2606 OID 244346)
-- Name: forecast_model_version forecast_model_version_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_model_version
    ADD CONSTRAINT forecast_model_version_unique UNIQUE (forecast_model_id, version_code);


--
-- TOC entry 8685 (class 2606 OID 244387)
-- Name: forecast_product forecast_product_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_product
    ADD CONSTRAINT forecast_product_code_unique UNIQUE (code);


--
-- TOC entry 8690 (class 2606 OID 244385)
-- Name: forecast_product forecast_product_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_product
    ADD CONSTRAINT forecast_product_pkey PRIMARY KEY (forecast_product_id);


--
-- TOC entry 8785 (class 2606 OID 245037)
-- Name: forecast_revision_definition forecast_revision_definition_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_revision_definition
    ADD CONSTRAINT forecast_revision_definition_code_unique UNIQUE (code);


--
-- TOC entry 8787 (class 2606 OID 245035)
-- Name: forecast_revision_definition forecast_revision_definition_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_revision_definition
    ADD CONSTRAINT forecast_revision_definition_pkey PRIMARY KEY (forecast_revision_definition_id);


--
-- TOC entry 8851 (class 2606 OID 245513)
-- Name: forecast_run_expectation forecast_run_expectation_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run_expectation
    ADD CONSTRAINT forecast_run_expectation_code_unique UNIQUE (code);


--
-- TOC entry 8859 (class 2606 OID 245553)
-- Name: forecast_run_expectation_item forecast_run_expectation_item_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run_expectation_item
    ADD CONSTRAINT forecast_run_expectation_item_pkey PRIMARY KEY (forecast_run_expectation_item_id);


--
-- TOC entry 8854 (class 2606 OID 245511)
-- Name: forecast_run_expectation forecast_run_expectation_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run_expectation
    ADD CONSTRAINT forecast_run_expectation_pkey PRIMARY KEY (forecast_run_expectation_id);


--
-- TOC entry 8693 (class 2606 OID 245577)
-- Name: forecast_run forecast_run_id_product_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run
    ADD CONSTRAINT forecast_run_id_product_unique UNIQUE (forecast_run_id, forecast_product_id);


--
-- TOC entry 8695 (class 2606 OID 245575)
-- Name: forecast_run forecast_run_identity_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run
    ADD CONSTRAINT forecast_run_identity_unique UNIQUE NULLS NOT DISTINCT (forecast_product_id, forecast_model_version_id, initialization_time, provider_revision);


--
-- TOC entry 8704 (class 2606 OID 244477)
-- Name: forecast_run_ingestion forecast_run_ingestion_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run_ingestion
    ADD CONSTRAINT forecast_run_ingestion_pkey PRIMARY KEY (forecast_run_ingestion_id);


--
-- TOC entry 8707 (class 2606 OID 244479)
-- Name: forecast_run_ingestion forecast_run_ingestion_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run_ingestion
    ADD CONSTRAINT forecast_run_ingestion_unique UNIQUE (forecast_run_id, ingestion_run_id, input_role);


--
-- TOC entry 8699 (class 2606 OID 244440)
-- Name: forecast_run forecast_run_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run
    ADD CONSTRAINT forecast_run_pkey PRIMARY KEY (forecast_run_id);


--
-- TOC entry 8808 (class 2606 OID 245183)
-- Name: forecast_verification forecast_verification_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification
    ADD CONSTRAINT forecast_verification_pkey PRIMARY KEY (forecast_verification_id);


--
-- TOC entry 8820 (class 2606 OID 245279)
-- Name: forecast_verification_summary forecast_verification_summary_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification_summary
    ADD CONSTRAINT forecast_verification_summary_pkey PRIMARY KEY (forecast_verification_summary_id);


--
-- TOC entry 8811 (class 2606 OID 245185)
-- Name: forecast_verification forecast_verification_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification
    ADD CONSTRAINT forecast_verification_unique UNIQUE (verification_definition_id, cell_forecast_id, forecast_valid_time, cell_observation_id, observation_time, variable_id);


--
-- TOC entry 8306 (class 2606 OID 225792)
-- Name: grid_cell grid_cell_h3_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.grid_cell
    ADD CONSTRAINT grid_cell_h3_unique UNIQUE (grid_system_id, h3_index);


--
-- TOC entry 8308 (class 2606 OID 225790)
-- Name: grid_cell grid_cell_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.grid_cell
    ADD CONSTRAINT grid_cell_pkey PRIMARY KEY (grid_cell_id);


--
-- TOC entry 8299 (class 2606 OID 225761)
-- Name: grid_system grid_system_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.grid_system
    ADD CONSTRAINT grid_system_code_unique UNIQUE (code);


--
-- TOC entry 8301 (class 2606 OID 225759)
-- Name: grid_system grid_system_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.grid_system
    ADD CONSTRAINT grid_system_pkey PRIMARY KEY (grid_system_id);


--
-- TOC entry 8367 (class 2606 OID 242281)
-- Name: ingestion_run ingestion_run_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.ingestion_run
    ADD CONSTRAINT ingestion_run_pkey PRIMARY KEY (ingestion_run_id);


--
-- TOC entry 8642 (class 2606 OID 244043)
-- Name: observation_correction_reason observation_correction_reason_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.observation_correction_reason
    ADD CONSTRAINT observation_correction_reason_code_unique UNIQUE (code);


--
-- TOC entry 8644 (class 2606 OID 244041)
-- Name: observation_correction_reason observation_correction_reason_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.observation_correction_reason
    ADD CONSTRAINT observation_correction_reason_pkey PRIMARY KEY (observation_correction_reason_id);


--
-- TOC entry 8426 (class 2606 OID 242616)
-- Name: observation_product observation_product_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.observation_product
    ADD CONSTRAINT observation_product_code_unique UNIQUE (code);


--
-- TOC entry 8431 (class 2606 OID 242614)
-- Name: observation_product observation_product_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.observation_product
    ADD CONSTRAINT observation_product_pkey PRIMARY KEY (observation_product_id);


--
-- TOC entry 8484 (class 2606 OID 242953)
-- Name: observation_record_status observation_record_status_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.observation_record_status
    ADD CONSTRAINT observation_record_status_code_unique UNIQUE (code);


--
-- TOC entry 8486 (class 2606 OID 242951)
-- Name: observation_record_status observation_record_status_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.observation_record_status
    ADD CONSTRAINT observation_record_status_pkey PRIMARY KEY (observation_record_status_id);


--
-- TOC entry 8343 (class 2606 OID 242159)
-- Name: provider provider_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.provider
    ADD CONSTRAINT provider_code_unique UNIQUE (code);


--
-- TOC entry 8346 (class 2606 OID 242157)
-- Name: provider provider_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.provider
    ADD CONSTRAINT provider_pkey PRIMARY KEY (provider_id);


--
-- TOC entry 8510 (class 2606 OID 243122)
-- Name: quality_flag quality_flag_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.quality_flag
    ADD CONSTRAINT quality_flag_code_unique UNIQUE (code);


--
-- TOC entry 8512 (class 2606 OID 243120)
-- Name: quality_flag quality_flag_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.quality_flag
    ADD CONSTRAINT quality_flag_pkey PRIMARY KEY (quality_flag_id);


--
-- TOC entry 8363 (class 2606 OID 242248)
-- Name: source_artifact source_artifact_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.source_artifact
    ADD CONSTRAINT source_artifact_pkey PRIMARY KEY (source_artifact_id);


--
-- TOC entry 8435 (class 2606 OID 242649)
-- Name: station_h3_map station_h3_map_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_h3_map
    ADD CONSTRAINT station_h3_map_pkey PRIMARY KEY (station_h3_map_id);


--
-- TOC entry 8438 (class 2606 OID 242651)
-- Name: station_h3_map station_h3_map_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_h3_map
    ADD CONSTRAINT station_h3_map_unique UNIQUE (station_history_id, grid_cell_id);


--
-- TOC entry 8414 (class 2606 OID 242955)
-- Name: station_history station_history_id_station_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_history
    ADD CONSTRAINT station_history_id_station_unique UNIQUE (station_history_id, station_id);


--
-- TOC entry 8416 (class 2606 OID 242548)
-- Name: station_history station_history_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_history
    ADD CONSTRAINT station_history_pkey PRIMARY KEY (station_history_id);


--
-- TOC entry 8407 (class 2606 OID 242507)
-- Name: station_identifier station_identifier_external_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_identifier
    ADD CONSTRAINT station_identifier_external_unique UNIQUE NULLS NOT DISTINCT (identifier_scheme, identifier_value, provider_id, station_network_id);


--
-- TOC entry 8409 (class 2606 OID 242505)
-- Name: station_identifier station_identifier_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_identifier
    ADD CONSTRAINT station_identifier_pkey PRIMARY KEY (station_identifier_id);


--
-- TOC entry 8397 (class 2606 OID 242451)
-- Name: station_network station_network_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_network
    ADD CONSTRAINT station_network_code_unique UNIQUE (code);


--
-- TOC entry 8421 (class 2606 OID 242576)
-- Name: station_network_membership station_network_membership_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_network_membership
    ADD CONSTRAINT station_network_membership_pkey PRIMARY KEY (station_network_membership_id);


--
-- TOC entry 8423 (class 2606 OID 242578)
-- Name: station_network_membership station_network_membership_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_network_membership
    ADD CONSTRAINT station_network_membership_unique UNIQUE NULLS NOT DISTINCT (station_id, station_network_id, valid_from);


--
-- TOC entry 8399 (class 2606 OID 242449)
-- Name: station_network station_network_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_network
    ADD CONSTRAINT station_network_pkey PRIMARY KEY (station_network_id);


--
-- TOC entry 8647 (class 2606 OID 244066)
-- Name: station_observation_correction station_observation_correction_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_correction
    ADD CONSTRAINT station_observation_correction_pkey PRIMARY KEY (station_observation_correction_id);


--
-- TOC entry 8650 (class 2606 OID 244068)
-- Name: station_observation_correction station_observation_correction_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_correction
    ADD CONSTRAINT station_observation_correction_unique UNIQUE (original_observation_id, original_observation_time, replacement_observation_id, replacement_observation_time);


--
-- TOC entry 8659 (class 2606 OID 244184)
-- Name: station_observation_daily_correction station_observation_daily_correction_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily_correction
    ADD CONSTRAINT station_observation_daily_correction_pkey PRIMARY KEY (station_observation_daily_correction_id);


--
-- TOC entry 8662 (class 2606 OID 244186)
-- Name: station_observation_daily_correction station_observation_daily_correction_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily_correction
    ADD CONSTRAINT station_observation_daily_correction_unique UNIQUE (original_observation_daily_id, original_observation_date, replacement_observation_daily_id, replacement_observation_date);


--
-- TOC entry 8559 (class 2606 OID 243441)
-- Name: station_observation_daily station_observation_daily_natural_revision_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily
    ADD CONSTRAINT station_observation_daily_natural_revision_unique UNIQUE (station_id, observation_product_id, observation_date, revision_no);


--
-- TOC entry 8568 (class 2606 OID 243513)
-- Name: station_observation_daily_default station_observation_daily_def_station_id_observation_produc_key; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily_default
    ADD CONSTRAINT station_observation_daily_def_station_id_observation_produc_key UNIQUE (station_id, observation_product_id, observation_date, revision_no);


--
-- TOC entry 8561 (class 2606 OID 243439)
-- Name: station_observation_daily station_observation_daily_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily
    ADD CONSTRAINT station_observation_daily_pkey PRIMARY KEY (station_observation_daily_id, observation_date);


--
-- TOC entry 8574 (class 2606 OID 243511)
-- Name: station_observation_daily_default station_observation_daily_default_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily_default
    ADD CONSTRAINT station_observation_daily_default_pkey PRIMARY KEY (station_observation_daily_id, observation_date);


--
-- TOC entry 8599 (class 2606 OID 243737)
-- Name: station_observation_daily_quality_exception station_observation_daily_quality_exception_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily_quality_exception
    ADD CONSTRAINT station_observation_daily_quality_exception_pkey PRIMARY KEY (station_observation_daily_quality_exception_id);


--
-- TOC entry 8601 (class 2606 OID 243739)
-- Name: station_observation_daily_quality_exception station_observation_daily_quality_exception_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily_quality_exception
    ADD CONSTRAINT station_observation_daily_quality_exception_unique UNIQUE (station_observation_daily_id, observation_date, variable_id, quality_flag_id);


--
-- TOC entry 8491 (class 2606 OID 242991)
-- Name: station_observation_hourly station_observation_hourly_natural_revision_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_hourly
    ADD CONSTRAINT station_observation_hourly_natural_revision_unique UNIQUE (station_id, observation_product_id, observation_time, revision_no);


--
-- TOC entry 8501 (class 2606 OID 243056)
-- Name: station_observation_hourly_default station_observation_hourly_de_station_id_observation_produc_key; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_hourly_default
    ADD CONSTRAINT station_observation_hourly_de_station_id_observation_produc_key UNIQUE (station_id, observation_product_id, observation_time, revision_no);


--
-- TOC entry 8493 (class 2606 OID 242989)
-- Name: station_observation_hourly station_observation_hourly_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_hourly
    ADD CONSTRAINT station_observation_hourly_pkey PRIMARY KEY (station_observation_id, observation_time);


--
-- TOC entry 8508 (class 2606 OID 243054)
-- Name: station_observation_hourly_default station_observation_hourly_default_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_hourly_default
    ADD CONSTRAINT station_observation_hourly_default_pkey PRIMARY KEY (station_observation_id, observation_time);


--
-- TOC entry 8517 (class 2606 OID 243144)
-- Name: station_observation_quality_exception station_observation_quality_exception_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_quality_exception
    ADD CONSTRAINT station_observation_quality_exception_pkey PRIMARY KEY (station_observation_quality_exception_id);


--
-- TOC entry 8519 (class 2606 OID 243146)
-- Name: station_observation_quality_exception station_observation_quality_exception_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_quality_exception
    ADD CONSTRAINT station_observation_quality_exception_unique UNIQUE (station_observation_id, observation_time, variable_id, quality_flag_id);


--
-- TOC entry 8615 (class 2606 OID 243836)
-- Name: station_observation_value station_observation_value_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_value
    ADD CONSTRAINT station_observation_value_pkey PRIMARY KEY (station_observation_value_id);


--
-- TOC entry 8617 (class 2606 OID 243838)
-- Name: station_observation_value station_observation_value_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_value
    ADD CONSTRAINT station_observation_value_unique UNIQUE (station_observation_id, observation_time, variable_id);


--
-- TOC entry 8405 (class 2606 OID 242480)
-- Name: station station_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station
    ADD CONSTRAINT station_pkey PRIMARY KEY (station_id);


--
-- TOC entry 8440 (class 2606 OID 242683)
-- Name: station_region_map station_region_map_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_region_map
    ADD CONSTRAINT station_region_map_pkey PRIMARY KEY (station_region_map_id);


--
-- TOC entry 8444 (class 2606 OID 242685)
-- Name: station_region_map station_region_map_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_region_map
    ADD CONSTRAINT station_region_map_unique UNIQUE (station_history_id, region_version_id);


--
-- TOC entry 8452 (class 2606 OID 242748)
-- Name: statistic statistic_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.statistic
    ADD CONSTRAINT statistic_code_unique UNIQUE (code);


--
-- TOC entry 8454 (class 2606 OID 242746)
-- Name: statistic statistic_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.statistic
    ADD CONSTRAINT statistic_pkey PRIMARY KEY (statistic_id);


--
-- TOC entry 8456 (class 2606 OID 242772)
-- Name: temporal_semantics temporal_semantics_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.temporal_semantics
    ADD CONSTRAINT temporal_semantics_code_unique UNIQUE (code);


--
-- TOC entry 8458 (class 2606 OID 242770)
-- Name: temporal_semantics temporal_semantics_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.temporal_semantics
    ADD CONSTRAINT temporal_semantics_pkey PRIMARY KEY (temporal_semantics_id);


--
-- TOC entry 8447 (class 2606 OID 242724)
-- Name: unit unit_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.unit
    ADD CONSTRAINT unit_code_unique UNIQUE (code);


--
-- TOC entry 8449 (class 2606 OID 242722)
-- Name: unit unit_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.unit
    ADD CONSTRAINT unit_pkey PRIMARY KEY (unit_id);


--
-- TOC entry 8469 (class 2606 OID 242855)
-- Name: variable variable_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.variable
    ADD CONSTRAINT variable_code_unique UNIQUE (code);


--
-- TOC entry 8472 (class 2606 OID 242853)
-- Name: variable variable_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.variable
    ADD CONSTRAINT variable_pkey PRIMARY KEY (variable_id);


--
-- TOC entry 8799 (class 2606 OID 245140)
-- Name: verification_definition verification_definition_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.verification_definition
    ADD CONSTRAINT verification_definition_code_unique UNIQUE (code);


--
-- TOC entry 8802 (class 2606 OID 245138)
-- Name: verification_definition verification_definition_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.verification_definition
    ADD CONSTRAINT verification_definition_pkey PRIMARY KEY (verification_definition_id);


--
-- TOC entry 8464 (class 2606 OID 242820)
-- Name: vertical_level vertical_level_code_unique; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.vertical_level
    ADD CONSTRAINT vertical_level_code_unique UNIQUE (code);


--
-- TOC entry 8466 (class 2606 OID 242818)
-- Name: vertical_level vertical_level_pkey; Type: CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.vertical_level
    ADD CONSTRAINT vertical_level_pkey PRIMARY KEY (vertical_level_id);


--
-- TOC entry 8169 (class 1259 OID 57746)
-- Name: idx_flight_enrichment_lookup; Type: INDEX; Schema: aviation; Owner: postgres
--

CREATE INDEX idx_flight_enrichment_lookup ON aviation.flight_enrichment USING btree (icao24, callsign, flight_number);


--
-- TOC entry 8163 (class 1259 OID 57732)
-- Name: idx_flight_history_archived_at; Type: INDEX; Schema: aviation; Owner: postgres
--

CREATE INDEX idx_flight_history_archived_at ON aviation.flight_history USING btree (archived_at);


--
-- TOC entry 8164 (class 1259 OID 57730)
-- Name: idx_flight_history_callsign; Type: INDEX; Schema: aviation; Owner: postgres
--

CREATE INDEX idx_flight_history_callsign ON aviation.flight_history USING btree (callsign);


--
-- TOC entry 8165 (class 1259 OID 57729)
-- Name: idx_flight_history_icao24; Type: INDEX; Schema: aviation; Owner: postgres
--

CREATE INDEX idx_flight_history_icao24 ON aviation.flight_history USING btree (icao24);


--
-- TOC entry 8166 (class 1259 OID 57731)
-- Name: idx_flight_history_last_seen_at; Type: INDEX; Schema: aviation; Owner: postgres
--

CREATE INDEX idx_flight_history_last_seen_at ON aviation.flight_history USING btree (last_seen_at);


--
-- TOC entry 8172 (class 1259 OID 57762)
-- Name: idx_flight_ingest_raw_batch_time; Type: INDEX; Schema: aviation; Owner: postgres
--

CREATE INDEX idx_flight_ingest_raw_batch_time ON aviation.flight_ingest_raw USING btree (batch_time);


--
-- TOC entry 8173 (class 1259 OID 57763)
-- Name: idx_flight_ingest_raw_icao24; Type: INDEX; Schema: aviation; Owner: postgres
--

CREATE INDEX idx_flight_ingest_raw_icao24 ON aviation.flight_ingest_raw USING btree (icao24);


--
-- TOC entry 8157 (class 1259 OID 57713)
-- Name: idx_flight_live_callsign; Type: INDEX; Schema: aviation; Owner: postgres
--

CREATE INDEX idx_flight_live_callsign ON aviation.flight_live USING btree (callsign);


--
-- TOC entry 8158 (class 1259 OID 57714)
-- Name: idx_flight_live_last_seen_at; Type: INDEX; Schema: aviation; Owner: postgres
--

CREATE INDEX idx_flight_live_last_seen_at ON aviation.flight_live USING btree (last_seen_at);


--
-- TOC entry 8159 (class 1259 OID 57715)
-- Name: idx_flight_live_status; Type: INDEX; Schema: aviation; Owner: postgres
--

CREATE INDEX idx_flight_live_status ON aviation.flight_live USING btree (status);


--
-- TOC entry 8160 (class 1259 OID 57712)
-- Name: ux_flight_live_icao24; Type: INDEX; Schema: aviation; Owner: postgres
--

CREATE UNIQUE INDEX ux_flight_live_icao24 ON aviation.flight_live USING btree (icao24) WHERE (icao24 IS NOT NULL);


--
-- TOC entry 8218 (class 1259 OID 86345)
-- Name: idx_consumption_monthly_region_month; Type: INDEX; Schema: gas; Owner: postgres
--

CREATE INDEX idx_consumption_monthly_region_month ON gas.consumption_monthly USING btree (region, report_month DESC);


--
-- TOC entry 8219 (class 1259 OID 86369)
-- Name: idx_consumption_monthly_region_report_month; Type: INDEX; Schema: gas; Owner: postgres
--

CREATE INDEX idx_consumption_monthly_region_report_month ON gas.consumption_monthly USING btree (region, report_month DESC);


--
-- TOC entry 8220 (class 1259 OID 86344)
-- Name: idx_consumption_monthly_report_month; Type: INDEX; Schema: gas; Owner: postgres
--

CREATE INDEX idx_consumption_monthly_report_month ON gas.consumption_monthly USING btree (report_month DESC);


--
-- TOC entry 8200 (class 1259 OID 86294)
-- Name: idx_lng_exports_date; Type: INDEX; Schema: gas; Owner: postgres
--

CREATE INDEX idx_lng_exports_date ON gas.lng_exports_daily USING btree (report_date DESC);


--
-- TOC entry 8201 (class 1259 OID 86296)
-- Name: idx_lng_exports_region; Type: INDEX; Schema: gas; Owner: postgres
--

CREATE INDEX idx_lng_exports_region ON gas.lng_exports_daily USING btree (destination_region);


--
-- TOC entry 8202 (class 1259 OID 86295)
-- Name: idx_lng_exports_terminal; Type: INDEX; Schema: gas; Owner: postgres
--

CREATE INDEX idx_lng_exports_terminal ON gas.lng_exports_daily USING btree (terminal_name);


--
-- TOC entry 8207 (class 1259 OID 86297)
-- Name: idx_pipeline_flows_date; Type: INDEX; Schema: gas; Owner: postgres
--

CREATE INDEX idx_pipeline_flows_date ON gas.pipeline_flows_daily USING btree (report_date DESC);


--
-- TOC entry 8208 (class 1259 OID 86298)
-- Name: idx_pipeline_flows_pipeline; Type: INDEX; Schema: gas; Owner: postgres
--

CREATE INDEX idx_pipeline_flows_pipeline ON gas.pipeline_flows_daily USING btree (pipeline_name);


--
-- TOC entry 8209 (class 1259 OID 86299)
-- Name: idx_pipeline_flows_regions; Type: INDEX; Schema: gas; Owner: postgres
--

CREATE INDEX idx_pipeline_flows_regions ON gas.pipeline_flows_daily USING btree (origin_region, destination_region);


--
-- TOC entry 8225 (class 1259 OID 86395)
-- Name: idx_prices_daily_market_price_date; Type: INDEX; Schema: gas; Owner: postgres
--

CREATE INDEX idx_prices_daily_market_price_date ON gas.prices_daily USING btree (market, price_date DESC);


--
-- TOC entry 8226 (class 1259 OID 86394)
-- Name: idx_prices_daily_price_date; Type: INDEX; Schema: gas; Owner: postgres
--

CREATE INDEX idx_prices_daily_price_date ON gas.prices_daily USING btree (price_date DESC);


--
-- TOC entry 8152 (class 1259 OID 57576)
-- Name: idx_geo_airports_gps_code; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX idx_geo_airports_gps_code ON geo.airports USING btree (gps_code);


--
-- TOC entry 8153 (class 1259 OID 57574)
-- Name: idx_geo_airports_iata_code; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX idx_geo_airports_iata_code ON geo.airports USING btree (iata_code);


--
-- TOC entry 8154 (class 1259 OID 57575)
-- Name: idx_geo_airports_ident; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX idx_geo_airports_ident ON geo.airports USING btree (ident);


--
-- TOC entry 8147 (class 1259 OID 69904)
-- Name: idx_geo_locations_source_unique; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE UNIQUE INDEX idx_geo_locations_source_unique ON geo.locations USING btree (source_system, source_id) WHERE (source_id IS NOT NULL);


--
-- TOC entry 8174 (class 1259 OID 61960)
-- Name: idx_ports_country; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX idx_ports_country ON geo.ports USING btree (country_code);


--
-- TOC entry 8175 (class 1259 OID 61961)
-- Name: idx_ports_draft; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX idx_ports_draft ON geo.ports USING btree (max_vessel_draft);


--
-- TOC entry 8176 (class 1259 OID 61962)
-- Name: idx_ports_name; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX idx_ports_name ON geo.ports USING gin (name public.gin_trgm_ops);


--
-- TOC entry 8177 (class 1259 OID 61963)
-- Name: idx_ports_source_id; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX idx_ports_source_id ON geo.ports USING btree (source, source_id);


--
-- TOC entry 8243 (class 1259 OID 225513)
-- Name: location_active_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX location_active_idx ON geo.location USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8310 (class 1259 OID 225827)
-- Name: location_cell_map_grid_cell_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX location_cell_map_grid_cell_idx ON geo.location_cell_map USING btree (grid_cell_id);


--
-- TOC entry 8311 (class 1259 OID 225826)
-- Name: location_cell_map_location_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX location_cell_map_location_idx ON geo.location_cell_map USING btree (location_id);


--
-- TOC entry 8244 (class 1259 OID 225511)
-- Name: location_country_subdivision_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX location_country_subdivision_idx ON geo.location USING btree (country_code, subdivision_code);


--
-- TOC entry 8252 (class 1259 OID 225545)
-- Name: location_identifier_location_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX location_identifier_location_idx ON geo.location_identifier USING btree (location_id);


--
-- TOC entry 8255 (class 1259 OID 225544)
-- Name: location_identifier_primary_unique_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE UNIQUE INDEX location_identifier_primary_unique_idx ON geo.location_identifier USING btree (location_id, identifier_scheme) WHERE (is_primary = true);


--
-- TOC entry 8256 (class 1259 OID 225546)
-- Name: location_identifier_scheme_value_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX location_identifier_scheme_value_idx ON geo.location_identifier USING btree (identifier_scheme, identifier_value);


--
-- TOC entry 8257 (class 1259 OID 225547)
-- Name: location_identifier_source_value_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX location_identifier_source_value_idx ON geo.location_identifier USING btree (source_system, identifier_value);


--
-- TOC entry 8245 (class 1259 OID 225512)
-- Name: location_lower_name_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX location_lower_name_idx ON geo.location USING btree (lower(name));


--
-- TOC entry 8248 (class 1259 OID 225509)
-- Name: location_position_gix; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX location_position_gix ON geo.location USING gist ("position");


--
-- TOC entry 8249 (class 1259 OID 225510)
-- Name: location_type_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX location_type_idx ON geo.location USING btree (location_type);


--
-- TOC entry 8276 (class 1259 OID 225663)
-- Name: region_active_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_active_idx ON geo.region USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8316 (class 1259 OID 225852)
-- Name: region_cell_map_grid_cell_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_cell_map_grid_cell_idx ON geo.region_cell_map USING btree (grid_cell_id);


--
-- TOC entry 8319 (class 1259 OID 225851)
-- Name: region_cell_map_region_version_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_cell_map_region_version_idx ON geo.region_cell_map USING btree (region_version_id);


--
-- TOC entry 8277 (class 1259 OID 225660)
-- Name: region_country_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_country_idx ON geo.region USING btree (country_code);


--
-- TOC entry 8278 (class 1259 OID 225661)
-- Name: region_country_subdivision_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_country_subdivision_idx ON geo.region USING btree (country_code, subdivision_code);


--
-- TOC entry 8287 (class 1259 OID 225694)
-- Name: region_identifier_primary_unique_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE UNIQUE INDEX region_identifier_primary_unique_idx ON geo.region_identifier USING btree (region_id, identifier_scheme) WHERE (is_primary = true);


--
-- TOC entry 8288 (class 1259 OID 225695)
-- Name: region_identifier_region_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_identifier_region_idx ON geo.region_identifier USING btree (region_id);


--
-- TOC entry 8289 (class 1259 OID 225696)
-- Name: region_identifier_scheme_value_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_identifier_scheme_value_idx ON geo.region_identifier USING btree (identifier_scheme, identifier_value);


--
-- TOC entry 8290 (class 1259 OID 225697)
-- Name: region_identifier_source_value_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_identifier_source_value_idx ON geo.region_identifier USING btree (source_system, identifier_value);


--
-- TOC entry 8279 (class 1259 OID 225662)
-- Name: region_lower_name_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_lower_name_idx ON geo.region USING btree (lower(name));


--
-- TOC entry 8328 (class 1259 OID 229291)
-- Name: region_relationship_child_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_relationship_child_idx ON geo.region_relationship USING btree (child_region_id);


--
-- TOC entry 8329 (class 1259 OID 229293)
-- Name: region_relationship_current_parent_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_relationship_current_parent_idx ON geo.region_relationship USING btree (child_region_id, relationship_type) WHERE (is_current = true);


--
-- TOC entry 8330 (class 1259 OID 229290)
-- Name: region_relationship_parent_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_relationship_parent_idx ON geo.region_relationship USING btree (parent_region_id);


--
-- TOC entry 8333 (class 1259 OID 229292)
-- Name: region_relationship_type_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_relationship_type_idx ON geo.region_relationship USING btree (relationship_type);


--
-- TOC entry 8271 (class 1259 OID 225630)
-- Name: region_type_active_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_type_active_idx ON geo.region_type USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8282 (class 1259 OID 225659)
-- Name: region_type_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_type_idx ON geo.region USING btree (region_type_id);


--
-- TOC entry 8291 (class 1259 OID 225735)
-- Name: region_version_current_unique_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE UNIQUE INDEX region_version_current_unique_idx ON geo.region_version USING btree (region_id) WHERE (is_current = true);


--
-- TOC entry 8292 (class 1259 OID 225734)
-- Name: region_version_dataset_version_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_version_dataset_version_idx ON geo.region_version USING btree (spatial_dataset_version_id);


--
-- TOC entry 8293 (class 1259 OID 225732)
-- Name: region_version_geometry_gix; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_version_geometry_gix ON geo.region_version USING gist (geometry);


--
-- TOC entry 8296 (class 1259 OID 225733)
-- Name: region_version_region_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX region_version_region_idx ON geo.region_version USING btree (region_id);


--
-- TOC entry 8258 (class 1259 OID 225574)
-- Name: spatial_dataset_active_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX spatial_dataset_active_idx ON geo.spatial_dataset USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8261 (class 1259 OID 225573)
-- Name: spatial_dataset_provider_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX spatial_dataset_provider_idx ON geo.spatial_dataset USING btree (provider_name);


--
-- TOC entry 8264 (class 1259 OID 225603)
-- Name: spatial_dataset_version_current_unique_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE UNIQUE INDEX spatial_dataset_version_current_unique_idx ON geo.spatial_dataset_version USING btree (spatial_dataset_id) WHERE (is_current = true);


--
-- TOC entry 8265 (class 1259 OID 225604)
-- Name: spatial_dataset_version_dataset_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX spatial_dataset_version_dataset_idx ON geo.spatial_dataset_version USING btree (spatial_dataset_id);


--
-- TOC entry 8268 (class 1259 OID 225605)
-- Name: spatial_dataset_version_release_date_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX spatial_dataset_version_release_date_idx ON geo.spatial_dataset_version USING btree (release_date);


--
-- TOC entry 8325 (class 1259 OID 229243)
-- Name: stage_tiger_2025_county_geom_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX stage_tiger_2025_county_geom_idx ON geo.stage_tiger_2025_county USING gist (geom);


--
-- TOC entry 8336 (class 1259 OID 242079)
-- Name: stage_tiger_2025_county_utf8_geom_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX stage_tiger_2025_county_utf8_geom_idx ON geo.stage_tiger_2025_county_utf8 USING gist (geom);


--
-- TOC entry 8322 (class 1259 OID 225920)
-- Name: stage_tiger_2025_state_geom_idx; Type: INDEX; Schema: geo; Owner: postgres
--

CREATE INDEX stage_tiger_2025_state_geom_idx ON geo.stage_tiger_2025_state USING gist (geom);


--
-- TOC entry 8143 (class 1259 OID 57510)
-- Name: idx_locations_coords; Type: INDEX; Schema: locations; Owner: postgres
--

CREATE INDEX idx_locations_coords ON locations.locations USING gist (public.ll_to_earth(lat, lng));


--
-- TOC entry 8144 (class 1259 OID 57509)
-- Name: idx_locations_type; Type: INDEX; Schema: locations; Owner: postgres
--

CREATE INDEX idx_locations_type ON locations.locations USING btree (type);


--
-- TOC entry 8182 (class 1259 OID 69899)
-- Name: idx_mining_mines_all_commodities; Type: INDEX; Schema: mining; Owner: postgres
--

CREATE INDEX idx_mining_mines_all_commodities ON mining.assets USING gin (all_commodities);


--
-- TOC entry 8183 (class 1259 OID 69896)
-- Name: idx_mining_mines_location_id; Type: INDEX; Schema: mining; Owner: postgres
--

CREATE INDEX idx_mining_mines_location_id ON mining.assets USING btree (location_id);


--
-- TOC entry 8184 (class 1259 OID 69897)
-- Name: idx_mining_mines_primary_commodity; Type: INDEX; Schema: mining; Owner: postgres
--

CREATE INDEX idx_mining_mines_primary_commodity ON mining.assets USING btree (primary_commodity);


--
-- TOC entry 8185 (class 1259 OID 69898)
-- Name: idx_mining_mines_primary_group; Type: INDEX; Schema: mining; Owner: postgres
--

CREATE INDEX idx_mining_mines_primary_group ON mining.assets USING btree (primary_commodity_group);


--
-- TOC entry 8186 (class 1259 OID 69895)
-- Name: idx_mining_mines_source_id; Type: INDEX; Schema: mining; Owner: postgres
--

CREATE UNIQUE INDEX idx_mining_mines_source_id ON mining.assets USING btree (source_system, source_id) WHERE (source_id IS NOT NULL);


--
-- TOC entry 8187 (class 1259 OID 69905)
-- Name: idx_mining_mines_source_unique; Type: INDEX; Schema: mining; Owner: postgres
--

CREATE UNIQUE INDEX idx_mining_mines_source_unique ON mining.assets USING btree (source_system, source_id) WHERE (source_id IS NOT NULL);


--
-- TOC entry 8112 (class 1259 OID 32789)
-- Name: idx_strategic_point_lat_lon; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_strategic_point_lat_lon ON public.strategic_point USING btree (latitude, longitude);


--
-- TOC entry 8113 (class 1259 OID 32788)
-- Name: idx_strategic_point_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_strategic_point_type ON public.strategic_point USING btree (point_type);


--
-- TOC entry 8116 (class 1259 OID 32840)
-- Name: idx_weather_grid_point_lat_lon; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_weather_grid_point_lat_lon ON public.weather_grid_point USING btree (latitude, longitude);


--
-- TOC entry 8123 (class 1259 OID 40983)
-- Name: idx_weather_observation_grid_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_weather_observation_grid_time ON public.weather_observation USING btree (grid_point_id, observation_time);


--
-- TOC entry 8124 (class 1259 OID 40984)
-- Name: idx_weather_observation_time; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX idx_weather_observation_time ON public.weather_observation USING btree (observation_time);


--
-- TOC entry 8129 (class 1259 OID 49164)
-- Name: ix_signals_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_signals_id ON public.signals USING btree (id);


--
-- TOC entry 8130 (class 1259 OID 49163)
-- Name: ix_signals_module; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_signals_module ON public.signals USING btree (module);


--
-- TOC entry 8131 (class 1259 OID 49166)
-- Name: ix_signals_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_signals_name ON public.signals USING btree (name);


--
-- TOC entry 8132 (class 1259 OID 49162)
-- Name: ix_signals_signal_type; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_signals_signal_type ON public.signals USING btree (signal_type);


--
-- TOC entry 8133 (class 1259 OID 49165)
-- Name: ix_signals_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_signals_timestamp ON public.signals USING btree ("timestamp");


--
-- TOC entry 8136 (class 1259 OID 49180)
-- Name: ix_weather_data_id; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_weather_data_id ON public.weather_data USING btree (id);


--
-- TOC entry 8137 (class 1259 OID 49179)
-- Name: ix_weather_data_location; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_weather_data_location ON public.weather_data USING btree (location);


--
-- TOC entry 8138 (class 1259 OID 49178)
-- Name: ix_weather_data_timestamp; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_weather_data_timestamp ON public.weather_data USING btree ("timestamp");


--
-- TOC entry 8097 (class 1259 OID 24875)
-- Name: ix_weather_forecast_run_issued_at_desc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_weather_forecast_run_issued_at_desc ON public.weather_forecast_run USING btree (issued_at DESC);


--
-- TOC entry 8101 (class 1259 OID 24903)
-- Name: ix_weather_forecast_value_location_lead; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_weather_forecast_value_location_lead ON public.weather_forecast_value USING btree (location_id, lead_hours, valid_time DESC);


--
-- TOC entry 8102 (class 1259 OID 24901)
-- Name: ix_weather_forecast_value_location_valid_desc; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_weather_forecast_value_location_valid_desc ON public.weather_forecast_value USING btree (location_id, valid_time DESC);


--
-- TOC entry 8103 (class 1259 OID 24902)
-- Name: ix_weather_forecast_value_run_location_valid; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_weather_forecast_value_run_location_valid ON public.weather_forecast_value USING btree (forecast_run_id, location_id, valid_time);


--
-- TOC entry 8092 (class 1259 OID 24838)
-- Name: ix_weather_location_name; Type: INDEX; Schema: public; Owner: postgres
--

CREATE INDEX ix_weather_location_name ON public.weather_location USING btree (name);


--
-- TOC entry 8098 (class 1259 OID 24874)
-- Name: ux_weather_forecast_run_unique; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_weather_forecast_run_unique ON public.weather_forecast_run USING btree (provider, COALESCE(model_name, ''::text), COALESCE(product_name, ''::text), issued_at);


--
-- TOC entry 8093 (class 1259 OID 24943)
-- Name: ux_weather_location_code; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_weather_location_code ON public.weather_location USING btree (location_code);


--
-- TOC entry 8094 (class 1259 OID 24837)
-- Name: ux_weather_location_provider_key; Type: INDEX; Schema: public; Owner: postgres
--

CREATE UNIQUE INDEX ux_weather_location_provider_key ON public.weather_location USING btree (source_system, provider_location_key);


--
-- TOC entry 8835 (class 1259 OID 245451)
-- Name: bias_correction_definition_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX bias_correction_definition_active_idx ON weather.bias_correction_definition USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8838 (class 1259 OID 245452)
-- Name: bias_correction_definition_current_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX bias_correction_definition_current_idx ON weather.bias_correction_definition USING btree (is_current) WHERE (is_current = true);


--
-- TOC entry 8839 (class 1259 OID 245450)
-- Name: bias_correction_definition_observation_product_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX bias_correction_definition_observation_product_idx ON weather.bias_correction_definition USING btree (training_observation_product_id);


--
-- TOC entry 8842 (class 1259 OID 245449)
-- Name: bias_correction_definition_variable_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX bias_correction_definition_variable_idx ON weather.bias_correction_definition USING btree (target_variable_id);


--
-- TOC entry 8843 (class 1259 OID 245485)
-- Name: bias_correction_input_product_definition_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX bias_correction_input_product_definition_idx ON weather.bias_correction_input_product USING btree (bias_correction_definition_id);


--
-- TOC entry 8844 (class 1259 OID 245486)
-- Name: bias_correction_input_product_forecast_product_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX bias_correction_input_product_forecast_product_idx ON weather.bias_correction_input_product USING btree (forecast_product_id);


--
-- TOC entry 8718 (class 1259 OID 244624)
-- Name: cell_forecast_cell_valid_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_cell_valid_time_idx ON ONLY weather.cell_forecast USING btree (grid_cell_id, valid_time);


--
-- TOC entry 8776 (class 1259 OID 245009)
-- Name: cell_forecast_correction_artifact_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_correction_artifact_idx ON weather.cell_forecast_correction USING btree (source_artifact_id) WHERE (source_artifact_id IS NOT NULL);


--
-- TOC entry 8777 (class 1259 OID 245006)
-- Name: cell_forecast_correction_original_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_correction_original_idx ON weather.cell_forecast_correction USING btree (original_cell_forecast_id, original_valid_time);


--
-- TOC entry 8780 (class 1259 OID 245008)
-- Name: cell_forecast_correction_reason_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_correction_reason_idx ON weather.cell_forecast_correction USING btree (forecast_correction_reason_id);


--
-- TOC entry 8781 (class 1259 OID 245007)
-- Name: cell_forecast_correction_replacement_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_correction_replacement_idx ON weather.cell_forecast_correction USING btree (replacement_cell_forecast_id, replacement_valid_time);


--
-- TOC entry 8719 (class 1259 OID 244630)
-- Name: cell_forecast_derivation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_derivation_idx ON ONLY weather.cell_forecast USING btree (derivation_run_id);


--
-- TOC entry 8730 (class 1259 OID 244663)
-- Name: cell_forecast_default_derivation_run_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_default_derivation_run_id_idx ON weather.cell_forecast_default USING btree (derivation_run_id);


--
-- TOC entry 8721 (class 1259 OID 244627)
-- Name: cell_forecast_member_valid_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_member_valid_time_idx ON ONLY weather.cell_forecast USING btree (forecast_member_id, valid_time);


--
-- TOC entry 8731 (class 1259 OID 244660)
-- Name: cell_forecast_default_forecast_member_id_valid_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_default_forecast_member_id_valid_time_idx ON weather.cell_forecast_default USING btree (forecast_member_id, valid_time);


--
-- TOC entry 8727 (class 1259 OID 244628)
-- Name: cell_forecast_product_valid_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_product_valid_time_idx ON ONLY weather.cell_forecast USING btree (forecast_product_id, valid_time);


--
-- TOC entry 8732 (class 1259 OID 244661)
-- Name: cell_forecast_default_forecast_product_id_valid_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_default_forecast_product_id_valid_time_idx ON weather.cell_forecast_default USING btree (forecast_product_id, valid_time);


--
-- TOC entry 8728 (class 1259 OID 244626)
-- Name: cell_forecast_run_valid_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_run_valid_time_idx ON ONLY weather.cell_forecast USING btree (forecast_run_id, valid_time);


--
-- TOC entry 8735 (class 1259 OID 244659)
-- Name: cell_forecast_default_forecast_run_id_valid_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_default_forecast_run_id_valid_time_idx ON weather.cell_forecast_default USING btree (forecast_run_id, valid_time);


--
-- TOC entry 8726 (class 1259 OID 244629)
-- Name: cell_forecast_preferred_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_preferred_idx ON ONLY weather.cell_forecast USING btree (grid_cell_id, forecast_product_id, valid_time) WHERE (is_preferred = true);


--
-- TOC entry 8736 (class 1259 OID 244662)
-- Name: cell_forecast_default_grid_cell_id_forecast_product_id_vali_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_default_grid_cell_id_forecast_product_id_vali_idx ON weather.cell_forecast_default USING btree (grid_cell_id, forecast_product_id, valid_time) WHERE (is_preferred = true);


--
-- TOC entry 8737 (class 1259 OID 244657)
-- Name: cell_forecast_default_grid_cell_id_valid_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_default_grid_cell_id_valid_time_idx ON weather.cell_forecast_default USING btree (grid_cell_id, valid_time);


--
-- TOC entry 8720 (class 1259 OID 244631)
-- Name: cell_forecast_ingestion_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_ingestion_idx ON ONLY weather.cell_forecast USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL);


--
-- TOC entry 8738 (class 1259 OID 244664)
-- Name: cell_forecast_default_ingestion_run_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_default_ingestion_run_id_idx ON weather.cell_forecast_default USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL);


--
-- TOC entry 8729 (class 1259 OID 244625)
-- Name: cell_forecast_valid_time_cell_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_valid_time_cell_idx ON ONLY weather.cell_forecast USING btree (valid_time, grid_cell_id);


--
-- TOC entry 8741 (class 1259 OID 244658)
-- Name: cell_forecast_default_valid_time_grid_cell_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_default_valid_time_grid_cell_id_idx ON weather.cell_forecast_default USING btree (valid_time, grid_cell_id);


--
-- TOC entry 8788 (class 1259 OID 245104)
-- Name: cell_forecast_revision_calculated_at_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_revision_calculated_at_idx ON weather.cell_forecast_revision USING btree (calculated_at DESC);


--
-- TOC entry 8789 (class 1259 OID 245101)
-- Name: cell_forecast_revision_comparison_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_revision_comparison_idx ON weather.cell_forecast_revision USING btree (comparison_cell_forecast_id, comparison_valid_time);


--
-- TOC entry 8790 (class 1259 OID 245103)
-- Name: cell_forecast_revision_definition_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_revision_definition_idx ON weather.cell_forecast_revision USING btree (forecast_revision_definition_id);


--
-- TOC entry 8791 (class 1259 OID 245100)
-- Name: cell_forecast_revision_newer_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_revision_newer_idx ON weather.cell_forecast_revision USING btree (newer_cell_forecast_id, newer_valid_time);


--
-- TOC entry 8796 (class 1259 OID 245102)
-- Name: cell_forecast_revision_variable_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_revision_variable_idx ON weather.cell_forecast_revision USING btree (variable_id);


--
-- TOC entry 8742 (class 1259 OID 244770)
-- Name: cell_forecast_value_derivation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_value_derivation_idx ON weather.cell_forecast_value USING btree (derivation_run_id);


--
-- TOC entry 8743 (class 1259 OID 244767)
-- Name: cell_forecast_value_forecast_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_value_forecast_idx ON weather.cell_forecast_value USING btree (cell_forecast_id, valid_time);


--
-- TOC entry 8744 (class 1259 OID 244769)
-- Name: cell_forecast_value_ingestion_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_value_ingestion_idx ON weather.cell_forecast_value USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL);


--
-- TOC entry 8749 (class 1259 OID 244768)
-- Name: cell_forecast_value_variable_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_forecast_value_variable_idx ON weather.cell_forecast_value USING btree (variable_id, valid_time);


--
-- TOC entry 8651 (class 1259 OID 244160)
-- Name: cell_observation_correction_original_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_correction_original_idx ON weather.cell_observation_correction USING btree (original_observation_id, original_observation_time);


--
-- TOC entry 8654 (class 1259 OID 244161)
-- Name: cell_observation_correction_replacement_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_correction_replacement_idx ON weather.cell_observation_correction USING btree (replacement_observation_id, replacement_observation_time);


--
-- TOC entry 8575 (class 1259 OID 243634)
-- Name: cell_observation_daily_cell_date_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_cell_date_idx ON ONLY weather.cell_observation_daily USING btree (grid_cell_id, observation_date DESC);


--
-- TOC entry 8663 (class 1259 OID 244279)
-- Name: cell_observation_daily_correction_original_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_correction_original_idx ON weather.cell_observation_daily_correction USING btree (original_observation_daily_id, original_observation_date);


--
-- TOC entry 8666 (class 1259 OID 244280)
-- Name: cell_observation_daily_correction_replacement_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_correction_replacement_idx ON weather.cell_observation_daily_correction USING btree (replacement_observation_daily_id, replacement_observation_date);


--
-- TOC entry 8576 (class 1259 OID 243635)
-- Name: cell_observation_daily_date_cell_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_date_cell_idx ON ONLY weather.cell_observation_daily USING btree (observation_date, grid_cell_id);


--
-- TOC entry 8585 (class 1259 OID 243671)
-- Name: cell_observation_daily_defaul_grid_cell_id_observation_date_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_defaul_grid_cell_id_observation_date_idx ON weather.cell_observation_daily_default USING btree (grid_cell_id, observation_date DESC);


--
-- TOC entry 8583 (class 1259 OID 243637)
-- Name: cell_observation_daily_preferred_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_preferred_idx ON ONLY weather.cell_observation_daily USING btree (grid_cell_id, observation_product_id, observation_date DESC) WHERE (is_preferred = true);


--
-- TOC entry 8586 (class 1259 OID 243674)
-- Name: cell_observation_daily_defaul_grid_cell_id_observation_prod_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_defaul_grid_cell_id_observation_prod_idx ON weather.cell_observation_daily_default USING btree (grid_cell_id, observation_product_id, observation_date DESC) WHERE (is_preferred = true);


--
-- TOC entry 8589 (class 1259 OID 243672)
-- Name: cell_observation_daily_defaul_observation_date_grid_cell_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_defaul_observation_date_grid_cell_id_idx ON weather.cell_observation_daily_default USING btree (observation_date, grid_cell_id);


--
-- TOC entry 8584 (class 1259 OID 243636)
-- Name: cell_observation_daily_product_date_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_product_date_idx ON ONLY weather.cell_observation_daily USING btree (observation_product_id, observation_date DESC);


--
-- TOC entry 8590 (class 1259 OID 243673)
-- Name: cell_observation_daily_defaul_observation_product_id_observ_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_defaul_observation_product_id_observ_idx ON weather.cell_observation_daily_default USING btree (observation_product_id, observation_date DESC);


--
-- TOC entry 8577 (class 1259 OID 243639)
-- Name: cell_observation_daily_derivation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_derivation_idx ON ONLY weather.cell_observation_daily USING btree (derivation_run_id);


--
-- TOC entry 8591 (class 1259 OID 243676)
-- Name: cell_observation_daily_default_derivation_run_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_default_derivation_run_id_idx ON weather.cell_observation_daily_default USING btree (derivation_run_id);


--
-- TOC entry 8578 (class 1259 OID 243638)
-- Name: cell_observation_daily_ingestion_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_ingestion_idx ON ONLY weather.cell_observation_daily USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL);


--
-- TOC entry 8592 (class 1259 OID 243675)
-- Name: cell_observation_daily_default_ingestion_run_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_default_ingestion_run_id_idx ON weather.cell_observation_daily_default USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL);


--
-- TOC entry 8603 (class 1259 OID 243817)
-- Name: cell_observation_daily_quality_exception_derivation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_quality_exception_derivation_idx ON weather.cell_observation_daily_quality_exception USING btree (derivation_run_id) WHERE (derivation_run_id IS NOT NULL);


--
-- TOC entry 8604 (class 1259 OID 243816)
-- Name: cell_observation_daily_quality_exception_flag_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_quality_exception_flag_idx ON weather.cell_observation_daily_quality_exception USING btree (quality_flag_id);


--
-- TOC entry 8605 (class 1259 OID 243814)
-- Name: cell_observation_daily_quality_exception_observation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_quality_exception_observation_idx ON weather.cell_observation_daily_quality_exception USING btree (cell_observation_daily_id, observation_date);


--
-- TOC entry 8610 (class 1259 OID 243815)
-- Name: cell_observation_daily_quality_exception_variable_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_daily_quality_exception_variable_idx ON weather.cell_observation_daily_quality_exception USING btree (variable_id);


--
-- TOC entry 8521 (class 1259 OID 243241)
-- Name: cell_observation_hourly_cell_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_hourly_cell_time_idx ON ONLY weather.cell_observation_hourly USING btree (grid_cell_id, observation_time DESC);


--
-- TOC entry 8522 (class 1259 OID 244018)
-- Name: cell_observation_hourly_condition_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_hourly_condition_idx ON ONLY weather.cell_observation_hourly USING btree (condition_code_id) WHERE (condition_code_id IS NOT NULL);


--
-- TOC entry 8529 (class 1259 OID 243244)
-- Name: cell_observation_hourly_preferred_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_hourly_preferred_idx ON ONLY weather.cell_observation_hourly USING btree (grid_cell_id, observation_product_id, observation_time DESC) WHERE (is_preferred = true);


--
-- TOC entry 8532 (class 1259 OID 243275)
-- Name: cell_observation_hourly_defau_grid_cell_id_observation_prod_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_hourly_defau_grid_cell_id_observation_prod_idx ON weather.cell_observation_hourly_default USING btree (grid_cell_id, observation_product_id, observation_time DESC) WHERE (is_preferred = true);


--
-- TOC entry 8535 (class 1259 OID 243272)
-- Name: cell_observation_hourly_defau_grid_cell_id_observation_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_hourly_defau_grid_cell_id_observation_time_idx ON weather.cell_observation_hourly_default USING btree (grid_cell_id, observation_time DESC);


--
-- TOC entry 8530 (class 1259 OID 243243)
-- Name: cell_observation_hourly_product_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_hourly_product_time_idx ON ONLY weather.cell_observation_hourly USING btree (observation_product_id, observation_time DESC);


--
-- TOC entry 8536 (class 1259 OID 243274)
-- Name: cell_observation_hourly_defau_observation_product_id_observ_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_hourly_defau_observation_product_id_observ_idx ON weather.cell_observation_hourly_default USING btree (observation_product_id, observation_time DESC);


--
-- TOC entry 8531 (class 1259 OID 243242)
-- Name: cell_observation_hourly_time_cell_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_hourly_time_cell_idx ON ONLY weather.cell_observation_hourly USING btree (observation_time, grid_cell_id);


--
-- TOC entry 8537 (class 1259 OID 243273)
-- Name: cell_observation_hourly_defau_observation_time_grid_cell_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_hourly_defau_observation_time_grid_cell_id_idx ON weather.cell_observation_hourly_default USING btree (observation_time, grid_cell_id);


--
-- TOC entry 8538 (class 1259 OID 244019)
-- Name: cell_observation_hourly_default_condition_code_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_hourly_default_condition_code_id_idx ON weather.cell_observation_hourly_default USING btree (condition_code_id) WHERE (condition_code_id IS NOT NULL);


--
-- TOC entry 8523 (class 1259 OID 243246)
-- Name: cell_observation_hourly_derivation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_hourly_derivation_idx ON ONLY weather.cell_observation_hourly USING btree (derivation_run_id);


--
-- TOC entry 8539 (class 1259 OID 243277)
-- Name: cell_observation_hourly_default_derivation_run_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_hourly_default_derivation_run_id_idx ON weather.cell_observation_hourly_default USING btree (derivation_run_id);


--
-- TOC entry 8524 (class 1259 OID 243245)
-- Name: cell_observation_hourly_ingestion_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_hourly_ingestion_idx ON ONLY weather.cell_observation_hourly USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL);


--
-- TOC entry 8540 (class 1259 OID 243276)
-- Name: cell_observation_hourly_default_ingestion_run_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_hourly_default_ingestion_run_id_idx ON weather.cell_observation_hourly_default USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL);


--
-- TOC entry 8543 (class 1259 OID 243365)
-- Name: cell_observation_quality_exception_derivation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_quality_exception_derivation_idx ON weather.cell_observation_quality_exception USING btree (derivation_run_id) WHERE (derivation_run_id IS NOT NULL);


--
-- TOC entry 8544 (class 1259 OID 243364)
-- Name: cell_observation_quality_exception_flag_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_quality_exception_flag_idx ON weather.cell_observation_quality_exception USING btree (quality_flag_id);


--
-- TOC entry 8545 (class 1259 OID 243362)
-- Name: cell_observation_quality_exception_observation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_quality_exception_observation_idx ON weather.cell_observation_quality_exception USING btree (cell_observation_id, observation_time);


--
-- TOC entry 8550 (class 1259 OID 243363)
-- Name: cell_observation_quality_exception_variable_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_quality_exception_variable_idx ON weather.cell_observation_quality_exception USING btree (variable_id);


--
-- TOC entry 8619 (class 1259 OID 243924)
-- Name: cell_observation_value_derivation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_value_derivation_idx ON weather.cell_observation_value USING btree (derivation_run_id);


--
-- TOC entry 8620 (class 1259 OID 243923)
-- Name: cell_observation_value_ingestion_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_value_ingestion_idx ON weather.cell_observation_value USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL);


--
-- TOC entry 8621 (class 1259 OID 243921)
-- Name: cell_observation_value_observation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_value_observation_idx ON weather.cell_observation_value USING btree (cell_observation_id, observation_time);


--
-- TOC entry 8626 (class 1259 OID 243922)
-- Name: cell_observation_value_variable_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX cell_observation_value_variable_idx ON weather.cell_observation_value USING btree (variable_id, observation_time);


--
-- TOC entry 8627 (class 1259 OID 243957)
-- Name: condition_code_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX condition_code_active_idx ON weather.condition_code USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8628 (class 1259 OID 243956)
-- Name: condition_code_category_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX condition_code_category_idx ON weather.condition_code USING btree (category);


--
-- TOC entry 8822 (class 1259 OID 245350)
-- Name: consensus_definition_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX consensus_definition_active_idx ON weather.consensus_definition USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8825 (class 1259 OID 245351)
-- Name: consensus_definition_current_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX consensus_definition_current_idx ON weather.consensus_definition USING btree (is_current) WHERE (is_current = true);


--
-- TOC entry 8828 (class 1259 OID 245391)
-- Name: consensus_definition_member_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX consensus_definition_member_active_idx ON weather.consensus_definition_member USING btree (consensus_definition_id) WHERE (is_active = true);


--
-- TOC entry 8829 (class 1259 OID 245389)
-- Name: consensus_definition_member_definition_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX consensus_definition_member_definition_idx ON weather.consensus_definition_member USING btree (consensus_definition_id);


--
-- TOC entry 8832 (class 1259 OID 245390)
-- Name: consensus_definition_member_product_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX consensus_definition_member_product_idx ON weather.consensus_definition_member USING btree (forecast_product_id);


--
-- TOC entry 8347 (class 1259 OID 242197)
-- Name: dataset_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX dataset_active_idx ON weather.dataset USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8633 (class 1259 OID 243998)
-- Name: dataset_condition_mapping_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX dataset_condition_mapping_active_idx ON weather.dataset_condition_mapping USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8634 (class 1259 OID 243996)
-- Name: dataset_condition_mapping_condition_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX dataset_condition_mapping_condition_idx ON weather.dataset_condition_mapping USING btree (condition_code_id);


--
-- TOC entry 8635 (class 1259 OID 243995)
-- Name: dataset_condition_mapping_dataset_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX dataset_condition_mapping_dataset_idx ON weather.dataset_condition_mapping USING btree (dataset_version_id);


--
-- TOC entry 8638 (class 1259 OID 243997)
-- Name: dataset_condition_mapping_provider_code_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX dataset_condition_mapping_provider_code_idx ON weather.dataset_condition_mapping USING btree (dataset_version_id, provider_condition_code);


--
-- TOC entry 8352 (class 1259 OID 242195)
-- Name: dataset_provider_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX dataset_provider_idx ON weather.dataset USING btree (provider_id);


--
-- TOC entry 8353 (class 1259 OID 242196)
-- Name: dataset_type_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX dataset_type_idx ON weather.dataset USING btree (dataset_type);


--
-- TOC entry 8475 (class 1259 OID 242929)
-- Name: dataset_variable_mapping_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX dataset_variable_mapping_active_idx ON weather.dataset_variable_mapping USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8476 (class 1259 OID 242926)
-- Name: dataset_variable_mapping_dataset_version_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX dataset_variable_mapping_dataset_version_idx ON weather.dataset_variable_mapping USING btree (dataset_version_id);


--
-- TOC entry 8479 (class 1259 OID 242928)
-- Name: dataset_variable_mapping_provider_field_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX dataset_variable_mapping_provider_field_idx ON weather.dataset_variable_mapping USING btree (dataset_version_id, provider_field_name);


--
-- TOC entry 8482 (class 1259 OID 242927)
-- Name: dataset_variable_mapping_variable_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX dataset_variable_mapping_variable_idx ON weather.dataset_variable_mapping USING btree (variable_id);


--
-- TOC entry 8354 (class 1259 OID 242225)
-- Name: dataset_version_current_unique_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE UNIQUE INDEX dataset_version_current_unique_idx ON weather.dataset_version USING btree (dataset_id) WHERE (is_current = true);


--
-- TOC entry 8355 (class 1259 OID 242226)
-- Name: dataset_version_dataset_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX dataset_version_dataset_idx ON weather.dataset_version USING btree (dataset_id);


--
-- TOC entry 8371 (class 1259 OID 242324)
-- Name: derivation_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX derivation_active_idx ON weather.derivation USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8383 (class 1259 OID 242391)
-- Name: derivation_run_ingestion_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX derivation_run_ingestion_idx ON weather.derivation_run USING btree (ingestion_run_id);


--
-- TOC entry 8389 (class 1259 OID 242426)
-- Name: derivation_run_input_derivation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX derivation_run_input_derivation_idx ON weather.derivation_run_input USING btree (derivation_run_id);


--
-- TOC entry 8390 (class 1259 OID 242427)
-- Name: derivation_run_input_ingestion_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX derivation_run_input_ingestion_idx ON weather.derivation_run_input USING btree (ingestion_run_id);


--
-- TOC entry 8386 (class 1259 OID 242393)
-- Name: derivation_run_started_at_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX derivation_run_started_at_idx ON weather.derivation_run USING btree (started_at DESC);


--
-- TOC entry 8387 (class 1259 OID 242392)
-- Name: derivation_run_status_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX derivation_run_status_idx ON weather.derivation_run USING btree (status);


--
-- TOC entry 8388 (class 1259 OID 242390)
-- Name: derivation_run_version_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX derivation_run_version_idx ON weather.derivation_run USING btree (derivation_version_id);


--
-- TOC entry 8376 (class 1259 OID 242323)
-- Name: derivation_type_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX derivation_type_idx ON weather.derivation USING btree (derivation_type);


--
-- TOC entry 8377 (class 1259 OID 242355)
-- Name: derivation_version_current_unique_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE UNIQUE INDEX derivation_version_current_unique_idx ON weather.derivation_version USING btree (derivation_id) WHERE (is_current = true);


--
-- TOC entry 8378 (class 1259 OID 242356)
-- Name: derivation_version_derivation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX derivation_version_derivation_idx ON weather.derivation_version USING btree (derivation_id);


--
-- TOC entry 8768 (class 1259 OID 244916)
-- Name: ensemble_probability_summary_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX ensemble_probability_summary_idx ON weather.ensemble_probability USING btree (ensemble_summary_id, valid_time);


--
-- TOC entry 8769 (class 1259 OID 244917)
-- Name: ensemble_probability_threshold_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX ensemble_probability_threshold_idx ON weather.ensemble_probability USING btree (threshold_operator, threshold_value);


--
-- TOC entry 8750 (class 1259 OID 244828)
-- Name: ensemble_summary_cell_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX ensemble_summary_cell_time_idx ON ONLY weather.ensemble_summary USING btree (grid_cell_id, valid_time);


--
-- TOC entry 8753 (class 1259 OID 244831)
-- Name: ensemble_summary_product_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX ensemble_summary_product_time_idx ON ONLY weather.ensemble_summary USING btree (forecast_product_id, valid_time);


--
-- TOC entry 8758 (class 1259 OID 244856)
-- Name: ensemble_summary_default_forecast_product_id_valid_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX ensemble_summary_default_forecast_product_id_valid_time_idx ON weather.ensemble_summary_default USING btree (forecast_product_id, valid_time);


--
-- TOC entry 8754 (class 1259 OID 244829)
-- Name: ensemble_summary_run_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX ensemble_summary_run_time_idx ON ONLY weather.ensemble_summary USING btree (forecast_run_id, valid_time);


--
-- TOC entry 8761 (class 1259 OID 244854)
-- Name: ensemble_summary_default_forecast_run_id_valid_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX ensemble_summary_default_forecast_run_id_valid_time_idx ON weather.ensemble_summary_default USING btree (forecast_run_id, valid_time);


--
-- TOC entry 8762 (class 1259 OID 244853)
-- Name: ensemble_summary_default_grid_cell_id_valid_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX ensemble_summary_default_grid_cell_id_valid_time_idx ON weather.ensemble_summary_default USING btree (grid_cell_id, valid_time);


--
-- TOC entry 8757 (class 1259 OID 244830)
-- Name: ensemble_summary_variable_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX ensemble_summary_variable_time_idx ON ONLY weather.ensemble_summary USING btree (variable_id, valid_time);


--
-- TOC entry 8765 (class 1259 OID 244855)
-- Name: ensemble_summary_default_variable_id_valid_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX ensemble_summary_default_variable_id_valid_time_idx ON weather.ensemble_summary_default USING btree (variable_id, valid_time);


--
-- TOC entry 8710 (class 1259 OID 244529)
-- Name: forecast_member_one_control_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE UNIQUE INDEX forecast_member_one_control_idx ON weather.forecast_member USING btree (forecast_run_id) WHERE (is_control = true);


--
-- TOC entry 8711 (class 1259 OID 244528)
-- Name: forecast_member_one_deterministic_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE UNIQUE INDEX forecast_member_one_deterministic_idx ON weather.forecast_member USING btree (forecast_run_id) WHERE (is_deterministic = true);


--
-- TOC entry 8714 (class 1259 OID 244527)
-- Name: forecast_member_run_code_unique_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE UNIQUE INDEX forecast_member_run_code_unique_idx ON weather.forecast_member USING btree (forecast_run_id, member_code) WHERE (member_code IS NOT NULL);


--
-- TOC entry 8715 (class 1259 OID 244530)
-- Name: forecast_member_run_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_member_run_idx ON weather.forecast_member USING btree (forecast_run_id);


--
-- TOC entry 8716 (class 1259 OID 244526)
-- Name: forecast_member_run_number_unique_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE UNIQUE INDEX forecast_member_run_number_unique_idx ON weather.forecast_member USING btree (forecast_run_id, member_number) WHERE (member_number IS NOT NULL);


--
-- TOC entry 8717 (class 1259 OID 244531)
-- Name: forecast_member_type_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_member_type_idx ON weather.forecast_member USING btree (member_type);


--
-- TOC entry 8673 (class 1259 OID 244320)
-- Name: forecast_model_provider_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_model_provider_idx ON weather.forecast_model USING btree (provider_id);


--
-- TOC entry 8674 (class 1259 OID 244321)
-- Name: forecast_model_scope_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_model_scope_idx ON weather.forecast_model USING btree (model_scope);


--
-- TOC entry 8675 (class 1259 OID 244322)
-- Name: forecast_model_status_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_model_status_idx ON weather.forecast_model USING btree (operational_status);


--
-- TOC entry 8676 (class 1259 OID 244352)
-- Name: forecast_model_version_current_unique_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE UNIQUE INDEX forecast_model_version_current_unique_idx ON weather.forecast_model_version USING btree (forecast_model_id) WHERE (is_current = true);


--
-- TOC entry 8677 (class 1259 OID 244353)
-- Name: forecast_model_version_model_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_model_version_model_idx ON weather.forecast_model_version USING btree (forecast_model_id);


--
-- TOC entry 8682 (class 1259 OID 244407)
-- Name: forecast_product_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_product_active_idx ON weather.forecast_product USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8683 (class 1259 OID 244406)
-- Name: forecast_product_class_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_product_class_idx ON weather.forecast_product USING btree (forecast_class);


--
-- TOC entry 8686 (class 1259 OID 244404)
-- Name: forecast_product_dataset_version_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_product_dataset_version_idx ON weather.forecast_product USING btree (dataset_version_id);


--
-- TOC entry 8687 (class 1259 OID 244405)
-- Name: forecast_product_derivation_version_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_product_derivation_version_idx ON weather.forecast_product USING btree (derivation_version_id);


--
-- TOC entry 8688 (class 1259 OID 244403)
-- Name: forecast_product_model_version_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_product_model_version_idx ON weather.forecast_product USING btree (forecast_model_version_id);


--
-- TOC entry 8849 (class 1259 OID 245526)
-- Name: forecast_run_expectation_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_run_expectation_active_idx ON weather.forecast_run_expectation USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8691 (class 1259 OID 245573)
-- Name: forecast_run_expectation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_run_expectation_idx ON weather.forecast_run USING btree (forecast_run_expectation_id) WHERE (forecast_run_expectation_id IS NOT NULL);


--
-- TOC entry 8856 (class 1259 OID 245564)
-- Name: forecast_run_expectation_item_expectation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_run_expectation_item_expectation_idx ON weather.forecast_run_expectation_item USING btree (forecast_run_expectation_id);


--
-- TOC entry 8857 (class 1259 OID 245567)
-- Name: forecast_run_expectation_item_lead_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_run_expectation_item_lead_idx ON weather.forecast_run_expectation_item USING btree (lead_minutes) WHERE (lead_minutes IS NOT NULL);


--
-- TOC entry 8860 (class 1259 OID 245565)
-- Name: forecast_run_expectation_item_type_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_run_expectation_item_type_idx ON weather.forecast_run_expectation_item USING btree (item_type);


--
-- TOC entry 8861 (class 1259 OID 245566)
-- Name: forecast_run_expectation_item_variable_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_run_expectation_item_variable_idx ON weather.forecast_run_expectation_item USING btree (variable_id) WHERE (variable_id IS NOT NULL);


--
-- TOC entry 8852 (class 1259 OID 245525)
-- Name: forecast_run_expectation_model_version_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_run_expectation_model_version_idx ON weather.forecast_run_expectation USING btree (forecast_model_version_id);


--
-- TOC entry 8855 (class 1259 OID 245524)
-- Name: forecast_run_expectation_product_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_run_expectation_product_idx ON weather.forecast_run_expectation USING btree (forecast_product_id);


--
-- TOC entry 8702 (class 1259 OID 244491)
-- Name: forecast_run_ingestion_ingestion_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_run_ingestion_ingestion_idx ON weather.forecast_run_ingestion USING btree (ingestion_run_id);


--
-- TOC entry 8705 (class 1259 OID 244490)
-- Name: forecast_run_ingestion_run_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_run_ingestion_run_idx ON weather.forecast_run_ingestion USING btree (forecast_run_id);


--
-- TOC entry 8696 (class 1259 OID 244457)
-- Name: forecast_run_initialization_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_run_initialization_time_idx ON weather.forecast_run USING btree (initialization_time DESC);


--
-- TOC entry 8697 (class 1259 OID 244455)
-- Name: forecast_run_model_version_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_run_model_version_time_idx ON weather.forecast_run USING btree (forecast_model_version_id, initialization_time DESC);


--
-- TOC entry 8700 (class 1259 OID 244454)
-- Name: forecast_run_product_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_run_product_time_idx ON weather.forecast_run USING btree (forecast_product_id, initialization_time DESC);


--
-- TOC entry 8701 (class 1259 OID 244456)
-- Name: forecast_run_status_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_run_status_idx ON weather.forecast_run USING btree (run_status);


--
-- TOC entry 8803 (class 1259 OID 245240)
-- Name: forecast_verification_cell_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_verification_cell_time_idx ON weather.forecast_verification USING btree (grid_cell_id, forecast_valid_time);


--
-- TOC entry 8804 (class 1259 OID 245242)
-- Name: forecast_verification_definition_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_verification_definition_idx ON weather.forecast_verification USING btree (verification_definition_id);


--
-- TOC entry 8805 (class 1259 OID 245238)
-- Name: forecast_verification_forecast_product_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_verification_forecast_product_idx ON weather.forecast_verification USING btree (forecast_product_id);


--
-- TOC entry 8806 (class 1259 OID 245239)
-- Name: forecast_verification_observation_product_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_verification_observation_product_idx ON weather.forecast_verification USING btree (observation_product_id);


--
-- TOC entry 8809 (class 1259 OID 245237)
-- Name: forecast_verification_run_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_verification_run_idx ON weather.forecast_verification USING btree (forecast_run_id);


--
-- TOC entry 8814 (class 1259 OID 245312)
-- Name: forecast_verification_summary_cell_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_verification_summary_cell_idx ON weather.forecast_verification_summary USING btree (grid_cell_id) WHERE (grid_cell_id IS NOT NULL);


--
-- TOC entry 8815 (class 1259 OID 245315)
-- Name: forecast_verification_summary_definition_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_verification_summary_definition_idx ON weather.forecast_verification_summary USING btree (verification_definition_id);


--
-- TOC entry 8816 (class 1259 OID 245313)
-- Name: forecast_verification_summary_lead_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_verification_summary_lead_idx ON weather.forecast_verification_summary USING btree (lead_band_minutes_start, lead_band_minutes_end);


--
-- TOC entry 8817 (class 1259 OID 245311)
-- Name: forecast_verification_summary_observation_product_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_verification_summary_observation_product_idx ON weather.forecast_verification_summary USING btree (observation_product_id);


--
-- TOC entry 8818 (class 1259 OID 245314)
-- Name: forecast_verification_summary_period_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_verification_summary_period_idx ON weather.forecast_verification_summary USING btree (verification_period_start, verification_period_end);


--
-- TOC entry 8821 (class 1259 OID 245310)
-- Name: forecast_verification_summary_product_variable_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_verification_summary_product_variable_idx ON weather.forecast_verification_summary USING btree (forecast_product_id, variable_id);


--
-- TOC entry 8812 (class 1259 OID 245241)
-- Name: forecast_verification_variable_lead_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_verification_variable_lead_idx ON weather.forecast_verification USING btree (variable_id, lead_minutes);


--
-- TOC entry 8813 (class 1259 OID 245243)
-- Name: forecast_verification_verified_at_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX forecast_verification_verified_at_idx ON weather.forecast_verification USING btree (verified_at DESC);


--
-- TOC entry 8302 (class 1259 OID 242103)
-- Name: grid_cell_boundary_gix; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX grid_cell_boundary_gix ON weather.grid_cell USING gist (boundary);


--
-- TOC entry 8303 (class 1259 OID 225801)
-- Name: grid_cell_center_gix; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX grid_cell_center_gix ON weather.grid_cell USING gist (center);


--
-- TOC entry 8304 (class 1259 OID 225798)
-- Name: grid_cell_grid_system_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX grid_cell_grid_system_idx ON weather.grid_cell USING btree (grid_system_id);


--
-- TOC entry 8309 (class 1259 OID 225799)
-- Name: grid_cell_resolution_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX grid_cell_resolution_idx ON weather.grid_cell USING btree (resolution);


--
-- TOC entry 8297 (class 1259 OID 225762)
-- Name: grid_system_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX grid_system_active_idx ON weather.grid_system USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8365 (class 1259 OID 242292)
-- Name: ingestion_run_dataset_version_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX ingestion_run_dataset_version_idx ON weather.ingestion_run USING btree (dataset_version_id);


--
-- TOC entry 8368 (class 1259 OID 242293)
-- Name: ingestion_run_source_artifact_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX ingestion_run_source_artifact_idx ON weather.ingestion_run USING btree (source_artifact_id);


--
-- TOC entry 8369 (class 1259 OID 242295)
-- Name: ingestion_run_started_at_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX ingestion_run_started_at_idx ON weather.ingestion_run USING btree (started_at DESC);


--
-- TOC entry 8370 (class 1259 OID 242294)
-- Name: ingestion_run_status_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX ingestion_run_status_idx ON weather.ingestion_run USING btree (status);


--
-- TOC entry 8424 (class 1259 OID 242630)
-- Name: observation_product_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX observation_product_active_idx ON weather.observation_product USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8427 (class 1259 OID 243396)
-- Name: observation_product_daily_period_definition_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX observation_product_daily_period_definition_idx ON weather.observation_product USING btree (daily_period_definition_id);


--
-- TOC entry 8428 (class 1259 OID 242627)
-- Name: observation_product_dataset_version_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX observation_product_dataset_version_idx ON weather.observation_product USING btree (dataset_version_id);


--
-- TOC entry 8429 (class 1259 OID 242628)
-- Name: observation_product_derivation_version_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX observation_product_derivation_version_idx ON weather.observation_product USING btree (derivation_version_id);


--
-- TOC entry 8432 (class 1259 OID 242629)
-- Name: observation_product_type_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX observation_product_type_idx ON weather.observation_product USING btree (product_type);


--
-- TOC entry 8341 (class 1259 OID 242160)
-- Name: provider_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX provider_active_idx ON weather.provider USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8344 (class 1259 OID 242161)
-- Name: provider_lower_name_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX provider_lower_name_idx ON weather.provider USING btree (lower(name));


--
-- TOC entry 8360 (class 1259 OID 242256)
-- Name: source_artifact_checksum_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX source_artifact_checksum_idx ON weather.source_artifact USING btree (checksum_sha256) WHERE (checksum_sha256 IS NOT NULL);


--
-- TOC entry 8361 (class 1259 OID 242254)
-- Name: source_artifact_dataset_version_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX source_artifact_dataset_version_idx ON weather.source_artifact USING btree (dataset_version_id);


--
-- TOC entry 8364 (class 1259 OID 242255)
-- Name: source_artifact_provider_created_at_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX source_artifact_provider_created_at_idx ON weather.source_artifact USING btree (provider_created_at);


--
-- TOC entry 8401 (class 1259 OID 242482)
-- Name: station_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_active_idx ON weather.station USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8402 (class 1259 OID 242481)
-- Name: station_country_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_country_idx ON weather.station USING btree (country_code);


--
-- TOC entry 8433 (class 1259 OID 242664)
-- Name: station_h3_map_grid_cell_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_h3_map_grid_cell_idx ON weather.station_h3_map USING btree (grid_cell_id);


--
-- TOC entry 8436 (class 1259 OID 242663)
-- Name: station_h3_map_station_history_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_h3_map_station_history_idx ON weather.station_h3_map USING btree (station_history_id);


--
-- TOC entry 8417 (class 1259 OID 242556)
-- Name: station_history_position_gix; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_history_position_gix ON weather.station_history USING gist ("position");


--
-- TOC entry 8418 (class 1259 OID 242555)
-- Name: station_history_station_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_history_station_idx ON weather.station_history USING btree (station_id);


--
-- TOC entry 8419 (class 1259 OID 242557)
-- Name: station_history_validity_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_history_validity_idx ON weather.station_history USING btree (station_id, valid_from, valid_to);


--
-- TOC entry 8410 (class 1259 OID 242525)
-- Name: station_identifier_primary_unique_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE UNIQUE INDEX station_identifier_primary_unique_idx ON weather.station_identifier USING btree (station_id, identifier_scheme) WHERE (is_primary = true);


--
-- TOC entry 8411 (class 1259 OID 242524)
-- Name: station_identifier_scheme_value_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_identifier_scheme_value_idx ON weather.station_identifier USING btree (identifier_scheme, identifier_value);


--
-- TOC entry 8412 (class 1259 OID 242523)
-- Name: station_identifier_station_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_identifier_station_idx ON weather.station_identifier USING btree (station_id);


--
-- TOC entry 8403 (class 1259 OID 242483)
-- Name: station_lower_name_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_lower_name_idx ON weather.station USING btree (lower(canonical_name));


--
-- TOC entry 8395 (class 1259 OID 242458)
-- Name: station_network_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_network_active_idx ON weather.station_network USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8400 (class 1259 OID 242457)
-- Name: station_network_provider_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_network_provider_idx ON weather.station_network USING btree (provider_id);


--
-- TOC entry 8645 (class 1259 OID 244100)
-- Name: station_observation_correction_original_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_correction_original_idx ON weather.station_observation_correction USING btree (original_observation_id, original_observation_time);


--
-- TOC entry 8648 (class 1259 OID 244101)
-- Name: station_observation_correction_replacement_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_correction_replacement_idx ON weather.station_observation_correction USING btree (replacement_observation_id, replacement_observation_time);


--
-- TOC entry 8657 (class 1259 OID 244218)
-- Name: station_observation_daily_correction_original_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_correction_original_idx ON weather.station_observation_daily_correction USING btree (original_observation_daily_id, original_observation_date);


--
-- TOC entry 8660 (class 1259 OID 244219)
-- Name: station_observation_daily_correction_replacement_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_correction_replacement_idx ON weather.station_observation_daily_correction USING btree (replacement_observation_daily_id, replacement_observation_date);


--
-- TOC entry 8555 (class 1259 OID 243478)
-- Name: station_observation_daily_date_station_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_date_station_idx ON ONLY weather.station_observation_daily USING btree (observation_date, station_id);


--
-- TOC entry 8563 (class 1259 OID 243479)
-- Name: station_observation_daily_product_date_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_product_date_idx ON ONLY weather.station_observation_daily USING btree (observation_product_id, observation_date DESC);


--
-- TOC entry 8565 (class 1259 OID 243516)
-- Name: station_observation_daily_def_observation_product_id_observ_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_def_observation_product_id_observ_idx ON weather.station_observation_daily_default USING btree (observation_product_id, observation_date DESC);


--
-- TOC entry 8562 (class 1259 OID 243480)
-- Name: station_observation_daily_preferred_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_preferred_idx ON ONLY weather.station_observation_daily USING btree (station_id, observation_product_id, observation_date DESC) WHERE (is_preferred = true);


--
-- TOC entry 8566 (class 1259 OID 243517)
-- Name: station_observation_daily_def_station_id_observation_produc_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_def_station_id_observation_produc_idx ON weather.station_observation_daily_default USING btree (station_id, observation_product_id, observation_date DESC) WHERE (is_preferred = true);


--
-- TOC entry 8569 (class 1259 OID 243515)
-- Name: station_observation_daily_defau_observation_date_station_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_defau_observation_date_station_id_idx ON weather.station_observation_daily_default USING btree (observation_date, station_id);


--
-- TOC entry 8564 (class 1259 OID 243477)
-- Name: station_observation_daily_station_date_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_station_date_idx ON ONLY weather.station_observation_daily USING btree (station_id, observation_date DESC);


--
-- TOC entry 8570 (class 1259 OID 243514)
-- Name: station_observation_daily_defau_station_id_observation_date_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_defau_station_id_observation_date_idx ON weather.station_observation_daily_default USING btree (station_id, observation_date DESC);


--
-- TOC entry 8556 (class 1259 OID 243482)
-- Name: station_observation_daily_derivation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_derivation_idx ON ONLY weather.station_observation_daily USING btree (derivation_run_id) WHERE (derivation_run_id IS NOT NULL);


--
-- TOC entry 8571 (class 1259 OID 243519)
-- Name: station_observation_daily_default_derivation_run_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_default_derivation_run_id_idx ON weather.station_observation_daily_default USING btree (derivation_run_id) WHERE (derivation_run_id IS NOT NULL);


--
-- TOC entry 8557 (class 1259 OID 243481)
-- Name: station_observation_daily_ingestion_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_ingestion_idx ON ONLY weather.station_observation_daily USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL);


--
-- TOC entry 8572 (class 1259 OID 243518)
-- Name: station_observation_daily_default_ingestion_run_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_default_ingestion_run_id_idx ON weather.station_observation_daily_default USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL);


--
-- TOC entry 8595 (class 1259 OID 243766)
-- Name: station_observation_daily_quality_exception_derivation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_quality_exception_derivation_idx ON weather.station_observation_daily_quality_exception USING btree (derivation_run_id) WHERE (derivation_run_id IS NOT NULL);


--
-- TOC entry 8596 (class 1259 OID 243765)
-- Name: station_observation_daily_quality_exception_flag_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_quality_exception_flag_idx ON weather.station_observation_daily_quality_exception USING btree (quality_flag_id);


--
-- TOC entry 8597 (class 1259 OID 243763)
-- Name: station_observation_daily_quality_exception_observation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_quality_exception_observation_idx ON weather.station_observation_daily_quality_exception USING btree (station_observation_daily_id, observation_date);


--
-- TOC entry 8602 (class 1259 OID 243764)
-- Name: station_observation_daily_quality_exception_variable_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_daily_quality_exception_variable_idx ON weather.station_observation_daily_quality_exception USING btree (variable_id);


--
-- TOC entry 8487 (class 1259 OID 244007)
-- Name: station_observation_hourly_condition_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_hourly_condition_idx ON ONLY weather.station_observation_hourly USING btree (condition_code_id) WHERE (condition_code_id IS NOT NULL);


--
-- TOC entry 8495 (class 1259 OID 243029)
-- Name: station_observation_hourly_product_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_hourly_product_time_idx ON ONLY weather.station_observation_hourly USING btree (observation_product_id, observation_time DESC);


--
-- TOC entry 8498 (class 1259 OID 243059)
-- Name: station_observation_hourly_de_observation_product_id_observ_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_hourly_de_observation_product_id_observ_idx ON weather.station_observation_hourly_default USING btree (observation_product_id, observation_time DESC);


--
-- TOC entry 8494 (class 1259 OID 243030)
-- Name: station_observation_hourly_preferred_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_hourly_preferred_idx ON ONLY weather.station_observation_hourly USING btree (station_id, observation_product_id, observation_time DESC) WHERE (is_preferred = true);


--
-- TOC entry 8499 (class 1259 OID 243060)
-- Name: station_observation_hourly_de_station_id_observation_produc_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_hourly_de_station_id_observation_produc_idx ON weather.station_observation_hourly_default USING btree (station_id, observation_product_id, observation_time DESC) WHERE (is_preferred = true);


--
-- TOC entry 8497 (class 1259 OID 243028)
-- Name: station_observation_hourly_time_station_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_hourly_time_station_idx ON ONLY weather.station_observation_hourly USING btree (observation_time, station_id);


--
-- TOC entry 8502 (class 1259 OID 243058)
-- Name: station_observation_hourly_defa_observation_time_station_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_hourly_defa_observation_time_station_id_idx ON weather.station_observation_hourly_default USING btree (observation_time, station_id);


--
-- TOC entry 8496 (class 1259 OID 243027)
-- Name: station_observation_hourly_station_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_hourly_station_time_idx ON ONLY weather.station_observation_hourly USING btree (station_id, observation_time DESC);


--
-- TOC entry 8503 (class 1259 OID 243057)
-- Name: station_observation_hourly_defa_station_id_observation_time_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_hourly_defa_station_id_observation_time_idx ON weather.station_observation_hourly_default USING btree (station_id, observation_time DESC);


--
-- TOC entry 8504 (class 1259 OID 244008)
-- Name: station_observation_hourly_default_condition_code_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_hourly_default_condition_code_id_idx ON weather.station_observation_hourly_default USING btree (condition_code_id) WHERE (condition_code_id IS NOT NULL);


--
-- TOC entry 8488 (class 1259 OID 243032)
-- Name: station_observation_hourly_derivation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_hourly_derivation_idx ON ONLY weather.station_observation_hourly USING btree (derivation_run_id) WHERE (derivation_run_id IS NOT NULL);


--
-- TOC entry 8505 (class 1259 OID 243062)
-- Name: station_observation_hourly_default_derivation_run_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_hourly_default_derivation_run_id_idx ON weather.station_observation_hourly_default USING btree (derivation_run_id) WHERE (derivation_run_id IS NOT NULL);


--
-- TOC entry 8489 (class 1259 OID 243031)
-- Name: station_observation_hourly_ingestion_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_hourly_ingestion_idx ON ONLY weather.station_observation_hourly USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL);


--
-- TOC entry 8506 (class 1259 OID 243061)
-- Name: station_observation_hourly_default_ingestion_run_id_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_hourly_default_ingestion_run_id_idx ON weather.station_observation_hourly_default USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL);


--
-- TOC entry 8513 (class 1259 OID 243173)
-- Name: station_observation_quality_exception_derivation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_quality_exception_derivation_idx ON weather.station_observation_quality_exception USING btree (derivation_run_id) WHERE (derivation_run_id IS NOT NULL);


--
-- TOC entry 8514 (class 1259 OID 243172)
-- Name: station_observation_quality_exception_flag_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_quality_exception_flag_idx ON weather.station_observation_quality_exception USING btree (quality_flag_id);


--
-- TOC entry 8515 (class 1259 OID 243170)
-- Name: station_observation_quality_exception_observation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_quality_exception_observation_idx ON weather.station_observation_quality_exception USING btree (station_observation_id, observation_time);


--
-- TOC entry 8520 (class 1259 OID 243171)
-- Name: station_observation_quality_exception_variable_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_quality_exception_variable_idx ON weather.station_observation_quality_exception USING btree (variable_id);


--
-- TOC entry 8611 (class 1259 OID 243870)
-- Name: station_observation_value_derivation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_value_derivation_idx ON weather.station_observation_value USING btree (derivation_run_id) WHERE (derivation_run_id IS NOT NULL);


--
-- TOC entry 8612 (class 1259 OID 243869)
-- Name: station_observation_value_ingestion_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_value_ingestion_idx ON weather.station_observation_value USING btree (ingestion_run_id) WHERE (ingestion_run_id IS NOT NULL);


--
-- TOC entry 8613 (class 1259 OID 243867)
-- Name: station_observation_value_observation_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_value_observation_idx ON weather.station_observation_value USING btree (station_observation_id, observation_time);


--
-- TOC entry 8618 (class 1259 OID 243868)
-- Name: station_observation_value_variable_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_observation_value_variable_idx ON weather.station_observation_value USING btree (variable_id, observation_time);


--
-- TOC entry 8441 (class 1259 OID 242697)
-- Name: station_region_map_region_version_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_region_map_region_version_idx ON weather.station_region_map USING btree (region_version_id);


--
-- TOC entry 8442 (class 1259 OID 242696)
-- Name: station_region_map_station_history_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX station_region_map_station_history_idx ON weather.station_region_map USING btree (station_history_id);


--
-- TOC entry 8445 (class 1259 OID 242726)
-- Name: unit_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX unit_active_idx ON weather.unit USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8450 (class 1259 OID 242725)
-- Name: unit_quantity_type_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX unit_quantity_type_idx ON weather.unit USING btree (quantity_type);


--
-- TOC entry 8467 (class 1259 OID 242884)
-- Name: variable_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX variable_active_idx ON weather.variable USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8470 (class 1259 OID 242883)
-- Name: variable_core_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX variable_core_idx ON weather.variable USING btree (is_core) WHERE (is_core = true);


--
-- TOC entry 8473 (class 1259 OID 242881)
-- Name: variable_quantity_type_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX variable_quantity_type_idx ON weather.variable USING btree (quantity_type);


--
-- TOC entry 8474 (class 1259 OID 242882)
-- Name: variable_unit_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX variable_unit_idx ON weather.variable USING btree (canonical_unit_id);


--
-- TOC entry 8797 (class 1259 OID 245147)
-- Name: verification_definition_active_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX verification_definition_active_idx ON weather.verification_definition USING btree (is_active) WHERE (is_active = true);


--
-- TOC entry 8800 (class 1259 OID 245146)
-- Name: verification_definition_observation_product_idx; Type: INDEX; Schema: weather; Owner: postgres
--

CREATE INDEX verification_definition_observation_product_idx ON weather.verification_definition USING btree (observation_product_id);


--
-- TOC entry 8896 (class 0 OID 0)
-- Name: cell_forecast_default_derivation_run_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_forecast_derivation_idx ATTACH PARTITION weather.cell_forecast_default_derivation_run_id_idx;


--
-- TOC entry 8897 (class 0 OID 0)
-- Name: cell_forecast_default_forecast_member_id_valid_time_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_forecast_member_valid_time_idx ATTACH PARTITION weather.cell_forecast_default_forecast_member_id_valid_time_idx;


--
-- TOC entry 8898 (class 0 OID 0)
-- Name: cell_forecast_default_forecast_product_id_valid_time_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_forecast_product_valid_time_idx ATTACH PARTITION weather.cell_forecast_default_forecast_product_id_valid_time_idx;


--
-- TOC entry 8899 (class 0 OID 0)
-- Name: cell_forecast_default_forecast_run_id_forecast_member_id_fo_key; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_forecast_natural_revision_unique ATTACH PARTITION weather.cell_forecast_default_forecast_run_id_forecast_member_id_fo_key;


--
-- TOC entry 8900 (class 0 OID 0)
-- Name: cell_forecast_default_forecast_run_id_valid_time_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_forecast_run_valid_time_idx ATTACH PARTITION weather.cell_forecast_default_forecast_run_id_valid_time_idx;


--
-- TOC entry 8901 (class 0 OID 0)
-- Name: cell_forecast_default_grid_cell_id_forecast_product_id_vali_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_forecast_preferred_idx ATTACH PARTITION weather.cell_forecast_default_grid_cell_id_forecast_product_id_vali_idx;


--
-- TOC entry 8902 (class 0 OID 0)
-- Name: cell_forecast_default_grid_cell_id_valid_time_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_forecast_cell_valid_time_idx ATTACH PARTITION weather.cell_forecast_default_grid_cell_id_valid_time_idx;


--
-- TOC entry 8903 (class 0 OID 0)
-- Name: cell_forecast_default_ingestion_run_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_forecast_ingestion_idx ATTACH PARTITION weather.cell_forecast_default_ingestion_run_id_idx;


--
-- TOC entry 8904 (class 0 OID 0)
-- Name: cell_forecast_default_pkey; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_forecast_pkey ATTACH PARTITION weather.cell_forecast_default_pkey;


--
-- TOC entry 8905 (class 0 OID 0)
-- Name: cell_forecast_default_valid_time_grid_cell_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_forecast_valid_time_cell_idx ATTACH PARTITION weather.cell_forecast_default_valid_time_grid_cell_id_idx;


--
-- TOC entry 8888 (class 0 OID 0)
-- Name: cell_observation_daily_defaul_grid_cell_id_observation_date_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_daily_cell_date_idx ATTACH PARTITION weather.cell_observation_daily_defaul_grid_cell_id_observation_date_idx;


--
-- TOC entry 8889 (class 0 OID 0)
-- Name: cell_observation_daily_defaul_grid_cell_id_observation_prod_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_daily_preferred_idx ATTACH PARTITION weather.cell_observation_daily_defaul_grid_cell_id_observation_prod_idx;


--
-- TOC entry 8890 (class 0 OID 0)
-- Name: cell_observation_daily_defaul_grid_cell_id_observation_prod_key; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_daily_natural_revision_unique ATTACH PARTITION weather.cell_observation_daily_defaul_grid_cell_id_observation_prod_key;


--
-- TOC entry 8891 (class 0 OID 0)
-- Name: cell_observation_daily_defaul_observation_date_grid_cell_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_daily_date_cell_idx ATTACH PARTITION weather.cell_observation_daily_defaul_observation_date_grid_cell_id_idx;


--
-- TOC entry 8892 (class 0 OID 0)
-- Name: cell_observation_daily_defaul_observation_product_id_observ_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_daily_product_date_idx ATTACH PARTITION weather.cell_observation_daily_defaul_observation_product_id_observ_idx;


--
-- TOC entry 8893 (class 0 OID 0)
-- Name: cell_observation_daily_default_derivation_run_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_daily_derivation_idx ATTACH PARTITION weather.cell_observation_daily_default_derivation_run_id_idx;


--
-- TOC entry 8894 (class 0 OID 0)
-- Name: cell_observation_daily_default_ingestion_run_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_daily_ingestion_idx ATTACH PARTITION weather.cell_observation_daily_default_ingestion_run_id_idx;


--
-- TOC entry 8895 (class 0 OID 0)
-- Name: cell_observation_daily_default_pkey; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_daily_pkey ATTACH PARTITION weather.cell_observation_daily_default_pkey;


--
-- TOC entry 8871 (class 0 OID 0)
-- Name: cell_observation_hourly_defau_grid_cell_id_observation_prod_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_hourly_preferred_idx ATTACH PARTITION weather.cell_observation_hourly_defau_grid_cell_id_observation_prod_idx;


--
-- TOC entry 8872 (class 0 OID 0)
-- Name: cell_observation_hourly_defau_grid_cell_id_observation_prod_key; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_hourly_natural_revision_unique ATTACH PARTITION weather.cell_observation_hourly_defau_grid_cell_id_observation_prod_key;


--
-- TOC entry 8873 (class 0 OID 0)
-- Name: cell_observation_hourly_defau_grid_cell_id_observation_time_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_hourly_cell_time_idx ATTACH PARTITION weather.cell_observation_hourly_defau_grid_cell_id_observation_time_idx;


--
-- TOC entry 8874 (class 0 OID 0)
-- Name: cell_observation_hourly_defau_observation_product_id_observ_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_hourly_product_time_idx ATTACH PARTITION weather.cell_observation_hourly_defau_observation_product_id_observ_idx;


--
-- TOC entry 8875 (class 0 OID 0)
-- Name: cell_observation_hourly_defau_observation_time_grid_cell_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_hourly_time_cell_idx ATTACH PARTITION weather.cell_observation_hourly_defau_observation_time_grid_cell_id_idx;


--
-- TOC entry 8876 (class 0 OID 0)
-- Name: cell_observation_hourly_default_condition_code_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_hourly_condition_idx ATTACH PARTITION weather.cell_observation_hourly_default_condition_code_id_idx;


--
-- TOC entry 8877 (class 0 OID 0)
-- Name: cell_observation_hourly_default_derivation_run_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_hourly_derivation_idx ATTACH PARTITION weather.cell_observation_hourly_default_derivation_run_id_idx;


--
-- TOC entry 8878 (class 0 OID 0)
-- Name: cell_observation_hourly_default_ingestion_run_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_hourly_ingestion_idx ATTACH PARTITION weather.cell_observation_hourly_default_ingestion_run_id_idx;


--
-- TOC entry 8879 (class 0 OID 0)
-- Name: cell_observation_hourly_default_pkey; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.cell_observation_hourly_pkey ATTACH PARTITION weather.cell_observation_hourly_default_pkey;


--
-- TOC entry 8906 (class 0 OID 0)
-- Name: ensemble_summary_default_forecast_product_id_valid_time_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.ensemble_summary_product_time_idx ATTACH PARTITION weather.ensemble_summary_default_forecast_product_id_valid_time_idx;


--
-- TOC entry 8907 (class 0 OID 0)
-- Name: ensemble_summary_default_forecast_run_id_forecast_product_i_key; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.ensemble_summary_unique ATTACH PARTITION weather.ensemble_summary_default_forecast_run_id_forecast_product_i_key;


--
-- TOC entry 8908 (class 0 OID 0)
-- Name: ensemble_summary_default_forecast_run_id_valid_time_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.ensemble_summary_run_time_idx ATTACH PARTITION weather.ensemble_summary_default_forecast_run_id_valid_time_idx;


--
-- TOC entry 8909 (class 0 OID 0)
-- Name: ensemble_summary_default_grid_cell_id_valid_time_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.ensemble_summary_cell_time_idx ATTACH PARTITION weather.ensemble_summary_default_grid_cell_id_valid_time_idx;


--
-- TOC entry 8910 (class 0 OID 0)
-- Name: ensemble_summary_default_pkey; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.ensemble_summary_pkey ATTACH PARTITION weather.ensemble_summary_default_pkey;


--
-- TOC entry 8911 (class 0 OID 0)
-- Name: ensemble_summary_default_variable_id_valid_time_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.ensemble_summary_variable_time_idx ATTACH PARTITION weather.ensemble_summary_default_variable_id_valid_time_idx;


--
-- TOC entry 8880 (class 0 OID 0)
-- Name: station_observation_daily_def_observation_product_id_observ_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_daily_product_date_idx ATTACH PARTITION weather.station_observation_daily_def_observation_product_id_observ_idx;


--
-- TOC entry 8881 (class 0 OID 0)
-- Name: station_observation_daily_def_station_id_observation_produc_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_daily_preferred_idx ATTACH PARTITION weather.station_observation_daily_def_station_id_observation_produc_idx;


--
-- TOC entry 8882 (class 0 OID 0)
-- Name: station_observation_daily_def_station_id_observation_produc_key; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_daily_natural_revision_unique ATTACH PARTITION weather.station_observation_daily_def_station_id_observation_produc_key;


--
-- TOC entry 8883 (class 0 OID 0)
-- Name: station_observation_daily_defau_observation_date_station_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_daily_date_station_idx ATTACH PARTITION weather.station_observation_daily_defau_observation_date_station_id_idx;


--
-- TOC entry 8884 (class 0 OID 0)
-- Name: station_observation_daily_defau_station_id_observation_date_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_daily_station_date_idx ATTACH PARTITION weather.station_observation_daily_defau_station_id_observation_date_idx;


--
-- TOC entry 8885 (class 0 OID 0)
-- Name: station_observation_daily_default_derivation_run_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_daily_derivation_idx ATTACH PARTITION weather.station_observation_daily_default_derivation_run_id_idx;


--
-- TOC entry 8886 (class 0 OID 0)
-- Name: station_observation_daily_default_ingestion_run_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_daily_ingestion_idx ATTACH PARTITION weather.station_observation_daily_default_ingestion_run_id_idx;


--
-- TOC entry 8887 (class 0 OID 0)
-- Name: station_observation_daily_default_pkey; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_daily_pkey ATTACH PARTITION weather.station_observation_daily_default_pkey;


--
-- TOC entry 8862 (class 0 OID 0)
-- Name: station_observation_hourly_de_observation_product_id_observ_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_hourly_product_time_idx ATTACH PARTITION weather.station_observation_hourly_de_observation_product_id_observ_idx;


--
-- TOC entry 8863 (class 0 OID 0)
-- Name: station_observation_hourly_de_station_id_observation_produc_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_hourly_preferred_idx ATTACH PARTITION weather.station_observation_hourly_de_station_id_observation_produc_idx;


--
-- TOC entry 8864 (class 0 OID 0)
-- Name: station_observation_hourly_de_station_id_observation_produc_key; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_hourly_natural_revision_unique ATTACH PARTITION weather.station_observation_hourly_de_station_id_observation_produc_key;


--
-- TOC entry 8865 (class 0 OID 0)
-- Name: station_observation_hourly_defa_observation_time_station_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_hourly_time_station_idx ATTACH PARTITION weather.station_observation_hourly_defa_observation_time_station_id_idx;


--
-- TOC entry 8866 (class 0 OID 0)
-- Name: station_observation_hourly_defa_station_id_observation_time_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_hourly_station_time_idx ATTACH PARTITION weather.station_observation_hourly_defa_station_id_observation_time_idx;


--
-- TOC entry 8867 (class 0 OID 0)
-- Name: station_observation_hourly_default_condition_code_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_hourly_condition_idx ATTACH PARTITION weather.station_observation_hourly_default_condition_code_id_idx;


--
-- TOC entry 8868 (class 0 OID 0)
-- Name: station_observation_hourly_default_derivation_run_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_hourly_derivation_idx ATTACH PARTITION weather.station_observation_hourly_default_derivation_run_id_idx;


--
-- TOC entry 8869 (class 0 OID 0)
-- Name: station_observation_hourly_default_ingestion_run_id_idx; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_hourly_ingestion_idx ATTACH PARTITION weather.station_observation_hourly_default_ingestion_run_id_idx;


--
-- TOC entry 8870 (class 0 OID 0)
-- Name: station_observation_hourly_default_pkey; Type: INDEX ATTACH; Schema: weather; Owner: postgres
--

ALTER INDEX weather.station_observation_hourly_pkey ATTACH PARTITION weather.station_observation_hourly_default_pkey;


--
-- TOC entry 8920 (class 2606 OID 242125)
-- Name: airports airports_location_id_canonical_fkey; Type: FK CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.airports
    ADD CONSTRAINT airports_location_id_canonical_fkey FOREIGN KEY (location_id) REFERENCES geo.location(location_id) ON DELETE CASCADE;


--
-- TOC entry 8929 (class 2606 OID 225821)
-- Name: location_cell_map location_cell_map_grid_cell_fkey; Type: FK CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.location_cell_map
    ADD CONSTRAINT location_cell_map_grid_cell_fkey FOREIGN KEY (grid_cell_id) REFERENCES weather.grid_cell(grid_cell_id) ON DELETE CASCADE;


--
-- TOC entry 8930 (class 2606 OID 225816)
-- Name: location_cell_map location_cell_map_location_fkey; Type: FK CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.location_cell_map
    ADD CONSTRAINT location_cell_map_location_fkey FOREIGN KEY (location_id) REFERENCES geo.location(location_id) ON DELETE CASCADE;


--
-- TOC entry 8922 (class 2606 OID 225539)
-- Name: location_identifier location_identifier_location_fkey; Type: FK CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.location_identifier
    ADD CONSTRAINT location_identifier_location_fkey FOREIGN KEY (location_id) REFERENCES geo.location(location_id) ON DELETE CASCADE;


--
-- TOC entry 8931 (class 2606 OID 225846)
-- Name: region_cell_map region_cell_map_grid_cell_fkey; Type: FK CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_cell_map
    ADD CONSTRAINT region_cell_map_grid_cell_fkey FOREIGN KEY (grid_cell_id) REFERENCES weather.grid_cell(grid_cell_id) ON DELETE CASCADE;


--
-- TOC entry 8932 (class 2606 OID 225841)
-- Name: region_cell_map region_cell_map_region_version_fkey; Type: FK CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_cell_map
    ADD CONSTRAINT region_cell_map_region_version_fkey FOREIGN KEY (region_version_id) REFERENCES geo.region_version(region_version_id) ON DELETE CASCADE;


--
-- TOC entry 8925 (class 2606 OID 225689)
-- Name: region_identifier region_identifier_region_fkey; Type: FK CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_identifier
    ADD CONSTRAINT region_identifier_region_fkey FOREIGN KEY (region_id) REFERENCES geo.region(region_id) ON DELETE CASCADE;


--
-- TOC entry 8924 (class 2606 OID 225654)
-- Name: region region_region_type_fkey; Type: FK CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region
    ADD CONSTRAINT region_region_type_fkey FOREIGN KEY (region_type_id) REFERENCES geo.region_type(region_type_id) ON DELETE RESTRICT;


--
-- TOC entry 8933 (class 2606 OID 229280)
-- Name: region_relationship region_relationship_child_fkey; Type: FK CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_relationship
    ADD CONSTRAINT region_relationship_child_fkey FOREIGN KEY (child_region_id) REFERENCES geo.region(region_id) ON DELETE CASCADE;


--
-- TOC entry 8934 (class 2606 OID 229285)
-- Name: region_relationship region_relationship_dataset_version_fkey; Type: FK CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_relationship
    ADD CONSTRAINT region_relationship_dataset_version_fkey FOREIGN KEY (spatial_dataset_version_id) REFERENCES geo.spatial_dataset_version(spatial_dataset_version_id) ON DELETE RESTRICT;


--
-- TOC entry 8935 (class 2606 OID 229275)
-- Name: region_relationship region_relationship_parent_fkey; Type: FK CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_relationship
    ADD CONSTRAINT region_relationship_parent_fkey FOREIGN KEY (parent_region_id) REFERENCES geo.region(region_id) ON DELETE CASCADE;


--
-- TOC entry 8926 (class 2606 OID 225726)
-- Name: region_version region_version_dataset_version_fkey; Type: FK CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_version
    ADD CONSTRAINT region_version_dataset_version_fkey FOREIGN KEY (spatial_dataset_version_id) REFERENCES geo.spatial_dataset_version(spatial_dataset_version_id) ON DELETE RESTRICT;


--
-- TOC entry 8927 (class 2606 OID 225721)
-- Name: region_version region_version_region_fkey; Type: FK CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.region_version
    ADD CONSTRAINT region_version_region_fkey FOREIGN KEY (region_id) REFERENCES geo.region(region_id) ON DELETE CASCADE;


--
-- TOC entry 8923 (class 2606 OID 225598)
-- Name: spatial_dataset_version spatial_dataset_version_dataset_fkey; Type: FK CONSTRAINT; Schema: geo; Owner: postgres
--

ALTER TABLE ONLY geo.spatial_dataset_version
    ADD CONSTRAINT spatial_dataset_version_dataset_fkey FOREIGN KEY (spatial_dataset_id) REFERENCES geo.spatial_dataset(spatial_dataset_id) ON DELETE RESTRICT;


--
-- TOC entry 8921 (class 2606 OID 242130)
-- Name: assets assets_location_id_canonical_fkey; Type: FK CONSTRAINT; Schema: mining; Owner: postgres
--

ALTER TABLE ONLY mining.assets
    ADD CONSTRAINT assets_location_id_canonical_fkey FOREIGN KEY (location_id) REFERENCES geo.location(location_id) ON DELETE CASCADE;


--
-- TOC entry 8917 (class 2606 OID 32855)
-- Name: strategic_point_grid_map strategic_point_grid_map_grid_point_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.strategic_point_grid_map
    ADD CONSTRAINT strategic_point_grid_map_grid_point_id_fkey FOREIGN KEY (grid_point_id) REFERENCES public.weather_grid_point(id) ON DELETE CASCADE;


--
-- TOC entry 8918 (class 2606 OID 32850)
-- Name: strategic_point_grid_map strategic_point_grid_map_strategic_point_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.strategic_point_grid_map
    ADD CONSTRAINT strategic_point_grid_map_strategic_point_id_fkey FOREIGN KEY (strategic_point_id) REFERENCES public.strategic_point(id) ON DELETE CASCADE;


--
-- TOC entry 8914 (class 2606 OID 24916)
-- Name: weather_climatology_daily weather_climatology_daily_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_climatology_daily
    ADD CONSTRAINT weather_climatology_daily_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.weather_location(id) ON DELETE CASCADE;


--
-- TOC entry 8912 (class 2606 OID 24891)
-- Name: weather_forecast_value weather_forecast_value_forecast_run_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_forecast_value
    ADD CONSTRAINT weather_forecast_value_forecast_run_id_fkey FOREIGN KEY (forecast_run_id) REFERENCES public.weather_forecast_run(id) ON DELETE CASCADE;


--
-- TOC entry 8913 (class 2606 OID 24896)
-- Name: weather_forecast_value weather_forecast_value_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_forecast_value
    ADD CONSTRAINT weather_forecast_value_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.weather_location(id) ON DELETE CASCADE;


--
-- TOC entry 8916 (class 2606 OID 24956)
-- Name: weather_gas_signal weather_gas_signal_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_gas_signal
    ADD CONSTRAINT weather_gas_signal_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.weather_location(id) ON DELETE CASCADE;


--
-- TOC entry 8915 (class 2606 OID 24938)
-- Name: weather_ingestion_run weather_ingestion_run_location_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_ingestion_run
    ADD CONSTRAINT weather_ingestion_run_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.weather_location(id) ON DELETE SET NULL;


--
-- TOC entry 8919 (class 2606 OID 40978)
-- Name: weather_observation weather_observation_grid_point_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: postgres
--

ALTER TABLE ONLY public.weather_observation
    ADD CONSTRAINT weather_observation_grid_point_id_fkey FOREIGN KEY (grid_point_id) REFERENCES public.weather_grid_point(id) ON DELETE CASCADE;


--
-- TOC entry 9106 (class 2606 OID 245444)
-- Name: bias_correction_definition bias_correction_definition_derivation_version_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.bias_correction_definition
    ADD CONSTRAINT bias_correction_definition_derivation_version_fkey FOREIGN KEY (derivation_version_id) REFERENCES weather.derivation_version(derivation_version_id) ON DELETE RESTRICT;


--
-- TOC entry 9107 (class 2606 OID 245439)
-- Name: bias_correction_definition bias_correction_definition_observation_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.bias_correction_definition
    ADD CONSTRAINT bias_correction_definition_observation_product_fkey FOREIGN KEY (training_observation_product_id) REFERENCES weather.observation_product(observation_product_id) ON DELETE RESTRICT;


--
-- TOC entry 9108 (class 2606 OID 245434)
-- Name: bias_correction_definition bias_correction_definition_variable_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.bias_correction_definition
    ADD CONSTRAINT bias_correction_definition_variable_fkey FOREIGN KEY (target_variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT;


--
-- TOC entry 9109 (class 2606 OID 245475)
-- Name: bias_correction_input_product bias_correction_input_product_definition_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.bias_correction_input_product
    ADD CONSTRAINT bias_correction_input_product_definition_fkey FOREIGN KEY (bias_correction_definition_id) REFERENCES weather.bias_correction_definition(bias_correction_definition_id) ON DELETE CASCADE;


--
-- TOC entry 9110 (class 2606 OID 245480)
-- Name: bias_correction_input_product bias_correction_input_product_forecast_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.bias_correction_input_product
    ADD CONSTRAINT bias_correction_input_product_forecast_product_fkey FOREIGN KEY (forecast_product_id) REFERENCES weather.forecast_product(forecast_product_id) ON DELETE RESTRICT;


--
-- TOC entry 9055 (class 2606 OID 244607)
-- Name: cell_forecast cell_forecast_condition_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_forecast
    ADD CONSTRAINT cell_forecast_condition_fkey FOREIGN KEY (condition_code_id) REFERENCES weather.condition_code(condition_code_id) ON DELETE RESTRICT;


--
-- TOC entry 9077 (class 2606 OID 244990)
-- Name: cell_forecast_correction cell_forecast_correction_artifact_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_correction
    ADD CONSTRAINT cell_forecast_correction_artifact_fkey FOREIGN KEY (source_artifact_id) REFERENCES weather.source_artifact(source_artifact_id) ON DELETE RESTRICT;


--
-- TOC entry 9078 (class 2606 OID 245000)
-- Name: cell_forecast_correction cell_forecast_correction_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_correction
    ADD CONSTRAINT cell_forecast_correction_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9079 (class 2606 OID 244995)
-- Name: cell_forecast_correction cell_forecast_correction_ingestion_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_correction
    ADD CONSTRAINT cell_forecast_correction_ingestion_fkey FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9080 (class 2606 OID 244969)
-- Name: cell_forecast_correction cell_forecast_correction_original_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_correction
    ADD CONSTRAINT cell_forecast_correction_original_fkey FOREIGN KEY (original_cell_forecast_id, original_valid_time) REFERENCES weather.cell_forecast(cell_forecast_id, valid_time) ON DELETE RESTRICT;


--
-- TOC entry 9081 (class 2606 OID 244985)
-- Name: cell_forecast_correction cell_forecast_correction_reason_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_correction
    ADD CONSTRAINT cell_forecast_correction_reason_fkey FOREIGN KEY (forecast_correction_reason_id) REFERENCES weather.forecast_correction_reason(forecast_correction_reason_id) ON DELETE RESTRICT;


--
-- TOC entry 9082 (class 2606 OID 244977)
-- Name: cell_forecast_correction cell_forecast_correction_replacement_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_correction
    ADD CONSTRAINT cell_forecast_correction_replacement_fkey FOREIGN KEY (replacement_cell_forecast_id, replacement_valid_time) REFERENCES weather.cell_forecast(cell_forecast_id, valid_time) ON DELETE RESTRICT;


--
-- TOC entry 9056 (class 2606 OID 244602)
-- Name: cell_forecast cell_forecast_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_forecast
    ADD CONSTRAINT cell_forecast_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9057 (class 2606 OID 244587)
-- Name: cell_forecast cell_forecast_grid_cell_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_forecast
    ADD CONSTRAINT cell_forecast_grid_cell_fkey FOREIGN KEY (grid_cell_id) REFERENCES weather.grid_cell(grid_cell_id) ON DELETE RESTRICT;


--
-- TOC entry 9058 (class 2606 OID 244597)
-- Name: cell_forecast cell_forecast_ingestion_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_forecast
    ADD CONSTRAINT cell_forecast_ingestion_fkey FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9059 (class 2606 OID 244577)
-- Name: cell_forecast cell_forecast_member_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_forecast
    ADD CONSTRAINT cell_forecast_member_fkey FOREIGN KEY (forecast_member_id) REFERENCES weather.forecast_member(forecast_member_id) ON DELETE RESTRICT;


--
-- TOC entry 9060 (class 2606 OID 244614)
-- Name: cell_forecast cell_forecast_member_run_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_forecast
    ADD CONSTRAINT cell_forecast_member_run_fkey FOREIGN KEY (forecast_member_id, forecast_run_id) REFERENCES weather.forecast_member(forecast_member_id, forecast_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9061 (class 2606 OID 244582)
-- Name: cell_forecast cell_forecast_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_forecast
    ADD CONSTRAINT cell_forecast_product_fkey FOREIGN KEY (forecast_product_id) REFERENCES weather.forecast_product(forecast_product_id) ON DELETE RESTRICT;


--
-- TOC entry 9083 (class 2606 OID 245074)
-- Name: cell_forecast_revision cell_forecast_revision_comparison_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_revision
    ADD CONSTRAINT cell_forecast_revision_comparison_fkey FOREIGN KEY (comparison_cell_forecast_id, comparison_valid_time) REFERENCES weather.cell_forecast(cell_forecast_id, valid_time) ON DELETE RESTRICT;


--
-- TOC entry 9084 (class 2606 OID 245069)
-- Name: cell_forecast_revision cell_forecast_revision_definition_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_revision
    ADD CONSTRAINT cell_forecast_revision_definition_fkey FOREIGN KEY (forecast_revision_definition_id) REFERENCES weather.forecast_revision_definition(forecast_revision_definition_id) ON DELETE RESTRICT;


--
-- TOC entry 9085 (class 2606 OID 245095)
-- Name: cell_forecast_revision cell_forecast_revision_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_revision
    ADD CONSTRAINT cell_forecast_revision_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9086 (class 2606 OID 245082)
-- Name: cell_forecast_revision cell_forecast_revision_newer_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_revision
    ADD CONSTRAINT cell_forecast_revision_newer_fkey FOREIGN KEY (newer_cell_forecast_id, newer_valid_time) REFERENCES weather.cell_forecast(cell_forecast_id, valid_time) ON DELETE RESTRICT;


--
-- TOC entry 9087 (class 2606 OID 245090)
-- Name: cell_forecast_revision cell_forecast_revision_variable_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_revision
    ADD CONSTRAINT cell_forecast_revision_variable_fkey FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT;


--
-- TOC entry 9062 (class 2606 OID 244572)
-- Name: cell_forecast cell_forecast_run_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_forecast
    ADD CONSTRAINT cell_forecast_run_fkey FOREIGN KEY (forecast_run_id) REFERENCES weather.forecast_run(forecast_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9063 (class 2606 OID 245578)
-- Name: cell_forecast cell_forecast_run_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_forecast
    ADD CONSTRAINT cell_forecast_run_product_fkey FOREIGN KEY (forecast_run_id, forecast_product_id) REFERENCES weather.forecast_run(forecast_run_id, forecast_product_id) ON DELETE RESTRICT;


--
-- TOC entry 9064 (class 2606 OID 244592)
-- Name: cell_forecast cell_forecast_status_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_forecast
    ADD CONSTRAINT cell_forecast_status_fkey FOREIGN KEY (observation_record_status_id) REFERENCES weather.observation_record_status(observation_record_status_id) ON DELETE RESTRICT;


--
-- TOC entry 9065 (class 2606 OID 244619)
-- Name: cell_forecast cell_forecast_supersedes_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_forecast
    ADD CONSTRAINT cell_forecast_supersedes_fkey FOREIGN KEY (supersedes_cell_forecast_id, supersedes_valid_time) REFERENCES weather.cell_forecast(cell_forecast_id, valid_time) ON DELETE RESTRICT;


--
-- TOC entry 9066 (class 2606 OID 244762)
-- Name: cell_forecast_value cell_forecast_value_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_value
    ADD CONSTRAINT cell_forecast_value_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9067 (class 2606 OID 244739)
-- Name: cell_forecast_value cell_forecast_value_forecast_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_value
    ADD CONSTRAINT cell_forecast_value_forecast_fkey FOREIGN KEY (cell_forecast_id, valid_time) REFERENCES weather.cell_forecast(cell_forecast_id, valid_time) ON DELETE CASCADE;


--
-- TOC entry 9068 (class 2606 OID 244757)
-- Name: cell_forecast_value cell_forecast_value_ingestion_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_value
    ADD CONSTRAINT cell_forecast_value_ingestion_fkey FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9069 (class 2606 OID 244752)
-- Name: cell_forecast_value cell_forecast_value_status_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_value
    ADD CONSTRAINT cell_forecast_value_status_fkey FOREIGN KEY (observation_record_status_id) REFERENCES weather.observation_record_status(observation_record_status_id) ON DELETE RESTRICT;


--
-- TOC entry 9070 (class 2606 OID 244747)
-- Name: cell_forecast_value cell_forecast_value_variable_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_forecast_value
    ADD CONSTRAINT cell_forecast_value_variable_fkey FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT;


--
-- TOC entry 9029 (class 2606 OID 244149)
-- Name: cell_observation_correction cell_observation_correction_artifact_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_correction
    ADD CONSTRAINT cell_observation_correction_artifact_fkey FOREIGN KEY (source_artifact_id) REFERENCES weather.source_artifact(source_artifact_id) ON DELETE RESTRICT;


--
-- TOC entry 9030 (class 2606 OID 244154)
-- Name: cell_observation_correction cell_observation_correction_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_correction
    ADD CONSTRAINT cell_observation_correction_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9031 (class 2606 OID 244128)
-- Name: cell_observation_correction cell_observation_correction_original_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_correction
    ADD CONSTRAINT cell_observation_correction_original_fkey FOREIGN KEY (original_observation_id, original_observation_time) REFERENCES weather.cell_observation_hourly(cell_observation_id, observation_time) ON DELETE RESTRICT;


--
-- TOC entry 9032 (class 2606 OID 244144)
-- Name: cell_observation_correction cell_observation_correction_reason_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_correction
    ADD CONSTRAINT cell_observation_correction_reason_fkey FOREIGN KEY (observation_correction_reason_id) REFERENCES weather.observation_correction_reason(observation_correction_reason_id) ON DELETE RESTRICT;


--
-- TOC entry 9033 (class 2606 OID 244136)
-- Name: cell_observation_correction cell_observation_correction_replacement_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_correction
    ADD CONSTRAINT cell_observation_correction_replacement_fkey FOREIGN KEY (replacement_observation_id, replacement_observation_time) REFERENCES weather.cell_observation_hourly(cell_observation_id, observation_time) ON DELETE RESTRICT;


--
-- TOC entry 9039 (class 2606 OID 244269)
-- Name: cell_observation_daily_correction cell_observation_daily_correction_artifact_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily_correction
    ADD CONSTRAINT cell_observation_daily_correction_artifact_fkey FOREIGN KEY (source_artifact_id) REFERENCES weather.source_artifact(source_artifact_id) ON DELETE RESTRICT;


--
-- TOC entry 9040 (class 2606 OID 244274)
-- Name: cell_observation_daily_correction cell_observation_daily_correction_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily_correction
    ADD CONSTRAINT cell_observation_daily_correction_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9041 (class 2606 OID 244248)
-- Name: cell_observation_daily_correction cell_observation_daily_correction_original_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily_correction
    ADD CONSTRAINT cell_observation_daily_correction_original_fkey FOREIGN KEY (original_observation_daily_id, original_observation_date) REFERENCES weather.cell_observation_daily(cell_observation_daily_id, observation_date) ON DELETE RESTRICT;


--
-- TOC entry 9042 (class 2606 OID 244264)
-- Name: cell_observation_daily_correction cell_observation_daily_correction_reason_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily_correction
    ADD CONSTRAINT cell_observation_daily_correction_reason_fkey FOREIGN KEY (observation_correction_reason_id) REFERENCES weather.observation_correction_reason(observation_correction_reason_id) ON DELETE RESTRICT;


--
-- TOC entry 9043 (class 2606 OID 244256)
-- Name: cell_observation_daily_correction cell_observation_daily_correction_replacement_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily_correction
    ADD CONSTRAINT cell_observation_daily_correction_replacement_fkey FOREIGN KEY (replacement_observation_daily_id, replacement_observation_date) REFERENCES weather.cell_observation_daily(cell_observation_daily_id, observation_date) ON DELETE RESTRICT;


--
-- TOC entry 8998 (class 2606 OID 243624)
-- Name: cell_observation_daily cell_observation_daily_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_daily
    ADD CONSTRAINT cell_observation_daily_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 8999 (class 2606 OID 243604)
-- Name: cell_observation_daily cell_observation_daily_grid_cell_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_daily
    ADD CONSTRAINT cell_observation_daily_grid_cell_fkey FOREIGN KEY (grid_cell_id) REFERENCES weather.grid_cell(grid_cell_id) ON DELETE RESTRICT;


--
-- TOC entry 9000 (class 2606 OID 243619)
-- Name: cell_observation_daily cell_observation_daily_ingestion_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_daily
    ADD CONSTRAINT cell_observation_daily_ingestion_fkey FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9001 (class 2606 OID 243609)
-- Name: cell_observation_daily cell_observation_daily_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_daily
    ADD CONSTRAINT cell_observation_daily_product_fkey FOREIGN KEY (observation_product_id) REFERENCES weather.observation_product(observation_product_id) ON DELETE RESTRICT;


--
-- TOC entry 9008 (class 2606 OID 243809)
-- Name: cell_observation_daily_quality_exception cell_observation_daily_quality_exception_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily_quality_exception
    ADD CONSTRAINT cell_observation_daily_quality_exception_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9009 (class 2606 OID 243804)
-- Name: cell_observation_daily_quality_exception cell_observation_daily_quality_exception_flag_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily_quality_exception
    ADD CONSTRAINT cell_observation_daily_quality_exception_flag_fkey FOREIGN KEY (quality_flag_id) REFERENCES weather.quality_flag(quality_flag_id) ON DELETE RESTRICT;


--
-- TOC entry 9010 (class 2606 OID 243791)
-- Name: cell_observation_daily_quality_exception cell_observation_daily_quality_exception_observation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily_quality_exception
    ADD CONSTRAINT cell_observation_daily_quality_exception_observation_fkey FOREIGN KEY (cell_observation_daily_id, observation_date) REFERENCES weather.cell_observation_daily(cell_observation_daily_id, observation_date) ON DELETE CASCADE;


--
-- TOC entry 9011 (class 2606 OID 243799)
-- Name: cell_observation_daily_quality_exception cell_observation_daily_quality_exception_variable_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_daily_quality_exception
    ADD CONSTRAINT cell_observation_daily_quality_exception_variable_fkey FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT;


--
-- TOC entry 9002 (class 2606 OID 243614)
-- Name: cell_observation_daily cell_observation_daily_status_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_daily
    ADD CONSTRAINT cell_observation_daily_status_fkey FOREIGN KEY (observation_record_status_id) REFERENCES weather.observation_record_status(observation_record_status_id) ON DELETE RESTRICT;


--
-- TOC entry 9003 (class 2606 OID 243629)
-- Name: cell_observation_daily cell_observation_daily_supersedes_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_daily
    ADD CONSTRAINT cell_observation_daily_supersedes_fkey FOREIGN KEY (supersedes_observation_daily_id, supersedes_observation_date) REFERENCES weather.cell_observation_daily(cell_observation_daily_id, observation_date) ON DELETE RESTRICT;


--
-- TOC entry 8980 (class 2606 OID 244010)
-- Name: cell_observation_hourly cell_observation_hourly_condition_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_hourly
    ADD CONSTRAINT cell_observation_hourly_condition_fkey FOREIGN KEY (condition_code_id) REFERENCES weather.condition_code(condition_code_id) ON DELETE RESTRICT;


--
-- TOC entry 8981 (class 2606 OID 243231)
-- Name: cell_observation_hourly cell_observation_hourly_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_hourly
    ADD CONSTRAINT cell_observation_hourly_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 8982 (class 2606 OID 243211)
-- Name: cell_observation_hourly cell_observation_hourly_grid_cell_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_hourly
    ADD CONSTRAINT cell_observation_hourly_grid_cell_fkey FOREIGN KEY (grid_cell_id) REFERENCES weather.grid_cell(grid_cell_id) ON DELETE RESTRICT;


--
-- TOC entry 8983 (class 2606 OID 243226)
-- Name: cell_observation_hourly cell_observation_hourly_ingestion_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_hourly
    ADD CONSTRAINT cell_observation_hourly_ingestion_fkey FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT;


--
-- TOC entry 8984 (class 2606 OID 243216)
-- Name: cell_observation_hourly cell_observation_hourly_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_hourly
    ADD CONSTRAINT cell_observation_hourly_product_fkey FOREIGN KEY (observation_product_id) REFERENCES weather.observation_product(observation_product_id) ON DELETE RESTRICT;


--
-- TOC entry 8985 (class 2606 OID 243221)
-- Name: cell_observation_hourly cell_observation_hourly_status_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_hourly
    ADD CONSTRAINT cell_observation_hourly_status_fkey FOREIGN KEY (observation_record_status_id) REFERENCES weather.observation_record_status(observation_record_status_id) ON DELETE RESTRICT;


--
-- TOC entry 8986 (class 2606 OID 243236)
-- Name: cell_observation_hourly cell_observation_hourly_supersedes_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.cell_observation_hourly
    ADD CONSTRAINT cell_observation_hourly_supersedes_fkey FOREIGN KEY (supersedes_observation_id, supersedes_observation_time) REFERENCES weather.cell_observation_hourly(cell_observation_id, observation_time) ON DELETE RESTRICT;


--
-- TOC entry 8987 (class 2606 OID 243357)
-- Name: cell_observation_quality_exception cell_observation_quality_exception_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_quality_exception
    ADD CONSTRAINT cell_observation_quality_exception_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 8988 (class 2606 OID 243352)
-- Name: cell_observation_quality_exception cell_observation_quality_exception_flag_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_quality_exception
    ADD CONSTRAINT cell_observation_quality_exception_flag_fkey FOREIGN KEY (quality_flag_id) REFERENCES weather.quality_flag(quality_flag_id) ON DELETE RESTRICT;


--
-- TOC entry 8989 (class 2606 OID 243339)
-- Name: cell_observation_quality_exception cell_observation_quality_exception_observation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_quality_exception
    ADD CONSTRAINT cell_observation_quality_exception_observation_fkey FOREIGN KEY (cell_observation_id, observation_time) REFERENCES weather.cell_observation_hourly(cell_observation_id, observation_time) ON DELETE CASCADE;


--
-- TOC entry 8990 (class 2606 OID 243347)
-- Name: cell_observation_quality_exception cell_observation_quality_exception_variable_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_quality_exception
    ADD CONSTRAINT cell_observation_quality_exception_variable_fkey FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT;


--
-- TOC entry 9017 (class 2606 OID 243916)
-- Name: cell_observation_value cell_observation_value_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_value
    ADD CONSTRAINT cell_observation_value_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9018 (class 2606 OID 243911)
-- Name: cell_observation_value cell_observation_value_ingestion_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_value
    ADD CONSTRAINT cell_observation_value_ingestion_fkey FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9019 (class 2606 OID 243893)
-- Name: cell_observation_value cell_observation_value_observation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_value
    ADD CONSTRAINT cell_observation_value_observation_fkey FOREIGN KEY (cell_observation_id, observation_time) REFERENCES weather.cell_observation_hourly(cell_observation_id, observation_time) ON DELETE CASCADE;


--
-- TOC entry 9020 (class 2606 OID 243906)
-- Name: cell_observation_value cell_observation_value_status_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_value
    ADD CONSTRAINT cell_observation_value_status_fkey FOREIGN KEY (observation_record_status_id) REFERENCES weather.observation_record_status(observation_record_status_id) ON DELETE RESTRICT;


--
-- TOC entry 9021 (class 2606 OID 243901)
-- Name: cell_observation_value cell_observation_value_variable_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.cell_observation_value
    ADD CONSTRAINT cell_observation_value_variable_fkey FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT;


--
-- TOC entry 9104 (class 2606 OID 245379)
-- Name: consensus_definition_member consensus_definition_member_definition_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.consensus_definition_member
    ADD CONSTRAINT consensus_definition_member_definition_fkey FOREIGN KEY (consensus_definition_id) REFERENCES weather.consensus_definition(consensus_definition_id) ON DELETE CASCADE;


--
-- TOC entry 9105 (class 2606 OID 245384)
-- Name: consensus_definition_member consensus_definition_member_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.consensus_definition_member
    ADD CONSTRAINT consensus_definition_member_product_fkey FOREIGN KEY (forecast_product_id) REFERENCES weather.forecast_product(forecast_product_id) ON DELETE RESTRICT;


--
-- TOC entry 9022 (class 2606 OID 243990)
-- Name: dataset_condition_mapping dataset_condition_mapping_condition_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.dataset_condition_mapping
    ADD CONSTRAINT dataset_condition_mapping_condition_fkey FOREIGN KEY (condition_code_id) REFERENCES weather.condition_code(condition_code_id) ON DELETE RESTRICT;


--
-- TOC entry 9023 (class 2606 OID 243985)
-- Name: dataset_condition_mapping dataset_condition_mapping_dataset_version_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.dataset_condition_mapping
    ADD CONSTRAINT dataset_condition_mapping_dataset_version_fkey FOREIGN KEY (dataset_version_id) REFERENCES weather.dataset_version(dataset_version_id) ON DELETE RESTRICT;


--
-- TOC entry 8936 (class 2606 OID 242189)
-- Name: dataset dataset_provider_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.dataset
    ADD CONSTRAINT dataset_provider_fkey FOREIGN KEY (provider_id) REFERENCES weather.provider(provider_id) ON DELETE RESTRICT;


--
-- TOC entry 8966 (class 2606 OID 242916)
-- Name: dataset_variable_mapping dataset_variable_mapping_dataset_version_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.dataset_variable_mapping
    ADD CONSTRAINT dataset_variable_mapping_dataset_version_fkey FOREIGN KEY (dataset_version_id) REFERENCES weather.dataset_version(dataset_version_id) ON DELETE RESTRICT;


--
-- TOC entry 8967 (class 2606 OID 242921)
-- Name: dataset_variable_mapping dataset_variable_mapping_variable_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.dataset_variable_mapping
    ADD CONSTRAINT dataset_variable_mapping_variable_fkey FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT;


--
-- TOC entry 8937 (class 2606 OID 242220)
-- Name: dataset_version dataset_version_dataset_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.dataset_version
    ADD CONSTRAINT dataset_version_dataset_fkey FOREIGN KEY (dataset_id) REFERENCES weather.dataset(dataset_id) ON DELETE RESTRICT;


--
-- TOC entry 8942 (class 2606 OID 242385)
-- Name: derivation_run derivation_run_ingestion_run_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.derivation_run
    ADD CONSTRAINT derivation_run_ingestion_run_fkey FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT;


--
-- TOC entry 8944 (class 2606 OID 242416)
-- Name: derivation_run_input derivation_run_input_derivation_run_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.derivation_run_input
    ADD CONSTRAINT derivation_run_input_derivation_run_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE CASCADE;


--
-- TOC entry 8945 (class 2606 OID 242421)
-- Name: derivation_run_input derivation_run_input_ingestion_run_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.derivation_run_input
    ADD CONSTRAINT derivation_run_input_ingestion_run_fkey FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT;


--
-- TOC entry 8943 (class 2606 OID 242380)
-- Name: derivation_run derivation_run_version_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.derivation_run
    ADD CONSTRAINT derivation_run_version_fkey FOREIGN KEY (derivation_version_id) REFERENCES weather.derivation_version(derivation_version_id) ON DELETE RESTRICT;


--
-- TOC entry 8941 (class 2606 OID 242350)
-- Name: derivation_version derivation_version_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.derivation_version
    ADD CONSTRAINT derivation_version_derivation_fkey FOREIGN KEY (derivation_id) REFERENCES weather.derivation(derivation_id) ON DELETE RESTRICT;


--
-- TOC entry 9076 (class 2606 OID 244908)
-- Name: ensemble_probability ensemble_probability_summary_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.ensemble_probability
    ADD CONSTRAINT ensemble_probability_summary_fkey FOREIGN KEY (ensemble_summary_id, valid_time) REFERENCES weather.ensemble_summary(ensemble_summary_id, valid_time) ON DELETE CASCADE;


--
-- TOC entry 9071 (class 2606 OID 244823)
-- Name: ensemble_summary ensemble_summary_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.ensemble_summary
    ADD CONSTRAINT ensemble_summary_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9072 (class 2606 OID 244813)
-- Name: ensemble_summary ensemble_summary_grid_cell_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.ensemble_summary
    ADD CONSTRAINT ensemble_summary_grid_cell_fkey FOREIGN KEY (grid_cell_id) REFERENCES weather.grid_cell(grid_cell_id) ON DELETE RESTRICT;


--
-- TOC entry 9073 (class 2606 OID 244808)
-- Name: ensemble_summary ensemble_summary_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.ensemble_summary
    ADD CONSTRAINT ensemble_summary_product_fkey FOREIGN KEY (forecast_product_id) REFERENCES weather.forecast_product(forecast_product_id) ON DELETE RESTRICT;


--
-- TOC entry 9074 (class 2606 OID 244803)
-- Name: ensemble_summary ensemble_summary_run_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.ensemble_summary
    ADD CONSTRAINT ensemble_summary_run_fkey FOREIGN KEY (forecast_run_id) REFERENCES weather.forecast_run(forecast_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9075 (class 2606 OID 244818)
-- Name: ensemble_summary ensemble_summary_variable_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.ensemble_summary
    ADD CONSTRAINT ensemble_summary_variable_fkey FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT;


--
-- TOC entry 9054 (class 2606 OID 244521)
-- Name: forecast_member forecast_member_run_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_member
    ADD CONSTRAINT forecast_member_run_fkey FOREIGN KEY (forecast_run_id) REFERENCES weather.forecast_run(forecast_run_id) ON DELETE CASCADE;


--
-- TOC entry 9044 (class 2606 OID 244315)
-- Name: forecast_model forecast_model_provider_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_model
    ADD CONSTRAINT forecast_model_provider_fkey FOREIGN KEY (provider_id) REFERENCES weather.provider(provider_id) ON DELETE RESTRICT;


--
-- TOC entry 9045 (class 2606 OID 244347)
-- Name: forecast_model_version forecast_model_version_model_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_model_version
    ADD CONSTRAINT forecast_model_version_model_fkey FOREIGN KEY (forecast_model_id) REFERENCES weather.forecast_model(forecast_model_id) ON DELETE RESTRICT;


--
-- TOC entry 9046 (class 2606 OID 244393)
-- Name: forecast_product forecast_product_dataset_version_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_product
    ADD CONSTRAINT forecast_product_dataset_version_fkey FOREIGN KEY (dataset_version_id) REFERENCES weather.dataset_version(dataset_version_id) ON DELETE RESTRICT;


--
-- TOC entry 9047 (class 2606 OID 244398)
-- Name: forecast_product forecast_product_derivation_version_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_product
    ADD CONSTRAINT forecast_product_derivation_version_fkey FOREIGN KEY (derivation_version_id) REFERENCES weather.derivation_version(derivation_version_id) ON DELETE RESTRICT;


--
-- TOC entry 9048 (class 2606 OID 244388)
-- Name: forecast_product forecast_product_model_version_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_product
    ADD CONSTRAINT forecast_product_model_version_fkey FOREIGN KEY (forecast_model_version_id) REFERENCES weather.forecast_model_version(forecast_model_version_id) ON DELETE RESTRICT;


--
-- TOC entry 9049 (class 2606 OID 245568)
-- Name: forecast_run forecast_run_expectation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run
    ADD CONSTRAINT forecast_run_expectation_fkey FOREIGN KEY (forecast_run_expectation_id) REFERENCES weather.forecast_run_expectation(forecast_run_expectation_id) ON DELETE RESTRICT;


--
-- TOC entry 9113 (class 2606 OID 245554)
-- Name: forecast_run_expectation_item forecast_run_expectation_item_expectation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run_expectation_item
    ADD CONSTRAINT forecast_run_expectation_item_expectation_fkey FOREIGN KEY (forecast_run_expectation_id) REFERENCES weather.forecast_run_expectation(forecast_run_expectation_id) ON DELETE CASCADE;


--
-- TOC entry 9114 (class 2606 OID 245559)
-- Name: forecast_run_expectation_item forecast_run_expectation_item_variable_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run_expectation_item
    ADD CONSTRAINT forecast_run_expectation_item_variable_fkey FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT;


--
-- TOC entry 9111 (class 2606 OID 245519)
-- Name: forecast_run_expectation forecast_run_expectation_model_version_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run_expectation
    ADD CONSTRAINT forecast_run_expectation_model_version_fkey FOREIGN KEY (forecast_model_version_id) REFERENCES weather.forecast_model_version(forecast_model_version_id) ON DELETE RESTRICT;


--
-- TOC entry 9112 (class 2606 OID 245514)
-- Name: forecast_run_expectation forecast_run_expectation_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run_expectation
    ADD CONSTRAINT forecast_run_expectation_product_fkey FOREIGN KEY (forecast_product_id) REFERENCES weather.forecast_product(forecast_product_id) ON DELETE RESTRICT;


--
-- TOC entry 9052 (class 2606 OID 244485)
-- Name: forecast_run_ingestion forecast_run_ingestion_ingestion_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run_ingestion
    ADD CONSTRAINT forecast_run_ingestion_ingestion_fkey FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9053 (class 2606 OID 244480)
-- Name: forecast_run_ingestion forecast_run_ingestion_run_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run_ingestion
    ADD CONSTRAINT forecast_run_ingestion_run_fkey FOREIGN KEY (forecast_run_id) REFERENCES weather.forecast_run(forecast_run_id) ON DELETE CASCADE;


--
-- TOC entry 9050 (class 2606 OID 244448)
-- Name: forecast_run forecast_run_model_version_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run
    ADD CONSTRAINT forecast_run_model_version_fkey FOREIGN KEY (forecast_model_version_id) REFERENCES weather.forecast_model_version(forecast_model_version_id) ON DELETE RESTRICT;


--
-- TOC entry 9051 (class 2606 OID 244443)
-- Name: forecast_run forecast_run_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_run
    ADD CONSTRAINT forecast_run_product_fkey FOREIGN KEY (forecast_product_id) REFERENCES weather.forecast_product(forecast_product_id) ON DELETE RESTRICT;


--
-- TOC entry 9089 (class 2606 OID 245186)
-- Name: forecast_verification forecast_verification_definition_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification
    ADD CONSTRAINT forecast_verification_definition_fkey FOREIGN KEY (verification_definition_id) REFERENCES weather.verification_definition(verification_definition_id) ON DELETE RESTRICT;


--
-- TOC entry 9090 (class 2606 OID 245232)
-- Name: forecast_verification forecast_verification_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification
    ADD CONSTRAINT forecast_verification_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9091 (class 2606 OID 245191)
-- Name: forecast_verification forecast_verification_forecast_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification
    ADD CONSTRAINT forecast_verification_forecast_fkey FOREIGN KEY (cell_forecast_id, forecast_valid_time) REFERENCES weather.cell_forecast(cell_forecast_id, valid_time) ON DELETE RESTRICT;


--
-- TOC entry 9092 (class 2606 OID 245212)
-- Name: forecast_verification forecast_verification_forecast_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification
    ADD CONSTRAINT forecast_verification_forecast_product_fkey FOREIGN KEY (forecast_product_id) REFERENCES weather.forecast_product(forecast_product_id) ON DELETE RESTRICT;


--
-- TOC entry 9093 (class 2606 OID 245222)
-- Name: forecast_verification forecast_verification_grid_cell_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification
    ADD CONSTRAINT forecast_verification_grid_cell_fkey FOREIGN KEY (grid_cell_id) REFERENCES weather.grid_cell(grid_cell_id) ON DELETE RESTRICT;


--
-- TOC entry 9094 (class 2606 OID 245199)
-- Name: forecast_verification forecast_verification_observation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification
    ADD CONSTRAINT forecast_verification_observation_fkey FOREIGN KEY (cell_observation_id, observation_time) REFERENCES weather.cell_observation_hourly(cell_observation_id, observation_time) ON DELETE RESTRICT;


--
-- TOC entry 9095 (class 2606 OID 245217)
-- Name: forecast_verification forecast_verification_observation_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification
    ADD CONSTRAINT forecast_verification_observation_product_fkey FOREIGN KEY (observation_product_id) REFERENCES weather.observation_product(observation_product_id) ON DELETE RESTRICT;


--
-- TOC entry 9096 (class 2606 OID 245207)
-- Name: forecast_verification forecast_verification_run_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification
    ADD CONSTRAINT forecast_verification_run_fkey FOREIGN KEY (forecast_run_id) REFERENCES weather.forecast_run(forecast_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9098 (class 2606 OID 245280)
-- Name: forecast_verification_summary forecast_verification_summary_definition_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification_summary
    ADD CONSTRAINT forecast_verification_summary_definition_fkey FOREIGN KEY (verification_definition_id) REFERENCES weather.verification_definition(verification_definition_id) ON DELETE RESTRICT;


--
-- TOC entry 9099 (class 2606 OID 245305)
-- Name: forecast_verification_summary forecast_verification_summary_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification_summary
    ADD CONSTRAINT forecast_verification_summary_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9100 (class 2606 OID 245285)
-- Name: forecast_verification_summary forecast_verification_summary_forecast_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification_summary
    ADD CONSTRAINT forecast_verification_summary_forecast_product_fkey FOREIGN KEY (forecast_product_id) REFERENCES weather.forecast_product(forecast_product_id) ON DELETE RESTRICT;


--
-- TOC entry 9101 (class 2606 OID 245300)
-- Name: forecast_verification_summary forecast_verification_summary_grid_cell_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification_summary
    ADD CONSTRAINT forecast_verification_summary_grid_cell_fkey FOREIGN KEY (grid_cell_id) REFERENCES weather.grid_cell(grid_cell_id) ON DELETE RESTRICT;


--
-- TOC entry 9102 (class 2606 OID 245290)
-- Name: forecast_verification_summary forecast_verification_summary_observation_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification_summary
    ADD CONSTRAINT forecast_verification_summary_observation_product_fkey FOREIGN KEY (observation_product_id) REFERENCES weather.observation_product(observation_product_id) ON DELETE RESTRICT;


--
-- TOC entry 9103 (class 2606 OID 245295)
-- Name: forecast_verification_summary forecast_verification_summary_variable_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification_summary
    ADD CONSTRAINT forecast_verification_summary_variable_fkey FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT;


--
-- TOC entry 9097 (class 2606 OID 245227)
-- Name: forecast_verification forecast_verification_variable_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.forecast_verification
    ADD CONSTRAINT forecast_verification_variable_fkey FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT;


--
-- TOC entry 8928 (class 2606 OID 225793)
-- Name: grid_cell grid_cell_grid_system_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.grid_cell
    ADD CONSTRAINT grid_cell_grid_system_fkey FOREIGN KEY (grid_system_id) REFERENCES weather.grid_system(grid_system_id) ON DELETE RESTRICT;


--
-- TOC entry 8939 (class 2606 OID 242282)
-- Name: ingestion_run ingestion_run_dataset_version_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.ingestion_run
    ADD CONSTRAINT ingestion_run_dataset_version_fkey FOREIGN KEY (dataset_version_id) REFERENCES weather.dataset_version(dataset_version_id) ON DELETE RESTRICT;


--
-- TOC entry 8940 (class 2606 OID 242287)
-- Name: ingestion_run ingestion_run_source_artifact_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.ingestion_run
    ADD CONSTRAINT ingestion_run_source_artifact_fkey FOREIGN KEY (source_artifact_id) REFERENCES weather.source_artifact(source_artifact_id) ON DELETE RESTRICT;


--
-- TOC entry 8953 (class 2606 OID 243390)
-- Name: observation_product observation_product_daily_period_definition_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.observation_product
    ADD CONSTRAINT observation_product_daily_period_definition_fkey FOREIGN KEY (daily_period_definition_id) REFERENCES weather.daily_period_definition(daily_period_definition_id) ON DELETE RESTRICT;


--
-- TOC entry 8954 (class 2606 OID 242617)
-- Name: observation_product observation_product_dataset_version_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.observation_product
    ADD CONSTRAINT observation_product_dataset_version_fkey FOREIGN KEY (dataset_version_id) REFERENCES weather.dataset_version(dataset_version_id) ON DELETE RESTRICT;


--
-- TOC entry 8955 (class 2606 OID 242622)
-- Name: observation_product observation_product_derivation_version_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.observation_product
    ADD CONSTRAINT observation_product_derivation_version_fkey FOREIGN KEY (derivation_version_id) REFERENCES weather.derivation_version(derivation_version_id) ON DELETE RESTRICT;


--
-- TOC entry 8938 (class 2606 OID 242249)
-- Name: source_artifact source_artifact_dataset_version_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.source_artifact
    ADD CONSTRAINT source_artifact_dataset_version_fkey FOREIGN KEY (dataset_version_id) REFERENCES weather.dataset_version(dataset_version_id) ON DELETE RESTRICT;


--
-- TOC entry 8956 (class 2606 OID 242657)
-- Name: station_h3_map station_h3_map_grid_cell_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_h3_map
    ADD CONSTRAINT station_h3_map_grid_cell_fkey FOREIGN KEY (grid_cell_id) REFERENCES weather.grid_cell(grid_cell_id) ON DELETE RESTRICT;


--
-- TOC entry 8957 (class 2606 OID 242652)
-- Name: station_h3_map station_h3_map_station_history_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_h3_map
    ADD CONSTRAINT station_h3_map_station_history_fkey FOREIGN KEY (station_history_id) REFERENCES weather.station_history(station_history_id) ON DELETE CASCADE;


--
-- TOC entry 8950 (class 2606 OID 242549)
-- Name: station_history station_history_station_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_history
    ADD CONSTRAINT station_history_station_fkey FOREIGN KEY (station_id) REFERENCES weather.station(station_id) ON DELETE CASCADE;


--
-- TOC entry 8947 (class 2606 OID 242518)
-- Name: station_identifier station_identifier_network_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_identifier
    ADD CONSTRAINT station_identifier_network_fkey FOREIGN KEY (station_network_id) REFERENCES weather.station_network(station_network_id) ON DELETE RESTRICT;


--
-- TOC entry 8948 (class 2606 OID 242513)
-- Name: station_identifier station_identifier_provider_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_identifier
    ADD CONSTRAINT station_identifier_provider_fkey FOREIGN KEY (provider_id) REFERENCES weather.provider(provider_id) ON DELETE RESTRICT;


--
-- TOC entry 8949 (class 2606 OID 242508)
-- Name: station_identifier station_identifier_station_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_identifier
    ADD CONSTRAINT station_identifier_station_fkey FOREIGN KEY (station_id) REFERENCES weather.station(station_id) ON DELETE CASCADE;


--
-- TOC entry 8951 (class 2606 OID 242584)
-- Name: station_network_membership station_network_membership_network_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_network_membership
    ADD CONSTRAINT station_network_membership_network_fkey FOREIGN KEY (station_network_id) REFERENCES weather.station_network(station_network_id) ON DELETE RESTRICT;


--
-- TOC entry 8952 (class 2606 OID 242579)
-- Name: station_network_membership station_network_membership_station_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_network_membership
    ADD CONSTRAINT station_network_membership_station_fkey FOREIGN KEY (station_id) REFERENCES weather.station(station_id) ON DELETE CASCADE;


--
-- TOC entry 8946 (class 2606 OID 242452)
-- Name: station_network station_network_provider_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_network
    ADD CONSTRAINT station_network_provider_fkey FOREIGN KEY (provider_id) REFERENCES weather.provider(provider_id) ON DELETE RESTRICT;


--
-- TOC entry 9024 (class 2606 OID 244090)
-- Name: station_observation_correction station_observation_correction_artifact_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_correction
    ADD CONSTRAINT station_observation_correction_artifact_fkey FOREIGN KEY (source_artifact_id) REFERENCES weather.source_artifact(source_artifact_id) ON DELETE RESTRICT;


--
-- TOC entry 9025 (class 2606 OID 244095)
-- Name: station_observation_correction station_observation_correction_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_correction
    ADD CONSTRAINT station_observation_correction_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9026 (class 2606 OID 244069)
-- Name: station_observation_correction station_observation_correction_original_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_correction
    ADD CONSTRAINT station_observation_correction_original_fkey FOREIGN KEY (original_observation_id, original_observation_time) REFERENCES weather.station_observation_hourly(station_observation_id, observation_time) ON DELETE RESTRICT;


--
-- TOC entry 9027 (class 2606 OID 244085)
-- Name: station_observation_correction station_observation_correction_reason_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_correction
    ADD CONSTRAINT station_observation_correction_reason_fkey FOREIGN KEY (observation_correction_reason_id) REFERENCES weather.observation_correction_reason(observation_correction_reason_id) ON DELETE RESTRICT;


--
-- TOC entry 9028 (class 2606 OID 244077)
-- Name: station_observation_correction station_observation_correction_replacement_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_correction
    ADD CONSTRAINT station_observation_correction_replacement_fkey FOREIGN KEY (replacement_observation_id, replacement_observation_time) REFERENCES weather.station_observation_hourly(station_observation_id, observation_time) ON DELETE RESTRICT;


--
-- TOC entry 9034 (class 2606 OID 244208)
-- Name: station_observation_daily_correction station_observation_daily_correction_artifact_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily_correction
    ADD CONSTRAINT station_observation_daily_correction_artifact_fkey FOREIGN KEY (source_artifact_id) REFERENCES weather.source_artifact(source_artifact_id) ON DELETE RESTRICT;


--
-- TOC entry 9035 (class 2606 OID 244213)
-- Name: station_observation_daily_correction station_observation_daily_correction_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily_correction
    ADD CONSTRAINT station_observation_daily_correction_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9036 (class 2606 OID 244187)
-- Name: station_observation_daily_correction station_observation_daily_correction_original_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily_correction
    ADD CONSTRAINT station_observation_daily_correction_original_fkey FOREIGN KEY (original_observation_daily_id, original_observation_date) REFERENCES weather.station_observation_daily(station_observation_daily_id, observation_date) ON DELETE RESTRICT;


--
-- TOC entry 9037 (class 2606 OID 244203)
-- Name: station_observation_daily_correction station_observation_daily_correction_reason_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily_correction
    ADD CONSTRAINT station_observation_daily_correction_reason_fkey FOREIGN KEY (observation_correction_reason_id) REFERENCES weather.observation_correction_reason(observation_correction_reason_id) ON DELETE RESTRICT;


--
-- TOC entry 9038 (class 2606 OID 244195)
-- Name: station_observation_daily_correction station_observation_daily_correction_replacement_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily_correction
    ADD CONSTRAINT station_observation_daily_correction_replacement_fkey FOREIGN KEY (replacement_observation_daily_id, replacement_observation_date) REFERENCES weather.station_observation_daily(station_observation_daily_id, observation_date) ON DELETE RESTRICT;


--
-- TOC entry 8991 (class 2606 OID 243467)
-- Name: station_observation_daily station_observation_daily_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_daily
    ADD CONSTRAINT station_observation_daily_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 8992 (class 2606 OID 243462)
-- Name: station_observation_daily station_observation_daily_ingestion_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_daily
    ADD CONSTRAINT station_observation_daily_ingestion_fkey FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT;


--
-- TOC entry 8993 (class 2606 OID 243452)
-- Name: station_observation_daily station_observation_daily_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_daily
    ADD CONSTRAINT station_observation_daily_product_fkey FOREIGN KEY (observation_product_id) REFERENCES weather.observation_product(observation_product_id) ON DELETE RESTRICT;


--
-- TOC entry 9004 (class 2606 OID 243758)
-- Name: station_observation_daily_quality_exception station_observation_daily_quality_exception_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily_quality_exception
    ADD CONSTRAINT station_observation_daily_quality_exception_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9005 (class 2606 OID 243753)
-- Name: station_observation_daily_quality_exception station_observation_daily_quality_exception_flag_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily_quality_exception
    ADD CONSTRAINT station_observation_daily_quality_exception_flag_fkey FOREIGN KEY (quality_flag_id) REFERENCES weather.quality_flag(quality_flag_id) ON DELETE RESTRICT;


--
-- TOC entry 9006 (class 2606 OID 243740)
-- Name: station_observation_daily_quality_exception station_observation_daily_quality_exception_observation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily_quality_exception
    ADD CONSTRAINT station_observation_daily_quality_exception_observation_fkey FOREIGN KEY (station_observation_daily_id, observation_date) REFERENCES weather.station_observation_daily(station_observation_daily_id, observation_date) ON DELETE CASCADE;


--
-- TOC entry 9007 (class 2606 OID 243748)
-- Name: station_observation_daily_quality_exception station_observation_daily_quality_exception_variable_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_daily_quality_exception
    ADD CONSTRAINT station_observation_daily_quality_exception_variable_fkey FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT;


--
-- TOC entry 8994 (class 2606 OID 243442)
-- Name: station_observation_daily station_observation_daily_station_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_daily
    ADD CONSTRAINT station_observation_daily_station_fkey FOREIGN KEY (station_id) REFERENCES weather.station(station_id) ON DELETE RESTRICT;


--
-- TOC entry 8995 (class 2606 OID 243447)
-- Name: station_observation_daily station_observation_daily_station_history_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_daily
    ADD CONSTRAINT station_observation_daily_station_history_fkey FOREIGN KEY (station_history_id, station_id) REFERENCES weather.station_history(station_history_id, station_id) ON DELETE RESTRICT;


--
-- TOC entry 8996 (class 2606 OID 243457)
-- Name: station_observation_daily station_observation_daily_status_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_daily
    ADD CONSTRAINT station_observation_daily_status_fkey FOREIGN KEY (observation_record_status_id) REFERENCES weather.observation_record_status(observation_record_status_id) ON DELETE RESTRICT;


--
-- TOC entry 8997 (class 2606 OID 243472)
-- Name: station_observation_daily station_observation_daily_supersedes_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_daily
    ADD CONSTRAINT station_observation_daily_supersedes_fkey FOREIGN KEY (supersedes_observation_daily_id, supersedes_observation_date) REFERENCES weather.station_observation_daily(station_observation_daily_id, observation_date) ON DELETE RESTRICT;


--
-- TOC entry 8968 (class 2606 OID 243999)
-- Name: station_observation_hourly station_observation_hourly_condition_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_hourly
    ADD CONSTRAINT station_observation_hourly_condition_fkey FOREIGN KEY (condition_code_id) REFERENCES weather.condition_code(condition_code_id) ON DELETE RESTRICT;


--
-- TOC entry 8969 (class 2606 OID 243017)
-- Name: station_observation_hourly station_observation_hourly_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_hourly
    ADD CONSTRAINT station_observation_hourly_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 8970 (class 2606 OID 243012)
-- Name: station_observation_hourly station_observation_hourly_ingestion_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_hourly
    ADD CONSTRAINT station_observation_hourly_ingestion_fkey FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT;


--
-- TOC entry 8971 (class 2606 OID 243002)
-- Name: station_observation_hourly station_observation_hourly_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_hourly
    ADD CONSTRAINT station_observation_hourly_product_fkey FOREIGN KEY (observation_product_id) REFERENCES weather.observation_product(observation_product_id) ON DELETE RESTRICT;


--
-- TOC entry 8972 (class 2606 OID 242992)
-- Name: station_observation_hourly station_observation_hourly_station_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_hourly
    ADD CONSTRAINT station_observation_hourly_station_fkey FOREIGN KEY (station_id) REFERENCES weather.station(station_id) ON DELETE RESTRICT;


--
-- TOC entry 8973 (class 2606 OID 242997)
-- Name: station_observation_hourly station_observation_hourly_station_history_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_hourly
    ADD CONSTRAINT station_observation_hourly_station_history_fkey FOREIGN KEY (station_history_id, station_id) REFERENCES weather.station_history(station_history_id, station_id) ON DELETE RESTRICT;


--
-- TOC entry 8974 (class 2606 OID 243007)
-- Name: station_observation_hourly station_observation_hourly_status_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_hourly
    ADD CONSTRAINT station_observation_hourly_status_fkey FOREIGN KEY (observation_record_status_id) REFERENCES weather.observation_record_status(observation_record_status_id) ON DELETE RESTRICT;


--
-- TOC entry 8975 (class 2606 OID 243022)
-- Name: station_observation_hourly station_observation_hourly_supersedes_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE weather.station_observation_hourly
    ADD CONSTRAINT station_observation_hourly_supersedes_fkey FOREIGN KEY (supersedes_observation_id, supersedes_observation_time) REFERENCES weather.station_observation_hourly(station_observation_id, observation_time) ON DELETE RESTRICT;


--
-- TOC entry 8976 (class 2606 OID 243165)
-- Name: station_observation_quality_exception station_observation_quality_exception_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_quality_exception
    ADD CONSTRAINT station_observation_quality_exception_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 8977 (class 2606 OID 243160)
-- Name: station_observation_quality_exception station_observation_quality_exception_flag_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_quality_exception
    ADD CONSTRAINT station_observation_quality_exception_flag_fkey FOREIGN KEY (quality_flag_id) REFERENCES weather.quality_flag(quality_flag_id) ON DELETE RESTRICT;


--
-- TOC entry 8978 (class 2606 OID 243147)
-- Name: station_observation_quality_exception station_observation_quality_exception_observation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_quality_exception
    ADD CONSTRAINT station_observation_quality_exception_observation_fkey FOREIGN KEY (station_observation_id, observation_time) REFERENCES weather.station_observation_hourly(station_observation_id, observation_time) ON DELETE CASCADE;


--
-- TOC entry 8979 (class 2606 OID 243155)
-- Name: station_observation_quality_exception station_observation_quality_exception_variable_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_quality_exception
    ADD CONSTRAINT station_observation_quality_exception_variable_fkey FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT;


--
-- TOC entry 9012 (class 2606 OID 243862)
-- Name: station_observation_value station_observation_value_derivation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_value
    ADD CONSTRAINT station_observation_value_derivation_fkey FOREIGN KEY (derivation_run_id) REFERENCES weather.derivation_run(derivation_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9013 (class 2606 OID 243857)
-- Name: station_observation_value station_observation_value_ingestion_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_value
    ADD CONSTRAINT station_observation_value_ingestion_fkey FOREIGN KEY (ingestion_run_id) REFERENCES weather.ingestion_run(ingestion_run_id) ON DELETE RESTRICT;


--
-- TOC entry 9014 (class 2606 OID 243839)
-- Name: station_observation_value station_observation_value_observation_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_value
    ADD CONSTRAINT station_observation_value_observation_fkey FOREIGN KEY (station_observation_id, observation_time) REFERENCES weather.station_observation_hourly(station_observation_id, observation_time) ON DELETE CASCADE;


--
-- TOC entry 9015 (class 2606 OID 243852)
-- Name: station_observation_value station_observation_value_status_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_value
    ADD CONSTRAINT station_observation_value_status_fkey FOREIGN KEY (observation_record_status_id) REFERENCES weather.observation_record_status(observation_record_status_id) ON DELETE RESTRICT;


--
-- TOC entry 9016 (class 2606 OID 243847)
-- Name: station_observation_value station_observation_value_variable_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_observation_value
    ADD CONSTRAINT station_observation_value_variable_fkey FOREIGN KEY (variable_id) REFERENCES weather.variable(variable_id) ON DELETE RESTRICT;


--
-- TOC entry 8958 (class 2606 OID 242691)
-- Name: station_region_map station_region_map_region_version_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_region_map
    ADD CONSTRAINT station_region_map_region_version_fkey FOREIGN KEY (region_version_id) REFERENCES geo.region_version(region_version_id) ON DELETE RESTRICT;


--
-- TOC entry 8959 (class 2606 OID 242686)
-- Name: station_region_map station_region_map_station_history_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.station_region_map
    ADD CONSTRAINT station_region_map_station_history_fkey FOREIGN KEY (station_history_id) REFERENCES weather.station_history(station_history_id) ON DELETE CASCADE;


--
-- TOC entry 8961 (class 2606 OID 242871)
-- Name: variable variable_accumulation_period_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.variable
    ADD CONSTRAINT variable_accumulation_period_fkey FOREIGN KEY (accumulation_period_id) REFERENCES weather.accumulation_period(accumulation_period_id) ON DELETE RESTRICT;


--
-- TOC entry 8962 (class 2606 OID 242861)
-- Name: variable variable_statistic_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.variable
    ADD CONSTRAINT variable_statistic_fkey FOREIGN KEY (statistic_id) REFERENCES weather.statistic(statistic_id) ON DELETE RESTRICT;


--
-- TOC entry 8963 (class 2606 OID 242866)
-- Name: variable variable_temporal_semantics_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.variable
    ADD CONSTRAINT variable_temporal_semantics_fkey FOREIGN KEY (temporal_semantics_id) REFERENCES weather.temporal_semantics(temporal_semantics_id) ON DELETE RESTRICT;


--
-- TOC entry 8964 (class 2606 OID 242856)
-- Name: variable variable_unit_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.variable
    ADD CONSTRAINT variable_unit_fkey FOREIGN KEY (canonical_unit_id) REFERENCES weather.unit(unit_id) ON DELETE RESTRICT;


--
-- TOC entry 8965 (class 2606 OID 242876)
-- Name: variable variable_vertical_level_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.variable
    ADD CONSTRAINT variable_vertical_level_fkey FOREIGN KEY (vertical_level_id) REFERENCES weather.vertical_level(vertical_level_id) ON DELETE RESTRICT;


--
-- TOC entry 9088 (class 2606 OID 245141)
-- Name: verification_definition verification_definition_observation_product_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.verification_definition
    ADD CONSTRAINT verification_definition_observation_product_fkey FOREIGN KEY (observation_product_id) REFERENCES weather.observation_product(observation_product_id) ON DELETE RESTRICT;


--
-- TOC entry 8960 (class 2606 OID 242821)
-- Name: vertical_level vertical_level_unit_fkey; Type: FK CONSTRAINT; Schema: weather; Owner: postgres
--

ALTER TABLE ONLY weather.vertical_level
    ADD CONSTRAINT vertical_level_unit_fkey FOREIGN KEY (unit_id) REFERENCES weather.unit(unit_id) ON DELETE RESTRICT;


-- Completed on 2026-09-06 01:59:39

--
-- PostgreSQL database dump complete
--

\unrestrict zzzDLqKc1wa5e7eOkVozJ94KEQyEh6SDslJzIAacgctNjQWIvngqIvqBMsI4LZq

