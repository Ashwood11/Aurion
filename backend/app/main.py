from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.api.airports import router as airports_router
from app.api.mining import router as mining_router
from app.api.planes import router as planes_router
from app.api.ports import router as ports_router
from app.api.weather import get_globe_weather, router as weather_router


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
app.include_router(weather_router)


# Temporary compatibility route for the current frontend.
# New callers should use /api/weather/globe.
@app.get("/globe/data", deprecated=True)
def get_globe_data():
    return get_globe_weather()


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
