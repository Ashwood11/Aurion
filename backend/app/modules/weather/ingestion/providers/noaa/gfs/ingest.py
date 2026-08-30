from __future__ import annotations

from datetime import (
    datetime,
    timezone,
)
from pathlib import Path
import json

from .config import (
    FILTER_URL,
)

from .downloader import (
    GFSSubsetBounds,
    download_gfs_subset,
)

from .grib_reader import (
    read_gfs_fields,
    validate_required_fields,
)

from .remapper import (
    H3TargetBounds,
    H3ForecastRow,
    remap_to_h3,
)

from .provenance import (
    GFSProvenanceContext,
    register_gfs_provenance,
)


def context_from_provenance(
    provenance: GFSProvenanceContext,
) -> dict:
    return {
        "forecast_run_id": (
            provenance
            .derived_forecast_run_id
        ),

        "forecast_member_id": (
            provenance
            .derived_forecast_member_id
        ),

        "forecast_product_id": (
            provenance
            .derived_forecast_product_id
        ),

        "ingestion_run_id": (
            provenance
            .ingestion_run_id
        ),

        "derivation_run_id": (
            provenance
            .derivation_run_id
        ),
    }


def resolve_provisional_status_id(
    conn,
) -> int:
    with conn.cursor() as cur:

        cur.execute(
            """
            SELECT
                observation_record_status_id
            FROM weather.observation_record_status
            WHERE code = 'PROVISIONAL'
            """
        )

        row = cur.fetchone()

        if row is None:
            raise RuntimeError(
                "PROVISIONAL record "
                "status not found."
            )

        return row[0]


def resolve_grid_cell_ids(
    conn,
    rows: list[
        H3ForecastRow
    ],
) -> dict[
    str,
    int,
]:
    result = {}

    with conn.cursor() as cur:

        for row in rows:
            cur.execute(
                """
                SELECT
                    grid_cell_id
                FROM weather.grid_cell
                WHERE h3_index =
                      %s::h3index
                  AND resolution = 5
                """,
                (
                    row.h3_index,
                ),
            )

            db_row = (
                cur.fetchone()
            )

            if db_row is None:
                raise RuntimeError(
                    "Missing canonical "
                    "grid cell: "
                    f"{row.h3_index}"
                )

            result[
                row.h3_index
            ] = db_row[0]

    return result


def write_cell_forecasts(
    conn,
    *,
    rows: list[
        H3ForecastRow
    ],
    provenance: (
        GFSProvenanceContext
    ),
    record_status_id: int,
    grid_cell_ids: dict[
        str,
        int,
    ],
) -> int:
    context = (
        context_from_provenance(
            provenance
        )
    )

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
            %s,
            %s,
            %s,
            %s,

            %s,
            %s,
            %s,
            %s,

            %s,

            %s,
            %s,

            1,
            true,

            %s,
            %s,
            %s,
            %s,

            %s,

            %s,
            %s,

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
                EXCLUDED
                .observation_record_status_id,

            ingestion_run_id =
                EXCLUDED.ingestion_run_id,

            derivation_run_id =
                EXCLUDED.derivation_run_id,

            is_preferred =
                EXCLUDED.is_preferred,

            air_temperature_2m_c =
                EXCLUDED
                .air_temperature_2m_c,

            dew_point_2m_c =
                EXCLUDED
                .dew_point_2m_c,

            relative_humidity_2m_pct =
                EXCLUDED
                .relative_humidity_2m_pct,

            surface_pressure_hpa =
                EXCLUDED
                .surface_pressure_hpa,

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

    written = 0

    with conn.cursor() as cur:

        for row in rows:
            cur.execute(
                sql,
                (
                    context[
                        "forecast_run_id"
                    ],

                    context[
                        "forecast_member_id"
                    ],

                    context[
                        "forecast_product_id"
                    ],

                    grid_cell_ids[
                        row.h3_index
                    ],

                    row.valid_time,
                    row.period_start,
                    row.period_end,
                    row.lead_minutes,

                    record_status_id,

                    context[
                        "ingestion_run_id"
                    ],

                    context[
                        "derivation_run_id"
                    ],

                    row.air_temperature_2m_c,

                    row.dew_point_2m_c,

                    row.relative_humidity_2m_pct,

                    row.surface_pressure_hpa,

                    row.precipitation_mm,

                    row.wind_u_10m_ms,

                    row.wind_v_10m_ms,

                    row.coverage_fraction,

                    json.dumps(
                        row.metadata
                    ),
                ),
            )

            written += 1

    return written


