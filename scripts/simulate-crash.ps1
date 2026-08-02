# Powershell Script: Simulate Container Crash & Verify Load Balancer Failover & Auto-Healing
$ErrorActionPreference = "Continue"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Container Crash & Auto-Healing Simulation        " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Identify target web replica container
$targetContainer = (docker ps --filter "name=webserver-1" --format "{{.ID}}")
if (-not $targetContainer) {
    $targetContainer = (docker ps --filter "name=webserver" --format "{{.ID}}" | Select-Object -First 1)
}

if (-not $targetContainer) {
    Write-Host "[Error] No webserver container found." -ForegroundColor Red
    exit 1
}

$containerName = (docker inspect --format='{{.Name}}' $targetContainer).TrimStart('/')
Write-Host "`n1. Selected target container for crash simulation: [$containerName ($targetContainer)]" -ForegroundColor Yellow

# 2. Kill PID 1 inside target container
Write-Host "Executing process termination command ('docker exec $targetContainer kill 1')..." -ForegroundColor Red
docker exec $targetContainer kill 1

Start-Sleep -Seconds 1

# 3. Test HTTP Availability during crash (Load Balancer failover check)
Write-Host "`n2. Testing HTTP availability immediately after crash..." -ForegroundColor Yellow
try {
    $res = Invoke-WebRequest -Uri "http://localhost:8088" -UseBasicParsing
    Write-Host "[Failover Success] Load balancer served traffic seamlessly! StatusCode: $($res.StatusCode)" -ForegroundColor Green
} catch {
    Write-Host "[Failover Notice] Request failed: $_" -ForegroundColor Red
}

# 4. Check status & auto-restart recovery
Write-Host "`n3. Waiting 5 seconds for Docker auto-healing restart policy..." -ForegroundColor Yellow
Start-Sleep -Seconds 5

Write-Host "[Status] Container status after auto-recovery:" -ForegroundColor Gray
docker ps --filter "id=$targetContainer"

Write-Host "`n==================================================" -ForegroundColor Green
Write-Host " Crash & Auto-Healing Simulation Complete        " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
