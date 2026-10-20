---
name: macos-hygiene-automation
category: apple
description: "Use when automating Mac process/disk hygiene HITL."
---

# macOS Hygiene Automation (HITL)

## Trigger
User wants recurring cleanup of stale processes (esp. Hermes/Hivemind), Downloads/one-off scripts, or folder-structure suggestions; Mac-Hygiene plan; ground cleanup before monitoring; cron that **proposes** then waits for freigabe.

**Related:** live "internet slow / Mac vs ISP" → `macos-network-health` first. This skill is the **ongoing control loop**.

## User constraints (activi)
- German, direct, short. Dry-run / freigabe before kill or delete.
- Overwhelm: answer only asked steps; skip "not recommended" lists unless requested.
- User-facing plans often `~/Downloads/…` when they ask Downloads.
- SoT plan (2026-07-27): `~/Downloads/Mac-Hygiene-Plan-2026-07-27.md`

## Architecture (mandatory)
```
Phase 0  Ground Complete Cleanup (once) → baseline
Scan (cron/script, read-only) → numbered report → notify user
User: approve ids | approve safe | skip
Apply (on-demand only) → recheck still valid → trash/kill tree → log
```

**Never** merge unattended scan + destructive apply in one cron tick.

| Piece | How |
|---|---|
| Scan | Deterministic **script** (`no_agent` Hermes cron preferred) → JSON + short MD |
| LLM | Optional German summary only — **must not invent PIDs/paths** |
| Process apply | Kill **session parent tree**, not lone MCP child (Hermes parent **or** Codex `app-server` / Codex.app — never `uvx`/`npm` MCP procs) |
| Disk apply | **Trash only** |
| Structure | Suggestions only until approved; no auto-resort of `~/Code` |
| Notify | Telegram via gateway if available; always `~/Logs/mac-hygiene/reports/` |
| Heartbeat | Optional scan-OK signal; quiet runs stay silent when possible |

### Modules + cadence
| Module | Cadence | Contents |
|---|---|---|
| process | every 2–3 days | stale hermes, multi Hivemind, Codex MCP copies, autostart inventory |
| disk | every 10–14 days | Downloads aged installers, tmp/one-shot scripts |
| structure | monthly / manual | organization suggestions only |

### Paths
```text
~/Logs/mac-hygiene/{reports,state,logs}/
~/.hermes/scripts/mac-hygiene/{config.yaml,scan_*.py,apply.py}
```

### Safety defaults
Never without special freigabe: `~/Code/**` (except clear tmp artifacts), `~/.hermes` config/skills/auth, `~/.hivemind/graphs`, SSH keys, `.env*`, 1Password, system paths. Do not blindly kill `ai.hermes.gateway`.

### User decisions (2026-09-18 cleanup — do not re-propose)
- Stopped Docker/OrbStack containers are **intentionally stopped by the user** (paused projects, not junk) — never `prune`/remove without per-container approval.
- LaunchAgents + Login Items: user keeps ALL (pm2, GoogleUpdater, Setapp x4, Soniox, Ollama-brew, Kimi CU, Pieces, Codex, OpenCode) — no deletion proposals.
- Removed with approval: Devin.app (+ Library data), Defang (brew uninstall).
- Cleanup flow: user wants list-first-then-decide per phase ("zeige, ich sage was bleibt/geht").

### Explicit component teardown
When the user explicitly scopes a component for complete removal, follow their ordered teardown rather than the generic Phase-0 loop: backup named configs → read-only inventory → remove and validate config references → stop processes and inspect respawn sources → uninstall packages and delete only named paths → measure disk and run residue checks. Do not advance a later deletion when an earlier required config or process gate is pending.

Create the backup before inventory changes and include a manifest of copied and missing paths with source size and mtime; keep the backup outside every deletion glob. Parse every target config before any mutation plan. Build and parse every edited config payload in memory before atomically replacing any source file, so one malformed input cannot leave a partial config cleanup. Treat an already-malformed `*.save` or `*.bak` snapshot as a separate non-live artifact: preserve it in the backup and handle or remove it only after live configs validate.

Heuristics: `keep_newest_hermes_sessions: 1`, `stale_hermes_hours: 12`, Downloads installers age ≥ 14d.

