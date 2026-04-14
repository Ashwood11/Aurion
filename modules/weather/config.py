# modules/weather/config.py
from dataclasses import dataclass
from typing import List

@dataclass
class Location:
    name: str
    lat: float
    lon: float
    tags: list[str]

LOCATIONS = [
    Location("New York", 40.7128, -74.0060, ["finance", "east_coast"]),
    Location("London", 51.5074, -0.1278, ["finance", "europe"]),
    Location("Tokyo", 35.6762, 139.6503, ["asia", "tech"]),
    Location("Singapore", 1.3521, 103.8198, ["shipping", "asia"]),
    Location("Rotterdam", 51.9225, 4.4792, ["port", "europe"]),
    Location("Houston", 29.7604, -95.3698, ["energy", "oil"]),
    Location("Chicago", 41.8781, -87.6298, ["agriculture", "corn"]),
    Location("São Paulo", -23.5505, -46.6333, ["agriculture", "soy"]),
    Location("Buenos Aires", -34.6037, -58.3816, ["agriculture", "wheat"]),
    Location("Moscow", 55.7558, 37.6173, ["wheat", "gas"]),
    Location("Shanghai", 31.2304, 121.4737, ["shipping", "manufacturing"]),
    Location("Dubai", 25.2048, 55.2708, ["oil", "shipping"]),
]

def get_all_locations() -> List[Location]:
    return LOCATIONS