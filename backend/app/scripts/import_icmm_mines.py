import os
import re
from collections import Counter

import pandas as pd
import psycopg2
from psycopg2.extras import Json
from dotenv import load_dotenv

load_dotenv()

EXCEL_FILE = "global-mining-dataset.xlsx"
SHEET_NAME = "External"
SOURCE_SYSTEM = "icmm"


COMMODITY_ALIASES = {
    "alumina": "alumina",
    "aluminium": "aluminium",
    "antimony": "antimony",
    "barium": "barium",
    "bauxite": "bauxite",
    "borates": "borates",
    "boron": "boron",
    "chromite": "chromite",
    "chromium": "chromium",
    "coal": "coal",
    "cobalt": "cobalt",
    "copper": "copper",
    "diamond": "diamond",
    "ferrochrome": "ferrochrome",
    "ferromanganese": "ferromanganese",
    "ferromolybdenum": "ferromolybdenum",
    "ferronickel": "ferronickel",
    "ferroniobium": "ferroniobium",
    "ferrosilicon manganese": "ferrosilicon_manganese",
    "ferrosilicon": "ferrosilicon",
    "ferrotungsten": "ferrotungsten",
    "ferrovanadium": "ferrovanadium",
    "fluorspar": "fluorspar",
    "gold": "gold",
    "graphite": "graphite",
    "heavy mineral sands": "heavy_mineral_sands",
    "iron ore": "iron_ore",
    "lead": "lead",
    "lithium": "lithium",
    "manganese": "manganese",
    "mercury": "mercury",
    "molybdenum": "molybdenum",
    "nickel": "nickel",
    "niobium": "niobium",
    "pge/pgm": "pge_pgm",
    "pgm": "pge_pgm",
    "pge": "pge_pgm",
    "phosphate": "phosphate",
    "potash": "potash",
    "ree": "rare_earth_elements",
    "rare earth": "rare_earth_elements",
    "rare earth elements": "rare_earth_elements",
    "silver": "silver",
    "steel": "steel",
    "tantalum": "tantalum",
    "tin": "tin",
    "titanium": "titanium",
    "tungsten": "tungsten",
    "uranium": "uranium",
    "vanadium": "vanadium",
    "zinc": "zinc",
}


COMMODITY_GROUPS = {
    "alumina": "aluminium_chain",
    "aluminium": "aluminium_chain",
    "bauxite": "aluminium_chain",
    "coal": "energy",
    "uranium": "energy",
    "copper": "base_metal",
    "lead": "base_metal",
    "nickel": "base_metal",
    "tin": "base_metal",
    "zinc": "base_metal",
    "gold": "precious_metal",
    "silver": "precious_metal",
    "pge_pgm": "precious_metal",
    "diamond": "precious_mineral",
    "iron_ore": "steel_chain",
    "steel": "steel_chain",
    "manganese": "steel_chain",
    "chromite": "steel_chain",
    "chromium": "steel_chain",
    "ferrochrome": "steel_chain",
    "ferromanganese": "steel_chain",
    "ferromolybdenum": "steel_chain",
    "ferronickel": "steel_chain",
    "ferroniobium": "steel_chain",
    "ferrosilicon": "steel_chain",
    "ferrosilicon_manganese": "steel_chain",
    "ferrotungsten": "steel_chain",
    "ferrovanadium": "steel_chain",
    "lithium": "battery_critical",
    "cobalt": "battery_critical",
    "graphite": "battery_critical",
    "rare_earth_elements": "battery_critical",
    "vanadium": "battery_critical",
    "tantalum": "battery_critical",
    "niobium": "battery_critical",
    "molybdenum": "industrial_metal",
    "tungsten": "industrial_metal",
    "titanium": "industrial_metal",
    "antimony": "industrial_metal",
    "barium": "industrial_metal",
    "borates": "industrial_mineral",
    "boron": "industrial_mineral",
    "fluorspar": "industrial_mineral",
    "heavy_mineral_sands": "industrial_mineral",
    "phosphate": "agriculture",
    "potash": "agriculture",
    "mercury": "hazardous_legacy",
}


def clean_text(value):
    if pd.isna(value):
        return None

    value = str(value).strip()

    if not value or value.lower() in {"nan", "none", "null"}:
        return None

    return value


def safe_float(value):
    if pd.isna(value):
        return None

    try:
        return float(value)
    except Exception:
        return None


