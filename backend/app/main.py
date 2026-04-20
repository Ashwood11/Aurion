from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import select, text
from app.api.planes import router as planes_router

from .core.database import SessionLocal
from .models.weather import WeatherData

app = FastAPI(title="Aurion Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.include_router(planes_router)


@app.get("/globe/data")
def get_globe_data():
    db = SessionLocal()
    try:
        weather = db.execute(
            select(WeatherData)
        ).scalars().all()

        return {
            "weather": [
                {
                    "name": w.location,
                    "temp": w.temperature_2m,
                    "wind": w.wind_speed_10m,
                    "precip": w.precipitation,
                }
                for w in weather
            ],
            "last_updated": datetime.now(timezone.utc).isoformat(),
        }
    finally:
        db.close()


@app.get("/api/airports")
def get_airports(
    limit: int = 3000,
    airport_types: str = "large_airport,medium_airport"
):
    db = SessionLocal()
    try:
        airport_type_list = [a.strip() for a in airport_types.split(",") if a.strip()]
        if not airport_type_list:
            airport_type_list = ["large_airport", "medium_airport"]

        placeholders = ", ".join([f":type_{i}" for i in range(len(airport_type_list))])

        query = text(f"""
            SELECT
                l.id,
                l.name,
                l.lat,
                l.lng,
                a.ident,
                a.iata_code,
                a.gps_code,
                a.airport_type,
                a.scheduled_service
            FROM geo.locations l
            JOIN geo.airports a
              ON a.location_id = l.id
            WHERE l.entity_type = 'airport'
              AND a.airport_type IN ({placeholders})
            LIMIT :limit
        """)

        params = {"limit": limit}
        for i, airport_type in enumerate(airport_type_list):
            params[f"type_{i}"] = airport_type

        result = db.execute(query, params).fetchall()

        return [
            {
                "id": r.id,
                "name": r.name,
                "lat": r.lat,
                "lng": r.lng,
                "code": r.iata_code or r.ident,
                "ident": r.ident,
                "gps_code": r.gps_code,
                "airport_type": r.airport_type,
                "scheduled_service": r.scheduled_service,
            }
            for r in result
        ]
    finally:
        db.close()


@app.get("/")
def root():
    return {"message": "Aurion Backend is running ✅"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="127.0.0.1", port=8000, reload=True)