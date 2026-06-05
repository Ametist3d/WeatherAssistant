# Personal Weather Assistant

A simple full-stack weather assistant that combines OpenWeatherMap forecast data with Groq LLM recommendations.

The app accepts a city, date, and optional custom note, then returns a short weather summary with practical AI recommendations for clothing, activities, and things to watch out for.

## Try it at:

http://46.225.185.220:8000/

## Features

- City and date input
- Optional custom note, for example: `I am going hiking`
- Weather data from OpenWeatherMap
- AI recommendations from Groq
- React/Vite frontend
- FastAPI backend
- Docker and no-Docker setup options
- Linux/WSL/Hetzner and Windows setup scripts

## Short usage

After setup, open the app in your browser:

```txt
http://localhost:8000
```

On a VPS, use:

```txt
http://YOUR_SERVER_IP:8000
```

Enter:

```txt
City: Zagreb
Date: 2026-06-06
Custom note: I am going hiking
```

The date should be within the available OpenWeather forecast window, usually the next few days. If a city is not found, try local spelling or `City,CountryCode`, for example:

```txt
Zagreb,HR
London,GB
Žagre,BA
```

## Prerequisites

### Required API keys

You need your own API keys:

- OpenWeatherMap API key
- Groq API key

The setup scripts will ask for these keys and create a local `.env` file. The `.env` file is not committed to Git.

### Recommended deployment: Docker

For Docker setup, install:

- Git
- Docker
- Docker Compose plugin

On Ubuntu/Hetzner, Docker Compose should work as:

```bash
docker compose version
```

On Windows, install Docker Desktop.

### No-Docker setup

For no-Docker setup, install:

- Git
- Python 3.10+
- Python venv support
- Node.js
- npm

Linux/Ubuntu packages usually needed:

```bash
sudo apt update
sudo apt install -y git python3 python3-venv python3-pip nodejs npm
```

Windows usually needs:

- Python 3.10+ added to PATH
- Node.js LTS installed
- PowerShell

Check:

```powershell
python --version
node -v
npm.cmd -v
```

## Setup on Linux / WSL / Hetzner

Use this for Ubuntu, WSL, or a Hetzner VPS.

```bash
git clone https://github.com/YOUR_USERNAME/WeatherAssistant.git
cd WeatherAssistant
bash setup_linux.sh
```

The script will ask:

```txt
Setup mode:
1) Docker deployment [recommended]
2) No-Docker setup with Python .venv
```

For Hetzner production, choose:

```txt
1) Docker deployment
```

For local testing without Docker, choose:

```txt
2) No-Docker setup with Python .venv
```

The script will also ask:

```txt
Frontend API mode:
1) Same app URL / same container [default]
2) Custom backend API URL
```

For normal Docker or no-Docker setup, choose:

```txt
1) Same app URL / same container
```

Choose option `2` only if the frontend and backend are deployed separately.

### Start and stop on Linux

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
# Docker mode
docker compose logs -f

# No-Docker mode
tail -f app.log
```

## Setup on Windows

Run PowerShell from the project folder.

```powershell
git clone https://github.com/YOUR_USERNAME/WeatherAssistant.git
cd WeatherAssistant
powershell -ExecutionPolicy Bypass -File .\setup_windows.ps1
```

The script will ask:

```txt
Setup mode:
1) Docker deployment [recommended]
2) No-Docker setup with Python .venv
```

For Docker Desktop, choose:

```txt
1) Docker deployment
```

For no-Docker local setup, choose:

```txt
2) No-Docker setup with Python .venv
```

For frontend API mode, choose the default option unless you intentionally host frontend and backend separately:

```txt
1) Same app URL / same container
```

### Start and stop on Windows

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
# Docker mode
docker compose logs -f

# No-Docker mode
Get-Content app.log -Wait
Get-Content app_error.log -Wait
```

## Manual local development

If you want to run frontend and backend separately during development:

### Backend

```bash
python3 -m venv .venv
source .venv/bin/activate
pip install -r requirements.txt
uvicorn backend.api:app --reload --host 0.0.0.0 --port 8000
```

On Windows:

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

The Vite dev server proxies `/api/*` requests to the backend at `http://localhost:8000`.

## Environment variables

The setup scripts generate `.env`:

```env
OPENWEATHER_API_KEY=your_openweather_key
GROQ_API_KEY=your_groq_key
GROQ_MODEL=llama-3.1-8b-instant
APP_PORT=8000
VITE_API_URL=
```

Notes:

- Keep `.env` private.
- Do not commit `.env` to GitHub.
- `VITE_API_URL` should usually be empty for single-app deployment.
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

## Deployment notes

Docker mode is recommended for VPS deployment because it keeps dependencies isolated and starts automatically after reboot with:

```yaml
restart: unless-stopped
```

No-Docker mode uses a local Python `.venv` and runs Uvicorn directly. It is useful for local testing or environments where Docker is not available.

## Troubleshooting

### API returns city/date error

Try a different city spelling or country code:

```txt
Zagreb,HR
London,GB
Žagre,BA
```

### Backend cannot find API keys

Check that `.env` exists in the project root and restart the app:

```bash
bash stop_linux.sh
bash start_linux.sh
```

Windows:

```powershell
powershell -ExecutionPolicy Bypass -File .\stop_windows.ps1
powershell -ExecutionPolicy Bypass -File .\start_windows.ps1
```

### Windows npm PowerShell issue

If `npm` is blocked by PowerShell execution policy, use:

```powershell
npm.cmd -v
```

The Windows setup script should use `npm.cmd` to avoid execution policy issues.

### Docker rebuild after changes

```bash
docker compose down
docker compose up -d --build
```

For a completely clean rebuild:

```bash
docker compose down
docker compose build --no-cache
docker compose up -d
```
