# core/database/models/weather.py
from sqlalchemy import Column, Integer, Float, String, DateTime, JSON
from datetime import datetime
from core.database.db import Base   # Import shared Base


class WeatherData(Base):
    __tablename__ = "weather_data"

    id = Column(Integer, primary_key=True, index=True)
    location = Column(String(100), index=True, nullable=False)
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)

    # Main weather variables (structured columns)
    temperature_2m = Column(Float)
    apparent_temperature = Column(Float)
    relative_humidity = Column(Float)
    precipitation = Column(Float, default=0.0)
    wind_speed_10m = Column(Float)
    wind_direction_10m = Column(Float)
    cloud_cover = Column(Float)
    soil_temperature_0cm = Column(Float)
    soil_moisture_index = Column(Float)
    et0_evapotranspiration = Column(Float)
    dew_point = Column(Float)
    weather_code = Column(Integer)

    source = Column(String(50), default="open_meteo")
    extra_metadata = Column(JSON, default=dict)

    def __repr__(self):
        return f"<Weather {self.location} @ {self.timestamp} | {self.temperature_2m}°C>"