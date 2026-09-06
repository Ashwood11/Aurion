# Aurion Database Architecture

## Domain separation

Aurion is modular. Shared physical/world facts live in reusable schemas; domain-specific interpretation lives with the consumer.

```text
geo ----------------------┐
                          ├─> weather canonical targeting / spatial joins
weather physical data ----┼─> gas interpretation
                          ├─> aviation interpretation
                          ├─> energy interpretation
                          └─> mining / future domains
```

### Geography

`geo.region` is stable identity. `geo.region_version` carries time/version-specific exact MultiPolygon geometry. `geo.location` is stable point geography. `geo.region_cell_map` and `geo.location_cell_map` connect reusable geography to canonical weather-grid cells.

### Weather canonical grid

The canonical path is:

```text
weather.grid_system
    -> weather.grid_cell
    -> selected target cells
    -> provider-specific acquisition
    -> remapping/derivation
    -> canonical forecast/observation rows
```

The critical correction made during GFS work was to stop generating targets from native GFS points. Native model grids are source support, not Aurion geography.

### Forecast lineage

```text
provider
 -> dataset
 -> dataset_version
 -> source_artifact
 -> ingestion_run
 -> derivation / derivation_version
 -> derivation_run (+ derivation_run_input)
 -> forecast_run / canonical cell forecast
```

A single logical forecast run may consume multiple source artifacts/windows. This is required for dateline-split or geographically separate acquisition windows.

### Forecast completeness

Completeness is not merely received steps / expected steps. Production completeness must be defined against a target-set/version and include at least expected forecast steps, target cells, required variables and required acquisition/source inputs.

### Gas/weather boundary

Weather provides physical temperature and other meteorology. Gas chooses the geography and weighting used for demand interpretation. For spatially distributed HDD/CDD, the intended scientific order is:

```text
cell temperature
 -> cell HDD/CDD (nonlinear transformation)
 -> cell weighting
 -> regional HDD/CDD
```

Do not average temperature first and then apply the degree-day `max()` transform unless a separately defined methodology explicitly intends that product.

### Storage

PostgreSQL is hot operational/canonical storage. Long historical forecast vintages may later move to compressed columnar analytical storage while retaining lineage and discoverability. Native provider artifacts can be retained in cold/source archives where justified.