Apply recheck: PID+cmdline+start or path+mtime+size must match report or **skip**.

## Phase 0 — before first cron
1. Save docs 2. Excess loaded tabs / one browser 3. Idle AI quit  
4. One Hermes session (parent trees); gateway stays if cron/messaging needed  
5. Skim Login Items 6. Optional CleanMyMac safe 7. Reboot 8. Baseline swap + hermes/Hivemind counts  

See `references/phase0-ground-cleanup.md`.

## Hermes cron
- Gateway required for scheduler/delivery.
- Prefer `no_agent=True` + `script=` for scans.
- Apply = chat/CLI on-demand only.

## Implement order
1. Freigabe defaults 2. Gate review 3. Phase 0 4. Scripts 5. Manual process scan 6. First apply 7. Crons 8. Structure later

**Stop after Phase 0 if baseline is healthy** — do not build crons/MCP only because the plan lists them.

## Systematic Cleanup Pipeline (user-initiated)
When the user wants a full Mac cleanup (not just monitoring), run this phased pipeline. **Always show what will be killed/deleted first — user decides what stays.**

```text
Phase 1  Scan & categorize (read-only)
  → ps aux, launch agents, login items, docker, disk hogs
  → Group into: System (kill-safe), User-apps (ask), Daemons (check config)
  → Present categorized list to user

Phase 2  Daemon config check
  → PM2 (pm2 list), Defang, Ollama (app vs brew), Docker (running vs exited)
  → Identify duplicates, unused services, ghost launch agents

Phase 3  Login items & Launch Agents cleanup
  → Show each agent with recommendation (keep/remove)
  → User decides per item
  → Remove approved plists, disable (don't delete) uncertain ones

Phase 4  Setup hygiene crons (read-only scans + notify)
  → Process scan every 2-3 days, disk scan every 10-14 days
  → Notify via gateway (telegram) or local deliver

Phase 5  Clean reboot
  → Stop all approved processes
  → Reboot to clear swap, restart services fresh

Phase 6  Post-check
  → Validate all expected services running
  → Measure disk before/after
  → Report what was freed (RAM + disk)
```

### Key commands (macOS)
```bash
# Process scan (macOS-compatible)
ps aux | awk 'NR>1 {printf "%s %s %s %s\n", $2, $6/1024, $3, $11}' | sort -t' ' -k2 -rn

# Launch agents
ls ~/Library/LaunchAgents/

# Login items
osascript -e 'tell application "System Events" to get the name of every login item'

# Docker (running vs exited)
docker ps -a --format '{{.Names}}\t{{.Status}}\t{{.Image}}'

# Ollama duplication check
ls /Applications/Ollama.app 2>/dev/null && echo "App installed"; brew list ollama 2>/dev/null && echo "Brew installed"

# Disk (Data volume, not root)
df -h /System/Volumes/Data | tail -1
```

See `references/systematic-cleanup.md` for the full procedure.

## ROI / anti-overkill (verified 2026-07)
Default path is **MINIMAL**. Full MCP + LLM-written kill scripts + multi-module Guard + structure-from-day-one = overkill for activi.

| Build | When |
|---|---|
| Phase 0 only (manual + reboot) | Always first; highest ROI |
| Mini: one process scan script + cron notify + chat freigabe | Only if stale Hermes/Hivemind **returns** |
| Custom disk engine / structure auto-org / MCP server | Park; disk → CleanMyMac, Mole (`mo`), or PureMac |

Reliability stack: Scripts=hands, JSON report=truth, Skill=rails, Plan MD=human map, MCP=optional outlet wrapping **same** scripts. LLM may fill fixed templates with report IDs; must not author ad-hoc `kill`/`rm`. Real apply = immutable apply script after freigabe + dry-run green + recheck — dry-run alone never auto-unlocks process kills.

Once wired correctly, **scans** can run automatically; **destroy** stays freigabe-gated. MCP is not automatic agent memory/runbook brain.

## Disk spike (500→900GB-class)

When user reports sudden full disk / “backup loop”:

