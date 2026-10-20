---
name: voice-ai-infrastructure
description: "Orchestrate, monitor, and auto-heal real-time voice AI infrastructure (LiveKit, Pipecat, SIP)."
version: 1.0.0
author: Hermes Agent
tags: [voice-ai, livekit, pipecat, monitoring, auto-healing, devops, webrtc]
---

# Voice AI Infrastructure Operations

This skill covers the setup, orchestration, and autonomous maintenance of real-time voice AI stacks. It focuses on low-latency communication (WebRTC), telephony integration (SIP), and building resilient "Self-Healing" pipelines.

## Core Components
- **Voice Runtime**: LiveKit Agents, Pipecat (pipeline management), Bolna-ai.
- **Connectivity**: LiveKit SIP, Asterisk, FreeSWITCH, Twilio Media Streams.
- **Monitoring**: Prometheus-style metrics (Port 8001), Log-Scraping (Loki/Custom).
- **Auto-Healing**: Durable execution via Temporal.io, automated container restarts.

## Workflow: Building an Autonomous Voice Stack

### 1. Project Initialization
Structure the project with dedicated directories for the Controller (Watchdog), Dashboard (UI), and Agent Runtime.
```bash
mkdir -p infra/{controller,dashboard,logs}
```

### 2. Implementation of the "Guardian" (Controller)
Implement a background Python script that performs "Deep Scans":
- **Port Checks**: Verify WebSocket accessibility (Port 7880).
- **Log Scraping**: Scan runtime logs for `ERROR`, `WRONG_URL`, or `AUTH_ERROR`.
- **Metrics**: Export gauges via `prometheus_client` for dash-boarding.
- **Auto-Heal**: Trigger `docker-compose restart` or service reloads on critical failure.

### 3. Production-Ready Dashboard
For high-quality monitoring, build a Flask-based UI using Tailwind CSS and Lucide Icons.
- **Widgets**: Create cards for System Health, Gateway Status, and Worker Vitals.
- **Live Stream**: Implement a 3-5 second auto-refresh or WebSocket update.
- **Design**: Use Dark Mode (Slate-950), Glassmorphism, and pulsante status dots.

## Troubleshooting & Pitfalls
- **Caching**: Browsers aggressively cache dashboard assets. Use `Cmd+Shift+R` or Incognito mode to bypass.
- **Port Conflict**: Ghost processes often keep ports 8080/8001 open. Use `lsof -t -i :8080 | xargs kill -9` before restarts.
- **Dependency Missing**: Scripts using `flask`, `prometheus_client`, or `requests` require pre-installation in the venv.
- **Backgrounding**: Only use `terminal(background=true)` for long-lived monitoring/UI processes to ensure observability.

## Orbstack (macOS) Docker Socket
User runs Docker exclusively via Orbstack. Always prefix or export:
```bash
DOCKER_HOST=unix://$HOME/.orbstack/run/docker.sock
```
before any `docker` or `docker compose` command. Default paths (`/var/run/docker.sock`, `~/.docker/run/docker.sock`) will fail with "no such file or directory". Add this as the first step in any infra startup sequence on this machine.

## External Telephony Provider Configuration (Telnyx, Twilio, etc.)
When guiding configuration of external providers:
- Always give **exact menu navigation paths** first (e.g. "Programmable Voice → SIP Connections → [Connection] → Webhooks tab").
- Lead with the precise location in the UI before any explanation.
- Keep instructions extremely concise — user prefers direct location + what to set, nothing else.
- For webhook setup, prioritize per-Connection webhooks over global settings when possible.

## Dograh + Asterisk ARI (split hosts)

Typical layout: **Dograh app host** ≠ **PBX host** (e.g. DograhEUV2 vs GonoPBX).

| Symptom | Meaning |
|---------|---------|
| Browser agent test works | Workflow + models OK |
| ARI call rings phone | SIP/ARI control OK |
| No audio | Media Asterisk ↔ Dograh broken |

ARI media uses `chan_websocket` externalMedia → `ws(s)://…/api/v1/telephony/ws/ari` (ulaw). Not the same path as browser WebRTC/TURN.

### Hard pitfalls

1. **Never `apt install asterisk`** when phones already ring. Host `asterisk: command not found` ≠ no PBX (often Docker/FreePBX). Apt creates a conflicting second stack. Apt prompt → always **`n`**.
2. Do not run Asterisk module checks on the Dograh app host.
3. AGENTS.md / voice-prompt topics do not fix silence — use ARI docs + live logs.

### Discovery then modules

PBX host: `docker ps` / `ps` / systemd for asterisk|freepbx|vicidial → then  
`docker exec -it <c> asterisk -rx "module show like chan_websocket"` (and `res_websocket_client`, `res_ari`). Both WS modules **Running**.

Dograh host: API logs during test call; match telephony fields to `ari.conf` / `websocket_client.conf` / ulaw.

Full checklist: `references/dograh-ari-ring-no-audio.md`. Docs: https://docs.dograh.com/integrations/telephony/asterisk-ari

Self-host public UI (Activi): **https://voiceeu.activi.io** — ARI media WS must target that deploy, not Cloud. Dual MCP: skill **`dograh-dual-instance`**. Env paste mask: `sed 's/=.*/=***/'` (mask everything after `=`), never `s/=./` (only one character). Do not call ARI silence a “WebRTC codec” problem first.

## Explain-commands preference

When user asks what diagnostic blocks do: short DE table command → effect → why; mark read-only. Prefer plain DE for dual-MCP (“zwei Fernbedienungen”) over YAML-only walls.

## References & Templates
- `references/livekit-api-versions.md`: Handling breaking changes in LiveKit Python SDK.
- `references/dograh-ari-ring-no-audio.md`: Browser OK + ARI rings + silence — host split, no apt-asterisk, module/WS/ulaw.
- `templates/ui_dashboard.py`: A ready-to-use Flask + Tailwind dashboard.
- `templates/minimal_room_manager.py`: Minimal example for managing rooms via Python API.
- `scripts/health_monitor.py`: A template for a multi-threaded deep-scan controller.
