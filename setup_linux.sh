#!/usr/bin/env bash

set -e

MODE_FILE=".deployment_mode"

echo ""
echo "Personal Weather Assistant - Linux Setup"
echo "----------------------------------------"
echo ""

ask_env() {
  if [ -f ".env" ]; then
    echo ".env already exists."
    read -p "Recreate .env and enter API keys again? [y/N]: " RECREATE_ENV

    if [[ ! "$RECREATE_ENV" =~ ^[Yy]$ ]]; then
      echo "Keeping existing .env"
      return
    fi

    rm .env
  fi

  echo ""
  echo "API key setup"
  echo "-------------"

  read -p "OpenWeather API key: " OPENWEATHER_API_KEY

  echo ""
  read -s -p "Groq API key: " GROQ_API_KEY
  echo ""

  if [ -z "$OPENWEATHER_API_KEY" ]; then
    echo "OpenWeather API key cannot be empty."
    exit 1
  fi

  if [ -z "$GROQ_API_KEY" ]; then
    echo "Groq API key cannot be empty."
    exit 1
  fi

  echo ""
  echo "Choose Groq model:"
  echo "1) llama-3.1-8b-instant      - fast/default"
  echo "2) llama-3.3-70b-versatile   - better quality"
  echo ""

  read -p "Model choice [1]: " MODEL_CHOICE

  case "$MODEL_CHOICE" in
    2)
      GROQ_MODEL="llama-3.3-70b-versatile"
      ;;
    *)
      GROQ_MODEL="llama-3.1-8b-instant"
      ;;
  esac

  read -p "App port [8000]: " APP_PORT
  APP_PORT=${APP_PORT:-8000}

  echo ""
  echo "Frontend API mode:"
  echo "1) Same app URL / same container [default]"
  echo "2) Custom backend API URL"
  echo ""

  read -p "Choose mode [1]: " API_MODE

  case "$API_MODE" in
    2)
      read -p "Backend API URL, example http://123.123.123.123:8000: " VITE_API_URL
      ;;
    *)
      VITE_API_URL=""
      ;;
  esac

  cat > .env <<EOF
OPENWEATHER_API_KEY=$OPENWEATHER_API_KEY
GROQ_API_KEY=$GROQ_API_KEY
GROQ_MODEL=$GROQ_MODEL
APP_PORT=$APP_PORT
VITE_API_URL=$VITE_API_URL
EOF

  chmod 600 .env

  echo ""
  echo ".env created."
}

install_no_docker() {
  echo ""
  echo "Running no-Docker setup..."
  echo ""

  if ! command -v python3 >/dev/null 2>&1; then
    echo "python3 is not installed."
    exit 1
  fi

  if ! command -v npm >/dev/null 2>&1; then
    echo "npm is not installed."
    exit 1
  fi

  python3 -m venv .venv

  source .venv/bin/activate

  python -m pip install --upgrade pip
  pip install -r requirements.txt

  VITE_API_URL_VALUE=$(grep "^VITE_API_URL=" .env | cut -d "=" -f2-)

  cd frontend
  npm install
  VITE_API_URL="$VITE_API_URL_VALUE" npm run build
  cd ..

  rm -rf backend/static
  mkdir -p backend/static
  cp -r frontend/dist/* backend/static/

  echo "manual" > "$MODE_FILE"

  echo ""
  echo "No-Docker setup complete."
}

install_docker() {
  echo ""
  echo "Running Docker setup..."
  echo ""

  if ! command -v docker >/dev/null 2>&1; then
    echo "Docker is not installed."
    echo "Install Docker first, then run this script again."
    exit 1
  fi

  if ! docker compose version >/dev/null 2>&1; then
    echo "Docker Compose plugin is not available."
    echo "Install docker-compose-plugin first, then run this script again."
    exit 1
  fi

  echo "docker" > "$MODE_FILE"

  docker compose up -d --build

  echo ""
  echo "Docker setup complete."
}

echo "Choose setup mode:"
echo "1) Docker deployment [recommended]"
echo "2) No-Docker setup with Python .venv"
echo ""

read -p "Setup mode [1]: " SETUP_MODE

ask_env

case "$SETUP_MODE" in
  2)
    install_no_docker
    bash start_linux.sh
    ;;
  *)
    install_docker
    ;;
esac

APP_PORT=$(grep "^APP_PORT=" .env | cut -d "=" -f2-)
APP_PORT=${APP_PORT:-8000}

echo ""
echo "Setup complete."
echo "App URL:"
echo "http://localhost:$APP_PORT"
echo ""
echo "Start:"
echo "  bash start_linux.sh"
echo ""
echo "Stop:"
echo "  bash stop_linux.sh"
echo ""
echo "Logs:"
echo "  Docker:    docker compose logs -f"
echo "  No-Docker: tail -f app.log"
echo ""