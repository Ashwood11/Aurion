from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
import traceback

from .downloader import (
    GFSSubsetBounds,
)

from .remapper import (
    H3TargetBounds,
)

from .ingest import (
    ingest_gfs_forecast_hour,
)

from .finalize import (
    finalize_successful_gfs_ingestion,
)

from .provenance import (
    GFSProvenanceContext,
)

from .config import (
    MAX_FORECAST_HOUR,
)


@dataclass
class GFSForecastHourResult:
    forecast_hour: int
    rows_written: int
    grib_path: Path
    provenance: GFSProvenanceContext


@dataclass
class GFSForecastHourFailure:
    forecast_hour: int
    error_type: str
    error_message: str


@dataclass
class GFSForecastRangeResult:
    initialization_time: datetime

    start_forecast_hour: int
    end_forecast_hour: int

    results: list[
        GFSForecastHourResult
    ]

    failures: list[
        GFSForecastHourFailure
    ]

    @property
    def successful_hours(
        self,
    ) -> int:
        return len(
            self.results
        )

    @property
    def failed_hours(
        self,
    ) -> int:
        return len(
            self.failures
        )

    @property
    def total_rows_written(
        self,
    ) -> int:
        return sum(
            result.rows_written
            for result in self.results
        )


def validate_forecast_hour_range(
    *,
    start_forecast_hour: int,
    end_forecast_hour: int,
) -> None:
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
        start_forecast_hour
        > end_forecast_hour
    ):
        raise ValueError(
            "start_forecast_hour cannot "
            "be greater than "
            "end_forecast_hour."
        )

    if (
        end_forecast_hour
        > MAX_FORECAST_HOUR
    ):
        raise ValueError(
            "end_forecast_hour exceeds "
            f"GFS maximum "
            f"F{MAX_FORECAST_HOUR:03d}."
        )


def run_gfs_forecast_hours(
    *,
    conn,
    initialization_time: datetime,
    start_forecast_hour: int,
    end_forecast_hour: int,
    download_bounds: GFSSubsetBounds,
    target_bounds: H3TargetBounds,
    continue_on_error: bool = True,
) -> GFSForecastRangeResult:
    """
    Process a sequence of GFS forecast hours.

    Each forecast hour is protected by its own
    PostgreSQL savepoint.

    Successful hours remain part of the caller's
    transaction.

    Failed hours are rolled back to their savepoint
    without discarding earlier successful hours.

    This function itself does NOT commit the outer
    transaction.
    """

    if initialization_time.tzinfo is None:
        raise ValueError(
            "initialization_time must "
            "be timezone-aware."
        )

    initialization_time = (
        initialization_time
        .astimezone(timezone.utc)
    )

    validate_forecast_hour_range(
        start_forecast_hour=(
            start_forecast_hour
        ),
        end_forecast_hour=(
            end_forecast_hour
        ),
    )

    results = []
    failures = []

    for forecast_hour in range(
        start_forecast_hour,
        end_forecast_hour + 1,
    ):
        print()
        print(
            f"GFS "
            f"{initialization_time:%Y-%m-%d %HZ} "
            f"F{forecast_hour:03d}"
        )

        savepoint_name = (
            f"gfs_f{forecast_hour:03d}"
        )

        with conn.cursor() as cur:
            cur.execute(
                f"SAVEPOINT {savepoint_name}"
            )

        try:
            (
                rows_written,
                provenance,
                grib_path,
            ) = ingest_gfs_forecast_hour(
                conn=conn,

                initialization_time=(
                    initialization_time
                ),

                forecast_hour=(
                    forecast_hour
                ),

                download_bounds=(
                    download_bounds
                ),

                target_bounds=(
                    target_bounds
                ),
            )

            finalize_successful_gfs_ingestion(
                conn,

                provenance=(
                    provenance
                ),

                rows_written=(
                    rows_written
                ),

                forecast_hour=(
                    forecast_hour
                ),
            )

            with conn.cursor() as cur:
                cur.execute(
                    f"RELEASE SAVEPOINT "
                    f"{savepoint_name}"
                )

            result = (
                GFSForecastHourResult(
                    forecast_hour=(
                        forecast_hour
                    ),

                    rows_written=(
                        rows_written
                    ),

                    grib_path=(
                        grib_path
                    ),

                    provenance=(
                        provenance
                    ),
                )
            )

            results.append(
                result
            )

            print(
                f"  status: success"
            )

            print(
                f"  rows: "
                f"{rows_written}"
            )

            print(
                "  native run: "
                f"{provenance.native_forecast_run_id}"
            )

            print(
                "  derived run: "
                f"{provenance.derived_forecast_run_id}"
            )

        except Exception as exc:
            with conn.cursor() as cur:
                cur.execute(
                    f"ROLLBACK TO SAVEPOINT "
                    f"{savepoint_name}"
                )

                cur.execute(
                    f"RELEASE SAVEPOINT "
                    f"{savepoint_name}"
                )

            failure = (
                GFSForecastHourFailure(
                    forecast_hour=(
                        forecast_hour
                    ),

                    error_type=(
                        type(exc).__name__
                    ),

                    error_message=str(
                        exc
                    ),
                )
            )

            failures.append(
                failure
            )

            print(
                "  status: FAILED"
            )

            print(
                "  error: "
                f"{failure.error_type}: "
                f"{failure.error_message}"
            )

            if not continue_on_error:
                raise

    return GFSForecastRangeResult(
        initialization_time=(
            initialization_time
        ),

        start_forecast_hour=(
            start_forecast_hour
        ),

        end_forecast_hour=(
            end_forecast_hour
        ),

        results=results,
        failures=failures,
    )