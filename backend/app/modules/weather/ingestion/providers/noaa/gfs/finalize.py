from __future__ import annotations

import json

from .config import (
    EXPECTED_FORECAST_STEPS,
)
from .provenance import (
    GFSProvenanceContext,
)


def count_completed_forecast_steps(
    conn,
    *,
    forecast_run_id: int,
) -> int:
    """
    Count distinct completed GFS forecast hours linked
    to one scientific forecast run.

    F003, F004, F005, etc. all belong to the same
    forecast_run but have separate ingestion runs.
    """

    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT
                count(
                    DISTINCT (
                        ir.metadata
                        ->> 'forecast_hour'
                    )
                )

            FROM weather.forecast_run_ingestion fri

            JOIN weather.ingestion_run ir
              ON ir.ingestion_run_id =
                 fri.ingestion_run_id

            WHERE fri.forecast_run_id = %s

              AND ir.status = 'complete'

              AND ir.metadata
                    ? 'forecast_hour'
            """,
            (
                forecast_run_id,
            ),
        )

        row = cur.fetchone()

        if row is None:
            return 0

        return int(
            row[0] or 0
        )


def update_forecast_run_progress(
    conn,
    *,
    forecast_run_id: int,
    forecast_product_id: int,
    received_step_count: int,
    forecast_hour: int,
    derived_h3: bool,
) -> None:
    if received_step_count < 0:
        raise ValueError(
            "received_step_count cannot "
            "be negative."
        )

    if received_step_count > (
        EXPECTED_FORECAST_STEPS
    ):
        raise RuntimeError(
            "Received step count exceeds "
            "expected GFS step count."
        )

    completeness_fraction = (
        received_step_count
        / EXPECTED_FORECAST_STEPS
    )

    if (
        received_step_count
        >= EXPECTED_FORECAST_STEPS
    ):
        run_status = "complete"
    else:
        run_status = "partial"

    metadata_update = {
        "latest_processed_forecast_hour":
            forecast_hour,

        "completed_forecast_steps":
            received_step_count,

        "expected_forecast_steps":
            EXPECTED_FORECAST_STEPS,

        "subset_ingestion":
            True,
    }

    if derived_h3:
        metadata_update[
            "derived_h3"
        ] = True

    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE weather.forecast_run
            SET
                received_member_count = 1,

                received_step_count = %s,

                completeness_fraction = %s,

                run_status = %s,

                metadata =
                    COALESCE(
                        metadata,
                        '{}'::jsonb
                    )
                    || %s::jsonb,

                updated_at = now()

            WHERE forecast_run_id = %s
              AND forecast_product_id = %s
            """,
            (
                received_step_count,
                completeness_fraction,
                run_status,

                json.dumps(
                    metadata_update
                ),

                forecast_run_id,
                forecast_product_id,
            ),
        )

        if cur.rowcount != 1:
            raise RuntimeError(
                "Expected exactly one "
                "forecast run to be updated."
            )


