from pathlib import Path


# ----------------------------------------------------------------------
# Provider / model identity
# ----------------------------------------------------------------------

PROVIDER_CODE = "NOAA"

GFS_MODEL_CODE = "GFS"

GFS_MODEL_VERSION_CODE = (
    "GFS_OPERATIONAL_2026"
)


# ----------------------------------------------------------------------
# Dataset identity
# ----------------------------------------------------------------------

DATASET_CODE = "GFS_0P25"

DATASET_VERSION_NAME = (
    "GFS_0P25_OPERATIONAL_2026"
)


# ----------------------------------------------------------------------
# Forecast products
# ----------------------------------------------------------------------

NATIVE_FORECAST_PRODUCT_CODE = (
    "NOAA_GFS_0P25_NATIVE"
)

H3_FORECAST_PRODUCT_CODE = (
    "AURION_GFS_H3_R5"
)


# ----------------------------------------------------------------------
# Derivation identity
# ----------------------------------------------------------------------

DERIVATION_CODE = (
    "GFS_0P25_TO_H3_R5"
)

DERIVATION_VERSION_NAME = "V1"


# ----------------------------------------------------------------------
# NOAA / NOMADS
# ----------------------------------------------------------------------

FILTER_URL = (
    "https://nomads.ncep.noaa.gov/"
    "cgi-bin/filter_gfs_0p25.pl"
)

USER_AGENT = (
    "Aurion Weather Research/0.1"
)


# ----------------------------------------------------------------------
# Native GFS configuration
# ----------------------------------------------------------------------

NATIVE_GRID_DEGREES = 0.25

NORMAL_CYCLES_UTC = (
    0,
    6,
    12,
    18,
)

MAX_FORECAST_HOUR = 384

EXPECTED_FORECAST_STEPS = 385


# ----------------------------------------------------------------------
# Automatic cycle selection
# ----------------------------------------------------------------------

# Conservative delay before Aurion considers a newly
# initialized GFS cycle ready for ingestion.
#
# This avoids attempting a cycle immediately at 00Z,
# 06Z, 12Z, or 18Z before NOAA has had time to publish
# the required files.
GFS_CYCLE_AVAILABILITY_DELAY_HOURS = 4


# ----------------------------------------------------------------------
# Canonical Aurion H3 grid
# ----------------------------------------------------------------------

H3_RESOLUTION = 5


# ----------------------------------------------------------------------
# Remapping policy
# ----------------------------------------------------------------------

CONTINUOUS_REMAP_METHOD = (
    "bilinear_to_h3_center"
)

WIND_REMAP_METHOD = (
    "bilinear_components_to_h3_center"
)

PRECIPITATION_REMAP_METHOD = (
    "nearest_native_point_provisional"
)

PRECIPITATION_REMAP_STATUS = (
    "provisional"
)


# ----------------------------------------------------------------------
# Ingestion pipeline identity
# ----------------------------------------------------------------------

INGESTION_RUN_TYPE = (
    "forecast_ingestion"
)

INGESTION_PIPELINE_VERSION = (
    "GFS_INGEST_V1"
)


# ----------------------------------------------------------------------
# Local raw-data storage
# ----------------------------------------------------------------------

WEATHER_DATA_ROOT = Path(
    "data/weather"
)

GFS_DATA_ROOT = (
    WEATHER_DATA_ROOT
    / "gfs"
)

GFS_RAW_ROOT = (
    GFS_DATA_ROOT
    / "raw"
)

GFS_SUBSET_ROOT = (
    GFS_DATA_ROOT
    / "subsets"
)

GFS_TEST_ROOT = (
    GFS_DATA_ROOT
    / "test"
)