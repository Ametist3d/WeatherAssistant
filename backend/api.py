from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel

from backend.weather import get_weather
from backend.llm import get_recommendation


app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:5173"],
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
