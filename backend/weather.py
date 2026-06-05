import os
import requests
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("OPENWEATHER_API_KEY")


def get_weather(city: str, date: str) -> dict:
    if not API_KEY:
        raise RuntimeError("Missing OPENWEATHER_API_KEY in .env")

    url = "https://api.openweathermap.org/data/2.5/forecast"

    params = {
        "q": city,
        "appid": API_KEY,
        "units": "metric",
    }

    response = requests.get(url, params=params, timeout=10)
    response.raise_for_status()

    data = response.json()

    items_for_date = [
        item for item in data["list"]
        if item["dt_txt"].startswith(date)
    ]

    if not items_for_date:
        raise ValueError("No weather data for this date. Use a date within the next 5 days.")

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

