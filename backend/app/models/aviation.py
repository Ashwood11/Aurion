from sqlalchemy import Column, Integer, BigInteger, Text, Float, DateTime
from sqlalchemy.sql import func

from app.core.database import Base


class FlightLive(Base):
    __tablename__ = "flight_live"
    __table_args__ = {"schema": "aviation"}

    id = Column(BigInteger, primary_key=True, autoincrement=True)
    flight_id = Column(Text, nullable=False, unique=True, index=True)
    icao24 = Column(Text, nullable=True, index=True)
    callsign = Column(Text, nullable=True, index=True)
    aircraft_type = Column(Text, nullable=True)

    latitude = Column(Float, nullable=False)
    longitude = Column(Float, nullable=False)
    altitude_ft = Column(Integer, nullable=True)
    ground_speed_kts = Column(Integer, nullable=True)
    heading_deg = Column(Integer, nullable=True)
    vertical_rate_fpm = Column(Integer, nullable=True)

    origin_airport_code = Column(Text, nullable=True)
    destination_airport_code = Column(Text, nullable=True)
    status = Column(Text, nullable=True)
    source = Column(Text, nullable=False, default="mock")

    first_seen_at = Column(DateTime(timezone=True), nullable=True)
    last_seen_at = Column(DateTime(timezone=True), nullable=False)
    updated_at = Column(DateTime(timezone=True), nullable=False, server_default=func.now(), onupdate=func.now())