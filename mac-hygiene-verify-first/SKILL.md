---
name: mac-hygiene-verify-first
description: "Use when Mac feels slow, Hermes/Hivemind/Codex RAM sprawl, swap pressure, or continuing the mac-hygiene project. Verify-first progress; no auto-kill."
category: software-development
---

# Mac hygiene + multi-session progress (verify-first)

## When to use

- Mac „langsam“ / Internet fühlt sich langsam an, aber Wi‑Fi/Download ok
- Viele Hermes-Sessions / Hivemind-Kopien / Codex-MCP-Kopien / hoher Swap
- Live RAM/CPU-Inventar (was belastet, lange Hintergründe, ungenutzt)
- Weiterarbeit am Projekt `/Users/activi/Code/Tools/mac-hygiene`
- Multi-Session-Pläne: Agent darf Status **nicht** aus Chat-Gedächtnis erfinden

## User communication (hard rules)

- **Deutsch, kurz, einfach** — keine Multi-Kapitel-Wände
- Eine Schicht / ein `next_step` pro Antwort
- Tabellen ok; keine Overkill-Optionen-Listen ohne Nachfrage
- RAM/CPU-Antwort: Top-RSS, Top-CPU, lange Idle, eine Freigabe-Frage — kein Prozessdump
- MCP-Liste nur auf Nachfrage: durchnummerierte **eindeutige** Namen, eine Zeile Beschreibung, Kopienzahl in Klammern. Keine PID-Liste.
- „MCP-Kopien“ = dasselbe Hilfsprogramm pro Codex-Thread nochmal gestartet (meist 0 % CPU, RAM addiert sich). Nicht Hermes.
- Finder/Ordner **nur** öffnen wenn User es will
- Destruktiv nur nach **expliziter Freigabe in diesem Turn**

## Canonical paths

| What | Path |
|------|------|
| Project | `/Users/activi/Code/Tools/mac-hygiene` |
| Start prompt (copy into new session) | `START_PROMPT.txt` **or** `~/Downloads/Mac-Hygiene-START-PROMPT.txt` |
| Agent rails | `AGENTS.md` |
| Steps | `RUNBOOK.md` |
| Background plan | `PLAN.md` |
| Checklist SoT | `state/checklist.json` (not the deprecated yaml stub) |

## Mandatory agent start

**Hygiene-Projekt** (`mac-hygiene` weiterarbeiten / START_PROMPT): immer

```bash
cd /Users/activi/Code/Tools/mac-hygiene
python3 scripts/verify_progress.py
```

Dann nur: `next_step` (id + title + phase), open required, live hint (hermes / hivemind / Codex-app-server-Kinder / swap / uptime). Nur an dem `next_step` weiterarbeiten. Nach jedem Mark/Cleanup verify neu.

**Live RAM/CPU-Frage ohne Hygiene-Projekt:** nicht mit `next_step` antworten. Messen: `scan_hermes.py` plus **ein** `ps -axo pid,ppid,pcpu,pmem,rss,etime,state,command` Pass. Dieselben Measurement-Pitfalls und Kill-Verbote gelten.

## Architecture (do not overbuild)

| Layer | Role |
|-------|------|
| Scripts | Only authority for measure/apply facts |
| `state/progress.json` + reports | Single source of runtime truth |
| `AGENTS.md` / skill | Procedure + bans for the agent |
| `PLAN.md` | Human background — not a substitute for verify |
| MCP | Optional tool bus later — **not** the brain; v1 needs no MCP |

**ROI default:** Phase 0 (trim + reboot) first. Mini `scan_hermes` if sprawl returns. Full MCP + LLM-written kill scripts + auto-apply cron = overkill unless user explicitly wants it.

## Scripts

| Command | Role |
|---------|------|
| `python3 scripts/verify_progress.py` | done / open / blocked / next_step |
| `python3 scripts/verify_progress.py --mark ID` | manual item after user confirms |
| `python3 scripts/verify_progress.py --unmark ID` | undo mark |
| `python3 scripts/scan_hermes.py` | read-only Hermes/Hivemind/swap |
| `python3 scripts/scan_hermes.py --save` | write `reports/hermes_scan_*.json` |

## Auto-check pitfalls (verified)

