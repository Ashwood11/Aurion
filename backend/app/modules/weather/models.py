from sqlalchemy import Column, Integer, Float, String, DateTime, JSON
from datetime import datetime
from app.core.database import Base


class WeatherData(Base):
    __tablename__ = "weather_data"

    id = Column(Integer, primary_key=True, index=True)

    location = Column(String, index=True)

    timestamp = Column(DateTime, default=datetime.utcnow)

    temperature_2m = Column(Float)
    apparent_temperature = Column(Float)
    relative_humidity = Column(Float)
    precipitation = Column(Float)

    wind_speed_10m = Column(Float)
    wind_direction_10m = Column(Float)

    cloud_cover = Column(Float)
    dew_point = Column(Float)

    extra_metadata = Column(JSON)