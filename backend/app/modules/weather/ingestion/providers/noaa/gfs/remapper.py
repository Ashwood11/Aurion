from __future__ import annotations

from dataclasses import dataclass
from datetime import (
    datetime,
    timedelta,
    timezone,
)
import math

import h3

from .config import (
    H3_RESOLUTION,
    CONTINUOUS_REMAP_METHOD,
    WIND_REMAP_METHOD,
    PRECIPITATION_REMAP_METHOD,
    PRECIPITATION_REMAP_STATUS,
)

from .grib_reader import (
    GFSReadResult,
    GFSField,
)


@dataclass(frozen=True)
class H3TargetBounds:
    min_lat: float
    max_lat: float

    min_lon: float
    max_lon: float


@dataclass
class H3ForecastRow:
    h3_index: str

    center_lat: float
    center_lon: float

    valid_time: datetime

    period_start: (
        datetime
        | None
    )

    period_end: (
        datetime
        | None
    )

    lead_minutes: int

    air_temperature_2m_c: (
        float
        | None
    )

    dew_point_2m_c: (
        float
        | None
    )

    relative_humidity_2m_pct: (
        float
        | None
    )

    surface_pressure_hpa: (
        float
        | None
    )

    precipitation_mm: (
        float
        | None
    )

    wind_u_10m_ms: (
        float
        | None
    )

    wind_v_10m_ms: (
        float
        | None
    )

    coverage_fraction: (
        float
        | None
    )

    metadata: dict


def _sorted_axes(
    field: GFSField,
) -> tuple[
    list[float],
    list[float],
]:
    lats = sorted({
        lat
        for lat, _ in field.values
    })

    lons = sorted({
        lon
        for _, lon in field.values
    })

    return (
        lats,
        lons,
    )


def _find_bracket(
    values: list[float],
    target: float,
) -> tuple[
    float,
    float,
] | None:
    if target < values[0]:
        return None

    if target > values[-1]:
        return None

    for index in range(
        len(values) - 1
    ):
        low = values[
            index
        ]

        high = values[
            index + 1
        ]

        if (
            low
            <= target
            <= high
        ):
            return (
                low,
                high,
            )

    if math.isclose(
        target,
        values[-1],
        abs_tol=1e-9,
    ):
        return (
            values[-1],
            values[-1],
        )

    return None


def bilinear_interpolate(
    field: GFSField,
    target_lat: float,
    target_lon: float,
) -> float:
    lats, lons = (
        _sorted_axes(
            field
        )
    )

    lat_bracket = (
        _find_bracket(
            lats,
            target_lat,
        )
    )

    lon_bracket = (
        _find_bracket(
            lons,
            target_lon,
        )
    )

    if lat_bracket is None:
        raise RuntimeError(
            "Target latitude lies "
            "outside source halo."
        )

    if lon_bracket is None:
        raise RuntimeError(
            "Target longitude lies "
            "outside source halo."
        )

    lat1, lat2 = (
        lat_bracket
    )

    lon1, lon2 = (
        lon_bracket
    )

    values = (
        field.values
    )

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
        return values[
            (
                lat1,
                lon1,
            )
        ]

    if math.isclose(
        lat1,
        lat2,
        abs_tol=1e-12,
    ):
        a = values[
            (
                lat1,
                lon1,
            )
        ]

        b = values[
            (
                lat1,
                lon2,
            )
        ]

        weight = (
            target_lon
            - lon1
        ) / (
            lon2
            - lon1
        )

        return (
            a
            + weight
            * (
                b - a
            )
        )

    if math.isclose(
        lon1,
        lon2,
        abs_tol=1e-12,
    ):
        a = values[
            (
                lat1,
                lon1,
            )
        ]

        b = values[
            (
                lat2,
                lon1,
            )
        ]

        weight = (
            target_lat
            - lat1
        ) / (
            lat2
            - lat1
        )

        return (
            a
            + weight
            * (
                b - a
            )
        )

    q11 = values[
        (
            lat1,
            lon1,
        )
    ]

    q21 = values[
        (
            lat1,
            lon2,
        )
    ]

    q12 = values[
        (
            lat2,
            lon1,
        )
    ]

    q22 = values[
        (
            lat2,
            lon2,
        )
    ]

    lon_weight = (
        target_lon
        - lon1
    ) / (
        lon2
        - lon1
    )

    lat_weight = (
        target_lat
        - lat1
    ) / (
        lat2
        - lat1
    )

    lower = (
        q11
        * (
            1.0
            - lon_weight
        )
        + q21
        * lon_weight
    )

    upper = (
        q12
        * (
            1.0
            - lon_weight
        )
        + q22
        * lon_weight
    )

    return (
        lower
        * (
            1.0
            - lat_weight
        )
        + upper
        * lat_weight
    )


