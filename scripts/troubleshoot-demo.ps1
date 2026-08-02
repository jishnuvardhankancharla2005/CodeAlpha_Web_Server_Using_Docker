# Powershell Script: Simulate & Resolve Common Docker Issues (Port Conflict & Health Monitoring)
$ErrorActionPreference = "Continue"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Docker Troubleshooting & Healthcheck Simulation  " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Scenario 1: Port Conflict Simulation
Write-Host "`n[Scenario 1] Simulating Port Conflict on Port 8088..." -ForegroundColor Yellow
Write-Host "Attempting to launch a second container binding to port 8088 (which is currently bound)..." -ForegroundColor Gray

$conflictOutput = docker run -d --name conflict-test -p 8088:80 nginx:alpine 2>&1

if ($conflictOutput -like "*port is already allocated*" -or $conflictOutput -like "*bind*" -or $conflictOutput -like "*Error response*") {
    Write-Host "`n[DETECTED PORT CONFLICT ERROR]" -ForegroundColor Red
    Write-Host "$conflictOutput" -ForegroundColor Red
    Write-Host "`n[RESOLUTION] Identifying process / container holding port 8088..." -ForegroundColor Green
    docker ps --filter "publish=8088"
    Write-Host "`nResolution options:" -ForegroundColor Cyan
    Write-Host "1. Stop the conflicting container: 'docker stop webserver-app'" -ForegroundColor Gray
    Write-Host "2. Or bind second container to an alternate port: 'docker run -p 8089:80 ...'" -ForegroundColor Gray
} else {
    Write-Host "Clean up test container..." -ForegroundColor Gray
    docker rm -f conflict-test | Out-Null
}

# Scenario 2: Health Monitoring
Write-Host "`n[Scenario 2] Inspecting Container HEALTHCHECK directive status..." -ForegroundColor Yellow
$healthStatus = docker inspect --format='{{json .State.Health}}' webserver-app
Write-Host "Health Inspection Data:" -ForegroundColor Gray
Write-Host $healthStatus

Write-Host "`n==================================================" -ForegroundColor Green
Write-Host " Troubleshooting Demonstration Finished          " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
