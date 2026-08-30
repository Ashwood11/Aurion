from pathlib import Path
from collections import defaultdict
from datetime import datetime, timezone, timedelta
import math
import json
import getpass

import eccodes
import h3
import psycopg


# ======================================================================
# CONFIG
# ======================================================================

GRIB_FILE = Path(
    "data/weather/gfs/test/"
    "gfs_20260828_06_f003_oklahoma_halo.grib2"
)

H3_RESOLUTION = 5

INITIALIZATION_TIME = datetime(
    2026,
    8,
    28,
    6,
    0,
    tzinfo=timezone.utc,
)

FORECAST_PRODUCT_CODE = "AURION_GFS_H3_R5"

CORE_MIN_LAT = 35.0
CORE_MAX_LAT = 36.0
CORE_MIN_LON = -98.0
CORE_MAX_LON = -97.0


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


# ======================================================================
# GRIB HELPERS
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
    if variable_code in {
        "AIR_TEMP_2M_INSTANT",
        "DEW_POINT_2M_INSTANT",
    }:
        return raw_value - 273.15

    if variable_code == "SURFACE_PRESSURE_INSTANT":
        return raw_value * 0.01

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
    for code, selector in FIELD_SELECTORS.items():
        if message_matches(gid, selector):
            return code

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
# EXTRACT SOURCE FIELDS
# ======================================================================

def extract_native_fields():
    fields = {}

    seen = set()
    duplicates = defaultdict(int)

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

                if signature in seen:
                    duplicates[variable_code] += 1
                    continue

                seen.add(signature)

                grid = {}

                for point in eccodes.codes_grib_get_data(gid):

                    lat = round(
                        float(point["lat"]),
                        8,
                    )

                    lon = round(
                        normalize_longitude(
                            float(point["lon"])
                        ),
                        8,
                    )

                    grid[(lat, lon)] = convert_value(
                        variable_code,
                        float(point["value"]),
                    )

                fields[variable_code] = {
                    "grid": grid,
                    "start_step": safe_get(gid, "startStep"),
                    "end_step": safe_get(gid, "endStep"),
                }

            finally:
                eccodes.codes_release(gid)

    return fields, duplicates


# ======================================================================
# H3 TARGETS
# ======================================================================

def build_target_h3_cells(fields):
    reference = fields["AIR_TEMP_2M_INSTANT"]["grid"]

    cells = set()

    for lat, lon in reference:

        if (
            CORE_MIN_LAT <= lat <= CORE_MAX_LAT
            and CORE_MIN_LON <= lon <= CORE_MAX_LON
        ):
            cells.add(
                h3.latlng_to_cell(
                    lat,
                    lon,
                    H3_RESOLUTION,
                )
            )

    return sorted(cells)


# ======================================================================
# INTERPOLATION
# ======================================================================

def sorted_axes(grid):
    lats = sorted({
        lat
        for lat, _ in grid
    })

    lons = sorted({
        lon
        for _, lon in grid
    })

    return lats, lons


def find_bracket(values, target):
    if target < values[0] or target > values[-1]:
        return None

    for i in range(len(values) - 1):

        low = values[i]
        high = values[i + 1]

        if low <= target <= high:
            return low, high

    if math.isclose(
        target,
        values[-1],
        abs_tol=1e-9,
    ):
        return values[-1], values[-1]

    return None


def bilinear_interpolate(
    grid,
    target_lat,
    target_lon,
):
    lats, lons = sorted_axes(grid)

    lat_bracket = find_bracket(
        lats,
        target_lat,
    )

    lon_bracket = find_bracket(
        lons,
        target_lon,
    )

    if (
        lat_bracket is None
        or lon_bracket is None
    ):
        raise RuntimeError(
            "Target lies outside GFS halo."
        )

    lat1, lat2 = lat_bracket
    lon1, lon2 = lon_bracket

    if (
        math.isclose(lat1, lat2, abs_tol=1e-12)
        and math.isclose(lon1, lon2, abs_tol=1e-12)
    ):
        return grid[(lat1, lon1)]

    if math.isclose(lat1, lat2, abs_tol=1e-12):

        a = grid[(lat1, lon1)]
        b = grid[(lat1, lon2)]

        weight = (
            (target_lon - lon1)
            / (lon2 - lon1)
        )

        return a + weight * (b - a)

    if math.isclose(lon1, lon2, abs_tol=1e-12):

        a = grid[(lat1, lon1)]
        b = grid[(lat2, lon1)]

        weight = (
            (target_lat - lat1)
            / (lat2 - lat1)
        )

        return a + weight * (b - a)

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

    return (
        lower * (1.0 - lat_weight)
        + upper * lat_weight
    )


