# Powershell Script: Demonstrate Horizontal Scaling and Load Balancer Round-Robin Routing
$ErrorActionPreference = "Continue"

Write-Host "==================================================" -ForegroundColor Cyan
Write-Host " Horizontal Scaling & Load Balancer Test          " -ForegroundColor Cyan
Write-Host "==================================================" -ForegroundColor Cyan

# 1. Scale cluster to 5 replicas
Write-Host "`n1. Scaling webserver replicas to 5 instances..." -ForegroundColor Yellow
docker compose up -d --scale webserver=5

Start-Sleep -Seconds 3

Write-Host "`n[Check] Active cluster services:" -ForegroundColor Gray
docker compose ps

# 2. Test Load Balancer Distribution across replicas
Write-Host "`n2. Sending 10 consecutive HTTP requests to Load Balancer (http://localhost:8088)..." -ForegroundColor Yellow
$replicaCounts = @{}

for ($i = 1; $i -le 10; $i++) {
    try {
        $res = Invoke-WebRequest -Uri "http://localhost:8088/api/info" -UseBasicParsing -Headers @{ "Cache-Control" = "no-cache" }
        $headerHost = $res.Headers["X-Served-By"]
        if (-not $headerHost) {
            # Parse container_id field from JSON body
            $json = $res.Content | ConvertFrom-Json -ErrorAction SilentlyContinue
            $headerHost = $json.container_id
        }
        if (-not $headerHost) { $headerHost = "webserver-replica" }

        Write-Host "Request #$i -> Served by Container Replica: [$headerHost]" -ForegroundColor Green
        $replicaCounts[$headerHost] = ([int]$replicaCounts[$headerHost] + 1)
    } catch {
        Write-Host "Request #$i -> Error: $_" -ForegroundColor Red
    }
    Start-Sleep -Milliseconds 150
}

Write-Host "`n[Summary] Load Distribution Breakdown:" -ForegroundColor Cyan
$replicaCounts.GetEnumerator() | ForEach-Object {
    Write-Host "Replica ID: $($_.Key) -> Handled $($_.Value) Requests" -ForegroundColor Gray
}

# 3. Scale back down to 3 replicas
Write-Host "`n3. Scaling back down to 3 replicas..." -ForegroundColor Yellow
docker compose up -d --scale webserver=3

Write-Host "`n==================================================" -ForegroundColor Green
Write-Host " Scaling Demonstration Completed Successfully     " -ForegroundColor Green
Write-Host "==================================================" -ForegroundColor Green
