from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path
import hashlib
import json

from .config import (
    DATASET_VERSION_NAME,
    NATIVE_FORECAST_PRODUCT_CODE,
    H3_FORECAST_PRODUCT_CODE,
    DERIVATION_CODE,
    DERIVATION_VERSION_NAME,
    GFS_MODEL_CODE,
    GFS_MODEL_VERSION_CODE,
    EXPECTED_FORECAST_STEPS,
    INGESTION_RUN_TYPE,
    INGESTION_PIPELINE_VERSION,
)


@dataclass
class GFSProvenanceContext:
    source_artifact_id: int
    ingestion_run_id: int

    native_forecast_product_id: int
    native_forecast_run_id: int
    native_forecast_member_id: int

    derived_forecast_product_id: int
    derived_forecast_run_id: int
    derived_forecast_member_id: int

    derivation_run_id: int


def sha256_file(
    path: Path,
) -> str:
    digest = hashlib.sha256()

    with path.open("rb") as handle:
        for chunk in iter(
            lambda: handle.read(
                1024 * 1024
            ),
            b"",
        ):
            digest.update(chunk)

    return digest.hexdigest()


def resolve_dataset_version_id(
    conn,
) -> int:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT dataset_version_id
            FROM weather.dataset_version
            WHERE version_name = %s
            """,
            (
                DATASET_VERSION_NAME,
            ),
        )

        row = cur.fetchone()

        if row is None:
            raise RuntimeError(
                "Dataset version not found: "
                f"{DATASET_VERSION_NAME}"
            )

        return row[0]


def resolve_forecast_product_id(
    conn,
    code: str,
) -> int:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT forecast_product_id
            FROM weather.forecast_product
            WHERE code = %s
            """,
            (
                code,
            ),
        )

        row = cur.fetchone()

        if row is None:
            raise RuntimeError(
                "Forecast product not found: "
                f"{code}"
            )

        return row[0]


def resolve_model_version_id(
    conn,
    *,
    model_code: str,
    version_code: str,
) -> int:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT
                fmv.forecast_model_version_id
            FROM weather.forecast_model_version fmv

            JOIN weather.forecast_model fm
              ON fm.forecast_model_id =
                 fmv.forecast_model_id

            WHERE fm.code = %s
              AND fmv.version_code = %s
            """,
            (
                model_code,
                version_code,
            ),
        )

        row = cur.fetchone()

        if row is None:
            raise RuntimeError(
                "Forecast model version "
                "not found: "
                f"{model_code} / "
                f"{version_code}"
            )

        return row[0]


def resolve_derivation_version_id(
    conn,
) -> int:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT
                dv.derivation_version_id
            FROM weather.derivation_version dv

            JOIN weather.derivation d
              ON d.derivation_id =
                 dv.derivation_id

            WHERE d.code = %s
              AND dv.version_name = %s
            """,
            (
                DERIVATION_CODE,
                DERIVATION_VERSION_NAME,
            ),
        )

        row = cur.fetchone()

        if row is None:
            raise RuntimeError(
                "Derivation version not found: "
                f"{DERIVATION_CODE} / "
                f"{DERIVATION_VERSION_NAME}"
            )

        return row[0]


def register_source_artifact(
    conn,
    *,
    dataset_version_id: int,
    grib_path: Path,
    source_uri: str,
    initialization_time: datetime,
    forecast_hour: int,
) -> int:
    checksum = sha256_file(
        grib_path
    )

    size_bytes = (
        grib_path
        .stat()
        .st_size
    )

    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT source_artifact_id
            FROM weather.source_artifact
            WHERE dataset_version_id = %s
              AND filename = %s
              AND checksum_sha256 = %s
            ORDER BY source_artifact_id DESC
            LIMIT 1
            """,
            (
                dataset_version_id,
                grib_path.name,
                checksum,
            ),
        )

        row = cur.fetchone()

        if row is not None:
            return row[0]

        cur.execute(
            """
            INSERT INTO weather.source_artifact (
                dataset_version_id,
                artifact_type,
                source_uri,
                filename,
                content_type,
                size_bytes,
                checksum_sha256,
                storage_tier,
                storage_uri,
                metadata
            )
            VALUES (
                %s,
                'forecast_grib2_subset',
                %s,
                %s,
                'application/x-grib2',
                %s,
                %s,
                'hot',
                %s,
                %s::jsonb
            )
            RETURNING source_artifact_id
            """,
            (
                dataset_version_id,
                source_uri,
                grib_path.name,
                size_bytes,
                checksum,
                str(grib_path),
                json.dumps(
                    {
                        "provider": "NOAA",
                        "model": "GFS",
                        "initialization_time":
                            initialization_time
                            .isoformat(),
                        "forecast_hour":
                            forecast_hour,
                        "subset": True,
                    }
                ),
            ),
        )

        return cur.fetchone()[0]


def register_ingestion_run(
    conn,
    *,
    dataset_version_id: int,
    source_artifact_id: int,
    initialization_time: datetime,
    forecast_hour: int,
) -> int:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT ingestion_run_id
            FROM weather.ingestion_run
            WHERE dataset_version_id = %s
              AND source_artifact_id = %s
              AND run_type = %s
              AND pipeline_version = %s
              AND status IN (
                    'pending',
                    'running'
              )
              AND metadata ->> 'forecast_hour' = %s
            ORDER BY ingestion_run_id DESC
            LIMIT 1
            """,
            (
                dataset_version_id,
                source_artifact_id,
                INGESTION_RUN_TYPE,
                INGESTION_PIPELINE_VERSION,
                str(forecast_hour),
            ),
        )

        row = cur.fetchone()

        if row is not None:
            return row[0]

        cur.execute(
            """
            INSERT INTO weather.ingestion_run (
                dataset_version_id,
                source_artifact_id,
                run_type,
                status,
                pipeline_version,
                metadata
            )
            VALUES (
                %s,
                %s,
                %s,
                'pending',
                %s,
                %s::jsonb
            )
            RETURNING ingestion_run_id
            """,
            (
                dataset_version_id,
                source_artifact_id,
                INGESTION_RUN_TYPE,
                INGESTION_PIPELINE_VERSION,
                json.dumps(
                    {
                        "provider": "NOAA",
                        "model": "GFS",
                        "initialization_time":
                            initialization_time
                            .isoformat(),
                        "forecast_hour":
                            forecast_hour,
                    }
                ),
            ),
        )

        return cur.fetchone()[0]


