from __future__ import annotations

from collections import defaultdict
from dataclasses import dataclass
from pathlib import Path

import eccodes

from .selectors import (
    FIELD_SELECTORS,
    canonical_variable_for_grib,
)


@dataclass
class GFSField:
    canonical_variable_code: str

    values: dict[
        tuple[float, float],
        float,
    ]

    start_step: int | None
    end_step: int | None

    step_type: str | None

    param_id: int | None
    type_of_level: str | None
    level: int | None


@dataclass
class GFSReadResult:
    fields: dict[
        str,
        GFSField,
    ]

    duplicate_counts: dict[
        str,
        int,
    ]


def safe_get(
    gid,
    key: str,
):
    try:
        return eccodes.codes_get(
            gid,
            key,
        )

    except Exception:
        return None


def normalize_longitude(
    lon: float,
) -> float:
    if lon > 180.0:
        return lon - 360.0

    return lon


def convert_value(
    canonical_variable_code: str,
    raw_value: float,
) -> float:
    if canonical_variable_code in {
        "AIR_TEMP_2M_INSTANT",
        "DEW_POINT_2M_INSTANT",
    }:
        # Kelvin -> Celsius
        return raw_value - 273.15

    if (
        canonical_variable_code
        == "SURFACE_PRESSURE_INSTANT"
    ):
        # Pa -> hPa
        return raw_value * 0.01

    # RH already %
    # wind already m/s
    #
    # APCP kg/m² is numerically equivalent
    # to mm liquid water.
    return raw_value


def duplicate_signature(
    gid,
) -> tuple:
    return (
        safe_get(
            gid,
            "paramId",
        ),

        safe_get(
            gid,
            "typeOfLevel",
        ),

        safe_get(
            gid,
            "level",
        ),

        safe_get(
            gid,
            "stepType",
        ),

        safe_get(
            gid,
            "startStep",
        ),

        safe_get(
            gid,
            "endStep",
        ),

        safe_get(
            gid,
            "validityDate",
        ),

        safe_get(
            gid,
            "validityTime",
        ),

        safe_get(
            gid,
            "dataDate",
        ),

        safe_get(
            gid,
            "dataTime",
        ),

        safe_get(
            gid,
            "productDefinitionTemplateNumber",
        ),

        safe_get(
            gid,
            "generatingProcessIdentifier",
        ),
    )


def read_gfs_fields(
    path: Path,
) -> GFSReadResult:
    if not path.exists():
        raise FileNotFoundError(
            f"GRIB file not found: {path}"
        )

    fields: dict[
        str,
        GFSField,
    ] = {}

    seen_signatures = set()

    duplicate_counts = defaultdict(
        int
    )

    with path.open("rb") as file_handle:

        while True:
            gid = (
                eccodes
                .codes_grib_new_from_file(
                    file_handle
                )
            )

            if gid is None:
                break

            try:
                param_id = safe_get(
                    gid,
                    "paramId",
                )

                type_of_level = safe_get(
                    gid,
                    "typeOfLevel",
                )

                level = safe_get(
                    gid,
                    "level",
                )

                step_type = safe_get(
                    gid,
                    "stepType",
                )

                variable_code = (
                    canonical_variable_for_grib(
                        param_id=(
                            param_id
                        ),

                        type_of_level=(
                            type_of_level
                        ),

                        level=(
                            level
                        ),

                        step_type=(
                            step_type
                        ),
                    )
                )

                if variable_code is None:
                    continue

                signature = (
                    duplicate_signature(
                        gid
                    )
                )

                if (
                    signature
                    in seen_signatures
                ):
                    duplicate_counts[
                        variable_code
                    ] += 1

                    continue

                seen_signatures.add(
                    signature
                )

                values = {}

                for point in (
                    eccodes
                    .codes_grib_get_data(
                        gid
                    )
                ):
                    lat = round(
                        float(
                            point["lat"]
                        ),
                        8,
                    )

                    lon = round(
                        normalize_longitude(
                            float(
                                point["lon"]
                            )
                        ),
                        8,
                    )

                    raw_value = float(
                        point["value"]
                    )

                    values[
                        (
                            lat,
                            lon,
                        )
                    ] = convert_value(
                        variable_code,
                        raw_value,
                    )

                fields[
                    variable_code
                ] = GFSField(
                    canonical_variable_code=(
                        variable_code
                    ),

                    values=values,

                    start_step=(
                        safe_get(
                            gid,
                            "startStep",
                        )
                    ),

                    end_step=(
                        safe_get(
                            gid,
                            "endStep",
                        )
                    ),

                    step_type=(
                        step_type
                    ),

                    param_id=(
                        param_id
                    ),

                    type_of_level=(
                        type_of_level
                    ),

                    level=(
                        level
                    ),
                )

            finally:
                eccodes.codes_release(
                    gid
                )

    return GFSReadResult(
        fields=fields,

        duplicate_counts=dict(
            duplicate_counts
        ),
    )


def validate_required_fields(
    result: GFSReadResult,
    *,
    forecast_hour: int | None = None,
) -> None:
    expected = set(
        FIELD_SELECTORS
    )

    # --------------------------------------------------------------
    # F000 edge case
    #
    # At forecast hour zero there is no preceding
    # accumulation period. Therefore GFS may legitimately
    # omit APCP / PRECIP_INTERVAL_TOTAL.
    # --------------------------------------------------------------

    if forecast_hour == 0:
        expected.discard(
            "PRECIP_INTERVAL_TOTAL"
        )

    actual = set(
        result.fields
    )

    missing = (
        expected
        - actual
    )

    if missing:
        raise RuntimeError(
            "Missing required GFS fields: "
            f"{sorted(missing)}"
        )