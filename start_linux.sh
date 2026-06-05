#!/usr/bin/env bash

set -e

MODE_FILE=".deployment_mode"

if [ ! -f "$MODE_FILE" ]; then
  echo "No .deployment_mode found. Run setup_linux.sh first."
  exit 1
fi

MODE=$(cat "$MODE_FILE")

if [ -f ".env" ]; then
  APP_PORT=$(grep "^APP_PORT=" .env | cut -d "=" -f2-)
fi

APP_PORT=${APP_PORT:-8000}

if [ "$MODE" = "docker" ]; then
  echo "Starting Docker app..."
  docker compose up -d
  echo "App started at http://localhost:$APP_PORT"
  exit 0
fi

if [ "$MODE" = "manual" ]; then
  echo "Starting no-Docker app..."

  if [ ! -d ".venv" ]; then
    echo ".venv not found. Run setup_linux.sh first."
    exit 1
  fi

  if [ -f "app.pid" ]; then
    OLD_PID=$(cat app.pid)

    if ps -p "$OLD_PID" >/dev/null 2>&1; then
      echo "App is already running. PID: $OLD_PID"
      echo "URL: http://localhost:$APP_PORT"
      exit 0
    else
      rm app.pid
    fi
  fi

  source .venv/bin/activate

  nohup python -m uvicorn backend.api:app \
    --host 0.0.0.0 \
    --port "$APP_PORT" \
    > app.log 2>&1 &

  echo $! > app.pid

  echo "App started."
  echo "PID: $(cat app.pid)"
  echo "URL: http://localhost:$APP_PORT"
  echo "Logs: tail -f app.log"
  exit 0
fi

echo "Unknown deployment mode: $MODE"
exit 1