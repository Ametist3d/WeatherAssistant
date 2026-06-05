from pathlib import Path

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

from backend.weather import get_weather
from backend.llm import get_recommendation


app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
    ],
    allow_methods=["*"],
    allow_headers=["*"],
)


class WeatherRequest(BaseModel):
    city: str
    date: str


@app.get("/health")
def health():
    return {"status": "ok"}


@app.post("/api/recommendation")
def recommendation(request: WeatherRequest):
    weather = get_weather(request.city, request.date)
    recommendation_text = get_recommendation(weather)

    return {
        "weather": weather,
        "recommendation": recommendation_text,
    }


static_dir = Path(__file__).parent / "static"

if static_dir.exists():
    app.mount("/", StaticFiles(directory=static_dir, html=True), name="static")