# Production Multi-Agent Dashboard for Voice Cluster on VPS

**Real state from repo (no overstatement):**
- `web/src/pages/ProfilesPage.tsx` is the main dashboard (Profile management, MCP, Skills, Models).
- No native Kanban UI or full "Command Center". Kanban is CLI + backend (`hermes kanban init`, `create`, `watch`, dispatcher in `hermes_cli/gateway.py`).
- Orchestration via `delegate_task(role="orchestrator")` + `cluster-orchestrator` skill + Kanban dependencies (`parents=[t_xxx]`).
- 13 existing profiles discovered by `hermes kanban init` (do **not** use them — create fresh ones with high-quality SOUL.md).

**Maximal combination possible from repo only:**
- Extend `ProfilesPage.tsx` + `ProfileProvider.tsx` + `ProfileSwitcher` into unified dashboard.
- Integrate `hermes kanban list/watch/stats` results as live widgets in existing Cards.
- Use Orchestrator profile to spawn workers (`agent-builder`, `research`, `mlops`, `dograh`, `hermes-livekit` etc.).
- Add buttons for Auto-Healing (`hermes curator run`, s6 restart), Deep Scans (`live-stack-verification` skill), Voice status (Pipecat MCP).
- Glassmorphism/dark theme via existing Tailwind + `@nous-research/ui` + `ThemeSwitcher.tsx`.
- Docker deployment via `docker-compose.prod.yml` (separate YAMLs), `HERMES_UID=$(id -u) HERMES_GID=$(id -g) docker compose up -d`, `hermes dashboard --host 0.0.0.0 --port 9119` behind reverse proxy.

**Workflow (patch this into ProfilesPage or new skill):**
1. `hermes kanban init` (creates kanban.db, discovers profiles).
2. `hermes gateway start` (starts dispatcher that picks up ready tasks every 60s).
3. Create fresh profiles: `hermes profile create voice-orchestrator --clone-from default` then edit SOUL.md with Identity/Expertise/Style/Mission/Behavior Rules + `tool_use_enforcement: true`.
4. `hermes dashboard` (or `--host 0.0.0.0` for VPS).
5. Assign tasks: `hermes kanban create "LiveKit SIP trunk setup" --assignee voice-orchestrator --parents [t_research]`.
6. Monitor: `hermes kanban watch` + `hermes kanban stats` in dashboard widgets.
7. Deploy on VPS with Dokploy: separate `values-prod.yaml`, s6 services for dashboard/gateway/kanban-dispatcher.

**Pitfalls:**
- Dashboard binds to 127.0.0.1 by default (security note in docker-compose.yml). Never expose directly.
- Updates (`hermes update`) overwrite `web/` changes — keep custom UI in skills or fork.
- Existing 13 profiles must be ignored — always create clean ones.
- No drag-and-drop Kanban UI — only CLI + API integration possible without new code.

**VPS Production Recipe (Dokploy/k3s):**
- Use `docker-compose.prod.yml` with volumes for `~/.hermes` and `~/hermes-livekit-infra`.
- Add `KANBAN_DISPATCH_INTERVAL=30` env.
- Reverse proxy (Caddy/Traefik) with auth for port 9119.
- Separate YAML per major service (gateway, dashboard, voice-mcp) for safety.

This file captures the real maximum from the repo for this user's voice-first multi-agent cluster on Hetzner VPS with Dokploy. Update this file when new pitfalls or better combinations are discovered.