def nearest_native_value(
    grid,
    target_lat,
    target_lon,
):
    nearest = None
    nearest_distance = None

    for lat, lon in grid:

        distance = (
            (lat - target_lat) ** 2
            + (lon - target_lon) ** 2
        )

        if (
            nearest_distance is None
            or distance < nearest_distance
        ):
            nearest = (lat, lon)
            nearest_distance = distance

    return grid[nearest], nearest


# ======================================================================
# BUILD 25 CANDIDATE ROWS
# ======================================================================

def build_rows(fields, cells):
    reference = fields[
        "AIR_TEMP_2M_INSTANT"
    ]

    valid_time = (
        INITIALIZATION_TIME
        + timedelta(
            hours=reference["end_step"]
        )
    )

    precip_field = fields[
        "PRECIP_INTERVAL_TOTAL"
    ]

    period_start = (
        INITIALIZATION_TIME
        + timedelta(
            hours=precip_field["start_step"]
        )
    )

    period_end = (
        INITIALIZATION_TIME
        + timedelta(
            hours=precip_field["end_step"]
        )
    )

    rows = []

    for h3_cell in cells:

        lat, lon = h3.cell_to_latlng(
            h3_cell
        )

        precip_value, precip_source = (
            nearest_native_value(
                precip_field["grid"],
                lat,
                lon,
            )
        )

        rows.append(
            {
                "h3_cell": h3_cell,
                "valid_time": valid_time,
                "period_start": period_start,
                "period_end": period_end,
                "lead_minutes": (
                    reference["end_step"] * 60
                ),

                "air_temperature_2m_c":
                    bilinear_interpolate(
                        fields[
                            "AIR_TEMP_2M_INSTANT"
                        ]["grid"],
                        lat,
                        lon,
                    ),

                "dew_point_2m_c":
                    bilinear_interpolate(
                        fields[
                            "DEW_POINT_2M_INSTANT"
                        ]["grid"],
                        lat,
                        lon,
                    ),

                "relative_humidity_2m_pct":
                    bilinear_interpolate(
                        fields[
                            "RELATIVE_HUMIDITY_2M_INSTANT"
                        ]["grid"],
                        lat,
                        lon,
                    ),

                "surface_pressure_hpa":
                    bilinear_interpolate(
                        fields[
                            "SURFACE_PRESSURE_INSTANT"
                        ]["grid"],
                        lat,
                        lon,
                    ),

                "precipitation_mm":
                    precip_value,

                "wind_u_10m_ms":
                    bilinear_interpolate(
                        fields[
                            "WIND_U_10M_INSTANT"
                        ]["grid"],
                        lat,
                        lon,
                    ),

                "wind_v_10m_ms":
                    bilinear_interpolate(
                        fields[
                            "WIND_V_10M_INSTANT"
                        ]["grid"],
                        lat,
                        lon,
                    ),

                "coverage_fraction": 1.0,

                "metadata": {
                    "test_ingestion": True,

                    "continuous_remapping":
                        "bilinear_to_h3_center",

                    "wind_remapping":
                        "bilinear_components_to_h3_center",

                    "precipitation_remapping":
                        "nearest_native_point_provisional",

                    "precipitation_source_lat":
                        precip_source[0],

                    "precipitation_source_lon":
                        precip_source[1],

                    "period_fields_apply_to":
                        [
                            "precipitation_mm"
                        ],

                    "instant_fields_apply_at":
                        valid_time.isoformat(),
                },
            }
        )

    return rows


# ======================================================================
# DATABASE LOOKUPS
# ======================================================================

