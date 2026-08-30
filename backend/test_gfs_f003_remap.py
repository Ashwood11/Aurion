from pathlib import Path
from collections import defaultdict
from datetime import datetime, timezone, timedelta
import math

import requests
import eccodes
import h3


# ======================================================================
# CONFIG
# ======================================================================

OUTPUT_DIR = Path("data/weather/gfs/test")
OUTPUT_DIR.mkdir(parents=True, exist_ok=True)

GRIB_FILE = OUTPUT_DIR / "gfs_20260828_06_f003_oklahoma_halo.grib2"

FILTER_URL = "https://nomads.ncep.noaa.gov/cgi-bin/filter_gfs_0p25.pl"

HEADERS = {
    "User-Agent": "Aurion Weather Research/0.1"
}

H3_RESOLUTION = 5

# ----------------------------------------------------------------------
# Core target area
#
# These are the points used to decide which H3 cells belong to our test.
# ----------------------------------------------------------------------

CORE_MIN_LAT = 35.0
CORE_MAX_LAT = 36.0

CORE_MIN_LON = -98.0
CORE_MAX_LON = -97.0


# ----------------------------------------------------------------------
# Download halo
#
# GFS grid spacing = 0.25 degrees.
#
# We fetch one extra native grid step around the target area so H3
# centres near the boundary still have four surrounding native points.
# ----------------------------------------------------------------------

DOWNLOAD_MIN_LAT = 34.75
DOWNLOAD_MAX_LAT = 36.25

DOWNLOAD_MIN_LON = -98.25
DOWNLOAD_MAX_LON = -96.75


PARAMS = {
    "file": "gfs.t06z.pgrb2.0p25.f003",

    # Levels
    "lev_2_m_above_ground": "on",
    "lev_10_m_above_ground": "on",
    "lev_surface": "on",

    # Variables
    "var_TMP": "on",
    "var_DPT": "on",
    "var_RH": "on",
    "var_UGRD": "on",
    "var_VGRD": "on",
    "var_PRES": "on",
    "var_APCP": "on",

    # Halo region
    "subregion": "",
    "leftlon": DOWNLOAD_MIN_LON,
    "rightlon": DOWNLOAD_MAX_LON,
    "toplat": DOWNLOAD_MAX_LAT,
    "bottomlat": DOWNLOAD_MIN_LAT,

    # GFS run
    "dir": "/gfs.20260828/06/atmos",
}


# ======================================================================
# EXACT GFS FIELD SELECTORS
# ======================================================================

FIELD_SELECTORS = {
    "AIR_TEMP_2M_INSTANT": {
        "paramId": 167,
        "typeOfLevel": "heightAboveGround",
        "level": 2,
        "stepType": "instant",
    },

    "DEW_POINT_2M_INSTANT": {
        "paramId": 168,
        "typeOfLevel": "heightAboveGround",
        "level": 2,
        "stepType": "instant",
    },

    "RELATIVE_HUMIDITY_2M_INSTANT": {
        "paramId": 260242,
        "typeOfLevel": "heightAboveGround",
        "level": 2,
        "stepType": "instant",
    },

    "WIND_U_10M_INSTANT": {
        "paramId": 165,
        "typeOfLevel": "heightAboveGround",
        "level": 10,
        "stepType": "instant",
    },

    "WIND_V_10M_INSTANT": {
        "paramId": 166,
        "typeOfLevel": "heightAboveGround",
        "level": 10,
        "stepType": "instant",
    },

    "SURFACE_PRESSURE_INSTANT": {
        "paramId": 134,
        "typeOfLevel": "surface",
        "level": 0,
        "stepType": "instant",
    },

    "PRECIP_INTERVAL_TOTAL": {
        "paramId": 228228,
        "typeOfLevel": "surface",
        "level": 0,
        "stepType": "accum",
    },
}


