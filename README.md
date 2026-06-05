# Personal Weather Assistant

A small full-stack app that combines OpenWeather forecast data with Groq LLM recommendations.

Input a city, date, and optional note such as `I am going hiking`, then get a short weather summary plus practical suggestions for clothing, activities, and things to watch out for.


## Try it at:

http://46.225.185.220:8000/

## Required API keys

Before setup, create your own free API keys:

- **OpenWeather API key:** [How to get an OpenWeather API key](https://openweathermap.org/appid)
- **Groq API key:** [Groq API quickstart / create API key](https://console.groq.com/docs/quickstart)

The setup scripts will ask for these keys and create a local `.env` file.  
Do **not** commit `.env` to GitHub.

## Quick start

```bash
git clone https://github.com/YOUR_USERNAME/WeatherAssistant.git
cd WeatherAssistant
```

Then choose your platform/setup below.

After setup, open:

```txt
http://localhost:8000
```

Example input:

```txt
City: Zagreb
Date: 2026-06-06
Custom note: I am going hiking
```

If a city is not found, try local spelling or `City,CountryCode`:

```txt
Zagreb,HR
London,GB
Žagre,BA
```

## Setup options

### Option 1: Linux / WSL with Docker

**Prerequisites:**

- Git
- Docker
- Docker Compose plugin

Check:

```bash
git --version
docker --version
docker compose version
```

Run:

```bash
bash setup_linux.sh
```

Choose:

```txt
1) Docker deployment [recommended]
```

For frontend API mode, choose the default:

```txt
1) Same app URL / same container
```

Start:

```bash
bash start_linux.sh
```

Stop:

```bash
bash stop_linux.sh
```

Logs:

```bash
docker compose logs -f
```

### Option 2: Linux / WSL without Docker

**Prerequisites:**

- Git
- Python 3.10+
- `python3-venv`
- Node.js
- npm

Ubuntu install example:

```bash
sudo apt update
sudo apt install -y git python3 python3-venv python3-pip nodejs npm
```

Run:

```bash
bash setup_linux.sh
```

Choose:

```txt
2) No-Docker setup with Python .venv
```

Start:

```bash
bash start_linux.sh
```

Stop:

```bash
bash stop_linux.sh
```

Logs:

```bash
tail -f app.log
```

### Option 3: Windows with Docker

**Prerequisites:**

- Git
- Docker Desktop
- PowerShell

Check:

```powershell
git --version
docker --version
docker compose version
```

Run from the project folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup_windows.ps1
```

Choose:

```txt
1) Docker deployment [recommended]
```

Start:

```powershell
powershell -ExecutionPolicy Bypass -File .\start_windows.ps1
```

Stop:

```powershell
powershell -ExecutionPolicy Bypass -File .\stop_windows.ps1
```

Logs:

```powershell
docker compose logs -f
```

### Option 4: Windows without Docker

**Prerequisites:**

- Git
- Python 3.10+ added to PATH
- Node.js / npm
- PowerShell

Check:

```powershell
python --version
node -v
npm.cmd -v
```

Run from the project folder:

```powershell
powershell -ExecutionPolicy Bypass -File .\setup_windows.ps1
```

Choose:

```txt
2) No-Docker setup with Python .venv
```

Start:

```powershell
powershell -ExecutionPolicy Bypass -File .\start_windows.ps1
```

Stop:

```powershell
powershell -ExecutionPolicy Bypass -File .\stop_windows.ps1
```

Logs:

```powershell
Get-Content app.log -Wait
Get-Content app_error.log -Wait
```

## Manual development mode

Use this if you want separate frontend/backend dev servers.

### Backend

Linux / WSL:

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn backend.api:app --reload --host 0.0.0.0 --port 8000
```

Windows:

```powershell
python -m venv .venv
.\.venv\Scripts\python.exe -m pip install -r requirements.txt
.\.venv\Scripts\python.exe -m uvicorn backend.api:app --reload --host 0.0.0.0 --port 8000
```

### Frontend

```bash
cd frontend
npm install
npm run dev
```

Open:

```txt
http://localhost:5173
```

The Vite dev server proxies `/api/*` requests to `http://localhost:8000`.

## Environment variables

The setup scripts generate `.env` in the project root:

```env
OPENWEATHER_API_KEY=your_openweather_key
GROQ_API_KEY=your_groq_key
GROQ_MODEL=llama-3.1-8b-instant
APP_PORT=8000
VITE_API_URL=
```

Notes:

- Keep `.env` private.
- `VITE_API_URL` should usually stay empty.
- Set `VITE_API_URL` only if frontend and backend are hosted separately.

## Project structure

```txt
WeatherAssistant/
  backend/
    api.py
    weather.py
    llm.py
    static/

  frontend/
    src/
    package.json
    vite.config.ts

  Dockerfile
  docker-compose.yml
  requirements.txt

  setup_linux.sh
  start_linux.sh
  stop_linux.sh

  setup_windows.ps1
  start_windows.ps1
  stop_windows.ps1
```

## Troubleshooting

### Backend cannot find API keys

Check that `.env` exists in the project root. Then restart:

Linux / WSL:

```bash
bash stop_linux.sh
bash start_linux.sh
```

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File .\stop_windows.ps1
powershell -ExecutionPolicy Bypass -File .\start_windows.ps1
```

### City not found

Try local spelling or country code:

```txt
Zagreb,HR
London,GB
Žagre,BA
```

### Windows npm PowerShell issue

Use `npm.cmd` instead of `npm`:

```powershell
npm.cmd -v
```

### Rebuild Docker app

```bash
docker compose down
docker compose up -d --build
```
