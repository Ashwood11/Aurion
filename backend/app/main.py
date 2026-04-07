from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.db import get_connection

app = FastAPI(title="AURION API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173", "http://127.0.0.1:5173"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/")
def root():
    return {"message": "AURION backend is running"}


@app.get("/grid")
def get_grid(step: int = 4):
    """
    step=1  -> every 0.5°
    step=2  -> every 1.0°
    step=4  -> every 2.0°
    step=6  -> every 3.0°
    """
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT grid_code, latitude, longitude
                FROM weather_grid_point
                WHERE MOD(ROUND((latitude + 90.0) * 2)::int, %s) = 0
                  AND MOD(ROUND((longitude + 180.0) * 2)::int, %s) = 0
                ORDER BY latitude, longitude;
                """,
                (step, step),
            )
            rows = cur.fetchall()

        return [
            {
                "gridCode": r[0],
                "lat": float(r[1]),
                "lng": float(r[2]),
            }
            for r in rows
        ]
    finally:
        conn.close()

@app.get("/points")
def get_points():
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute(
                """
                SELECT name, point_type, subtype, latitude, longitude, importance_score
                FROM strategic_point
                WHERE is_active = TRUE
                ORDER BY point_type, name;
                """
            )
            rows = cur.fetchall()

        return [
            {
                "name": r[0],
                "type": r[1],
                "subtype": r[2],
                "lat": r[3],
                "lng": r[4],
                "importance": float(r[5]) if r[5] is not None else None,
            }
            for r in rows
        ]
    finally:
        conn.close()


@app.get("/health/db")
def db_health():
    conn = get_connection()
    try:
        with conn.cursor() as cur:
            cur.execute("SELECT current_database(), NOW();")
            row = cur.fetchone()
        return {
            "database": row[0],
            "server_time": row[1].isoformat(),
            "status": "ok",
        }
    finally:
        conn.close()