CONTINUOUS_FIELDS = {
    "AIR_TEMP_2M_INSTANT",
    "DEW_POINT_2M_INSTANT",
    "RELATIVE_HUMIDITY_2M_INSTANT",
    "WIND_U_10M_INSTANT",
    "WIND_V_10M_INSTANT",
    "SURFACE_PRESSURE_INSTANT",
}


PRECIP_FIELD = "PRECIP_INTERVAL_TOTAL"


# ======================================================================
# HELPERS
# ======================================================================

def safe_get(gid, key):
    try:
        return eccodes.codes_get(gid, key)
    except Exception:
        return None


def normalize_longitude(lon):
    if lon > 180:
        return lon - 360

    return lon


def convert_value(variable_code, raw_value):
    """
    Convert provider-native GFS values to Aurion canonical units.
    """

    if variable_code in {
        "AIR_TEMP_2M_INSTANT",
        "DEW_POINT_2M_INSTANT",
    }:
        # K -> deg C
        return raw_value - 273.15

    if variable_code == "SURFACE_PRESSURE_INSTANT":
        # Pa -> hPa
        return raw_value * 0.01

    # RH: %
    # U/V: m/s
    # precipitation: kg/m2 numerically equals mm liquid water
    return raw_value


def message_matches(gid, selector):
    return (
        safe_get(gid, "paramId") == selector["paramId"]
        and safe_get(gid, "typeOfLevel")
        == selector["typeOfLevel"]
        and safe_get(gid, "level") == selector["level"]
        and safe_get(gid, "stepType") == selector["stepType"]
    )


def canonical_variable_for_message(gid):
    for variable_code, selector in FIELD_SELECTORS.items():
        if message_matches(gid, selector):
            return variable_code

    return None


def duplicate_signature(gid):
    return (
        safe_get(gid, "paramId"),
        safe_get(gid, "typeOfLevel"),
        safe_get(gid, "level"),
        safe_get(gid, "stepType"),
        safe_get(gid, "startStep"),
        safe_get(gid, "endStep"),
        safe_get(gid, "validityDate"),
        safe_get(gid, "validityTime"),
        safe_get(gid, "dataDate"),
        safe_get(gid, "dataTime"),
        safe_get(gid, "productDefinitionTemplateNumber"),
        safe_get(gid, "generatingProcessIdentifier"),
    )


# ======================================================================
# DOWNLOAD
# ======================================================================

def download_subset():
    print("Requesting NOAA GFS halo subset...")

    response = requests.get(
        FILTER_URL,
        params=PARAMS,
        headers=HEADERS,
        timeout=120,
    )

    if response.status_code != 200:
        print(f"HTTP status: {response.status_code}")
        print(response.url)

        try:
            print(response.text[:1500])
        except Exception:
            pass

        response.raise_for_status()

    if not response.content.startswith(b"GRIB"):
        raise RuntimeError(
            "NOAA response did not contain GRIB2 data."
        )

    GRIB_FILE.write_bytes(response.content)

    print(f"Saved: {GRIB_FILE}")
    print(f"Size: {GRIB_FILE.stat().st_size:,} bytes")


# ======================================================================
# EXTRACT NATIVE GRID
# ======================================================================

def extract_native_fields():
    fields = {}

    seen_signatures = set()
    duplicate_counts = defaultdict(int)

    with GRIB_FILE.open("rb") as f:

        while True:

            gid = eccodes.codes_grib_new_from_file(f)

            if gid is None:
                break

            try:

                variable_code = canonical_variable_for_message(gid)

                if variable_code is None:
                    continue

                signature = duplicate_signature(gid)

                if signature in seen_signatures:
                    duplicate_counts[variable_code] += 1
                    continue

                seen_signatures.add(signature)

                points = eccodes.codes_grib_get_data(gid)

                grid = {}

                for point in points:

                    lat = round(float(point["lat"]), 8)

                    lon = round(
                        normalize_longitude(
                            float(point["lon"])
                        ),
                        8,
                    )

                    raw_value = float(point["value"])

                    grid[(lat, lon)] = convert_value(
                        variable_code,
                        raw_value,
                    )

                fields[variable_code] = {
                    "grid": grid,

                    "start_step": safe_get(
                        gid,
                        "startStep",
                    ),

                    "end_step": safe_get(
                        gid,
                        "endStep",
                    ),

                    "data_date": safe_get(
                        gid,
                        "dataDate",
                    ),

                    "data_time": safe_get(
                        gid,
                        "dataTime",
                    ),

                    "validity_date": safe_get(
                        gid,
                        "validityDate",
                    ),

                    "validity_time": safe_get(
                        gid,
                        "validityTime",
                    ),
                }

            finally:

                eccodes.codes_release(gid)

    return fields, duplicate_counts