def clean_column_name(col):
    col = str(col).strip()
    col = col.replace("\n", " ")
    col = re.sub(r"\s+", " ", col)
    return col


def normalize_columns(df):
    df.columns = [clean_column_name(col) for col in df.columns]

    return df.rename(columns={
        "ICMMID": "icmm_id",
        "Confidence Factor": "confidence_factor",
        "Mine Name": "mine_name",
        "Group Names": "group_names",
        "Latitude": "latitude",
        "Longitude": "longitude",
        "Asset Type": "asset_type",
        "Country or Region": "country_or_region",
        "Primary Commodity": "primary_commodity",
        "Secondary Commodity": "secondary_commodity",
        "Other Commodities.": "other_commodities",
        "Other Commodities": "other_commodities",
    })


def normalize_commodity(value):
    value = clean_text(value)

    if not value:
        return None

    value = value.lower().strip()
    value = re.sub(r"\s+", " ", value)

    if value in COMMODITY_ALIASES:
        return COMMODITY_ALIASES[value]

    for raw_name in sorted(COMMODITY_ALIASES.keys(), key=len, reverse=True):
        if raw_name in value:
            return COMMODITY_ALIASES[raw_name]

    return None


def split_commodities(value):
    value = clean_text(value)

    if not value:
        return []

    parts = re.split(r"[,;/|]+", value)
    commodities = []

    for part in parts:
        commodity = normalize_commodity(part)

        if commodity:
            commodities.append(commodity)

    return list(dict.fromkeys(commodities))


def get_group(commodity):
    return COMMODITY_GROUPS.get(commodity, "other")


def normalize_entity_type(asset_type_raw):
    asset_type_raw = clean_text(asset_type_raw)

    if not asset_type_raw:
        return "mining_asset"

    value = asset_type_raw.lower()

    has_mine = "mine" in value
    has_smelter = "smelter" in value
    has_refinery = "refinery" in value
    has_plant = "plant" in value

    type_count = sum([has_mine, has_smelter, has_refinery, has_plant])

    if type_count > 1:
        return "mixed_mining_asset"

    if has_mine:
        return "mine"

    if has_smelter:
        return "smelter"

    if has_refinery:
        return "refinery"

    if has_plant:
        return "plant"

    return "mining_asset"


def build_record(row):
    source_id = clean_text(row.get("icmm_id"))
    mine_name = clean_text(row.get("mine_name"))

    lat = safe_float(row.get("latitude"))
    lng = safe_float(row.get("longitude"))

    if not source_id:
        return None, "missing_source_id"

    if not mine_name:
        return None, "missing_mine_name"

    if lat is None or lng is None:
        return None, "missing_coordinates"

    if not (-90 <= lat <= 90 and -180 <= lng <= 180):
        return None, "invalid_coordinates"

    primary = normalize_commodity(row.get("primary_commodity"))

    if not primary:
        return None, "missing_or_unknown_primary_commodity"

    secondary = normalize_commodity(row.get("secondary_commodity"))
    other_commodities = split_commodities(row.get("other_commodities"))

    all_commodities = [primary]

    if secondary:
        all_commodities.append(secondary)

    all_commodities.extend(other_commodities)
    all_commodities = list(dict.fromkeys(all_commodities))

    asset_type_raw = clean_text(row.get("asset_type"))
    entity_type = normalize_entity_type(asset_type_raw)

    details = {
        "icmm_id": source_id,
        "confidence_factor": clean_text(row.get("confidence_factor")),
        "asset_type_raw": asset_type_raw,
        "country_or_region": clean_text(row.get("country_or_region")),
        "group_names": clean_text(row.get("group_names")),
        "primary_commodity_raw": clean_text(row.get("primary_commodity")),
        "secondary_commodity_raw": clean_text(row.get("secondary_commodity")),
        "other_commodities_raw": clean_text(row.get("other_commodities")),
    }

    return {
        "source_id": source_id,
        "mine_name": mine_name,
        "entity_type": entity_type,
        "lat": lat,
        "lng": lng,
        "country_or_region": clean_text(row.get("country_or_region")),
        "confidence_factor": clean_text(row.get("confidence_factor")),
        "asset_type_raw": asset_type_raw,
        "primary_commodity": primary,
        "primary_commodity_group": get_group(primary),
        "secondary_commodity": secondary,
        "other_commodities": other_commodities,
        "all_commodities": all_commodities,
        "group_names": clean_text(row.get("group_names")),
        "importance_score": 0.9,
        "details": details,
    }, None


