from __future__ import annotations

from dataclasses import dataclass
from datetime import (
    datetime,
    timezone,
)

from .config import (
    H3_FORECAST_PRODUCT_CODE,
    MAX_FORECAST_HOUR,
)

from .cycle import (
    GFSCycleSelection,
    select_latest_available_gfs_cycle,
)

from .downloader import (
    GFSSubsetBounds,
)

from .remapper import (
    H3TargetBounds,
)

from .runner import (
    GFSForecastRangeResult,
    run_gfs_forecast_hours,
)


@dataclass
class GFSRunState:
    forecast_run_id: int

    initialization_time: datetime

    present_forecast_hours: list[int]

    missing_forecast_hours: list[int]


@dataclass(frozen=True)
class GFSInitializationSelection:
    """
    Records how the controller selected the GFS cycle.

    selection_mode:
        "explicit"  -> caller supplied initialization_time
        "automatic" -> cycle selector chose the cycle
    """

    initialization_time: datetime

    selection_mode: str

    automatic_selection: (
        GFSCycleSelection
        | None
    )


def resolve_initialization_time(
    *,
    initialization_time: (
        datetime
        | None
    ) = None,
    now: (
        datetime
        | None
    ) = None,
) -> GFSInitializationSelection:
    """
    Resolve the GFS initialization time used by the
    controller.

    Explicit initialization_time always takes priority.

    When initialization_time is None, Aurion selects the
    latest GFS cycle considered available by cycle.py.

    `now` exists primarily for deterministic testing.
    """

    if initialization_time is not None:
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

        return GFSInitializationSelection(
            initialization_time=(
                initialization_time
            ),

            selection_mode=(
                "explicit"
            ),

            automatic_selection=None,
        )

    selection = (
        select_latest_available_gfs_cycle(
            now=now
        )
    )

    return GFSInitializationSelection(
        initialization_time=(
            selection
            .initialization_time
        ),

        selection_mode=(
            "automatic"
        ),

        automatic_selection=(
            selection
        ),
    )


def resolve_derived_forecast_run_id(
    conn,
    *,
    initialization_time: datetime,
) -> int | None:
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

    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT
                fr.forecast_run_id

            FROM weather.forecast_run fr

            JOIN weather.forecast_product fp
              ON fp.forecast_product_id =
                 fr.forecast_product_id

            WHERE fp.code = %s
              AND fr.initialization_time = %s

            ORDER BY
                fr.forecast_run_id DESC

            LIMIT 1
            """,
            (
                H3_FORECAST_PRODUCT_CODE,
                initialization_time,
            ),
        )

        row = (
            cur.fetchone()
        )

        if row is None:
            return None

        return row[0]


def get_present_forecast_hours(
    conn,
    *,
    forecast_run_id: int,
) -> list[int]:
    """
    Determine completed forecast hours from ingestion
    provenance linked to this forecast run.

    We intentionally use the recorded forecast_hour in
    ingestion metadata rather than deriving the hour
    from valid_time.
    """

    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT DISTINCT
                (
                    ir.metadata
                    ->> 'forecast_hour'
                )::integer
                AS forecast_hour

            FROM weather.forecast_run_ingestion fri

            JOIN weather.ingestion_run ir
              ON ir.ingestion_run_id =
                 fri.ingestion_run_id

            WHERE fri.forecast_run_id = %s

              AND ir.status = 'complete'

              AND ir.metadata
                    ? 'forecast_hour'

            ORDER BY
                forecast_hour
            """,
            (
                forecast_run_id,
            ),
        )

        return [
            int(
                row[0]
            )
            for row
            in cur.fetchall()
        ]


def get_missing_forecast_hours(
    *,
    present_forecast_hours: list[int],
    start_forecast_hour: int = 0,
    end_forecast_hour: int = (
        MAX_FORECAST_HOUR
    ),
) -> list[int]:
    if start_forecast_hour < 0:
        raise ValueError(
            "start_forecast_hour cannot "
            "be negative."
        )

    if end_forecast_hour < 0:
        raise ValueError(
            "end_forecast_hour cannot "
            "be negative."
        )

    if (
        end_forecast_hour
        > MAX_FORECAST_HOUR
    ):
        raise ValueError(
            "end_forecast_hour exceeds "
            f"F{MAX_FORECAST_HOUR:03d}."
        )

    if (
        start_forecast_hour
        > end_forecast_hour
    ):
        raise ValueError(
            "start_forecast_hour cannot "
            "exceed end_forecast_hour."
        )

    present = set(
        present_forecast_hours
    )

    return [
        hour
        for hour in range(
            start_forecast_hour,
            end_forecast_hour + 1,
        )
        if hour not in present
    ]