def nearest_native_value(
    field: GFSField,
    target_lat: float,
    target_lon: float,
) -> tuple[
    float,
    tuple[
        float,
        float,
    ],
]:
    nearest_point = None

    nearest_distance = None

    for lat, lon in (
        field.values
    ):
        distance = (
            (
                lat
                - target_lat
            ) ** 2
            + (
                lon
                - target_lon
            ) ** 2
        )

        if (
            nearest_distance
            is None
            or distance
            < nearest_distance
        ):
            nearest_point = (
                lat,
                lon,
            )

            nearest_distance = (
                distance
            )

    if nearest_point is None:
        raise RuntimeError(
            "No native source "
            "points found."
        )

    return (
        field.values[
            nearest_point
        ],

        nearest_point,
    )


def build_target_h3_cells(
    result: GFSReadResult,
    bounds: H3TargetBounds,
) -> list[str]:
    reference = (
        result.fields[
            "AIR_TEMP_2M_INSTANT"
        ]
    )

    cells = set()

    for lat, lon in (
        reference.values
    ):
        if (
            bounds.min_lat
            <= lat
            <= bounds.max_lat

            and bounds.min_lon
            <= lon
            <= bounds.max_lon
        ):
            cells.add(
                h3.latlng_to_cell(
                    lat,
                    lon,
                    H3_RESOLUTION,
                )
            )

    return sorted(
        cells
    )


def _valid_time(
    initialization_time: datetime,
    reference_field: GFSField,
) -> datetime:
    if (
        reference_field
        .end_step
        is None
    ):
        raise RuntimeError(
            "Reference GFS field "
            "has no end_step."
        )

    return (
        initialization_time
        + timedelta(
            hours=(
                reference_field
                .end_step
            )
        )
    )


def _precipitation_period(
    initialization_time: datetime,
    precipitation_field: GFSField,
) -> tuple[
    datetime | None,
    datetime | None,
]:
    if (
        precipitation_field
        .start_step
        is None
        or precipitation_field
        .end_step
        is None
    ):
        return (
            None,
            None,
        )

    return (
        initialization_time
        + timedelta(
            hours=(
                precipitation_field
                .start_step
            )
        ),

        initialization_time
        + timedelta(
            hours=(
                precipitation_field
                .end_step
            )
        ),
    )


