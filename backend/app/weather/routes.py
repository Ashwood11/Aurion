from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session
from core.database import get_db
from .ingestion import fetch_current_weather
from app.api.ports import router as ports_router

app.include_router(ports_router)

router = APIRouter()

@router.get("/current")
async def get_current_weather(db: Session = Depends(get_db)):
    signal = fetch_current_weather("New York", db)  # Change location as needed
    return {
        "status": "success",
        "signals": [signal.dict()] if signal else []
    }