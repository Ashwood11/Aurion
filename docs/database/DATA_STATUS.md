# Aurion Database Data / Maturity Status

This file records known maturity/status, not exact row counts. Row populations should be re-queried when operational decisions depend on them.

## Active canonical foundations
- `geo.location`, `geo.region`, `geo.region_version`, identifier/mapping tables — shared canonical geography.
- `weather.grid_system`, `weather.grid_cell` — canonical Weather analysis grid.
- Weather provider/dataset/source/ingestion/derivation/forecast structures — active architecture under implementation.
- `gas.consumption_monthly`, `gas.states_consumption_monthly`, `gas.production_monthly`, `gas.storage_weekly`, `gas.prices_daily`, `gas.lng_monthly` — established natural-gas fundamentals structures.

## Provisional / legacy
- `gas.weather_demand_regions` — 12 representative prototype hubs; not production geography.
- `geo.locations` — earlier generic location model; canonical modern model is `geo.location`.
- `locations.locations` — separate older location schema retained in the database.
- `public.weather_*` and older public spatial/weather structures — legacy/general structures that must not be confused with canonical `weather` schema design.

## Staging
- `geo.ourairports_import`
- `geo.stage_country_name_iso2`
- `geo.stage_tiger_2025_state`
- `geo.stage_tiger_2025_county`
- `geo.stage_tiger_2025_county_utf8`

## Reserved empty schemas in this snapshot
- `core`
- `energy`

## Near-term planned structures
Production gas weather-demand modelling is planned to separate stable region identity, versioned region definition/membership, weight-set methodology/version, and canonical cell-level weights. Exact table DDL should be approved before creation.
