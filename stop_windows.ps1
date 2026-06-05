$ErrorActionPreference = "Stop"

$ModeFile = ".deployment_mode"

if (!(Test-Path $ModeFile)) {
    Write-Host "No .deployment_mode found."
    exit 0
}

$Mode = (Get-Content $ModeFile | Select-Object -First 1).Trim()

if ($Mode -eq "docker") {
    Write-Host "Stopping Docker app..."
    docker compose down
    Write-Host "Docker app stopped."
    exit 0
}

if ($Mode -eq "manual") {
    Write-Host "Stopping no-Docker app..."

    if (!(Test-Path "app.pid")) {
        Write-Host "No app.pid found. App may not be running."
        exit 0
    }

    $PidValue = Get-Content "app.pid" | Select-Object -First 1

    $Process = Get-Process -Id $PidValue -ErrorAction SilentlyContinue

    if ($Process) {
        Stop-Process -Id $PidValue -Force
        Remove-Item "app.pid" -Force
        Write-Host "App stopped."
    }
    else {
        Write-Host "Process not running. Removing stale app.pid."
        Remove-Item "app.pid" -Force
    }

    exit 0
}

Write-Host "Unknown deployment mode: $Mode"
exit 1