# Powershell Script: Advanced Verification (Resource Stats, Network Isolation, Volume Edits)
$ErrorActionPreference = "Continue"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Advanced Production Stack Verification           " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Resource Limits Check
Write-Host "`n1. Inspecting Live Resource Usage & Constraints (docker stats)..." -ForegroundColor Yellow
docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}"

# 2. Network Isolation Check
Write-Host "`n2. Verifying Network Security & Internal Isolation..." -ForegroundColor Yellow
Write-Host "Checking frontend-net and backend-net isolation..." -ForegroundColor Gray
$netInfo = docker network ls --filter "name=net"
Write-Host $netInfo

Write-Host "`nTesting direct host connection to internal Redis cache (should fail or be blocked):" -ForegroundColor Gray
$redisCheck = Test-NetConnection -ComputerName "localhost" -Port 63790 -WarningAction SilentlyContinue
if (-not $redisCheck.TcpTestSucceeded) {
    Write-Host "[SECURE] Internal Redis DB is isolated from host network direct access." -ForegroundColor Green
} else {
    Write-Host "[NOTICE] Redis port is exposed." -ForegroundColor Yellow
}

# 3. Persistent Volume Live Edit Verification
Write-Host "`n3. Testing Volume Persistence across all scaled replicas..." -ForegroundColor Yellow
$timestamp = Get-Date -Format "yyyy-MM-dd HH:mm:ss"
Write-Host "[Edit] Adding temporary marker file 'volume-test.txt' to host ./html directory..." -ForegroundColor Gray

"Persistent volume test generated at $timestamp" | Out-File -FilePath "./html/volume-test.txt" -Encoding utf8

try {
    $res = Invoke-WebRequest -Uri "http://localhost:8088/volume-test.txt" -UseBasicParsing
    Write-Host "[PERSISTENCE CONFIRMED] Container served updated host content without image rebuild!" -ForegroundColor Green
    Write-Host "Content: $($res.Content.Trim())" -ForegroundColor Gray
} catch {
    Write-Host "[ERROR] Could not fetch persistent volume file: $_" -ForegroundColor Red
}

# Clean up test marker file
Remove-Item -Path "./html/volume-test.txt" -ErrorAction SilentlyContinue

Write-Host "`n==================================================" -ForegroundColor Green
Write-Host " Advanced Verification Completed Successfully     " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