# ======================================================================
# TARGET H3 CELLS
# ======================================================================

def build_target_h3_cells(fields):
    """
    Build the smoke-test target H3 cells from native GFS points inside
    the original 35-36 N, 98-97 W core region.

    This preserves the 25-cell target set from the earlier H3 test.
    """

    reference = fields["AIR_TEMP_2M_INSTANT"]["grid"]

    cells = set()

    for lat, lon in reference.keys():

        if (
            CORE_MIN_LAT <= lat <= CORE_MAX_LAT
            and CORE_MIN_LON <= lon <= CORE_MAX_LON
        ):

            cell = h3.latlng_to_cell(
                lat,
                lon,
                H3_RESOLUTION,
            )

            cells.add(cell)

    return sorted(cells)


# ======================================================================
# GRID UTILITIES
# ======================================================================

def sorted_grid_axes(grid):
    lats = sorted({
        lat
        for lat, _ in grid.keys()
    })

    lons = sorted({
        lon
        for _, lon in grid.keys()
    })

    return lats, lons


def find_bracket(values, target):
    """
    Find:
        lower <= target <= upper

    Returns (lower, upper).

    Returns None when the point lies outside the available source grid.
    """

    if target < values[0] or target > values[-1]:
        return None

    for i in range(len(values) - 1):

        low = values[i]
        high = values[i + 1]

        if low <= target <= high:
            return low, high

    # Exact match with final grid coordinate.
    if math.isclose(
        target,
        values[-1],
        rel_tol=0,
        abs_tol=1e-9,
    ):
        return values[-1], values[-1]

    return None


# ======================================================================
# BILINEAR INTERPOLATION
# ======================================================================

def bilinear_interpolate(grid, target_lat, target_lon):
    lats, lons = sorted_grid_axes(grid)

    lat_bracket = find_bracket(
        lats,
        target_lat,
    )

    lon_bracket = find_bracket(
        lons,
        target_lon,
    )

    if lat_bracket is None or lon_bracket is None:
        raise ValueError(
            "H3 centre lies outside downloaded GFS halo."
        )

    lat1, lat2 = lat_bracket
    lon1, lon2 = lon_bracket

    # ------------------------------------------------------------------
    # Exact native point
    # ------------------------------------------------------------------

    if (
        math.isclose(
            lat1,
            lat2,
            abs_tol=1e-12,
        )
        and math.isclose(
            lon1,
            lon2,
            abs_tol=1e-12,
        )
    ):

        return grid[(lat1, lon1)]

    # ------------------------------------------------------------------
    # Exact latitude line
    # ------------------------------------------------------------------

    if math.isclose(
        lat1,
        lat2,
        abs_tol=1e-12,
    ):

        q1 = grid[(lat1, lon1)]
        q2 = grid[(lat1, lon2)]

        weight = (
            (target_lon - lon1)
            / (lon2 - lon1)
        )

        return q1 + weight * (q2 - q1)

    # ------------------------------------------------------------------
    # Exact longitude line
    # ------------------------------------------------------------------

    if math.isclose(
        lon1,
        lon2,
        abs_tol=1e-12,
    ):

        q1 = grid[(lat1, lon1)]
        q2 = grid[(lat2, lon1)]

        weight = (
            (target_lat - lat1)
            / (lat2 - lat1)
        )

        return q1 + weight * (q2 - q1)

    # ------------------------------------------------------------------
    # Four surrounding source points
    # ------------------------------------------------------------------

    q11 = grid[(lat1, lon1)]
    q21 = grid[(lat1, lon2)]
    q12 = grid[(lat2, lon1)]
    q22 = grid[(lat2, lon2)]

    lon_weight = (
        (target_lon - lon1)
        / (lon2 - lon1)
    )

    lat_weight = (
        (target_lat - lat1)
        / (lat2 - lat1)
    )

    lower = (
        q11 * (1.0 - lon_weight)
        + q21 * lon_weight
    )

    upper = (
        q12 * (1.0 - lon_weight)
        + q22 * lon_weight
    )

    value = (
        lower * (1.0 - lat_weight)
        + upper * lat_weight
    )

    return value


