from __future__ import annotations

from dataclasses import dataclass
from datetime import (
    datetime,
    timedelta,
    timezone,
)

from .availability import (
    GFSCycleAvailability,
    probe_gfs_cycle,
)

from .config import (
    NORMAL_CYCLES_UTC,
    GFS_CYCLE_AVAILABILITY_DELAY_HOURS,
)


@dataclass(frozen=True)
class GFSCycleSelection:
    initialization_time: datetime

    reference_time: datetime

    availability_delay_hours: int

    availability: (
        GFSCycleAvailability
        | None
    )

    attempts: tuple[
        GFSCycleAvailability,
        ...,
    ]


def _require_aware_datetime(
    value: datetime,
    *,
    name: str,
) -> datetime:
    if value.tzinfo is None:
        raise ValueError(
            f"{name} must be timezone-aware."
        )

    return value.astimezone(
        timezone.utc
    )


def latest_gfs_cycle_at_or_before(
    reference_time: datetime,
) -> datetime:
    """
    Return the most recent configured GFS cycle
    at or before reference_time.
    """

    reference_time = (
        _require_aware_datetime(
            reference_time,
            name="reference_time",
        )
    )

    cycles = sorted(
        NORMAL_CYCLES_UTC
    )

    if not cycles:
        raise RuntimeError(
            "No GFS cycles are configured."
        )

    for cycle_hour in reversed(
        cycles
    ):
        if (
            reference_time.hour
            >= cycle_hour
        ):
            return reference_time.replace(
                hour=cycle_hour,
                minute=0,
                second=0,
                microsecond=0,
            )

    previous_day = (
        reference_time
        - timedelta(
            days=1
        )
    )

    return previous_day.replace(
        hour=cycles[-1],
        minute=0,
        second=0,
        microsecond=0,
    )


def previous_gfs_cycle(
    initialization_time: datetime,
) -> datetime:
    """
    Return the immediately preceding configured
    GFS cycle.
    """

    initialization_time = (
        _require_aware_datetime(
            initialization_time,
            name="initialization_time",
        )
    )

    cycles = sorted(
        NORMAL_CYCLES_UTC
    )

    if (
        initialization_time.hour
        not in cycles
    ):
        raise ValueError(
            "initialization_time is not "
            "a configured GFS cycle."
        )

    index = cycles.index(
        initialization_time.hour
    )

    if index > 0:
        return initialization_time.replace(
            hour=cycles[index - 1],
            minute=0,
            second=0,
            microsecond=0,
        )

    previous_day = (
        initialization_time
        - timedelta(
            days=1
        )
    )

    return previous_day.replace(
        hour=cycles[-1],
        minute=0,
        second=0,
        microsecond=0,
    )


def select_latest_available_gfs_cycle(
    *,
    now: datetime | None = None,
    availability_delay_hours: (
        int
        | None
    ) = None,
    verify_with_noaa: bool = True,
    max_probe_attempts: int = 8,
) -> GFSCycleSelection:
    """
    Select the newest usable GFS cycle.

    Phase 1:

    1. Apply the configured publication safety delay.
    2. Determine the newest possible normal GFS cycle.
    3. Probe NOAA NOMADS.
    4. If unavailable, step backward through previous
       cycles until NOAA confirms one exists.

    When verify_with_noaa=False, this behaves like the
    earlier deterministic clock-only selector. That is
    useful for tests that must not make network calls.
    """

    if now is None:
        now = datetime.now(
            timezone.utc
        )

    now = (
        _require_aware_datetime(
            now,
            name="now",
        )
    )

    if availability_delay_hours is None:
        availability_delay_hours = (
            GFS_CYCLE_AVAILABILITY_DELAY_HOURS
        )

    if availability_delay_hours < 0:
        raise ValueError(
            "availability_delay_hours "
            "cannot be negative."
        )

    if max_probe_attempts < 1:
        raise ValueError(
            "max_probe_attempts must "
            "be at least 1."
        )

    reference_time = (
        now
        - timedelta(
            hours=(
                availability_delay_hours
            )
        )
    )

    candidate = (
        latest_gfs_cycle_at_or_before(
            reference_time
        )
    )

    # Deterministic mode used by tests/backfills where
    # no network availability check is wanted.
    if not verify_with_noaa:
        return GFSCycleSelection(
            initialization_time=(
                candidate
            ),

            reference_time=(
                reference_time
            ),

            availability_delay_hours=(
                availability_delay_hours
            ),

            availability=None,

            attempts=(),
        )

    attempts = []

    for _ in range(
        max_probe_attempts
    ):
        availability = (
            probe_gfs_cycle(
                initialization_time=(
                    candidate
                )
            )
        )

        attempts.append(
            availability
        )

        if availability.available:
            return GFSCycleSelection(
                initialization_time=(
                    candidate
                ),

                reference_time=(
                    reference_time
                ),

                availability_delay_hours=(
                    availability_delay_hours
                ),

                availability=(
                    availability
                ),

                attempts=tuple(
                    attempts
                ),
            )

        candidate = (
            previous_gfs_cycle(
                candidate
            )
        )

    attempted_cycles = [
        attempt
        .initialization_time
        .isoformat()
        for attempt in attempts
    ]

    raise RuntimeError(
        "No available GFS cycle was "
        "confirmed by NOAA after "
        f"{max_probe_attempts} attempts. "
        f"Attempted: {attempted_cycles}"
    )