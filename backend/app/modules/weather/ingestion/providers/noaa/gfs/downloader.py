from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime, timezone
from pathlib import Path

import requests

from .config import (
    FILTER_URL,
    USER_AGENT,
    GFS_SUBSET_ROOT,
)


@dataclass(frozen=True)
class GFSSubsetBounds:
    min_lat: float
    max_lat: float
    min_lon: float
    max_lon: float


def _forecast_filename(
    initialization_time: datetime,
    forecast_hour: int,
) -> str:
    cycle = initialization_time.strftime("%H")

    return (
        f"gfs.t{cycle}z.pgrb2.0p25."
        f"f{forecast_hour:03d}"
    )


def _forecast_directory(
    initialization_time: datetime,
) -> str:
    return (
        "/gfs."
        f"{initialization_time:%Y%m%d}/"
        f"{initialization_time:%H}/atmos"
    )


def build_nomads_params(
    *,
    initialization_time: datetime,
    forecast_hour: int,
    bounds: GFSSubsetBounds,
) -> dict[str, str]:
    return {
        "file": _forecast_filename(
            initialization_time,
            forecast_hour,
        ),

        "dir": _forecast_directory(
            initialization_time
        ),

        "lev_2_m_above_ground": "on",
        "lev_10_m_above_ground": "on",
        "lev_surface": "on",

        "var_TMP": "on",
        "var_DPT": "on",
        "var_RH": "on",
        "var_UGRD": "on",
        "var_VGRD": "on",
        "var_PRES": "on",
        "var_APCP": "on",

        "subregion": "",

        "leftlon": str(bounds.min_lon),
        "rightlon": str(bounds.max_lon),
        "toplat": str(bounds.max_lat),
        "bottomlat": str(bounds.min_lat),
    }


def default_output_path(
    *,
    initialization_time: datetime,
    forecast_hour: int,
    label: str = "subset",
) -> Path:
    directory = (
        GFS_SUBSET_ROOT
        / initialization_time.strftime("%Y%m%d")
        / initialization_time.strftime("%H")
    )

    filename = (
        f"gfs_{initialization_time:%Y%m%d}_"
        f"{initialization_time:%H}_"
        f"f{forecast_hour:03d}_"
        f"{label}.grib2"
    )

    return directory / filename


def download_gfs_subset(
    *,
    initialization_time: datetime,
    forecast_hour: int,
    bounds: GFSSubsetBounds,
    output_path: Path | None = None,
    timeout_seconds: int = 60,
) -> Path:
    if initialization_time.tzinfo is None:
        raise ValueError(
            "initialization_time must be timezone-aware"
        )

    initialization_time = (
        initialization_time
        .astimezone(timezone.utc)
    )

    if forecast_hour < 0:
        raise ValueError(
            "forecast_hour cannot be negative"
        )

    if output_path is None:
        output_path = default_output_path(
            initialization_time=initialization_time,
            forecast_hour=forecast_hour,
        )

    output_path.parent.mkdir(
        parents=True,
        exist_ok=True,
    )

    params = build_nomads_params(
        initialization_time=initialization_time,
        forecast_hour=forecast_hour,
        bounds=bounds,
    )

    response = requests.get(
        FILTER_URL,
        params=params,
        headers={
            "User-Agent": USER_AGENT,
        },
        timeout=timeout_seconds,
    )

    response.raise_for_status()

    if not response.content:
        raise RuntimeError(
            "NOMADS returned an empty response."
        )

    output_path.write_bytes(
        response.content
    )

    return output_path