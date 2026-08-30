from pathlib import Path
from collections import defaultdict

import eccodes
import h3


GRIB_FILE = Path(
    "data/weather/gfs/test/"
    "gfs_20260828_06_f003_oklahoma.grib2"
)

H3_RESOLUTION = 5


FIELD_SELECTORS = {
    "AIR_TEMP_2M_INSTANT": {
        "paramId": 167,
        "typeOfLevel": "heightAboveGround",
        "level": 2,
        "stepType": "instant",
    },

    "DEW_POINT_2M_INSTANT": {
        "paramId": 168,
        "typeOfLevel": "heightAboveGround",
        "level": 2,
        "stepType": "instant",
    },

    "RELATIVE_HUMIDITY_2M_INSTANT": {
        "paramId": 260242,
        "typeOfLevel": "heightAboveGround",
        "level": 2,
        "stepType": "instant",
    },

    "WIND_U_10M_INSTANT": {
        "paramId": 165,
        "typeOfLevel": "heightAboveGround",
        "level": 10,
        "stepType": "instant",
    },

    "WIND_V_10M_INSTANT": {
        "paramId": 166,
        "typeOfLevel": "heightAboveGround",
        "level": 10,
        "stepType": "instant",
    },

    "SURFACE_PRESSURE_INSTANT": {
        "paramId": 134,
        "typeOfLevel": "surface",
        "level": 0,
        "stepType": "instant",
    },

    "PRECIP_INTERVAL_TOTAL": {
        "paramId": 228228,
        "typeOfLevel": "surface",
        "level": 0,
        "stepType": "accum",
    },
}


def safe_get(gid, key):
    try:
        return eccodes.codes_get(gid, key)
    except Exception:
        return None


def normalize_longitude(lon):
    if lon > 180:
        return lon - 360

    return lon


def message_matches(gid, selector):
    return (
        safe_get(gid, "paramId") == selector["paramId"]
        and safe_get(gid, "typeOfLevel")
        == selector["typeOfLevel"]
        and safe_get(gid, "level") == selector["level"]
        and safe_get(gid, "stepType") == selector["stepType"]
    )


def canonical_variable_for_message(gid):
    for variable_code, selector in FIELD_SELECTORS.items():
        if message_matches(gid, selector):
            return variable_code

    return None


def duplicate_signature(gid):
    return (
        safe_get(gid, "paramId"),
        safe_get(gid, "typeOfLevel"),
        safe_get(gid, "level"),
        safe_get(gid, "stepType"),
        safe_get(gid, "startStep"),
        safe_get(gid, "endStep"),
        safe_get(gid, "validityDate"),
        safe_get(gid, "validityTime"),
        safe_get(gid, "dataDate"),
        safe_get(gid, "dataTime"),
        safe_get(gid, "productDefinitionTemplateNumber"),
        safe_get(gid, "generatingProcessIdentifier"),
    )


def extract_h3_points():
    seen_signatures = set()

    fields = {}

    with GRIB_FILE.open("rb") as f:
        while True:
            gid = eccodes.codes_grib_new_from_file(f)

            if gid is None:
                break

            try:
                variable_code = canonical_variable_for_message(gid)

                if variable_code is None:
                    continue

                signature = duplicate_signature(gid)

                if signature in seen_signatures:
                    continue

                seen_signatures.add(signature)

                points = eccodes.codes_grib_get_data(gid)

                h3_points = []

                for point in points:
                    lat = float(point["lat"])
                    lon = normalize_longitude(
                        float(point["lon"])
                    )

                    h3_cell = h3.latlng_to_cell(
                        lat,
                        lon,
                        H3_RESOLUTION,
                    )

                    center_lat, center_lon = (
                        h3.cell_to_latlng(h3_cell)
                    )

                    h3_points.append(
                        {
                            "lat": lat,
                            "lon": lon,
                            "h3_cell": h3_cell,
                            "h3_center_lat": center_lat,
                            "h3_center_lon": center_lon,
                            "value": float(
                                point["value"]
                            ),
                        }
                    )

                fields[variable_code] = h3_points

            finally:
                eccodes.codes_release(gid)

    return fields


def audit_h3(fields):
    print()
    print("=" * 110)
    print("GFS → H3-5 GEOGRAPHY TEST")
    print("=" * 110)

    all_cells = set()

    reference_cells = None

    for variable_code, points in fields.items():
        cells = {
            point["h3_cell"]
            for point in points
        }

        all_cells.update(cells)

        print()
        print(variable_code)
        print("-" * 110)

        print(
            f"Native GFS points: {len(points)}"
        )

        print(
            f"Unique H3-5 cells: {len(cells)}"
        )

        if reference_cells is None:
            reference_cells = cells

        elif cells != reference_cells:
            print(
                "WARNING: H3 cell set differs "
                "between variables."
            )

        sample = points[
            len(points) // 2
        ]

        print(
            "Sample:"
        )

        print(
            f"  GFS point: "
            f"{sample['lat']:.4f}, "
            f"{sample['lon']:.4f}"
        )

        print(
            f"  H3 cell: "
            f"{sample['h3_cell']}"
        )

        print(
            f"  H3 center: "
            f"{sample['h3_center_lat']:.6f}, "
            f"{sample['h3_center_lon']:.6f}"
        )

    print()
    print("=" * 110)
    print("OVERALL")
    print("=" * 110)

    print(
        f"Canonical variables: {len(fields)}"
    )

    print(
        f"Unique H3-5 cells across test: "
        f"{len(all_cells)}"
    )

    if len(fields) == len(FIELD_SELECTORS):
        print(
            "All expected variables present."
        )
    else:
        print(
            "WARNING: Missing canonical variables."
        )

    if reference_cells is not None:
        same_cells = all(
            {
                point["h3_cell"]
                for point in points
            }
            == reference_cells
            for points in fields.values()
        )

        if same_cells:
            print(
                "All variables share the same "
                "native GFS point/H3 mapping."
            )
        else:
            print(
                "WARNING: Variable grids differ."
            )

    print()
    print("H3 cells:")

    for cell in sorted(all_cells):
        lat, lon = h3.cell_to_latlng(cell)

        print(
            f"  {cell} | "
            f"{lat:.6f}, {lon:.6f}"
        )


if __name__ == "__main__":
    if not GRIB_FILE.exists():
        raise FileNotFoundError(
            f"GRIB file not found: {GRIB_FILE}"
        )

    fields = extract_h3_points()

    audit_h3(fields)