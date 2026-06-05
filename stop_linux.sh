#!/usr/bin/env bash

set -e

MODE_FILE=".deployment_mode"

if [ ! -f "$MODE_FILE" ]; then
  echo "No .deployment_mode found."
  exit 0
fi

MODE=$(cat "$MODE_FILE")

if [ "$MODE" = "docker" ]; then
  echo "Stopping Docker app..."
  docker compose down
  echo "Docker app stopped."
  exit 0
fi

if [ "$MODE" = "manual" ]; then
  echo "Stopping no-Docker app..."

  if [ ! -f "app.pid" ]; then
    echo "No app.pid found. App may not be running."
    exit 0
  fi

  PID=$(cat app.pid)

  if ps -p "$PID" >/dev/null 2>&1; then
    kill "$PID"
    rm app.pid
    echo "App stopped."
  else
    echo "Process not running. Removing stale app.pid."
    rm app.pid
  fi

  exit 0
fi

echo "Unknown deployment mode: $MODE"
exit 1