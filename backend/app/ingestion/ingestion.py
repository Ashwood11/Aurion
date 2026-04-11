import os
import requests
from datetime import datetime
from sqlalchemy.orm import Session
from core.signals.models import AurionSignal
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("VISUAL_CROSSING_API_KEY")

def fetch_current_weather(location: str = "New York", db: Session = None):
    """Fetch current weather and convert to AurionSignal"""
    
    url = f"https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/{location}?unitGroup=metric&key={API_KEY}&contentType=json"
    
    try:
        response = requests.get(url)
        data = response.json()
        
        current = data['currentConditions']
        
        signal = AurionSignal(
            timestamp=datetime.utcnow(),
            lat=data['latitude'],
            lng=data['longitude'],
            signal_type="temperature_anomaly" if current['temp'] > 25 else "normal_weather",
            strength=(current['temp'] - 15) / 20,  # Simple normalization example
            confidence=0.85,
            summary=f"{current['conditions']} at {current['temp']}°C, feels like {current['feelslike']}°C",
            source_module="weather",
            metadata={
                "temp": current['temp'],
                "humidity": current['humidity'],
                "windspeed": current['windspeed'],
                "conditions": current['conditions']
            },
            tags=["weather", "current"]
        )
        
        if db:
            db.add(signal)
            db.commit()
        
        return signal
        
    except Exception as e:
        print("Error fetching weather:", e)
        return None