def inspect_gfs_run_state(
    conn,
    *,
    initialization_time: (
        datetime
        | None
    ) = None,
    now: (
        datetime
        | None
    ) = None,
    start_forecast_hour: int = 0,
    end_forecast_hour: int = (
        MAX_FORECAST_HOUR
    ),
) -> GFSRunState | None:
    """
    Inspect an explicit GFS cycle or, when one is not
    supplied, automatically select the latest available
    cycle.

    This function does not download or write anything.
    """

    selection = (
        resolve_initialization_time(
            initialization_time=(
                initialization_time
            ),
            now=now,
        )
    )

    resolved_initialization_time = (
        selection
        .initialization_time
    )

    forecast_run_id = (
        resolve_derived_forecast_run_id(
            conn,
            initialization_time=(
                resolved_initialization_time
            ),
        )
    )

    if forecast_run_id is None:
        return None

    present = (
        get_present_forecast_hours(
            conn,
            forecast_run_id=(
                forecast_run_id
            ),
        )
    )

    missing = (
        get_missing_forecast_hours(
            present_forecast_hours=(
                present
            ),

            start_forecast_hour=(
                start_forecast_hour
            ),

            end_forecast_hour=(
                end_forecast_hour
            ),
        )
    )

    return GFSRunState(
        forecast_run_id=(
            forecast_run_id
        ),

        initialization_time=(
            resolved_initialization_time
        ),

        present_forecast_hours=(
            present
        ),

        missing_forecast_hours=(
            missing
        ),
    )


def _group_contiguous_hours(
    hours: list[int],
) -> list[
    tuple[
        int,
        int,
    ]
]:
    """
    Convert:
        [0, 1, 2, 13, 14, 15]

    into:
        [(0, 2), (13, 15)]
    """

    if not hours:
        return []

    ranges = []

    range_start = (
        hours[0]
    )

    previous = (
        hours[0]
    )

    for hour in hours[1:]:
        if (
            hour
            == previous + 1
        ):
            previous = hour
            continue

        ranges.append(
            (
                range_start,
                previous,
            )
        )

        range_start = hour
        previous = hour

    ranges.append(
        (
            range_start,
            previous,
        )
    )

    return ranges


def ingest_missing_gfs_hours(
    *,
    conn,
    initialization_time: (
        datetime
        | None
    ) = None,
    now: (
        datetime
        | None
    ) = None,
    start_forecast_hour: int,
    end_forecast_hour: int,
    download_bounds: GFSSubsetBounds,
    target_bounds: H3TargetBounds,
    continue_on_error: bool = True,
) -> list[
    GFSForecastRangeResult
]:
    """
    Process only missing forecast hours.

    If initialization_time is supplied, that exact cycle
    is used.

    If initialization_time is None, Aurion automatically
    selects the latest available GFS cycle.

    Missing hours are grouped into contiguous ranges and
    passed to the existing failure-isolated range runner.

    This function does not commit or roll back the outer
    database transaction.
    """

    selection = (
        resolve_initialization_time(
            initialization_time=(
                initialization_time
            ),
            now=now,
        )
    )

    resolved_initialization_time = (
        selection
        .initialization_time
    )

    print(
        "GFS controller cycle: "
        f"{resolved_initialization_time:%Y-%m-%d %HZ}"
    )

    print(
        "Cycle selection: "
        f"{selection.selection_mode}"
    )

    state = (
        inspect_gfs_run_state(
            conn,

            initialization_time=(
                resolved_initialization_time
            ),

            start_forecast_hour=(
                start_forecast_hour
            ),

            end_forecast_hour=(
                end_forecast_hour
            ),
        )
    )

    if state is None:
        missing_hours = list(
            range(
                start_forecast_hour,
                end_forecast_hour + 1,
            )
        )

        print(
            "Existing derived run: none"
        )

    else:
        missing_hours = (
            state
            .missing_forecast_hours
        )

        print(
            "Existing derived run: "
            f"{state.forecast_run_id}"
        )

        print(
            "Present forecast hours: "
            f"{state.present_forecast_hours}"
        )

    print(
        "Missing forecast hours: "
        f"{missing_hours}"
    )

    if not missing_hours:
        print(
            "No missing forecast hours "
            "to ingest."
        )

        return []

    ranges = (
        _group_contiguous_hours(
            missing_hours
        )
    )

    print(
        "Missing ranges: "
        f"{ranges}"
    )

    results = []

    for (
        start_hour,
        end_hour,
    ) in ranges:
        result = (
            run_gfs_forecast_hours(
                conn=conn,

                initialization_time=(
                    resolved_initialization_time
                ),

                start_forecast_hour=(
                    start_hour
                ),

                end_forecast_hour=(
                    end_hour
                ),

                download_bounds=(
                    download_bounds
                ),

                target_bounds=(
                    target_bounds
                ),

                continue_on_error=(
                    continue_on_error
                ),
            )
        )

        results.append(
            result
        )

    return results