- **`phase0_baseline_captured`**: auto only if `phase0_reboot_done` is marked **and** a scan report timestamp is **after** that mark. A scan during multi-day uptime alone must **not** complete baseline.
- **`phase2_scan_report_exists`**: auto only after `phase1_rules_confirmed` **and** a report exists (`phase2_official_scan`). Early test scans must not complete Phase 2.
- After reboot baseline: mark `phase0_reboot_done` → then `scan_hermes.py --save` → verify.

## Measurement pitfalls (learned the hard way — read before diagnosing RAM)

- **VSZ ≠ RAM.** Huge numbers in a warning (98 GB, 1.635 GB VSZ, etc.) are almost always **virtual address space (VSZ)**, not physical RAM. On Apple Silicon (arm64) every process gets a gigantic VSZ it never fills — Tabby showing 1.635 GB VSZ / Safari 437 GB VSZ while using <1 GB RSS is **normal**. A number bigger than installed RAM (e.g. 98 GB on a 48 GB Mac) is physically impossible as RSS → it's VSZ. **Only `RSS` is real memory.** Never report VSZ as "frisst X GB".
- **Check the clock before trusting ANY prior number.** Run `uptime` / `sysctl -n kern.boottime` first. A reboot wipes swap, pageouts, and compressor state — so dramatic pre-reboot figures (swap 98 % voll, 2,37 Mio pageouts, "8,8 GB Leak") are stale the moment the box restarts. If prior claims came from before boot time, **label them as pre-reboot and re-measure** rather than repeating them. This was the core failure in the past session: dramatic claims carried over across a silent reboot.
- **One clean measurement, not several.** Two `ps` passes gave 1.635 MB vs 488 MB for the *same* PID — an artifact of sampling during a spike / duplicate matches. Take one consistent `ps -axo pid,ppid,rss,etime,command` pass, dedupe, and cite that. Don't build a narrative on measurements that contradict each other.
- **"Memory leak" must survive the RSS-vs-age test.** A real leak means RSS grows monotonically with process age. Before claiming a leak, sort the servers by `etime` and check RSS actually correlates. In the past session the *oldest* server had the *least* RAM → no leak, just workload/graph-load variance. RAM growth over minutes within one long-lived process (1637: 4 GB @ 43 min vs a 2-min process @ 1.8 GB) is a stronger leak signal than cross-process age scatter — use the same process over time, not different processes.
- **"Orphaned / Karteileiche" must survive the live-parent test.** Each Hivemind `server.js` runs under a watchdog under a **hermes parent** (`gateway run` or `hermes --resume`). Check every parent PID is alive (`ps -p <ppid>`) before calling a server leaked/orphaned. If the parent lives, it's **one legitimate server per open Hermes session** — accumulation from many parallel sessions, not a defect. Killing it kills a real session.
- **Electron Crashpad: PPID 1 is normal, not proof of orphan.** Chromium/Electron `chrome_crashpad_handler` (Tabby, Cursor, …) often reparents to `launchd`. Two Tabby crashpads can both show PPID 1. Stale vs live = **etime vs the app main process**, not PPID. Example (verified): Tabby main ~6h, live crashpad ~6h, leftover crashpad since boot (~3d) — kill only the boot-aged PID after current-turn Freigabe + recheck (PID+cmdline+etime). Never kill the crashpad whose etime matches Tabby.
- **`scan_hermes.py` `hermes_sessions: 0` ≠ kein Hermes-RAM.** Der Scan zählt Hivemind/`--resume`-Sessions, nicht CLI `.../hermes-agent/hermes`, nicht Desktop `Hermes.app`, nicht `serve` / `gateway run`. Dieselben Prozesse aus dem einen `ps`-Pass extra zählen.
- **Codex-MCP-Kopien sind kein Leak einzelner Server.** `Codex.app`/`ChatGPT` startet einen `codex app-server`; jeder Thread startet dieselbe MCP-Menge erneut (`uvx mcp-server-git`, `arxiv-mcp-server`, `mcp-remote` Coresignal, `xcodebuildmcp`, Serena, Defang, …). Report: eindeutige Namen + Multiplizität. Familien-RSS-Summe überzählt Shared Memory — führe mit Main-PID-RSS und Kopienzahlen, nicht mit der Summen-GB-Zahl als physischem RAM.
- **Keine MCP-Kinder unter Codex killen.** Sie respawnen. Freigabe-Ziel ist überzählige Codex-Threads oder Codex.app beenden — analog Hermes-Parent-Tree, nicht lone `server.js`.
- **UI idle ≠ Daemon unused.** Ein Helper mit hoher CPU (z. B. Pieces OS) bei 0 %-CPU der App-UI ist Last. Beide nennen; die UI nicht als „ungenutzt“ führen wenn der Daemon läuft.

