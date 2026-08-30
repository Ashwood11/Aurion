from dataclasses import dataclass


@dataclass(frozen=True)
class GFSFieldSelector:
    canonical_variable_code: str

    param_id: int

    type_of_level: str
    level: int

    step_type: str


FIELD_SELECTORS = {

    "AIR_TEMP_2M_INSTANT": GFSFieldSelector(
        canonical_variable_code=(
            "AIR_TEMP_2M_INSTANT"
        ),
        param_id=167,
        type_of_level="heightAboveGround",
        level=2,
        step_type="instant",
    ),

    "DEW_POINT_2M_INSTANT": GFSFieldSelector(
        canonical_variable_code=(
            "DEW_POINT_2M_INSTANT"
        ),
        param_id=168,
        type_of_level="heightAboveGround",
        level=2,
        step_type="instant",
    ),

    "RELATIVE_HUMIDITY_2M_INSTANT":
        GFSFieldSelector(
            canonical_variable_code=(
                "RELATIVE_HUMIDITY_2M_INSTANT"
            ),
            param_id=260242,
            type_of_level="heightAboveGround",
            level=2,
            step_type="instant",
        ),

    "WIND_U_10M_INSTANT": GFSFieldSelector(
        canonical_variable_code=(
            "WIND_U_10M_INSTANT"
        ),
        param_id=165,
        type_of_level="heightAboveGround",
        level=10,
        step_type="instant",
    ),

    "WIND_V_10M_INSTANT": GFSFieldSelector(
        canonical_variable_code=(
            "WIND_V_10M_INSTANT"
        ),
        param_id=166,
        type_of_level="heightAboveGround",
        level=10,
        step_type="instant",
    ),

    "SURFACE_PRESSURE_INSTANT":
        GFSFieldSelector(
            canonical_variable_code=(
                "SURFACE_PRESSURE_INSTANT"
            ),
            param_id=134,
            type_of_level="surface",
            level=0,
            step_type="instant",
        ),

    "PRECIP_INTERVAL_TOTAL": GFSFieldSelector(
        canonical_variable_code=(
            "PRECIP_INTERVAL_TOTAL"
        ),
        param_id=228228,
        type_of_level="surface",
        level=0,
        step_type="accum",
    ),
}


def matches_selector(
    *,
    param_id,
    type_of_level,
    level,
    step_type,
    selector: GFSFieldSelector,
) -> bool:
    return (
        param_id == selector.param_id
        and type_of_level
        == selector.type_of_level
        and level == selector.level
        and step_type == selector.step_type
    )


def canonical_variable_for_grib(
    *,
    param_id,
    type_of_level,
    level,
    step_type,
):
    for selector in FIELD_SELECTORS.values():

        if matches_selector(
            param_id=param_id,
            type_of_level=type_of_level,
            level=level,
            step_type=step_type,
            selector=selector,
        ):
            return (
                selector.canonical_variable_code
            )

    return None