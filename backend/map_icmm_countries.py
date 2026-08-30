import pycountry
import psycopg

DB_CONFIG = {
    "dbname": "aurion",
    "user": "postgres",
    "password": "123",
    "host": "localhost",
    "port": 5432,
}

ALIASES = {
    "Bolivia": "BO",
    "Brunei": "BN",
    "Democratic Republic of the Congo": "CD",
    "Iran": "IR",
    "Laos": "LA",
    "Moldova": "MD",
    "North Korea": "KP",
    "Russia": "RU",
    "South Korea": "KR",
    "Syria": "SY",
    "Taiwan": "TW",
    "Tanzania": "TZ",
    "Turkey": "TR",
    "Venezuela": "VE",
    "Vietnam": "VN",
    "Kosovo": "XK",
}

with psycopg.connect(**DB_CONFIG) as conn:
    with conn.cursor() as cur:

        cur.execute("""
            SELECT source_country_name
            FROM geo.stage_country_name_iso2
            ORDER BY source_country_name;
        """)

        countries = [row[0] for row in cur.fetchall()]

        for name in countries:
            iso2 = None
            method = None

            if name == "Kosovo":
                iso2 = "XK"
                method = "user_assigned_code"

            elif name in ALIASES:
                iso2 = ALIASES[name]
                method = "explicit_alias"

            else:
                try:
                    country = pycountry.countries.lookup(name)
                    iso2 = country.alpha_2
                    method = "pycountry"

                except LookupError:
                    iso2 = None
                    method = "unresolved"

            cur.execute("""
                UPDATE geo.stage_country_name_iso2
                SET
                    iso2 = %s,
                    match_method = %s
                WHERE source_country_name = %s;
            """, (iso2, method, name))

    conn.commit()

print("Country mapping complete.")