# Powershell Script: Demonstrate Container Lifecycle Management & Volume Persistence
$ErrorActionPreference = "Continue"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Container Lifecycle Management Demonstration     " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# Select active container (load balancer or replica)
$containerName = (docker ps --filter "name=webserver-loadbalancer" --format "{{.Names}}")
if (-not $containerName) {
    $containerName = (docker ps --filter "name=webserver-1" --format "{{.Names}}")
}
if (-not $containerName) {
    $containerName = "webserver-app"
}

Write-Host "Targeting container: [$containerName]" -ForegroundColor Yellow

# 1. Inspect Status
Write-Host "`n1. Inspecting container metadata & status..." -ForegroundColor Yellow
docker inspect --format='ID: {{.Id}} | Status: {{.State.Status}} | Health: {{if .State.Health}}{{.State.Health.Status}}{{else}}N/A{{end}}' $containerName

# 2. View Logs
Write-Host "`n2. Retrieving recent container logs..." -ForegroundColor Yellow
docker logs --tail 10 $containerName

# 3. Stop Container
Write-Host "`n3. Stopping container '$containerName'..." -ForegroundColor Yellow
docker stop $containerName
Write-Host "[Check] Container status after stop:" -ForegroundColor Gray
docker ps -a -f name=$containerName

# 4. Start Container back up
Write-Host "`n4. Starting container '$containerName' back up..." -ForegroundColor Yellow
docker start $containerName
Write-Host "[Check] Container status after start:" -ForegroundColor Gray
docker ps -f name=$containerName

# 5. Restart Container
Write-Host "`n5. Issuing restart command..." -ForegroundColor Yellow
docker restart $containerName

# 6. Verify HTTP Response
Write-Host "`n6. Testing Web Server response..." -ForegroundColor Yellow
try {
    $res = Invoke-WebRequest -Uri "http://localhost:8088" -UseBasicParsing
    Write-Host "[HTTP OK] Response StatusCode: $($res.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "[HTTP Error] Failed to reach server: $_" -ForegroundColor Red
}

Write-Host "`n==================================================" -ForegroundColor Green
Write-Host " Lifecycle Demonstration Completed Successfully    " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
