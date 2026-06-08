import os
import requests
from pathlib import Path
from dotenv import load_dotenv

env_path = Path(__file__).resolve().parents[1] / ".env"
load_dotenv(env_path)

API_KEY = os.getenv("OPENWEATHER_API_KEY")


def get_weather(city: str, date: str) -> dict:
    '''Fetch weather data for a city and date from OpenWeather API.'''

    if not API_KEY:
        raise RuntimeError("Missing OPENWEATHER_API_KEY in .env")

    url = "https://api.openweathermap.org/data/2.5/forecast"

    params = {
        "q": city,
        "appid": API_KEY,
        "units": "metric",
    }

    response = requests.get(url, params=params, timeout=10)

    if response.status_code == 404:
        raise ValueError(f"No weather info available for '{city}'.")

    if response.status_code == 401:
        raise RuntimeError("OpenWeather API key is invalid or missing.")

    if response.status_code != 200:
        raise RuntimeError(f"OpenWeather API error: {response.status_code}")


    data = response.json()

    # Filter items for the specified date (YYYY-MM-DD)
    items_for_date = [
        item for item in data["list"]
        if item["dt_txt"].startswith(date)
    ]

    if not items_for_date:
        raise ValueError("No weather data for this date. Use a date within the next 5 days.")

    # Extract temperatures and descriptions for the date
    temps = [item["main"]["temp"] for item in items_for_date]
    descriptions = [
        item["weather"][0]["description"]
        for item in items_for_date
    ]

    return {
        "city": data["city"]["name"],
        "date": date,
        "min_temp": min(temps),
        "max_temp": max(temps),
        "weather": descriptions,
    }

def search_cities(query: str, limit: int = 5) -> list[dict]:
    '''
    Search for cities matching the query using OpenWeather Geocoding API.
    Returns a list of city info dicts with name, country, state, lat, lon, and label.
    '''
    
    if not API_KEY:
        raise RuntimeError("Missing OPENWEATHER_API_KEY in .env")

    url = "https://api.openweathermap.org/geo/1.0/direct"

    params = {
        "q": query,
        "limit": limit,
        "appid": API_KEY,
    }

    response = requests.get(url, params=params, timeout=10)
    response.raise_for_status()

    data = response.json()

    # Transform API response into a list of city info dicts
    return [
        {
            "name": item.get("name"),
            "country": item.get("country"),
            "state": item.get("state"),
            "lat": item.get("lat"),
            "lon": item.get("lon"),
            "label": ", ".join(
                part for part in [
                    item.get("name"),
                    item.get("state"),
                    item.get("country"),
                ]
                if part
            ),
        }
        for item in data
    ]

