import os
import time
import requests
import psycopg2
from psycopg2.extras import Json
from dotenv import load_dotenv

load_dotenv()

VISUAL_CROSSING_API_KEY = os.getenv("VISUAL_CROSSING_API_KEY")

PGHOST = os.getenv("PGHOST", "localhost")
PGPORT = os.getenv("PGPORT", "5432")
PGDATABASE = os.getenv("PGDATABASE")
PGUSER = os.getenv("PGUSER")
PGPASSWORD = os.getenv("PGPASSWORD")

if not VISUAL_CROSSING_API_KEY:
    raise ValueError("Missing VISUAL_CROSSING_API_KEY in .env")

if not all([PGDATABASE, PGUSER, PGPASSWORD]):
    raise ValueError("Missing one or more PostgreSQL connection values in .env")


def get_connection():
    return psycopg2.connect(
        host=PGHOST,
        port=PGPORT,
        dbname=PGDATABASE,
        user=PGUSER,
        password=PGPASSWORD,
    )


def fetch_target_grid_points(conn, limit=20):
    """
    Starts with only the grid points actually mapped to strategic points.
    That is the correct first step.
    """
    with conn.cursor() as cur:
        cur.execute(
            """
            SELECT DISTINCT gp.id, gp.latitude, gp.longitude, gp.grid_code
            FROM weather_grid_point gp
            JOIN strategic_point_grid_map spgm
              ON spgm.grid_point_id = gp.id
            ORDER BY gp.grid_code
            LIMIT %s;
            """,
            (limit,),
        )
        return cur.fetchall()


def build_visual_crossing_url(lat, lon, start_date, end_date):
    location = f"{lat},{lon}"
    return (
        f"https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/"
        f"{location}/{start_date}/{end_date}"
        f"?unitGroup=metric"
        f"&include=hours"
        f"&elements=datetime,temp,feelslike,humidity,dew,pressure,windspeed,windgust,"
        f"winddir,precip,snow,cloudcover,visibility,solarradiation,uvindex,conditions,icon"
        f"&key={VISUAL_CROSSING_API_KEY}"
        f"&contentType=json"
    )


def fetch_weather_for_point(lat, lon, start_date, end_date):
    url = build_visual_crossing_url(lat, lon, start_date, end_date)
    response = requests.get(url, timeout=60)
    response.raise_for_status()
    return response.json()


def insert_weather_rows(conn, grid_point_id, weather_json, data_type="historical"):
    rows_inserted = 0

    days = weather_json.get("days", [])
    if not days:
        return 0

    with conn.cursor() as cur:
        for day in days:
            day_date = day.get("datetime")
            hours = day.get("hours", [])

            for hour in hours:
                hour_time = hour.get("datetime")
                if not day_date or not hour_time:
                    continue

                observation_time = f"{day_date} {hour_time}"

                cur.execute(
                    """
                    INSERT INTO weather_observation (
                        grid_point_id,
                        observation_time,
                        data_type,
                        source_system,
                        temp_c,
                        feels_like_c,
                        humidity_pct,
                        dew_point_c,
                        pressure_mb,
                        wind_speed_kph,
                        wind_gust_kph,
                        wind_dir_deg,
                        precip_mm,
                        snow_mm,
                        cloud_cover_pct,
                        visibility_km,
                        solar_radiation_wm2,
                        uv_index,
                        conditions_text,
                        icon,
                        raw_payload
                    )
                    VALUES (
                        %s, %s, %s, 'visual_crossing',
                        %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s
                    )
                    ON CONFLICT (grid_point_id, observation_time, data_type, source_system)
                    DO NOTHING;
                    """,
                    (
                        grid_point_id,
                        observation_time,
                        data_type,
                        hour.get("temp"),
                        hour.get("feelslike"),
                        hour.get("humidity"),
                        hour.get("dew"),
                        hour.get("pressure"),
                        hour.get("windspeed"),
                        hour.get("windgust"),
                        hour.get("winddir"),
                        hour.get("precip"),
                        hour.get("snow"),
                        hour.get("cloudcover"),
                        hour.get("visibility"),
                        hour.get("solarradiation"),
                        hour.get("uvindex"),
                        hour.get("conditions"),
                        hour.get("icon"),
                        Json(hour),
                    ),
                )

                if cur.rowcount > 0:
                    rows_inserted += 1

    return rows_inserted


def main():
    start_date = "2026-03-30"
    end_date = "2026-04-06"
    batch_limit = 20

    conn = get_connection()
    conn.autocommit = False

    try:
        targets = fetch_target_grid_points(conn, limit=batch_limit)
        print(f"Found {len(targets)} mapped grid points to process.")

        total_inserted = 0

        for idx, (grid_point_id, lat, lon, grid_code) in enumerate(targets, start=1):
            print(f"[{idx}/{len(targets)}] Fetching {grid_code} ({lat}, {lon})")

            try:
                weather_json = fetch_weather_for_point(lat, lon, start_date, end_date)
                inserted = insert_weather_rows(conn, grid_point_id, weather_json, data_type="historical")
                conn.commit()
                total_inserted += inserted
                print(f"    Inserted {inserted} hourly rows.")
            except Exception as e:
                conn.rollback()
                print(f"    ERROR for {grid_code}: {e}")

            time.sleep(1)

        print(f"Done. Total inserted rows: {total_inserted}")

    finally:
        conn.close()


if __name__ == "__main__":
    main()