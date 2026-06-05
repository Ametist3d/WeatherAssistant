from pathlib import Path

from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel

from backend.weather import get_weather, search_cities
from backend.llm import get_recommendation


app = FastAPI()


app.add_middleware(
    CORSMiddleware,
    allow_origins=[
        "http://localhost:5173",
        "http://127.0.0.1:5173",
        "http://localhost:8000",
        "http://127.0.0.1:8000",
    ],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class WeatherRequest(BaseModel):
    city: str
    date: str
    note: str = ""


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/api/cities")
def cities(q: str):
    if len(q.strip()) < 2:
        return []

    return search_cities(q)


@app.post("/api/recommendation")
def recommendation(request: WeatherRequest):
    try:
        weather = get_weather(request.city, request.date)
        recommendation_text = get_recommendation(weather, request.note)

        return {
            "weather": weather,
            "recommendation": recommendation_text,
        }

    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

    except RuntimeError as e:
        raise HTTPException(status_code=502, detail=str(e))

    except Exception:
        raise HTTPException(
            status_code=500,
            detail="Unexpected server error. Please try again later."
        )

static_dir = Path(__file__).parent / "static"

if static_dir.exists():
    app.mount("/", StaticFiles(directory=static_dir, html=True), name="static")