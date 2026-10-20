import time
import subprocess
import os
import requests
import json
import socket
from prometheus_client import start_http_server, Gauge

# Metrics Configuration
HEALTH_STATUS = Gauge('livekit_infra_health', 'Health status of LiveKit infra (1=ok, 0=error)')
WEBSOCKET_CONN = Gauge('livekit_ws_reachable', 'Websocket accessibility (Port 7880)')
SIP_STATUS = Gauge('livekit_sip_active', 'SIP Port 5060 accessibility')

def check_port(host, port):
    try:
        with socket.create_connection((host, port), timeout=2):
            return True
    except:
        return False

def check_ws_url(url="http://localhost:7880"):
    try:
        r = requests.get(url, timeout=5)
        # LiveKit default 404 response check
        return r.status_code == 404 or "LiveKit" in r.text
    except:
        return False

def monitor_loop(log_path, history_path, port_metrics=8001):
    start_http_server(port_metrics)
    while True:
        is_healthy = True
        
        # 1. Connectivity Check
        if not check_ws_url():
            is_healthy = False
            
        # 2. SIP Check
        if not check_port("localhost", 5060):
             # SIP is often warning-level, not necessarily critical for health
             SIP_STATUS.set(0)
        else:
             SIP_STATUS.set(1)

        # 3. Log Scraping logic here...
        
        HEALTH_STATUS.set(1 if is_healthy else 0)
        WEBSOCKET_CONN.set(1 if is_healthy else 0)
        
        # Auto-Heal Trigger
        if not is_healthy:
            subprocess.run(["docker-compose", "restart"], capture_output=True)
            
        time.sleep(15)

if __name__ == "__main__":
    # Configure absolute paths for your environment
    monitor_loop("/path/to/logs/livekit.log", "/path/to/logs/history.json")