def get_connection():
    return psycopg2.connect(
        host=os.getenv("PGHOST", "localhost"),
        port=os.getenv("PGPORT", "5432"),
        dbname=os.getenv("PGDATABASE"),
        user=os.getenv("PGUSER"),
        password=os.getenv("PGPASSWORD"),
    )


def insert_record(cur, record):
    cur.execute(
        """
        INSERT INTO geo.locations (
            entity_type,
            name,
            lat,
            lng,
            country_code,
            source_system,
            source_id,
            details,
            updated_at
        )
        VALUES (
            %s,
            %s,
            %s,
            %s,
            %s,
            %s,
            %s,
            %s,
            NOW()
        )
        ON CONFLICT (source_system, source_id)
        WHERE source_id IS NOT NULL
        DO UPDATE SET
            entity_type = EXCLUDED.entity_type,
            name = EXCLUDED.name,
            lat = EXCLUDED.lat,
            lng = EXCLUDED.lng,
            country_code = EXCLUDED.country_code,
            details = EXCLUDED.details,
            updated_at = NOW()
        RETURNING id;
        """,
        (
            record["entity_type"],
            record["mine_name"],
            record["lat"],
            record["lng"],
            record["country_or_region"],
            SOURCE_SYSTEM,
            record["source_id"],
            Json(record["details"]),
        ),
    )

    location_id = cur.fetchone()[0]

    cur.execute(
        """
        INSERT INTO mining.mines (
            location_id,
            source_system,
            source_id,
            mine_name,
            confidence_factor,
            asset_type_raw,
            primary_commodity,
            primary_commodity_group,
            secondary_commodity,
            other_commodities,
            all_commodities,
            group_names,
            importance_score,
            details,
            updated_at
        )
        VALUES (
            %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, NOW()
        )
        ON CONFLICT (source_system, source_id)
        WHERE source_id IS NOT NULL
        DO UPDATE SET
            location_id = EXCLUDED.location_id,
            mine_name = EXCLUDED.mine_name,
            confidence_factor = EXCLUDED.confidence_factor,
            asset_type_raw = EXCLUDED.asset_type_raw,
            primary_commodity = EXCLUDED.primary_commodity,
            primary_commodity_group = EXCLUDED.primary_commodity_group,
            secondary_commodity = EXCLUDED.secondary_commodity,
            other_commodities = EXCLUDED.other_commodities,
            all_commodities = EXCLUDED.all_commodities,
            group_names = EXCLUDED.group_names,
            importance_score = EXCLUDED.importance_score,
            details = EXCLUDED.details,
            updated_at = NOW();
        """,
        (
            location_id,
            SOURCE_SYSTEM,
            record["source_id"],
            record["mine_name"],
            record["confidence_factor"],
            record["asset_type_raw"],
            record["primary_commodity"],
            record["primary_commodity_group"],
            record["secondary_commodity"],
            record["other_commodities"],
            record["all_commodities"],
            record["group_names"],
            record["importance_score"],
            Json(record["details"]),
        ),
    )


def main():
    print("Loading ICMM Excel file...")

    df = pd.read_excel(EXCEL_FILE, sheet_name=SHEET_NAME)
    df = normalize_columns(df)

    print(f"Raw rows loaded: {len(df)}")
    print("Columns found:")
    print(df.columns.tolist())

    required_columns = [
        "icmm_id",
        "mine_name",
        "latitude",
        "longitude",
        "primary_commodity",
    ]

    missing_columns = [col for col in required_columns if col not in df.columns]

    if missing_columns:
        print("Missing required columns:")
        print(missing_columns)
        print("Import stopped.")
        return

    records = []
    rejected = Counter()

    for _, row in df.iterrows():
        record, reason = build_record(row)

        if record:
            records.append(record)
        else:
            rejected[reason] += 1

    print(f"Valid normalized mining asset records: {len(records)}")

    if rejected:
        print("Rejected rows:")
        for reason, count in rejected.items():
            print(f"- {reason}: {count}")

    if not records:
        print("No valid records found. Nothing inserted.")
        return

    conn = get_connection()

    try:
        with conn:
            with conn.cursor() as cur:
                for record in records:
                    insert_record(cur, record)

        print("Import complete.")
        print(f"Inserted/updated mining assets: {len(records)}")

    finally:
        conn.close()


if __name__ == "__main__":
    main()