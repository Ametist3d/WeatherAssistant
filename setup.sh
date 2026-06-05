#!/usr/bin/env bash

set -e

echo ""
echo "Personal Weather Assistant - Docker Setup"
echo "-----------------------------------------"
echo ""

# Check Docker
if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is not installed."
  echo "Install Docker first, then run this script again."
  exit 1
fi

# Check Docker Compose
if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose plugin is not available."
  echo "Install docker-compose-plugin first, then run this script again."
  exit 1
fi

# If .env already exists
if [ -f ".env" ]; then
  echo ".env already exists."
  read -p "Do you want to recreate it? [y/N]: " RECREATE_ENV

  if [[ ! "$RECREATE_ENV" =~ ^[Yy]$ ]]; then
    echo "Keeping existing .env"
  else
    rm .env
  fi
fi

# Create .env if missing
if [ ! -f ".env" ]; then
  echo ""
  echo "API key setup"
  echo "-------------"

  read -p "OpenWeather API key: " OPENWEATHER_API_KEY

  echo ""
  read -s -p "Groq API key: " GROQ_API_KEY
  echo ""

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

  if [ -z "$OPENWEATHER_API_KEY" ]; then
    echo "OpenWeather API key cannot be empty."
    exit 1
  fi

  if [ -z "$GROQ_API_KEY" ]; then
    echo "Groq API key cannot be empty."
    exit 1
  fi

  cat > .env <<EOF
OPENWEATHER_API_KEY=$OPENWEATHER_API_KEY
GROQ_API_KEY=$GROQ_API_KEY
GROQ_MODEL=$GROQ_MODEL
APP_PORT=$APP_PORT
EOF

  chmod 600 .env

  echo ""
  echo ".env created successfully."
fi

echo ""
echo "Building and starting Docker container..."
echo ""

docker compose up -d --build

echo ""
echo "Setup complete."
echo ""
echo "App should be available at:"
echo "http://localhost:${APP_PORT:-8000}"
echo ""
echo "Useful commands:"
echo "  docker compose logs -f"
echo "  docker compose down"
echo "  docker compose up -d --build"
echo ""