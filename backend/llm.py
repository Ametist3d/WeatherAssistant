import os
from groq import Groq
from pathlib import Path
from dotenv import load_dotenv

env_path = Path(__file__).resolve().parents[1] / ".env"
load_dotenv(env_path)

API_KEY = os.getenv("GROQ_API_KEY")
MODEL = os.getenv("GROQ_MODEL", "llama-3.1-8b-instant")


def get_recommendation(weather: dict,  note: str = "") -> str:
    if not API_KEY:
        raise RuntimeError("Missing GROQ_API_KEY in .env")

    client = Groq(api_key=API_KEY)

    prompt = f"""
    You are a personal weather assistant.

    Based on this weather data, give simple recommendations:
    - what to wear
    - what activities are good
    - what to be careful about

    Weather data:
    {weather}

    User note:
    {note if note else "No additional notes."}

    Use the user note to personalize the answer when relevant.
    """

    response = client.chat.completions.create(
        model=MODEL,
        messages=[
            {"role": "user", "content": prompt}
        ],
        temperature=0.5,
    )

    return response.choices[0].message.content
