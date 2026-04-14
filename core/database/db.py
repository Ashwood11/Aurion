# core/database/db.py
import os
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, JSON
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import sessionmaker
from dotenv import load_dotenv
from datetime import datetime
from enum import Enum

# Load environment variables
load_dotenv()

# Build DATABASE_URL from individual PG variables (recommended way)
DATABASE_URL = (
    f"postgresql+psycopg2://"
    f"{os.getenv('PGUSER', 'postgres')}:"
    f"{os.getenv('PGPASSWORD', '123')}"
    f"@{os.getenv('PGHOST', 'localhost')}:"
    f"{os.getenv('PGPORT', '5432')}/"
    f"{os.getenv('PGDATABASE', 'aurion')}"
)

engine = create_engine(DATABASE_URL, echo=False)
SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)
Base = declarative_base()


class SignalTypeDB(str, Enum):
    ANOMALY = "anomaly"
    BASELINE = "baseline"
    TREND = "trend"
    FUSION = "fusion"
    PREDICTION = "prediction"


class SeverityDB(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    EXTREME = "extreme"


class DBSignal(Base):
    __tablename__ = "signals"

    id = Column(Integer, primary_key=True, index=True)
    module = Column(String, index=True)
    signal_type = Column(String, index=True)
    name = Column(String, index=True)
    value = Column(Float)
    baseline = Column(Float, nullable=True)
    deviation = Column(Float, nullable=True)
    severity = Column(String)
    timestamp = Column(DateTime, default=datetime.utcnow, index=True)
    expires_at = Column(DateTime, nullable=True)
    source = Column(String)
    extra_metadata = Column(JSON, default=dict)
    tags = Column(JSON, default=list)
    confidence = Column(Float, default=0.7)


def get_db():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def init_db():
    Base.metadata.create_all(bind=engine)
    print("✅ Aurion database initialized successfully!")
    print(f"Connected to: {os.getenv('PGDATABASE')} on {os.getenv('PGHOST')}")


if __name__ == "__main__":
    init_db()

# At the top of core/database/db.py, after load_dotenv()
from .models.weather import WeatherData   # New import

# Update init_db function
def init_db():
    Base.metadata.create_all(bind=engine)
    print("✅ Aurion database initialized successfully!")
    print("   Tables created: signals, weather_data")
    print(f"Connected to: {os.getenv('PGDATABASE')} on {os.getenv('PGHOST')}")