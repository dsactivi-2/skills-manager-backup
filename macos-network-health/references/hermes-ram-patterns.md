# Hermes / local-agent RAM patterns on macOS

## Symptom
User: "Hermes is barely open" but RSS shows multi-GB under `~/.hermes/`.

## Typical stack (sum these)
| Piece | Role | RAM pattern |
|---|---|---|
| `hermes` CLI × N | One process per session/profile | ~50–200MB each |
| `hermes_cli.main gateway run` | Background gateway | tens of MB |
| `hermes_cli.main serve` | Local serve | tens of MB |
| Hermes Desktop `.app` | Electron UI | tens–hundreds MB |
| **`node .../.hivemind/mcp/server.js` × N** | Hivemind MCP per attach | **often 0.5–1.7GB each** — main bloat |
| `mcp_stdio_watchdog.py` | Restarts MCP children | small but multiplies children |
| Other MCP (bhtelecom, context7, filesystem, xcodebuildmcp…) | Per session wiring | varies |

## Diagnosis commands
```bash
ps -Ao rss=,args= -m | egrep '/.hermes/|hivemind/mcp/server' | head -40
ps -Ao rss=,args= | awk '/hivemind\/mcp\/server\.js/ {s+=$1;n++} END{printf "hivemind_nodes=%d sum_MB=%.0f\n",n,s/1024}'
pgrep -lf 'hermes-agent/venv/bin/hermes|gateway run'
```

## Parent chain (live attribution)
Big Hivemind nodes often hang off:
- `gateway run` (LaunchAgent `ai.hermes.gateway`) → watchdog → `server.js`
- each `…/venv/bin/hermes` or `hermes -p <profile>` → watchdog → `server.js` (+ often bhtelecom MCP)
- Claude.app MCP attach → another `server.js`

```bash
ps -o pid=,ppid=,rss=,args= -p <PID>
ps -o pid=,ppid=,args= -p <PPID>
```

## Fix order (low drama)
1. Quit unused Hermes Desktop windows and extra CLI sessions/profiles.
2. Leave **one** working session if needed.
3. **Kill the hermes session parent** (or Ctrl+C in that terminal), not only `server.js` — watchdogs respawn children.
4. Confirm Hivemind `server.js` count drops (goal: 0–1 when idle, not 5–10).
5. Do **not** blindly kill gateway if cron/messaging delivery still needed; prefer reducing CLI sessions first.
6. Reboot if swap still huge after quits.
7. Avoid starting Codex/Claude/Hermes **all** with the same heavy MCP set at once unless required.
8. Inventory autostart: Login Items + `~/Library/LaunchAgents` + `brew services list` + pm2 — leftovers return after reboot if agents stay loaded.

## Do not
- Blame "the one chat bubble" alone.
- Delete `~/.hermes` or `~/.hivemind/graphs` to free RAM (destroys config/memory data; issue is live processes).
