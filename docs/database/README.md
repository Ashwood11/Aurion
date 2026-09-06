# Aurion Database Reference

**Canonical structural source:** `aurion_schema_2026-09-06.sql`  
**Snapshot date:** 2026-09-06  
**Database:** PostgreSQL 18.3

This documentation is the long-term human-readable reference for Aurion's PostgreSQL database. The SQL export remains the exact structural source of truth; these documents explain the intent, ownership boundaries, data status, architectural rules, and reasons behind the structure so future work does not require reverse-engineering old conversations.

## Schemas

| Schema | Tables in 2026-09-06 export | Responsibility |
|---|---:|---|
| `aviation` | 4 | Aviation tracking/history/enrichment data. |
| `core` | 0 | Reserved shared/core domain; no ordinary tables in this snapshot. |
| `energy` | 0 | Reserved broader energy domain; no ordinary tables in this snapshot. |
| `gas` | 11 | Natural-gas fundamentals, market data, derived signals, and gas-specific interpretation of shared inputs. |
| `geo` | 19 | Reusable real-world geography, identifiers, versioned geometry, and mappings to canonical weather cells. |
| `locations` | 1 | Earlier/legacy location model retained in the database. |
| `mining` | 1 | Mining asset data. |
| `public` | 14 | Legacy/general public-schema structures, including older weather/location models that must not be confused with canonical `weather`/`geo`. |
| `weather` | 72 | Universal physical weather, forecasts, observations, provenance, verification, and canonical grid analysis. |

## Core ownership rules

1. **Universal physical weather belongs in `weather`.** Gas, energy, aviation, agriculture and other consumers may interpret weather, but must not redefine physical weather semantics.
2. **Reusable real-world geography belongs in `geo`.** Domain schemas should reference or group canonical geography rather than duplicate state/country/region polygons.
3. **Canonical weather analysis geography is database-defined.** `weather.grid_system` / `weather.grid_cell` define Aurion's canonical grid. Provider-native source points never determine the target-cell population.
4. **Exact PostGIS geometry remains authoritative for real-world regions/events.** H3 is an analytical indexing/aggregation grid, not a replacement for exact geometry.
5. **Forecasts are historical predictions.** Forecast vintages are immutable historical records; corrections and revisions are represented explicitly.
6. **Lineage is first-class:** provider → dataset/version → source artifact → ingestion run → derivation/version/run → canonical result.
7. **Observations, forecasts, forecast event states, physical events and official alerts are distinct concepts.**
8. **High spatial resolution is targeted.** Broad areas can use coarser coverage; economically/operationally important areas can request finer H3 cells. Do not default to dense H3-R5 everywhere globally.
9. **Provider acquisition geography is separate from target geography.** A canonical target set may require one or many provider-specific source windows.
10. **Storage is tiered conceptually:** hot PostgreSQL, warm compressed analytical history, cold/native source archives. Archiving does not mean deleting historical knowledge.

## Status vocabulary

- **ACTIVE / PRODUCTION-CANDIDATE** — current canonical structure intended to continue.
- **ACTIVE** — used/current, but production maturity may still be evolving.
- **PROVISIONAL** — useful prototype/experimental structure whose semantics are not authoritative.
- **LEGACY** — retained older structure; do not build new architecture on it without explicit review.
- **STAGING** — import/cleanup table, not canonical analytical truth.
- **STRUCTURE PRESENT; DATA STATUS TO VERIFY** — schema exists but this documentation snapshot does not establish current row population/operational use.
- **PLANNED** — approved direction not yet present structurally.

## Maintenance rule

Every database change should follow: **design decision → SQL change → verification → documentation update → architectural-decision update (if applicable)**.

See [ARCHITECTURE.md](ARCHITECTURE.md), [DECISIONS.md](DECISIONS.md), [DATA_STATUS.md](DATA_STATUS.md), and schema-specific documents in `schemas/`.
