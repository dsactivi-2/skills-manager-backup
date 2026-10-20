from flask import Flask, render_template_string
import json
import os
import requests
import yaml

app = Flask(__name__)
# Load paths from environment or config
HISTORY_FILE = os.environ.get("HISTORY_FILE", "logs/history.json")
METRICS_URL = os.environ.get("METRICS_URL", "http://localhost:8001")

HTML_TEMPLATE = """
<!DOCTYPE html>
<html lang="en" class="dark">
<head>
    <meta charset="UTF-8">
    <title>Voice AI Ops</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <script src="https://unpkg.com/lucide@latest"></script>
    <meta http-equiv="refresh" content="5">
    <style>
        body { background-color: #020617; font-family: 'Inter', sans-serif; }
        .glass { background: rgba(15, 23, 42, 0.8); backdrop-filter: blur(12px); border: 1px solid rgba(255,255,255,0.08); }
    </style>
</head>
<body class="text-slate-300 p-8">
    <div class="max-w-7xl mx-auto">
        <h1 class="text-3xl font-bold mb-8">Infrastructure <span class="text-blue-500 text-sm">CONTROL PLANE</span></h1>
        
        <!-- Metrics Grid -->
        <div class="grid grid-cols-1 md:grid-cols-3 gap-6 mb-8">
             <div class="glass p-6 rounded-3xl">
                <div class="text-xs text-slate-500 uppercase mb-2">System Health</div>
                <div class="text-3xl font-bold {{ 'text-emerald-400' if metrics.get('livekit_infra_health') == '1.0' else 'text-rose-500' }}">
                    {{ 'HEALTHY' if metrics.get('livekit_infra_health') == '1.0' else 'DEGRADED' }}
                </div>
            </div>
            <!-- Add more metrics cards as needed -->
        </div>

        <!-- History -->
        <div class="glass rounded-3xl overflow-hidden h-[500px] flex flex-col">
            <div class="p-4 border-b border-slate-800 bg-slate-900/30">LOGS</div>
            <div class="p-4 overflow-y-auto font-mono text-sm space-y-2">
                {% for entry in history[::-1] %}
                <div class="flex gap-4">
                    <span class="text-slate-600">{{ entry.timestamp }}</span>
                    <span class="text-slate-200">{{ entry.message }}</span>
                </div>
                {% endfor %}
            </div>
        </div>
    </div>
    <script>lucide.createIcons();</script>
</body>
</html>
"""

def get_metrics():
    # Fetch from Prometheus gateway
    return {}

@app.route('/')
def index():
    # Logic to load history and metrics
    return render_template_string(HTML_TEMPLATE, history=[], metrics={})

if __name__ == "__main__":
    app.run(port=8080)
