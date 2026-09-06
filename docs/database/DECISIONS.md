# Aurion Database Architectural Decisions

This file records *why* major database decisions were made. It complements the SQL schema, which records only *what* exists.

## ADR-001 — Universal weather belongs in `weather`
**Decision:** Physical weather is canonical in `weather`; domain-specific meaning belongs in consumer schemas.  
**Reason:** Prevent duplicated meteorology and inconsistent semantics across gas, energy, aviation and future modules.

## ADR-002 — Reusable geography belongs in `geo`
**Decision:** Countries, subdivisions, counties, municipalities, locations and versioned polygons are shared geography.  
**Reason:** A region such as Texas or New York should not be copied into each consumer schema.

## ADR-003 — Canonical H3 targets come from Aurion, not provider grids
**Decision:** `weather.grid_cell` defines target populations.  
**Reason:** Deriving targets from 0.25° GFS source points under-sampled H3-R5. The corrected Oklahoma test produced 144/144 canonical cells, proving the architecture.

## ADR-004 — Target geography and acquisition windows are independent
**Decision:** Exact canonical target cells are selected first; a provider adapter/planner decides how many source windows/files are required.  
**Reason:** Alaska and Hawaii demonstrated dateline/extent cases where one logical target population requires multiple acquisition rectangles.

## ADR-005 — Multi-window acquisition remains one logical forecast run
**Decision:** Multiple source artifacts/ingestion runs may feed one model initialization/product forecast run.  
**Reason:** Physical acquisition layout must not fragment the logical forecast identity. Provenance must still retain each artifact/window separately.

## ADR-006 — Forecast history is immutable historical prediction
**Decision:** Preserve revisions/corrections rather than overwrite historical forecasts.  
**Reason:** Forecast vintages are needed for verification, model-skill analysis, backtesting and future predictive models.

## ADR-007 — HDD/CDD transformation precedes spatial weighting
**Decision:** Calculate HDD/CDD at each cell first, then aggregate using the versioned demand/population weighting methodology.  
**Reason:** HDD/CDD uses a nonlinear `max()` transform; weighting temperatures before transformation can erase real heating/cooling demand.

## ADR-008 — Gas demand geography must be versioned and globally reusable
**Decision:** Do not create US-only gas-region tables. Future demand-region identity, membership and weight methodology should be generic and reference `geo.region` / `weather.grid_cell`.  
**Reason:** The same architecture must support US Census/EIA-style regions, UK/European balancing or administrative geography, provinces, territories and other markets without redesign.

## ADR-009 — Existing `gas.weather_demand_regions` is provisional legacy seed data
**Decision:** Preserve but do not treat the 12 current hubs as production demand geography.  
**Evidence:** All 12 were inserted together as representative city/demand hubs; no source/method/version metadata was found; population weights total 0.73 and gas-demand weights 0.815; no views/functions were found that establish stronger semantics.

## ADR-010 — Production US gas weather-demand base geography uses authoritative shared regions
**Decision:** Use the existing canonical `geo.region` state/DC records as the shared geographic building blocks for the first EIA/Census-division demand model.  
**Verification:** All 50 states plus DC were resolved after restricting the join to `state` and `federal_district` region types.

## ADR-011 — High-resolution Weather is targeted, not globally dense by default
**Decision:** Use finer H3 detail around high-value demand centres/assets/regions and broader/coarser coverage elsewhere.  
**Reason:** Full-US R5 stress tests proved capacity but also demonstrated unnecessary PostgreSQL storage growth if maximum resolution is used indiscriminately.

## ADR-012 — Continuous production ingestion requires deliberate partitioning
**Decision:** The current default partitions are acceptable for controlled tests, but production scheduler-driven ingestion must use a deliberate partition strategy before sustained high volume.  
**Reason:** `weather.cell_forecast_default` currently holds physical forecast rows and would become an operational/retention bottleneck at scale.

## ADR-013 — Storage-size benchmarks are empirical estimates
**Decision:** Treat the observed ~1 KB/indexed forecast row as a workload-specific benchmark, not a universal constant.  
**Reason:** Relation size depends on page fill, index structure, TOAST, bloat/dead tuples and actual value distribution.

## ADR-014 — GFS expected steps must be explicit configuration
**Decision:** Do not interpret F000–F384 as 385 hourly files.  
**Reason:** The operational product cadence changes with horizon; completeness and capacity calculations must use an explicit expected forecast-hour sequence.
