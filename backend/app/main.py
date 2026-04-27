from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import select

from app.api.airports import router as airports_router
from app.api.planes import router as planes_router
from app.api.ports import router as ports_router
from app.api.mining import router as mining_router

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


app.include_router(airports_router)
app.include_router(planes_router)
app.include_router(ports_router)
app.include_router(mining_router)


@app.get("/globe/data")
def get_globe_data():
    db = SessionLocal()

    try:
        weather = db.execute(select(WeatherData)).scalars().all()

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

    uvicorn.run(
        "app.main:app",
        host="127.0.0.1",
        port=8000,
        reload=True,
    )