1. **Phase A only** first — `references/disk-phase-a-measure.md` (Data SoT, 48h writers, Docker/iCloud/Hermes).
2. Prefer this skill + `mac-hygiene-verify-first` over hub `disk-cleanup` hits from `find-skills`.
3. Disprove Hermes backup loop via `backup_keep` + zip inventory before chasing loops.
4. Safe prune only after freigabe; always re-measure **remaining** buckets after apply (not only GB freed).
5. If `Mobile Documents` missing: say so — check `CloudStorage` stub; do not treat all of `~/Documents` as disposable iCloud temp.

### APFS snapshot triage
- List both volumes: `tmutil listlocalsnapshots /`, `diskutil apfs listSnapshots /`, and `diskutil apfs listSnapshots /System/Volumes/Data`; the Time Machine snapshot can live on Data while update snapshots live on System.
- Report APFS snapshots as internal read-only volume states, not Finder files: they have no folder path or direct link. Open Disk Utility and use View → Show APFS Snapshots when the user wants to inspect them visually.
- Do not invent per-snapshot sizes. `diskutil` exposes name, UUID/XID, purgeability, and shrink constraints, but APFS copy-on-write sharing prevents a reliable individual physical size. Measure reclaimed capacity only before/after an approved deletion.
- Treat `com.apple.os.update-*` as macOS update/rollback protection and do not delete them merely to measure space. Restrict cleanup candidates to explicitly approved, purgeable Time Machine snapshots.

## Pitfalls
- Fenster zu ≠ Prozess tot.
- **macOS `ps` is not Linux:** `ps -ww --sort=-%mem` fails ("illegal option"). Use `ps aux` and parse/sort manually, or `top -l 1 -n 0`.
- **System Python is 3.13-incompatible:** macOS ships Python 3.9.6; many CLIs (memo, etc.) require 3.13+. Workaround: `python3.13 -m pip install` (Homebrew) or use the Hermes venv.
- **Stale patterns miss containerized agents:** `npm exec ollama-mcp@latest`, `uv tool uvx --python`, `opencode` are not caught by broad word search. Extend `STALE_PATTERNS` per agent.
- Xiaomi Router standardmäßig Cloud/Remote Access prüfen — oft aktiviert.
- Watchdog respawns MCP if only child killed. Codex does the same: each thread respawns the full MCP set under `codex app-server`; multiplicity is copies, not unique servers. Close extra Codex threads / quit Codex.app — do not kill the `uvx`/`npm`/`node` children.
- Match processes by service executable or runtime path, not a broad word search: backups, Git scans, and the checking shell can contain the component name without being the component process.
- `deliver=local` easy to miss — dual-write report file.
- CleanMyMac = UI junk only; not Hermes tree logic. If CMM installed, skip Nektony Memory Cleaner for the same job.
- Unix zombies ≠ stale long-running sessions.
- Designing full platform before Phase 0 overwhelms user — Phase 0 / measure first, automate second.
- Hub cleanup/hygiene skills rarely cover multi-Hivemind trees.
- Root `df` ~12 GB used while Data is 90%+ — always quote **Data**.
- OrbStack/disk-image mtime sums can show absurd “GB written in 48h” — artifact, not loop proof.
- Safe prune often frees only ~10–25 GB; do not promise emptying ~800 GB Data without user-data decisions.
- Hermes `pre-update` zips + `backup_keep: 5` ≠ infinite backup loop.
- **Electron-Apps replizieren sich:** Kimi, Cursor, Devin, Claude — jedes Tab = neuer Prozess. Statt `kill`: App sauber beenden oder Quit-Befehl.
- **Ollama-Duplikat:** Sowohl `/Applications/Ollama.app` ALSO `brew install ollama` startet jeweils einen Daemon + MCP-Wrapper. Einen Weg entfernen.
- **Docker Exited-Container** belegen kein RAM, aber Platz (Images, Volumes). `docker system prune -a` nach Freigabe.
- **PAIOS (FastAPI-App):** Auth in `/app/data/auth.json` (bcrypt). Container stop → Datei löschen → Container start → neues Passwort via ENV oder im Log.
- **Same MAC, multiple IPs:** Alte DHCP-Lease oder virtuelle Interface — kein neues Gerät. Nicht killen.

## References
- `references/plan-structure.md`
- `references/phase0-ground-cleanup.md`
- `references/hitl-approve-protocol.md`
- `references/anti-overkill-and-stack.md`
- `references/disk-phase-a-measure.md` — APFS Data SoT, 48h writers, safe-prune catalog, remaining map
