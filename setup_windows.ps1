$ErrorActionPreference = "Stop"

$ModeFile = ".deployment_mode"

Write-Host ""
Write-Host "Personal Weather Assistant - Windows Setup"
Write-Host "------------------------------------------"
Write-Host ""

function Convert-SecureStringToPlainText {
    param (
        [System.Security.SecureString]$SecureString
    )

    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($SecureString)

    try {
        return [System.Runtime.InteropServices.Marshal]::PtrToStringBSTR($BSTR)
    }
    finally {
        [System.Runtime.InteropServices.Marshal]::ZeroFreeBSTR($BSTR)
    }
}

function Ask-Env {
    if (Test-Path ".env") {
        Write-Host ".env already exists."
        $RecreateEnv = Read-Host "Recreate .env and enter API keys again? [y/N]"

        if ($RecreateEnv -notmatch "^[Yy]$") {
            Write-Host "Keeping existing .env"
            return
        }

        Remove-Item ".env" -Force
    }

    Write-Host ""
    Write-Host "API key setup"
    Write-Host "-------------"

    $OpenWeatherApiKey = Read-Host "OpenWeather API key"

    $GroqSecure = Read-Host "Groq API key" -AsSecureString
    $GroqApiKey = Convert-SecureStringToPlainText $GroqSecure

    if ([string]::IsNullOrWhiteSpace($OpenWeatherApiKey)) {
        Write-Host "OpenWeather API key cannot be empty."
        exit 1
    }

    if ([string]::IsNullOrWhiteSpace($GroqApiKey)) {
        Write-Host "Groq API key cannot be empty."
        exit 1
    }

    Write-Host ""
    Write-Host "Choose Groq model:"
    Write-Host "1) llama-3.1-8b-instant      - fast/default"
    Write-Host "2) llama-3.3-70b-versatile   - better quality"
    Write-Host ""

    $ModelChoice = Read-Host "Model choice [1]"

    switch ($ModelChoice) {
        "2" { $GroqModel = "llama-3.3-70b-versatile" }
        default { $GroqModel = "llama-3.1-8b-instant" }
    }

    $AppPort = Read-Host "App port [8000]"
    if ([string]::IsNullOrWhiteSpace($AppPort)) {
        $AppPort = "8000"
    }

    Write-Host ""
    Write-Host "Frontend API mode:"
    Write-Host "1) Same app URL / same container [default]"
    Write-Host "2) Custom backend API URL"
    Write-Host ""

    $ApiMode = Read-Host "Choose mode [1]"

    switch ($ApiMode) {
        "2" {
            $ViteApiUrl = Read-Host "Backend API URL, example http://123.123.123.123:8000"
        }
        default {
            $ViteApiUrl = ""
        }
    }

    $EnvContent = @"
OPENWEATHER_API_KEY=$OpenWeatherApiKey
GROQ_API_KEY=$GroqApiKey
GROQ_MODEL=$GroqModel
APP_PORT=$AppPort
VITE_API_URL=$ViteApiUrl
"@

    Set-Content -Path ".env" -Value $EnvContent -Encoding UTF8

    Write-Host ""
    Write-Host ".env created."
}

function Get-EnvValue {
    param (
        [string]$Key,
        [string]$DefaultValue = ""
    )

    if (!(Test-Path ".env")) {
        return $DefaultValue
    }

    $Line = Get-Content ".env" | Where-Object { $_ -like "$Key=*" } | Select-Object -First 1

    if (!$Line) {
        return $DefaultValue
    }

    return $Line.Substring($Key.Length + 1)
}

function Install-NoDocker {
    Write-Host ""
    Write-Host "Running no-Docker setup..."
    Write-Host ""

    if (!(Get-Command python -ErrorAction SilentlyContinue)) {
        Write-Host "Python is not installed or not available in PATH."
        exit 1
    }

    if (!(Get-Command npm -ErrorAction SilentlyContinue)) {
        Write-Host "npm is not installed or not available in PATH."
        exit 1
    }

    python -m venv .venv

    & ".\.venv\Scripts\python.exe" -m pip install --upgrade pip
    & ".\.venv\Scripts\pip.exe" install -r requirements.txt

    $ViteApiUrl = Get-EnvValue "VITE_API_URL" ""

    Push-Location "frontend"
    npm install
    $env:VITE_API_URL = $ViteApiUrl
    npm run build
    Remove-Item Env:\VITE_API_URL -ErrorAction SilentlyContinue
    Pop-Location

    if (Test-Path "backend\static") {
        Remove-Item "backend\static" -Recurse -Force
    }

    New-Item -ItemType Directory -Force "backend\static" | Out-Null
    Copy-Item "frontend\dist\*" "backend\static\" -Recurse -Force

    Set-Content -Path $ModeFile -Value "manual"

    Write-Host ""
    Write-Host "No-Docker setup complete."
}

function Install-Docker {
    Write-Host ""
    Write-Host "Running Docker setup..."
    Write-Host ""

    if (!(Get-Command docker -ErrorAction SilentlyContinue)) {
        Write-Host "Docker is not installed or not available in PATH."
        Write-Host "Install Docker Desktop first, then run this script again."
        exit 1
    }

    docker compose version | Out-Null

    Set-Content -Path $ModeFile -Value "docker"

    docker compose up -d --build

    Write-Host ""
    Write-Host "Docker setup complete."
}

Write-Host "Choose setup mode:"
Write-Host "1) Docker deployment [recommended]"
Write-Host "2) No-Docker setup with Python .venv"
Write-Host ""

$SetupMode = Read-Host "Setup mode [1]"

Ask-Env

switch ($SetupMode) {
    "2" {
        Install-NoDocker
        powershell -ExecutionPolicy Bypass -File ".\start_windows.ps1"
    }
    default {
        Install-Docker
    }
}

$AppPort = Get-EnvValue "APP_PORT" "8000"

Write-Host ""
Write-Host "Setup complete."
Write-Host "App URL:"
Write-Host "http://localhost:$AppPort"
Write-Host ""
Write-Host "Start:"
Write-Host "  powershell -ExecutionPolicy Bypass -File .\start_windows.ps1"
Write-Host ""
Write-Host "Stop:"
Write-Host "  powershell -ExecutionPolicy Bypass -File .\stop_windows.ps1"
Write-Host ""
Write-Host "Logs:"
Write-Host "  Docker:    docker compose logs -f"
Write-Host "  No-Docker: Get-Content app.log -Wait"
Write-Host ""