from sqlalchemy import Column, Integer, Float, String
from app.core.database import Base

class WeatherData(Base):
    __tablename__ = "weather_data"

    id = Column(Integer, primary_key=True, index=True)
    location = Column(String)
    temperature = Column(Float)