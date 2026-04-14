# modules/weather/ingestion/fetch_weather.py

import sys
import os
from datetime import datetime, timezone

import requests
from dotenv import load_dotenv
from sqlalchemy.orm import Session

sys.path.insert(
    0,
    os.path.dirname(
        os.path.dirname(
            os.path.dirname(os.path.abspath(__file__))
        )
    )
)

load_dotenv()

from core.signals.models import Signal, SignalType, Severity, DataSource
from core.database.db import get_db, init_db
from core.database.models.weather import WeatherData
from modules.weather.config import get_all_locations


API_KEY = os.getenv("VISUAL_CROSSING_API_KEY")

if not API_KEY:
    raise ValueError("❌ VISUAL_CROSSING_API_KEY not found in .env file")


def fetch_and_save_weather():
    print("🌍 Starting Weather Ingestion using Visual Crossing...\n")

    db = next(get_db())
    all_signals = []

    try:
        locations = get_all_locations()

        for loc in locations:
            signals = fetch_weather_for_location(loc, db)
            all_signals.extend(signals)

        db.commit()

        print(f"\n✅ Successfully processed {len(locations)} locations")
        print(f"   Total signals generated: {len(all_signals)}")

    except Exception as e:
        db.rollback()
        print(f"❌ Critical Error: {e}")

    finally:
        db.close()


def fetch_weather_for_location(loc, db: Session):
    url = (
        "https://weather.visualcrossing.com/"
        f"VisualCrossingWebServices/rest/services/timeline/{loc.lat},{loc.lon}/today"
    )

    params = {
        "unitGroup": "metric",
        "key": API_KEY,
        "contentType": "json",
        "include": "current",
    }

    try:
        resp = requests.get(url, params=params, timeout=20)
        resp.raise_for_status()
        data = resp.json()

        current = data.get("currentConditions", {})

        # Safe extraction
        temp = current.get("temp")
        wind = float(current.get("windspeed") or 0.0)
        precip = float(current.get("precip") or 0.0)

        # Safe printing
        temp_str = f"{temp:6.1f}" if temp is not None else "  N/A "
        wind_str = f"{wind:5.1f}"
        precip_str = f"{precip:5.1f}"

        print(
            f"✅ {loc.name:15} → {temp_str}°C  | Wind: {wind_str}km/h  | Precip: {precip_str}mm"
        )

        # Save structured weather data
        weather_entry = WeatherData(
            location=loc.name,
            timestamp=datetime.now(timezone.utc),
            temperature_2m=temp,
            apparent_temperature=current.get("feelslike"),
            relative_humidity=current.get("humidity"),
            precipitation=precip,
            wind_speed_10m=wind,
            wind_direction_10m=current.get("winddir"),
            cloud_cover=current.get("cloudcover"),
            dew_point=current.get("dew"),
            extra_metadata={
                "tags": getattr(loc, "tags", []),
                "conditions": current.get("conditions"),
                "icon": current.get("icon"),
                "visibility": current.get("visibility"),
                "source": "visual_crossing",
                "raw_station": current.get("station"),
            },
        )
        db.add(weather_entry)

        # Only generate signals if temperature exists
        if temp is None:
            print(f"   ⚠️  {loc.name} - No temperature data, skipping signals")
            return []

        signals = create_signals_from_weather(loc, current)
        return signals

    except requests.exceptions.HTTPError as e:
        status_code = e.response.status_code if e.response is not None else "Unknown"
        print(f"❌ HTTP Error {loc.name}: {status_code}")
        return []

    except requests.exceptions.RequestException as e:
        print(f"❌ Request failed for {loc.name}: {e}")
        return []

    except Exception as e:
        print(f"❌ Failed {loc.name}: {e}")
        return []


def create_signals_from_weather(loc, current):
    signals = []
    now = datetime.now(timezone.utc)

    temp = current.get("temp")
    precip = float(current.get("precip") or 0.0)
    wind = float(current.get("windspeed") or 0.0)

    # Temperature signal
    if temp is not None:
        signals.append(
            Signal(
                module="weather",
                signal_type=SignalType.BASELINE,
                name=f"Temp_{loc.name.replace(' ', '_')}",
                value=temp,
                severity=Severity.MEDIUM,
                timestamp=now,
                source=DataSource.VISUAL_CROSSING
                if hasattr(DataSource, "VISUAL_CROSSING")
                else DataSource.OPEN_METEO,
                tags=["temperature"] + getattr(loc, "tags", []),
                extra_metadata={
                    "location": loc.name,
                    "metric": "temperature",
                },
            )
        )

    # Precipitation anomaly signal
    if precip > 0.1:
        signals.append(
            Signal(
                module="weather",
                signal_type=SignalType.ANOMALY,
                name=f"Precip_{loc.name.replace(' ', '_')}",
                value=precip,
                severity=Severity.HIGH if precip > 5 else Severity.MEDIUM,
                timestamp=now,
                source=DataSource.VISUAL_CROSSING
                if hasattr(DataSource, "VISUAL_CROSSING")
                else DataSource.OPEN_METEO,
                tags=["precipitation"] + getattr(loc, "tags", []),
                extra_metadata={
                    "location": loc.name,
                    "metric": "precipitation",
                },
            )
        )

    # High wind anomaly signal
    if wind > 30:
        signals.append(
            Signal(
                module="weather",
                signal_type=SignalType.ANOMALY,
                name=f"HighWind_{loc.name.replace(' ', '_')}",
                value=wind,
                severity=Severity.HIGH,
                timestamp=now,
                source=DataSource.VISUAL_CROSSING
                if hasattr(DataSource, "VISUAL_CROSSING")
                else DataSource.OPEN_METEO,
                tags=["wind"] + getattr(loc, "tags", []),
                extra_metadata={
                    "location": loc.name,
                    "metric": "wind_speed",
                },
            )
        )

    return signals


if __name__ == "__main__":
    init_db()  # Ensure tables exist
    fetch_and_save_weather()