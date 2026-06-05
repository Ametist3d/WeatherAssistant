$ErrorActionPreference = "Stop"

$ModeFile = ".deployment_mode"

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

if (!(Test-Path $ModeFile)) {
    Write-Host "No .deployment_mode found. Run setup_windows.ps1 first."
    exit 1
}

$Mode = (Get-Content $ModeFile | Select-Object -First 1).Trim()
$AppPort = Get-EnvValue "APP_PORT" "8000"

if ($Mode -eq "docker") {
    Write-Host "Starting Docker app..."
    docker compose up -d
    Write-Host "App started at http://localhost:$AppPort"
    exit 0
}

if ($Mode -eq "manual") {
    Write-Host "Starting no-Docker app..."

    if (!(Test-Path ".venv")) {
        Write-Host ".venv not found. Run setup_windows.ps1 first."
        exit 1
    }

    if (Test-Path "app.pid") {
        $OldPid = Get-Content "app.pid" | Select-Object -First 1

        if (Get-Process -Id $OldPid -ErrorAction SilentlyContinue) {
            Write-Host "App is already running. PID: $OldPid"
            Write-Host "URL: http://localhost:$AppPort"
            exit 0
        }
        else {
            Remove-Item "app.pid" -Force
        }
    }

    $PythonExe = ".\.venv\Scripts\python.exe"

    $Process = Start-Process `
        -FilePath $PythonExe `
        -ArgumentList "-m uvicorn backend.api:app --host 0.0.0.0 --port $AppPort" `
        -RedirectStandardOutput "app.log" `
        -RedirectStandardError "app_error.log" `
        -WindowStyle Hidden `
        -PassThru

    Set-Content -Path "app.pid" -Value $Process.Id

    Write-Host "App started."
    Write-Host "PID: $($Process.Id)"
    Write-Host "URL: http://localhost:$AppPort"
    Write-Host "Logs:"
    Write-Host "  Get-Content app.log -Wait"
    Write-Host "  Get-Content app_error.log -Wait"
    exit 0
}

Write-Host "Unknown deployment mode: $Mode"
exit 1