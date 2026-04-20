import os
from pathlib import Path
from datetime import datetime
from enum import Enum

from dotenv import load_dotenv
from sqlalchemy import create_engine, Column, Integer, String, Float, DateTime, JSON
from sqlalchemy.orm import sessionmaker, declarative_base

# Resolve project root and explicitly load the root .env
ROOT_DIR = Path(__file__).resolve().parents[3]
ENV_PATH = ROOT_DIR / ".env"

load_dotenv(dotenv_path=ENV_PATH)

# Support either a full DATABASE_URL or separate PG* variables
DATABASE_URL = os.getenv("DATABASE_URL")

if not DATABASE_URL:
    pg_host = os.getenv("PGHOST")
    pg_port = os.getenv("PGPORT")
    pg_database = os.getenv("PGDATABASE")
    pg_user = os.getenv("PGUSER")
    pg_password = os.getenv("PGPASSWORD")

    missing = [
        name for name, value in {
            "PGHOST": pg_host,
            "PGPORT": pg_port,
            "PGDATABASE": pg_database,
            "PGUSER": pg_user,
            "PGPASSWORD": pg_password,
        }.items()
        if not value
    ]

    if missing:
        raise ValueError(
            f"Missing database environment variables in {ENV_PATH}: {', '.join(missing)}"
        )

    DATABASE_URL = (
        f"postgresql+psycopg2://{pg_user}:{pg_password}@{pg_host}:{pg_port}/{pg_database}"
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


if __name__ == "__main__":
    init_db()