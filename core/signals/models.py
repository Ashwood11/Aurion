from sqlalchemy import Column, Integer, String, Float, DateTime, JSON
from sqlalchemy.orm import declarative_base
from datetime import datetime

Base = declarative_base()

class AurionSignal(Base):
    __tablename__ = "signals"

    id = Column(Integer, primary_key=True, index=True)
    timestamp = Column(DateTime, default=datetime.utcnow)
    lat = Column(Float)
    lng = Column(Float)
    
    signal_type = Column(String)
    strength = Column(Float)
    confidence = Column(Float)
    
    summary = Column(String)
    source_module = Column(String)
    
    metadata = Column(JSON)
    tags = Column(JSON)   # List of strings stored as JSON