def resolve_or_create_forecast_run(
    conn,
    *,
    forecast_product_id: int,
    forecast_model_version_id: int,
    initialization_time: datetime,
    run_kind: str,
    cycle_code: str,
) -> int:
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO weather.forecast_run (
                forecast_product_id,
                forecast_model_version_id,
                initialization_time,

                cycle_code,
                run_kind,
                provider_revision,

                expected_member_count,
                received_member_count,

                expected_step_count,
                received_step_count,

                completeness_fraction,
                run_status,

                metadata
            )
            VALUES (
                %s,
                %s,
                %s,

                %s,
                %s,
                NULL,

                1,
                0,

                %s,
                0,

                0,
                'partial',

                '{}'::jsonb
            )

            ON CONFLICT (
                forecast_product_id,
                forecast_model_version_id,
                initialization_time,
                provider_revision
            )

            DO UPDATE SET
                updated_at = now()

            RETURNING forecast_run_id
            """,
            (
                forecast_product_id,
                forecast_model_version_id,
                initialization_time,
                cycle_code,
                run_kind,
                EXPECTED_FORECAST_STEPS,
            ),
        )

        return cur.fetchone()[0]


def link_forecast_run_ingestion(
    conn,
    *,
    forecast_run_id: int,
    ingestion_run_id: int,
    input_role: str = "source",
) -> None:
    with conn.cursor() as cur:
        cur.execute(
            """
            INSERT INTO weather.forecast_run_ingestion (
                forecast_run_id,
                ingestion_run_id,
                input_role,
                metadata
            )
            VALUES (
                %s,
                %s,
                %s,
                '{}'::jsonb
            )

            ON CONFLICT (
                forecast_run_id,
                ingestion_run_id,
                input_role
            )

            DO NOTHING
            """,
            (
                forecast_run_id,
                ingestion_run_id,
                input_role,
            ),
        )


def resolve_or_create_member(
    conn,
    *,
    forecast_run_id: int,
    member_type: str,
) -> int:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT forecast_member_id
            FROM weather.forecast_member
            WHERE forecast_run_id = %s
              AND member_code = 'det'
            ORDER BY forecast_member_id
            LIMIT 1
            """,
            (
                forecast_run_id,
            ),
        )

        row = cur.fetchone()

        if row is not None:
            return row[0]

        if member_type == "deterministic":
            name = (
                "Deterministic forecast"
            )
            is_deterministic = True
        else:
            name = (
                "Derived deterministic forecast"
            )
            is_deterministic = False

        cur.execute(
            """
            INSERT INTO weather.forecast_member (
                forecast_run_id,
                member_type,
                member_number,
                member_code,
                name,
                is_control,
                is_deterministic,
                is_available,
                metadata
            )
            VALUES (
                %s,
                %s,
                0,
                'det',
                %s,
                false,
                %s,
                false,
                '{}'::jsonb
            )
            RETURNING forecast_member_id
            """,
            (
                forecast_run_id,
                member_type,
                name,
                is_deterministic,
            ),
        )

        return cur.fetchone()[0]


