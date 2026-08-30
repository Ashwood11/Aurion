from __future__ import annotations

from dataclasses import dataclass

from .controller import (
    ingest_missing_gfs_hours,
)

from .downloader import (
    GFSSubsetBounds,
)

from .remapper import (
    H3TargetBounds,
)


@dataclass(frozen=True)
class GFSIngestionSummary:
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

    Transaction ownership remains with the caller.
    """

    results = (
        ingest_missing_gfs_hours(
            conn=conn,

            initialization_time=None,

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

    return GFSIngestionSummary(
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