def remap_to_h3(
    *,
    result: GFSReadResult,
    initialization_time: datetime,
    target_bounds: H3TargetBounds,
) -> list[
    H3ForecastRow
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

    reference_field = (
        result.fields[
            "AIR_TEMP_2M_INSTANT"
        ]
    )

    precipitation_field = (
        result.fields.get(
            "PRECIP_INTERVAL_TOTAL"
        )
    )

    valid_time = (
        _valid_time(
            initialization_time,
            reference_field,
        )
    )

    # --------------------------------------------------------------
    # F000 has no preceding accumulation interval.
    # --------------------------------------------------------------

    if precipitation_field is None:
        period_start = None
        period_end = None

    else:
        (
            period_start,
            period_end,
        ) = _precipitation_period(
            initialization_time,
            precipitation_field,
        )

    if (
        reference_field
        .end_step
        is None
    ):
        raise RuntimeError(
            "Cannot calculate "
            "forecast lead time."
        )

    lead_minutes = (
        reference_field
        .end_step
        * 60
    )

    target_cells = (
        build_target_h3_cells(
            result,
            target_bounds,
        )
    )

    rows = []

    for h3_index in (
        target_cells
    ):
        (
            center_lat,
            center_lon,
        ) = h3.cell_to_latlng(
            h3_index
        )

        # ----------------------------------------------------------
        # Precipitation
        # ----------------------------------------------------------

        if (
            precipitation_field
            is None
        ):
            precipitation_mm = (
                None
            )

            precipitation_source_lat = (
                None
            )

            precipitation_source_lon = (
                None
            )

        else:
            (
                precipitation_mm,
                (
                    precipitation_source_lat,
                    precipitation_source_lon,
                ),
            ) = nearest_native_value(
                precipitation_field,
                center_lat,
                center_lon,
            )

        # ----------------------------------------------------------
        # Row
        # ----------------------------------------------------------

        rows.append(
            H3ForecastRow(
                h3_index=(
                    h3_index
                ),

                center_lat=(
                    center_lat
                ),

                center_lon=(
                    center_lon
                ),

                valid_time=(
                    valid_time
                ),

                period_start=(
                    period_start
                ),

                period_end=(
                    period_end
                ),

                lead_minutes=(
                    lead_minutes
                ),

                air_temperature_2m_c=(
                    bilinear_interpolate(
                        result.fields[
                            "AIR_TEMP_2M_INSTANT"
                        ],
                        center_lat,
                        center_lon,
                    )
                ),

                dew_point_2m_c=(
                    bilinear_interpolate(
                        result.fields[
                            "DEW_POINT_2M_INSTANT"
                        ],
                        center_lat,
                        center_lon,
                    )
                ),

                relative_humidity_2m_pct=(
                    bilinear_interpolate(
                        result.fields[
                            "RELATIVE_HUMIDITY_2M_INSTANT"
                        ],
                        center_lat,
                        center_lon,
                    )
                ),

                surface_pressure_hpa=(
                    bilinear_interpolate(
                        result.fields[
                            "SURFACE_PRESSURE_INSTANT"
                        ],
                        center_lat,
                        center_lon,
                    )
                ),

                precipitation_mm=(
                    precipitation_mm
                ),

                wind_u_10m_ms=(
                    bilinear_interpolate(
                        result.fields[
                            "WIND_U_10M_INSTANT"
                        ],
                        center_lat,
                        center_lon,
                    )
                ),

                wind_v_10m_ms=(
                    bilinear_interpolate(
                        result.fields[
                            "WIND_V_10M_INSTANT"
                        ],
                        center_lat,
                        center_lon,
                    )
                ),

                # This currently means adequate source
                # support exists for the target centre.
                #
                # It is not yet an area-conservative
                # H3 spatial coverage measurement.
                coverage_fraction=1.0,

                metadata={
                    "continuous_remapping_method": (
                        CONTINUOUS_REMAP_METHOD
                    ),

                    "wind_remapping_method": (
                        WIND_REMAP_METHOD
                    ),

                    "precipitation_remapping_method": (
                        PRECIPITATION_REMAP_METHOD
                        if precipitation_field
                        is not None
                        else None
                    ),

                    "precipitation_method_status": (
                        PRECIPITATION_REMAP_STATUS
                        if precipitation_field
                        is not None
                        else
                        "not_applicable_f000"
                    ),

                    "precipitation_source_lat": (
                        precipitation_source_lat
                    ),

                    "precipitation_source_lon": (
                        precipitation_source_lon
                    ),

                    "period_fields_apply_to": (
                        [
                            "precipitation_mm"
                        ]
                        if precipitation_field
                        is not None
                        else []
                    ),

                    "instant_fields_apply_at": (
                        valid_time
                        .isoformat()
                    ),
                },
            )
        )

    return rows