## Domain facts

- Slow feel often **RAM/swap + loaded Safari/Chrome tabs + multi Hermes/Hivemind + Codex-MCP-Kopien**, not weak Wi‑Fi. Hivemind kann 0 sein und der Mac trotzdem voll sein.
- **`.hivemind` on disk is tiny** (~1.7 MB; 136 graph folders ≈ MB). The RAM cost is the running `node server.js` processes, not the files. Removing Hivemind is a config decision (hooks + `mcp_servers` in `~/.hermes/config.yaml`, Claude Desktop config, `~/.claude.json` stats), **not** a memory emergency.
- Kill **parent hermes session tree**, not lone child `server.js` (watchdogs respawn)
- Do not blindly kill `ai.hermes.gateway` (cron/messaging depend on it)
- Swap clear = **reboot** after save; no manual swap-file deletion
- Disk junk: CleanMyMac (user has it) / Mole / PureMac — do not rebuild a disk cleaner
- Tab groups themselves are light; **loaded** tabs cost RAM
- **Disk-full SoT is APFS Data** (`df -h /System/Volumes/Data`), not System `/` (~12 GB). Sudden multi-hundred-GB growth: Phase A measure-only first (`macos-hygiene-automation` + `references/disk-phase-a-measure.md`). Typical large buckets: iCloud CloudDocs **if path exists**, Docker images/build-cache/OrbStack, App Support (Claude can grow multi-GB/48h), local `~/Documents` projects. High swap + many hermes sessions ≠ disk write-loop; Hermes `pre-update` zips with `backup_keep: 5` are **not** infinite backups.
- Phase A / measure only: tables + freigabe ladder — **no** prune until pick. After approved safe prune: free-GB delta **and** remaining top buckets (user always asks what still fills the rest).
- iCloud path may vanish (`Mobile Documents` gone, `CloudStorage` stub only) — re-stat before delete; never rm vanished paths; never treat all of `~/Documents` as disposable iCloud junk without listing folders.
- **APFS snapshot trap (critical):** after `rm` of a huge file, `df` may show almost no space freed (e.g. deleted 223 GB, gained only ~3 GB). Cause is NOT a process holding the fd (check `lsof`, usually clears it out) — it's a **local Time Machine snapshot** freezing the blocks. Diagnose: `tmutil listlocalsnapshots /`. Fix: `tmutil deletelocalsnapshots <YYYY-MM-DD-HHMMSS>` (or `sudo tmutil thinlocalsnapshots / <bytes> 4`). Local snapshots are temporary hourly caches macOS auto-purges; deleting them does NOT touch real external/NAS Time Machine backups. Only the blocks written *after* the snapshot timestamp free on `rm`; the rest release when the snapshot goes. Always show `df` before/after both steps.
- **Deeplake cowork-queue runaway** = a known huge bucket: `~/.deeplake/queue-cowork/*.jsonl` is a producer-without-consumer stau (Cowork hooks append mitgeschnittene Claude-Session-Zeilen; no deeplake daemon runs to drain it) → one file can hit 200+ GB. It is NOT a FUSE mount (verify: no `deeplake`/`fuse-server.js` in `mount`), so the two files (`*.jsonl` + `*.inflight`) are safe to `rm`. Real hivemind memory (`~/.hivemind`, `summaries/`, `graphs/`) is tiny (~MB) and lives elsewhere — untouched. Deleting the file alone won't stop regrowth; the Cowork ingest hooks in the agent configs keep refilling.
- Prefer this skill + `macos-hygiene-automation` over hub `npx skills find disk-cleanup` for activi HITL/dry-run rules.

## Safety bans

- No `kill`/`rm`/reboot without current-turn approval
- No LLM-authored freeform kill/delete shell as the apply path — fixed scripts + IDs only if apply is ever added
- No auto-apply cron in v1
- Do not claim phase complete without verify/`--mark`

## References

- `references/session-start.md` — copy-paste prompts and mark examples
- `references/verify-auto-rules.md` — auto-check contract detail