# ======================================================================
# PROVISIONAL PRECIPITATION REMAP
# ======================================================================

def nearest_native_value(
    grid,
    target_lat,
    target_lon,
):
    """
    Temporary smoke-test precipitation remapping.

    Production precipitation remapping will later be replaced by an
    area/conservative treatment.
    """

    nearest_key = None
    nearest_distance = None

    for lat, lon in grid.keys():

        distance = (
            (lat - target_lat) ** 2
            + (lon - target_lon) ** 2
        )

        if (
            nearest_distance is None
            or distance < nearest_distance
        ):

            nearest_distance = distance
            nearest_key = (lat, lon)

    return (
        grid[nearest_key],
        nearest_key,
    )


# ======================================================================
# TIME
# ======================================================================

def parse_run_time(field):
    data_date = str(field["data_date"])

    data_time = int(field["data_time"])

    hour = data_time // 100
    minute = data_time % 100

    return datetime(
        int(data_date[0:4]),
        int(data_date[4:6]),
        int(data_date[6:8]),
        hour,
        minute,
        tzinfo=timezone.utc,
    )


# ======================================================================
# BUILD CANDIDATE CELL_FORECAST ROWS
# ======================================================================

def build_candidate_rows(fields, target_cells):
    reference = fields["AIR_TEMP_2M_INSTANT"]

    initialization_time = parse_run_time(
        reference
    )

    valid_time = initialization_time + timedelta(
        hours=reference["end_step"]
    )

    rows = []

    for cell in target_cells:

        center_lat, center_lon = (
            h3.cell_to_latlng(cell)
        )

        row = {
            "h3_cell": cell,

            "h3_resolution": H3_RESOLUTION,

            "center_lat": center_lat,
            "center_lon": center_lon,

            "initialization_time": initialization_time,

            "valid_time": valid_time,

            "lead_minutes":
                reference["end_step"] * 60,

            "period_start": None,
            "period_end": None,

            "air_temperature_c": None,
            "dew_point_c": None,
            "relative_humidity_pct": None,

            "surface_pressure_hpa": None,

            "wind_u_ms": None,
            "wind_v_ms": None,

            "precipitation_mm": None,

            "precip_source_lat": None,
            "precip_source_lon": None,

            "coverage_fraction": 1.0,
        }

        # --------------------------------------------------------------
        # Continuous variables
        # --------------------------------------------------------------

        row["air_temperature_c"] = bilinear_interpolate(
            fields[
                "AIR_TEMP_2M_INSTANT"
            ]["grid"],
            center_lat,
            center_lon,
        )

        row["dew_point_c"] = bilinear_interpolate(
            fields[
                "DEW_POINT_2M_INSTANT"
            ]["grid"],
            center_lat,
            center_lon,
        )

        row["relative_humidity_pct"] = bilinear_interpolate(
            fields[
                "RELATIVE_HUMIDITY_2M_INSTANT"
            ]["grid"],
            center_lat,
            center_lon,
        )

        row["surface_pressure_hpa"] = bilinear_interpolate(
            fields[
                "SURFACE_PRESSURE_INSTANT"
            ]["grid"],
            center_lat,
            center_lon,
        )

        row["wind_u_ms"] = bilinear_interpolate(
            fields[
                "WIND_U_10M_INSTANT"
            ]["grid"],
            center_lat,
            center_lon,
        )

        row["wind_v_ms"] = bilinear_interpolate(
            fields[
                "WIND_V_10M_INSTANT"
            ]["grid"],
            center_lat,
            center_lon,
        )

        # --------------------------------------------------------------
        # Precipitation
        # --------------------------------------------------------------

        precip_field = fields[
            PRECIP_FIELD
        ]

        precip_value, precip_point = (
            nearest_native_value(
                precip_field["grid"],
                center_lat,
                center_lon,
            )
        )

        row["precipitation_mm"] = precip_value

        row["precip_source_lat"] = (
            precip_point[0]
        )

        row["precip_source_lon"] = (
            precip_point[1]
        )

        row["period_start"] = (
            initialization_time
            + timedelta(
                hours=precip_field["start_step"]
            )
        )

        row["period_end"] = (
            initialization_time
            + timedelta(
                hours=precip_field["end_step"]
            )
        )

        rows.append(row)

    return rows


