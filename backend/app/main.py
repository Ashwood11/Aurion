from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import select, desc

from .core.database import SessionLocal
from .core.database.models.weather import WeatherData

app = FastAPI(title="Aurion Backend")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/globe/data")
def get_globe_data():
    db = SessionLocal()
    try:
        weather = db.execute(
            select(WeatherData).order_by(desc(WeatherData.timestamp))
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


@app.get("/")
def root():
    return {"message": "Aurion Backend is running ✅"}


if __name__ == "__main__":
    import uvicorn
    uvicorn.run("app.main:app", host="127.0.0.1", port=8000, reload=True)