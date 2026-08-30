# Aurion NOAA GFS Ingestion

This package implements Aurion's Phase 1 ingestion pipeline for NOAA's Global Forecast System (GFS).

## Scope

The Phase 1 GFS pipeline:

- selects a valid GFS initialization cycle,
- verifies NOAA NOMADS availability,
- downloads selected GFS 0.25° forecast fields,
- reads GRIB2 content with ecCodes,
- maps provider-native forecast data to Aurion's canonical weather variables,
- remaps selected fields to Aurion H3 resolution 5 cells,
- preserves forecast/provenance lineage,
- writes derived forecasts into Aurion's canonical weather forecast structures,
- resumes partially ingested forecast runs,
- skips forecast hours already completed,
- isolates per-hour failures using PostgreSQL savepoints.

The Phase 1 implementation is currently validated using a bounded Oklahoma test region.

It is not yet the final global production ingestion system.

---

## Package Structure

### `config.py`

Central configuration and identity constants for:

- NOAA provider identity,
- GFS model/version identity,
- dataset/version identity,
- native and derived forecast products,
- derivation identity,
- NOMADS endpoint,
- configured GFS cycle hours,
- maximum forecast hour,
- expected forecast-step count,
- H3 resolution,
- remapping policy,
- ingestion pipeline identity,
- local weather data paths.

---

### `availability.py`

Checks whether a GFS cycle has actually been published by NOAA.

A small F000 2-metre-temperature NOMADS request is used as an availability probe.

A cycle is accepted only when NOAA returns:

- HTTP 200,
- non-empty content,
- content beginning with the GRIB signature.

This module also owns validation of valid GFS initialization times.

Configured normal cycles are:

```text
00Z
06Z
12Z
18Z