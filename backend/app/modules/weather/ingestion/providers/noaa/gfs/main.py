from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime

from .controller import (
    ingest_missing_gfs_hours,
    resolve_initialization_time,
)

from .downloader import (
    GFSSubsetBounds,
)

from .remapper import (
    H3TargetBounds,
)


@dataclass(frozen=True)
class GFSIngestionSummary:
    initialization_time: datetime

    successful_hours: list[int]

    failures: list[
        tuple[
            int,
            str,
            str,
        ]
    ]

    rows_written: int

    @property
    def success_count(
        self,
    ) -> int:
        return len(
            self.successful_hours
        )

    @property
    def failure_count(
        self,
    ) -> int:
        return len(
            self.failures
        )


def ingest_latest_gfs(
    *,
    conn,
    start_forecast_hour: int = 0,
    end_forecast_hour: int = 6,
    download_bounds: GFSSubsetBounds,
    target_bounds: H3TargetBounds,
    continue_on_error: bool = True,
) -> GFSIngestionSummary:
    """
    Production-facing GFS ingestion entry point.

    Automatically selects the latest NOAA-confirmed
    available GFS cycle and processes only forecast
    hours that are missing from Aurion.

    The selected initialization time is always returned
    in the summary, including when no forecast hours
    require ingestion.

    Transaction ownership remains with the caller.
    """

    selection = (
        resolve_initialization_time(
            initialization_time=None,
        )
    )

    results = (
        ingest_missing_gfs_hours(
            conn=conn,

            initialization_selection=(
                selection
            ),

            start_forecast_hour=(
                start_forecast_hour
            ),

            end_forecast_hour=(
                end_forecast_hour
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

    successful_hours = [
        item.forecast_hour
        for result in results
        for item in result.results
    ]

    failures = [
        (
            item.forecast_hour,
            item.error_type,
            item.error_message,
        )
        for result in results
        for item in result.failures
    ]

    rows_written = sum(
        result.total_rows_written
        for result in results
    )

    for result in results:
        if (
            result.initialization_time
            != selection.initialization_time
        ):
            raise RuntimeError(
                "GFS range result initialization "
                "time does not match the cycle "
                "selected by the controller."
            )

    return GFSIngestionSummary(
        initialization_time=(
            selection.initialization_time
        ),

        successful_hours=(
            successful_hours
        ),

        failures=(
            failures
        ),

        rows_written=(
            rows_written
        ),
    )