# ======================================================================
# AUDIT OUTPUT
# ======================================================================

def print_candidate_rows(
    rows,
    duplicate_counts,
):
    print()
    print("=" * 120)
    print("AURION CANDIDATE H3 FORECAST ROWS")
    print("=" * 120)

    print()
    print(f"Candidate rows: {len(rows)}")

    print(
        "Continuous remapping: "
        "bilinear_to_h3_center"
    )

    print(
        "Wind remapping: "
        "bilinear_components_to_h3_center"
    )

    print(
        "Precipitation remapping: "
        "nearest_native_point_provisional"
    )

    print()

    if duplicate_counts:

        print("GRIB duplicates removed:")

        for code, count in duplicate_counts.items():
            print(f"  {code}: {count}")

    print()
    print("-" * 120)

    for row in rows:

        print(
            f"{row['h3_cell']} | "
            f"center="
            f"{row['center_lat']:.5f},"
            f"{row['center_lon']:.5f} | "
            f"T={row['air_temperature_c']:.2f} C | "
            f"Td={row['dew_point_c']:.2f} C | "
            f"RH={row['relative_humidity_pct']:.1f}% | "
            f"P={row['surface_pressure_hpa']:.2f} hPa | "
            f"U={row['wind_u_ms']:.2f} m/s | "
            f"V={row['wind_v_ms']:.2f} m/s | "
            f"Precip={row['precipitation_mm']:.2f} mm"
        )

    print()
    print("=" * 120)
    print("SAMPLE FULL ROW")
    print("=" * 120)

    sample = rows[len(rows) // 2]

    for key, value in sample.items():
        print(
            f"{key:<25} = {value}"
        )

    print()
    print("=" * 120)
    print("TIME CHECK")
    print("=" * 120)

    print(
        f"Initialization: "
        f"{sample['initialization_time'].isoformat()}"
    )

    print(
        f"Valid time:     "
        f"{sample['valid_time'].isoformat()}"
    )

    print(
        f"Lead minutes:   "
        f"{sample['lead_minutes']}"
    )

    print(
        f"Precip period:  "
        f"{sample['period_start'].isoformat()}"
        f" -> "
        f"{sample['period_end'].isoformat()}"
    )

    print()
    print(
        "NO DATABASE WRITES HAVE BEEN PERFORMED."
    )


# ======================================================================
# MAIN
# ======================================================================

if __name__ == "__main__":

    download_subset()

    fields, duplicate_counts = (
        extract_native_fields()
    )

    missing = (
        set(FIELD_SELECTORS)
        - set(fields)
    )

    if missing:
        raise RuntimeError(
            f"Required GFS fields missing: "
            f"{sorted(missing)}"
        )

    target_cells = build_target_h3_cells(
        fields
    )

    print()
    print(
        f"Target H3-5 cells: "
        f"{len(target_cells)}"
    )

    rows = build_candidate_rows(
        fields,
        target_cells,
    )

    print_candidate_rows(
        rows,
        duplicate_counts,
    )