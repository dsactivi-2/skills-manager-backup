# Systematic Mac Cleanup Procedure

Phased cleanup pipeline for a user-initiated Mac deep-clean. **Never blind-kill — always show first, user decides.**

## Phase 1 — Scan & Categorize (read-only)

### Process scan
```bash
ps aux | awk 'NR>1 {printf "%-8s %6s %5s  %s\n", $1, $2, $6/1024, $3, $11}' | sort -t' ' -k3 -rn | head -50
```

Group processes into:
- **System (kill-safe, do NOT kill):** WindowServer, Finder, tccd, routined, knowledge-agent, ControlCenter, ExtensionKit, XPCServices, coreauthd
- **User-apps (ask before kill):** Kimi, Claude, Cursor, Tabby, Devin, Opera, Ollama, Grok, Defang
- **Daemons (check config first):** Hermes, PM2, Defang, Ollama, Docker, MCP-Server

### Disk scan
```bash
# Data volume (not root)
df -h /System/Volumes/Data | tail -1

# Top disk hogs
du -sh ~/Downloads ~/Library/Caches ~/Movies ~/Music 2>/dev/null

# Docker disk usage
docker system df
```

### Docker inventory
```bash
docker ps -a --format '{{.Names}}\t{{.Status}}\t{{.Image}}'
```
Separate: Running (keep), Exited 0/Older (ask), Exit code ≥ 128 (failed, likely safe to remove).

### Login Items & Launch Agents
```bash
ls ~/Library/LaunchAgents/
osascript -e 'tell application "System Events" to get the name of every login item'
```

## Phase 2 — Daemon Config Check

### PM2
```bash
pm2 list  # If no process → ghost agent, remove plist
```

### Ollama duplication
```bash
ls /Applications/Ollama.app 2>/dev/null && echo "App"
brew list ollama 2>/dev/null &&echo "Brew"
# Both installed → recommend removing one (usually keep App, remove brew)
```

### Defang
```bash
which defang 2>/dev/null && brew list defang 2>/dev/null
# Cloud DevOps tool — remove if not used
```

### Docker exited cleanup
```bash
docker ps -f status=exited --format '{{.Names}}'
# All exited → docker container prune -f (after user approval)
# Images → docker image prune -a -f (after user approval)
# Volumes → docker volume prune -f (after user approval)
```

## Phase 3 — Launch Agent & Login Item Cleanup

For each agent/item:
1. Show name + what it does
2. Recommend: keep / disable / remove
3. User decides per item

### Disable vs Remove
- **Disable** (keep file, stop autoload): `launchctl unload -w <plist>`
- **Remove** (delete plist + file): `rm <plist>` then `launchctl remove <label>`

### Common safe-to-remove for activi
| Agent | Reason |
|---|---|
| `com.google.GoogleUpdater.wake.plist` | Google auto-updates, not needed |
| `pm2.activi.plist` | Ghost (no process) |
| `environment.codex.manifest.plist` | Codex, remove if not used |
| `com.openclaw.daily-backup.plist.disabled` | Already disabled |

### Common keep
| Agent | Reason |
|---|---|
| `ai.hermes.gateway.plist` | Kritisch — gateway |
| `ai.kimi.cu.service.plist` | Kimi service |
| `sh.brew.ollama.plist` | Ollama daemon |
| `Soniox.plist` | Voice platform |

## Phase 4 — Hygiene Crons

Prefer `no_agent=True` + `script=` for scans. Apply = chat/CLI on-demand.

| Cadence | Module | Contents |
|---|---|---|
| 2-3 days | process | Stale hermes, multi-Hivemind, Electron replication |
| 10-14 days | disk | Downloads, caches, Docker exited |
| Monthly | structure | Organization suggestions |

## Phase 5 — Clean Reboot

1. Stop all approved processes (App Quit, not kill)
2. `sudo shutdown -r now`
3. Wait for restart
4. Validate expected services running

## Phase 6 — Post-Check

```bash
# Services running
ps aux | grep -E "hermes|ollama|kimi|docker" | grep -v grep | wc -l

# Swap cleared
sysctl vm.swapusage

# Disk freed
df -h /System/Volumes/Data | tail -1

# Node process count (should be lower)
ps aux | grep -E "node|npm" | grep -v grep | wc -l
```

## Safety defaults (activi)
- **Hermes Gateway never kill** unless user explicitly orders
- **Trash only** for disk (never `rm -rf` without freigabe)
- **Ask before every batch kill** — never parallel-kill a group of PIDs
- **Electron apps**: Quit via app menu, not `kill` (replicates)
- **Docker**: Only `prune` exited containers, never running ones