def get_pipeline_ids(conn):
    with conn.cursor() as cur:

        cur.execute(
            """
            SELECT
                fr.forecast_run_id,
                fm.forecast_member_id,
                fp.forecast_product_id,
                ir.ingestion_run_id,
                dr.derivation_run_id
            FROM weather.forecast_run fr

            JOIN weather.forecast_product fp
              ON fp.forecast_product_id =
                 fr.forecast_product_id

            JOIN weather.forecast_member fm
              ON fm.forecast_run_id =
                 fr.forecast_run_id
             AND fm.member_code = 'det'

            JOIN weather.forecast_run_ingestion fri
              ON fri.forecast_run_id =
                 fr.forecast_run_id

            JOIN weather.ingestion_run ir
              ON ir.ingestion_run_id =
                 fri.ingestion_run_id

            JOIN weather.source_artifact sa
              ON sa.source_artifact_id =
                 ir.source_artifact_id

            JOIN weather.derivation_run dr
              ON dr.ingestion_run_id =
                 ir.ingestion_run_id

            WHERE fp.code = %s
              AND fr.initialization_time = %s
              AND sa.filename =
                  'gfs_20260828_06_f003_oklahoma_halo.grib2'
            """,
            (
                FORECAST_PRODUCT_CODE,
                INITIALIZATION_TIME,
            ),
        )

        result = cur.fetchone()

        if result is None:
            raise RuntimeError(
                "Could not resolve Aurion "
                "forecast provenance IDs."
            )

        return {
            "forecast_run_id": result[0],
            "forecast_member_id": result[1],
            "forecast_product_id": result[2],
            "ingestion_run_id": result[3],
            "derivation_run_id": result[4],
        }


def get_status_id(conn):
    with conn.cursor() as cur:

        cur.execute(
            """
            SELECT observation_record_status_id
            FROM weather.observation_record_status
            WHERE code = 'PROVISIONAL'
            """
        )

        result = cur.fetchone()

        if result is None:
            raise RuntimeError(
                "PROVISIONAL status not found."
            )

        return result[0]


def get_grid_cell_ids(conn, h3_cells):
    result = {}

    with conn.cursor() as cur:

        for h3_cell in h3_cells:

            cur.execute(
                """
                SELECT grid_cell_id
                FROM weather.grid_cell
                WHERE h3_index = %s::h3index
                  AND resolution = 5
                """,
                (h3_cell,),
            )

            row = cur.fetchone()

            if row is None:
                raise RuntimeError(
                    f"H3 cell missing from "
                    f"weather.grid_cell: {h3_cell}"
                )

            result[h3_cell] = row[0]

    return result


# ======================================================================
# INSERT
# ======================================================================

def insert_rows(
    conn,
    rows,
    ids,
    status_id,
    grid_cell_ids,
):
    sql = """
        INSERT INTO weather.cell_forecast (
            forecast_run_id,
            forecast_member_id,
            forecast_product_id,
            grid_cell_id,

            valid_time,
            period_start,
            period_end,
            lead_minutes,

            observation_record_status_id,

            ingestion_run_id,
            derivation_run_id,

            revision_no,
            is_preferred,

            air_temperature_2m_c,
            dew_point_2m_c,
            relative_humidity_2m_pct,
            surface_pressure_hpa,
            precipitation_mm,

            wind_u_10m_ms,
            wind_v_10m_ms,

            coverage_fraction,
            metadata
        )

        VALUES (
            %s, %s, %s, %s,
            %s, %s, %s, %s,
            %s,
            %s, %s,
            1,
            true,
            %s, %s, %s, %s, %s,
            %s, %s,
            %s,
            %s::jsonb
        )

        ON CONFLICT (
            forecast_run_id,
            forecast_member_id,
            forecast_product_id,
            grid_cell_id,
            valid_time,
            revision_no
        )

        DO UPDATE SET
            period_start =
                EXCLUDED.period_start,

            period_end =
                EXCLUDED.period_end,

            lead_minutes =
                EXCLUDED.lead_minutes,

            observation_record_status_id =
                EXCLUDED.observation_record_status_id,

            ingestion_run_id =
                EXCLUDED.ingestion_run_id,

            derivation_run_id =
                EXCLUDED.derivation_run_id,

            is_preferred =
                EXCLUDED.is_preferred,

            air_temperature_2m_c =
                EXCLUDED.air_temperature_2m_c,

            dew_point_2m_c =
                EXCLUDED.dew_point_2m_c,

            relative_humidity_2m_pct =
                EXCLUDED.relative_humidity_2m_pct,

            surface_pressure_hpa =
                EXCLUDED.surface_pressure_hpa,

            precipitation_mm =
                EXCLUDED.precipitation_mm,

            wind_u_10m_ms =
                EXCLUDED.wind_u_10m_ms,

            wind_v_10m_ms =
                EXCLUDED.wind_v_10m_ms,

            coverage_fraction =
                EXCLUDED.coverage_fraction,

            metadata =
                EXCLUDED.metadata,

            processed_at =
                now()
    """

    with conn.cursor() as cur:

        for row in rows:

            cur.execute(
                sql,
                (
                    ids["forecast_run_id"],
                    ids["forecast_member_id"],
                    ids["forecast_product_id"],
                    grid_cell_ids[
                        row["h3_cell"]
                    ],

                    row["valid_time"],
                    row["period_start"],
                    row["period_end"],
                    row["lead_minutes"],

                    status_id,

                    ids["ingestion_run_id"],
                    ids["derivation_run_id"],

                    row[
                        "air_temperature_2m_c"
                    ],

                    row[
                        "dew_point_2m_c"
                    ],

                    row[
                        "relative_humidity_2m_pct"
                    ],

                    row[
                        "surface_pressure_hpa"
                    ],

                    row[
                        "precipitation_mm"
                    ],

                    row[
                        "wind_u_10m_ms"
                    ],

                    row[
                        "wind_v_10m_ms"
                    ],

                    row[
                        "coverage_fraction"
                    ],

                    json.dumps(
                        row["metadata"]
                    ),
                ),
            )


