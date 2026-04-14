# core/signals/models.py
from datetime import datetime
from enum import Enum
from pydantic import BaseModel, Field
from typing import Dict, List, Optional, Any


class SignalType(str, Enum):
    ANOMALY = "anomaly"
    BASELINE = "baseline"
    TREND = "trend"
    FUSION = "fusion"
    PREDICTION = "prediction"


class Severity(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    EXTREME = "extreme"


class DataSource(str, Enum):
    OPEN_METEO = "open_meteo"
    NOAA = "noaa"
    CME = "cme"
    FLIGHT_AWARE = "flight_aware"
    # Add more later


class Signal(BaseModel):
    id: Optional[str] = None
    module: str                          # e.g. "weather"
    signal_type: SignalType
    name: str                            # e.g. "Temperature_Anomaly_Europe"
    value: float
    baseline: Optional[float] = None
    deviation: Optional[float] = None
    severity: Severity
    timestamp: datetime
    expires_at: Optional[datetime] = None
    source: DataSource
    extra_metadata: Dict[str, Any] = Field(default_factory=dict)   # ← Changed
    tags: List[str] = Field(default_factory=list)
    confidence: float = Field(ge=0.0, le=1.0, default=0.7)

    class Config:
        from_attributes = True


class Anomaly(Signal):
    """Specific type for anomalies"""
    signal_type: SignalType = SignalType.ANOMALY
    expected_range: tuple[float, float]


# Example usage
if __name__ == "__main__":
    from datetime import datetime, timezone
    
    signal = Signal(
        module="weather",
        signal_type=SignalType.ANOMALY,
        name="Heatwave_Detected",
        value=38.5,
        baseline=22.0,
        deviation=3.2,
        severity=Severity.HIGH,
        timestamp=datetime.now(timezone.utc),
        source=DataSource.OPEN_METEO,
        tags=["temperature", "europe", "extreme"],
        extra_metadata={"location": "Spain", "duration_hours": 48}
    )
    print("✅ Signal model test passed!")
    print(signal.model_dump())