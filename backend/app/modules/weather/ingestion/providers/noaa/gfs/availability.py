from __future__ import annotations

from dataclasses import dataclass
from datetime import (
    datetime,
    timezone,
)

import requests

from .config import (
    FILTER_URL,
    NORMAL_CYCLES_UTC,
    USER_AGENT,
)


@dataclass(frozen=True)
class GFSCycleAvailability:
    initialization_time: datetime

    available: bool

    status_code: int | None

    reason: str | None


def validate_gfs_initialization_time(
    initialization_time: datetime,
) -> datetime:
    if initialization_time.tzinfo is None:
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

    if (
        initialization_time.minute != 0
        or initialization_time.second != 0
        or initialization_time.microsecond != 0
    ):
        raise ValueError(
            "GFS initialization_time must "
            "be on an exact UTC hour."
        )

    if (
        initialization_time.hour
        not in NORMAL_CYCLES_UTC
    ):
        raise ValueError(
            "GFS initialization hour must "
            f"be one of {NORMAL_CYCLES_UTC}."
        )

    return initialization_time


def build_gfs_cycle_probe_params(
    initialization_time: datetime,
) -> dict[str, str]:
    """
    Construct a very small NOMADS request used only to
    determine whether a GFS cycle has actually been
    published.

    We request:
        F000
        2 m temperature
        a tiny geographic subset

    This avoids downloading a normal production subset
    merely to test cycle existence.
    """

    initialization_time = (
        validate_gfs_initialization_time(
            initialization_time
        )
    )

    date_text = (
        initialization_time
        .strftime(
            "%Y%m%d"
        )
    )

    cycle_text = (
        initialization_time
        .strftime(
            "%H"
        )
    )

    return {
        "file": (
            f"gfs.t{cycle_text}z."
            "pgrb2.0p25.f000"
        ),

        "dir": (
            f"/gfs.{date_text}/"
            f"{cycle_text}/atmos"
        ),

        "lev_2_m_above_ground": (
            "on"
        ),

        "var_TMP": (
            "on"
        ),

        "subregion": "",

        # Tiny probe area.
        # Approximately one native GFS grid interval.
        "leftlon": "-97.50",
        "rightlon": "-97.25",
        "toplat": "35.50",
        "bottomlat": "35.25",
    }


def probe_gfs_cycle(
    *,
    initialization_time: datetime,
    timeout_seconds: float = 20.0,
) -> GFSCycleAvailability:
    """
    Ask NOAA NOMADS whether a specific GFS cycle is
    genuinely available.

    This function performs no database writes.

    A cycle is considered available only when NOAA
    returns HTTP 200 with non-empty GRIB content.
    """

    initialization_time = (
        validate_gfs_initialization_time(
            initialization_time
        )
    )

    params = (
        build_gfs_cycle_probe_params(
            initialization_time
        )
    )

    headers = {
        "User-Agent": (
            USER_AGENT
        ),
    }

    try:
        response = requests.get(
            FILTER_URL,
            params=params,
            headers=headers,
            timeout=timeout_seconds,
        )

    except requests.RequestException as exc:
        return GFSCycleAvailability(
            initialization_time=(
                initialization_time
            ),

            available=False,

            status_code=None,

            reason=(
                f"{type(exc).__name__}: "
                f"{exc}"
            ),
        )

    status_code = (
        response.status_code
    )

    if status_code != 200:
        return GFSCycleAvailability(
            initialization_time=(
                initialization_time
            ),

            available=False,

            status_code=(
                status_code
            ),

            reason=(
                f"NOAA returned HTTP "
                f"{status_code}"
            ),
        )

    content = (
        response.content
    )

    if not content:
        return GFSCycleAvailability(
            initialization_time=(
                initialization_time
            ),

            available=False,

            status_code=(
                status_code
            ),

            reason=(
                "NOAA returned an empty "
                "response."
            ),
        )

    # GRIB edition 2 files begin with the ASCII
    # signature "GRIB".
    if not content.startswith(
        b"GRIB"
    ):
        preview = (
            content[:80]
            .decode(
                "utf-8",
                errors="replace",
            )
            .replace(
                "\n",
                " ",
            )
        )

        return GFSCycleAvailability(
            initialization_time=(
                initialization_time
            ),

            available=False,

            status_code=(
                status_code
            ),

            reason=(
                "NOAA returned HTTP 200 "
                "but the response was not "
                f"GRIB data: {preview!r}"
            ),
        )

    return GFSCycleAvailability(
        initialization_time=(
            initialization_time
        ),

        available=True,

        status_code=(
            status_code
        ),

        reason=None,
    )