def finalize_successful_gfs_ingestion(
    conn,
    *,
    provenance: GFSProvenanceContext,
    rows_written: int,
    forecast_hour: int,
) -> None:
    if rows_written < 0:
        raise ValueError(
            "rows_written cannot be negative."
        )

    if forecast_hour < 0:
        raise ValueError(
            "forecast_hour cannot "
            "be negative."
        )

    # --------------------------------------------------------------
    # 1. Complete this individual ingestion run
    # --------------------------------------------------------------

    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE weather.ingestion_run
            SET
                status = 'complete',

                completed_at = now(),

                records_read = %s,
                records_written = %s,
                records_rejected = 0,

                error_message = NULL,

                metadata =
                    COALESCE(
                        metadata,
                        '{}'::jsonb
                    )
                    || %s::jsonb

            WHERE ingestion_run_id = %s
            """,
            (
                rows_written,
                rows_written,

                json.dumps(
                    {
                        "forecast_hour":
                            forecast_hour,

                        "subset_ingestion":
                            True,

                        "completed":
                            True,
                    }
                ),

                provenance
                .ingestion_run_id,
            ),
        )

        if cur.rowcount != 1:
            raise RuntimeError(
                "Expected exactly one "
                "ingestion_run to be "
                "finalized."
            )

    # --------------------------------------------------------------
    # 2. Complete this individual derivation run
    # --------------------------------------------------------------

    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE weather.derivation_run
            SET
                status = 'complete',

                completed_at = now(),

                records_read = %s,
                records_written = %s,
                records_rejected = 0,

                error_message = NULL,

                metadata =
                    COALESCE(
                        metadata,
                        '{}'::jsonb
                    )
                    || %s::jsonb

            WHERE derivation_run_id = %s
            """,
            (
                rows_written,
                rows_written,

                json.dumps(
                    {
                        "forecast_hour":
                            forecast_hour,

                        "target_h3_rows":
                            rows_written,

                        "completed":
                            True,
                    }
                ),

                provenance
                .derivation_run_id,
            ),
        )

        if cur.rowcount != 1:
            raise RuntimeError(
                "Expected exactly one "
                "derivation_run to be "
                "finalized."
            )

    # --------------------------------------------------------------
    # 3. Native deterministic member is available
    # --------------------------------------------------------------

    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE weather.forecast_member
            SET
                is_available = true,

                metadata =
                    COALESCE(
                        metadata,
                        '{}'::jsonb
                    )
                    || %s::jsonb

            WHERE forecast_member_id = %s
              AND forecast_run_id = %s
            """,
            (
                json.dumps(
                    {
                        "latest_available_forecast_hour":
                            forecast_hour,

                        "available":
                            True,
                    }
                ),

                provenance
                .native_forecast_member_id,

                provenance
                .native_forecast_run_id,
            ),
        )

        if cur.rowcount != 1:
            raise RuntimeError(
                "Expected exactly one "
                "native forecast member "
                "to be updated."
            )

    # --------------------------------------------------------------
    # 4. Derived deterministic member is available
    # --------------------------------------------------------------

    with conn.cursor() as cur:
        cur.execute(
            """
            UPDATE weather.forecast_member
            SET
                is_available = true,

                metadata =
                    COALESCE(
                        metadata,
                        '{}'::jsonb
                    )
                    || %s::jsonb

            WHERE forecast_member_id = %s
              AND forecast_run_id = %s
            """,
            (
                json.dumps(
                    {
                        "latest_available_forecast_hour":
                            forecast_hour,

                        "available":
                            True,

                        "derived_h3":
                            True,
                    }
                ),

                provenance
                .derived_forecast_member_id,

                provenance
                .derived_forecast_run_id,
            ),
        )

        if cur.rowcount != 1:
            raise RuntimeError(
                "Expected exactly one "
                "derived forecast member "
                "to be updated."
            )

    # --------------------------------------------------------------
    # 5. Calculate actual run progress
    #
    # At this point this ingestion_run is already marked
    # complete, so it participates in the count.
    # --------------------------------------------------------------

    native_step_count = (
        count_completed_forecast_steps(
            conn,
            forecast_run_id=(
                provenance
                .native_forecast_run_id
            ),
        )
    )

    derived_step_count = (
        count_completed_forecast_steps(
            conn,
            forecast_run_id=(
                provenance
                .derived_forecast_run_id
            ),
        )
    )

    # These should normally be equal because every
    # successful GFS source step is linked to both runs.
    if (
        native_step_count
        != derived_step_count
    ):
        raise RuntimeError(
            "Native and derived GFS run "
            "step counts disagree: "
            f"{native_step_count} != "
            f"{derived_step_count}"
        )

    # --------------------------------------------------------------
    # 6. Update native run
    # --------------------------------------------------------------

    update_forecast_run_progress(
        conn,

        forecast_run_id=(
            provenance
            .native_forecast_run_id
        ),

        forecast_product_id=(
            provenance
            .native_forecast_product_id
        ),

        received_step_count=(
            native_step_count
        ),

        forecast_hour=(
            forecast_hour
        ),

        derived_h3=False,
    )

    # --------------------------------------------------------------
    # 7. Update derived run
    # --------------------------------------------------------------

    update_forecast_run_progress(
        conn,

        forecast_run_id=(
            provenance
            .derived_forecast_run_id
        ),

        forecast_product_id=(
            provenance
            .derived_forecast_product_id
        ),

        received_step_count=(
            derived_step_count
        ),

        forecast_hour=(
            forecast_hour
        ),

        derived_h3=True,
    )