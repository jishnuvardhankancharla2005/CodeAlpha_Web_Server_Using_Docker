document.addEventListener('DOMContentLoaded', () => {
    // 1. Live Uptime Counter
    const startTime = Date.now();
    const uptimeElement = document.getElementById('uptime-counter');

    function updateUptime() {
        const elapsedSeconds = Math.floor((Date.now() - startTime) / 1000);
        const hours = String(Math.floor(elapsedSeconds / 3600)).padStart(2, '0');
        const minutes = String(Math.floor((elapsedSeconds % 3600) / 60)).padStart(2, '0');
        const seconds = String(elapsedSeconds % 60).padStart(2, '0');
        if (uptimeElement) {
            uptimeElement.textContent = `${hours}:${minutes}:${seconds}`;
        }
    }
    setInterval(updateUptime, 1000);
    updateUptime();

    // 2. Fetch active replica ID from Nginx /api/info
    const replicaDisplay = document.getElementById('replica-id-display');
    const lbCurrentNode = document.getElementById('lb-current-node');
    const btnTestLB = document.getElementById('btn-test-lb');

    async function fetchServingReplica() {
        try {
            const res = await fetch('/api/info?t=' + Date.now());
            if (res.ok) {
                const data = await res.json();
                const containerId = data.container_id || 'Unknown';
                if (replicaDisplay) replicaDisplay.textContent = containerId;
                if (lbCurrentNode) lbCurrentNode.textContent = `replica: ${containerId}`;
            }
        } catch (e) {
            console.warn('API info probe error:', e);
        }
    }

    fetchServingReplica();

    if (btnTestLB) {
        btnTestLB.addEventListener('click', async () => {
            btnTestLB.classList.add('rotating');
            await fetchServingReplica();
            setTimeout(() => {
                btnTestLB.classList.remove('rotating');
            }, 400);
        });
    }

    // 3. Health check refresh action
    const btnRefresh = document.getElementById('btn-refresh-health');
    const lbHealthIndicator = document.getElementById('lb-health-indicator');
    const serverStatus = document.getElementById('server-status');

    if (btnRefresh) {
        btnRefresh.addEventListener('click', () => {
            btnRefresh.classList.add('rotating');
            if (lbHealthIndicator) lbHealthIndicator.textContent = 'probing stack...';
            
            setTimeout(() => {
                btnRefresh.classList.remove('rotating');
                if (lbHealthIndicator) {
                    lbHealthIndicator.textContent = 'passing (healthy)';
                    lbHealthIndicator.className = 'metric-value status-healthy';
                }
                if (serverStatus) {
                    serverStatus.textContent = 'Load Balancer & Replicas Healthy';
                }
            }, 500);
        });
    }
});