def determine_forecast_hour(
    result,
) -> int:
    """
    Determine the GFS forecast hour using the
    instantaneous 2m air-temperature field.

    This avoids relying on the filename.
    """

    reference = (
        result.fields[
            "AIR_TEMP_2M_INSTANT"
        ]
    )

    if reference.end_step is None:
        raise RuntimeError(
            "Cannot determine GFS "
            "forecast hour because "
            "AIR_TEMP_2M_INSTANT has "
            "no end_step."
        )

    return int(
        reference.end_step
    )


def ingest_existing_gfs_subset(
    *,
    conn,
    grib_path: Path,
    initialization_time: datetime,
    target_bounds: H3TargetBounds,
    provenance: (
        GFSProvenanceContext
    ),
) -> int:
    if (
        initialization_time
        .tzinfo
        is None
    ):
        raise ValueError(
            "initialization_time must "
            "be timezone-aware."
        )

    initialization_time = (
        initialization_time
        .astimezone(
            timezone.utc
        )
    )

    # --------------------------------------------------------------
    # Read GRIB
    # --------------------------------------------------------------

    result = (
        read_gfs_fields(
            grib_path
        )
    )

    # --------------------------------------------------------------
    # Determine actual GRIB F-hour
    # --------------------------------------------------------------

    forecast_hour = (
        determine_forecast_hour(
            result
        )
    )

    # --------------------------------------------------------------
    # Validate required scientific fields
    #
    # F000 is allowed to omit accumulated precipitation.
    # --------------------------------------------------------------

    validate_required_fields(
        result,
        forecast_hour=(
            forecast_hour
        ),
    )

    # --------------------------------------------------------------
    # H3 remapping
    # --------------------------------------------------------------

    rows = (
        remap_to_h3(
            result=result,

            initialization_time=(
                initialization_time
            ),

            target_bounds=(
                target_bounds
            ),
        )
    )

    if not rows:
        raise RuntimeError(
            "GFS remapping produced "
            "zero H3 rows."
        )

    # --------------------------------------------------------------
    # Database reference resolution
    # --------------------------------------------------------------

    record_status_id = (
        resolve_provisional_status_id(
            conn
        )
    )

    grid_cell_ids = (
        resolve_grid_cell_ids(
            conn,
            rows,
        )
    )

    # --------------------------------------------------------------
    # Forecast write
    # --------------------------------------------------------------

    return (
        write_cell_forecasts(
            conn,

            rows=rows,

            provenance=(
                provenance
            ),

            record_status_id=(
                record_status_id
            ),

            grid_cell_ids=(
                grid_cell_ids
            ),
        )
    )


def ingest_gfs_forecast_hour(
    *,
    conn,
    initialization_time: datetime,
    forecast_hour: int,
    download_bounds: (
        GFSSubsetBounds
    ),
    target_bounds: (
        H3TargetBounds
    ),
    output_path: (
        Path
        | None
    ) = None,
) -> tuple[
    int,
    GFSProvenanceContext,
    Path,
]:
    if (
        initialization_time
        .tzinfo
        is None
    ):
        raise ValueError(
            "initialization_time must "
            "be timezone-aware."
        )

    initialization_time = (
        initialization_time
        .astimezone(
            timezone.utc
        )
    )

    if forecast_hour < 0:
        raise ValueError(
            "forecast_hour cannot "
            "be negative."
        )

    # --------------------------------------------------------------
    # 1. Download
    # --------------------------------------------------------------

    grib_path = (
        download_gfs_subset(
            initialization_time=(
                initialization_time
            ),

            forecast_hour=(
                forecast_hour
            ),

            bounds=(
                download_bounds
            ),

            output_path=(
                output_path
            ),
        )
    )

    # --------------------------------------------------------------
    # 2. Register full provenance
    # --------------------------------------------------------------

    provenance = (
        register_gfs_provenance(
            conn,

            grib_path=(
                grib_path
            ),

            source_uri=(
                FILTER_URL
            ),

            initialization_time=(
                initialization_time
            ),

            forecast_hour=(
                forecast_hour
            ),
        )
    )

    # --------------------------------------------------------------
    # 3. Parse + validate + remap + write
    # --------------------------------------------------------------

    rows_written = (
        ingest_existing_gfs_subset(
            conn=conn,

            grib_path=(
                grib_path
            ),

            initialization_time=(
                initialization_time
            ),

            target_bounds=(
                target_bounds
            ),

            provenance=(
                provenance
            ),
        )
    )

    return (
        rows_written,
        provenance,
        grib_path,
    )