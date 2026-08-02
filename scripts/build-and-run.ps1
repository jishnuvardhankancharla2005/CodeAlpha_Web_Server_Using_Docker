# Powershell Script: Build and Run Single Container Setup
$ErrorActionPreference = "Stop"

Write-Host "==========================================" -ForegroundColor Cyan
Write-Host " Building Docker Web Server Image...     " -ForegroundColor Cyan
Write-Host "==========================================" -ForegroundColor Cyan

# Stop & remove existing webserver-app container if present
$existing = docker ps -a -q -f name=webserver-app
if ($existing) {
    Write-Host "[Clean] Removing old container 'webserver-app'..." -ForegroundColor Yellow
    docker rm -f webserver-app | Out-Null
}

# Build image
docker build -t codealpha-webserver:v1.0 .

Write-Host "`n[Run] Launching container 'webserver-app' on port 8088..." -ForegroundColor Green
$htmlPath = Join-Path (Get-Location) "html"

docker run -d `
    --name webserver-app `
    -p 8088:80 `
    -v "${htmlPath}:/usr/share/nginx/html" `
    codealpha-webserver:v1.0

Write-Host "`n[Status] Waiting 5 seconds for healthcheck initialization..." -ForegroundColor Gray
Start-Sleep -Seconds 5

# Check status
docker ps -f name=webserver-app

Write-Host "`n==========================================" -ForegroundColor Green
Write-Host " Web Server Ready: http://localhost:8088   " -ForegroundColor Green
Write-Host "==========================================" -ForegroundColor Green
