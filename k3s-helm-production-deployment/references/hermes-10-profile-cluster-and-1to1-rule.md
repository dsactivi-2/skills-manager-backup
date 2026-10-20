# Hermes 10-Profile Cluster + 1:1 Deployment Rule (Session 2026-06-16)

## Exact 10 Profiles (from user memory)
1. dev-op
2. agent-builder
3. n8n-workflow
4. dograh
5. ki-voice-agent
6. prompting-salesteleagent
7. xai-voice-dograh
8. research
9. mlops
10. creative

Coordinated via `cluster-sync.sh` and `HERMES_CLUSTER_MONITOR.txt` on desktop. Central dashboard must monitor all 10 (status, kanban, voice, auto-healing).

## Strict 1:1 Rule (user-defined, must be followed)
- Deploy **exactly** as currently in the hermes-agent repo (docker-compose.yml with gateway + dashboard, s6-overlay, web/ React dashboard).
- **Only allowed changes**:
  - Config files (`config.yaml` per profile, docker-compose extensions in same style, env files).
  - Extensions of **existing patterns** (additional `hermes-gateway-xxx` services, more s6-rc.d services, additional volume mounts for profiles, `hermes gateway start --profile=xxx` commands).
- **Forbidden**: Core code changes, new architecture, new orchestration design, anything not already present in the repo.

## Dashboard Deployment (official web/)
```bash
cd hermes-agent/web
npm run build
```
Then mount built assets into dashboard service or serve via nginx.

## Auto-Healing on plain VPS (s6 fallback)
- Official hermes-agent image already uses s6-overlay as PID 1.
- Use `restart: unless-stopped` in docker-compose.
- Extend `docker/s6-rc.d/` with watchdog services for deep scans (same style as existing services).
- Dashboard can trigger restarts on detected failures.
- Limited vs k3s (no cluster rescheduling, no Longhorn volume healing).

## User Preferences Embedded
- Language: German only.
- Style: Direct, concise, no pleasantries, no explanatory text.
- Behavior: Tool-first — execute commands immediately with real tool calls. Never describe plans without acting. "mach" = immediate execution.
- Dashboard: Production-Ready (Tailwind, dark theme, glassmorphism, live widgets, historical event log, Auto-Healing, Deep Scans).

This reference must be consulted before any deployment involving the Hermes cluster or VPS setup.