# ======================================================================
# VERIFY INSIDE TRANSACTION
# ======================================================================

def verify_insert(conn, ids):
    with conn.cursor() as cur:

        cur.execute(
            """
            SELECT
                count(*),

                min(air_temperature_2m_c),
                max(air_temperature_2m_c),

                min(surface_pressure_hpa),
                max(surface_pressure_hpa),

                min(precipitation_mm),
                max(precipitation_mm)

            FROM weather.cell_forecast

            WHERE forecast_run_id = %s
              AND forecast_member_id = %s
              AND forecast_product_id = %s
              AND valid_time =
                  '2026-08-28 09:00:00+00'
            """,
            (
                ids["forecast_run_id"],
                ids["forecast_member_id"],
                ids["forecast_product_id"],
            ),
        )

        return cur.fetchone()


# ======================================================================
# MAIN
# ======================================================================

if __name__ == "__main__":

    if not GRIB_FILE.exists():
        raise FileNotFoundError(
            f"Missing GRIB file: {GRIB_FILE}"
        )

    print("Reading GFS test artifact...")

    fields, duplicates = (
        extract_native_fields()
    )

    missing = (
        set(FIELD_SELECTORS)
        - set(fields)
    )

    if missing:
        raise RuntimeError(
            f"Missing required fields: "
            f"{sorted(missing)}"
        )

    cells = build_target_h3_cells(
        fields
    )

    rows = build_rows(
        fields,
        cells,
    )

    print(
        f"Candidate H3 rows: {len(rows)}"
    )

    if len(rows) != 25:
        raise RuntimeError(
            f"Expected 25 rows, got {len(rows)}"
        )

    password = getpass.getpass(
        "PostgreSQL password for postgres: "
    )

    conn_string = (
        "host=localhost "
        "port=5432 "
        "dbname=aurion "
        "user=postgres "
        f"password={password}"
    )

    with psycopg.connect(
        conn_string
    ) as conn:

        ids = get_pipeline_ids(
            conn
        )

        print()
        print("Resolved provenance:")
        print(ids)

        status_id = get_status_id(
            conn
        )

        print(
            f"PROVISIONAL status ID: "
            f"{status_id}"
        )

        grid_cell_ids = (
            get_grid_cell_ids(
                conn,
                cells,
            )
        )

        print(
            f"Resolved H3 cells: "
            f"{len(grid_cell_ids)}"
        )

        insert_rows(
            conn,
            rows,
            ids,
            status_id,
            grid_cell_ids,
        )

        verification = verify_insert(
            conn,
            ids,
        )

        print()
        print("Database verification:")
        print(
            f"Rows: {verification[0]}"
        )

        print(
            "Temperature range: "
            f"{verification[1]:.2f}"
            f" -> "
            f"{verification[2]:.2f} C"
        )

        print(
            "Pressure range: "
            f"{verification[3]:.2f}"
            f" -> "
            f"{verification[4]:.2f} hPa"
        )

        print(
            "Precipitation range: "
            f"{verification[5]:.2f}"
            f" -> "
            f"{verification[6]:.2f} mm"
        )

        if verification[0] != 25:
            raise RuntimeError(
                "Database verification "
                "did not return 25 rows."
            )

        # psycopg context commits automatically
        # only if no exception occurred.

    print()
    print(
        "SUCCESS: 25 provisional "
        "cell_forecast rows committed."
    )