def register_derivation_run(
    conn,
    *,
    derivation_version_id: int,
    ingestion_run_id: int,
) -> int:
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT derivation_run_id
            FROM weather.derivation_run
            WHERE derivation_version_id = %s
              AND ingestion_run_id = %s
              AND status IN (
                    'pending',
                    'running'
              )
            ORDER BY derivation_run_id DESC
            LIMIT 1
            """,
            (
                derivation_version_id,
                ingestion_run_id,
            ),
        )

        row = cur.fetchone()

        if row is not None:
            return row[0]

        cur.execute(
            """
            INSERT INTO weather.derivation_run (
                derivation_version_id,
                ingestion_run_id,
                status,
                metadata
            )
            VALUES (
                %s,
                %s,
                'pending',
                '{}'::jsonb
            )
            RETURNING derivation_run_id
            """,
            (
                derivation_version_id,
                ingestion_run_id,
            ),
        )

        return cur.fetchone()[0]


def register_gfs_provenance(
    conn,
    *,
    grib_path: Path,
    source_uri: str,
    initialization_time: datetime,
    forecast_hour: int,
) -> GFSProvenanceContext:
    if initialization_time.tzinfo is None:
        raise ValueError(
            "initialization_time must "
            "be timezone-aware."
        )

    initialization_time = (
        initialization_time
        .astimezone(timezone.utc)
    )

    if forecast_hour < 0:
        raise ValueError(
            "forecast_hour cannot be negative."
        )

    if not grib_path.exists():
        raise FileNotFoundError(
            f"GRIB file not found: {grib_path}"
        )

    cycle_code = (
        f"{initialization_time:%H}Z"
    )

    dataset_version_id = (
        resolve_dataset_version_id(
            conn
        )
    )

    native_product_id = (
        resolve_forecast_product_id(
            conn,
            NATIVE_FORECAST_PRODUCT_CODE,
        )
    )

    derived_product_id = (
        resolve_forecast_product_id(
            conn,
            H3_FORECAST_PRODUCT_CODE,
        )
    )

    model_version_id = (
        resolve_model_version_id(
            conn,
            model_code=GFS_MODEL_CODE,
            version_code=(
                GFS_MODEL_VERSION_CODE
            ),
        )
    )

    derivation_version_id = (
        resolve_derivation_version_id(
            conn
        )
    )

    source_artifact_id = (
        register_source_artifact(
            conn,
            dataset_version_id=(
                dataset_version_id
            ),
            grib_path=grib_path,
            source_uri=source_uri,
            initialization_time=(
                initialization_time
            ),
            forecast_hour=forecast_hour,
        )
    )

    ingestion_run_id = (
        register_ingestion_run(
            conn,
            dataset_version_id=(
                dataset_version_id
            ),
            source_artifact_id=(
                source_artifact_id
            ),
            initialization_time=(
                initialization_time
            ),
            forecast_hour=forecast_hour,
        )
    )

    native_forecast_run_id = (
        resolve_or_create_forecast_run(
            conn,
            forecast_product_id=(
                native_product_id
            ),
            forecast_model_version_id=(
                model_version_id
            ),
            initialization_time=(
                initialization_time
            ),
            run_kind="native",
            cycle_code=cycle_code,
        )
    )

    derived_forecast_run_id = (
        resolve_or_create_forecast_run(
            conn,
            forecast_product_id=(
                derived_product_id
            ),
            forecast_model_version_id=(
                model_version_id
            ),
            initialization_time=(
                initialization_time
            ),
            run_kind="derived",
            cycle_code=cycle_code,
        )
    )

    link_forecast_run_ingestion(
        conn,
        forecast_run_id=(
            native_forecast_run_id
        ),
        ingestion_run_id=(
            ingestion_run_id
        ),
        input_role="source",
    )

    link_forecast_run_ingestion(
        conn,
        forecast_run_id=(
            derived_forecast_run_id
        ),
        ingestion_run_id=(
            ingestion_run_id
        ),
        input_role="source",
    )

    native_forecast_member_id = (
        resolve_or_create_member(
            conn,
            forecast_run_id=(
                native_forecast_run_id
            ),
            member_type="deterministic",
        )
    )

    derived_forecast_member_id = (
        resolve_or_create_member(
            conn,
            forecast_run_id=(
                derived_forecast_run_id
            ),
            member_type="derived",
        )
    )

    derivation_run_id = (
        register_derivation_run(
            conn,
            derivation_version_id=(
                derivation_version_id
            ),
            ingestion_run_id=(
                ingestion_run_id
            ),
        )
    )

    return GFSProvenanceContext(
        source_artifact_id=(
            source_artifact_id
        ),

        ingestion_run_id=(
            ingestion_run_id
        ),

        native_forecast_product_id=(
            native_product_id
        ),

        native_forecast_run_id=(
            native_forecast_run_id
        ),

        native_forecast_member_id=(
            native_forecast_member_id
        ),

        derived_forecast_product_id=(
            derived_product_id
        ),

        derived_forecast_run_id=(
            derived_forecast_run_id
        ),

        derived_forecast_member_id=(
            derived_forecast_member_id
        ),

        derivation_run_id=(
            derivation_run_id
        ),
    )