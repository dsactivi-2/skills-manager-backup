---
name: macos-network-health
category: apple
description: "Use when Mac internet feels slow. Separate Wi-Fi/ISP/Mac."
---

# macOS Network + Local Health Diagnostics

## Trigger
User says internet/Wi-Fi is slow, wants a Mac network scan, speed/latency test, "liegt es am Mac oder am Internet", multi-day quality logging, or top bandwidth/RAM hogs on macOS.

**Not this skill:** single HTTP endpoint 404/timeout debug → `network-endpoint-diagnostics`.

## User style (this environment)
- German, direct, short. Tool-first, live verify before theory.
- When explaining metrics: plain words + one everyday image, then the number.
- Option comparisons: side-by-side table what each variant **shows / does not show**, autonomy (can agent run it?), and **what the data is for** (4 use-rows). Do not dump only prose plans.
- Prefer live verify over hub skills. Skills.sh/Hermes hub rarely has a solid Mac ISP/Wi-Fi forensic skill — use built-ins first.
- **Overwhelm rule:** if user says too much data / lost overview / explain simply — answer **only** the numbered questions they asked, short steps, no extra catalogs. If they say "don't list negatives/not-recommended", omit that section entirely.
- **Step ladder when teaching:** (1) forgotten vs planned? (2) is plan optimal? (3) concrete recommendation only — then stop unless they ask more.
- Ongoing process/disk HITL → `macos-hygiene-automation` (**mini** / Phase 0 first; full MCP hygiene overkill until recurrence). Plan SoT: `~/Downloads/Mac-Hygiene-Plan-2026-07-27.md`.
- ROI (“gibt’s das schon / overkill?”): re-verify live; disk CleanMyMac/Mole/PureMac; Hermes gap = small scan script only.

## Phase 0 — Live snapshot (always first)
Run in parallel (no install):

1. **Host:** `sw_vers`, `sysctl` CPU/mem, `uptime` / load
2. **Capacity + responsiveness:** `networkQuality -v` (and `-c` if JSON needed). Takes ~30–45s; loads the link.
3. **Path:** default route, `networksetup` Wi-Fi info, gateway IP
4. **Wi-Fi quality:** `system_profiler SPAirPortDataType` → signal/noise/channel/PHY/tx rate. Option: Wireless Diagnostics (GUI).
5. **Latency:** ping gateway (20–30×), ping 1.1.1.1 / 8.8.8.8; optional `traceroute -n` to 1.1.1.1
6. **DNS:** `scutil --dns` + `dig +stats` via 1.1.1.1 vs default (Tailscale `100.100.100.100` often first)
7. **Mac pressure:** `memory_pressure`, `sysctl vm.swapusage`, `vm_stat`; top CPU + top RSS; group by app
8. **Talkers:** `lsof -i` counts by process; `nettop -d -P` if usable; note VPNs (`scutil --nc list`, Tailscale/Proton/etc.)
9. **Already installed helpers:** Stats.app, TripMode, Little Snitch, etc. (`ls /Applications`)

Script: `scripts/macos-net-health-scan.sh` (best-effort single pass).

## Phase 1 — Attribution (Mac vs link vs Wi-Fi)
Use `references/metric-meanings.md`.

| Signal | Points to |
|---|---|
| Strong Wi-Fi (e.g. RSSI ≥ about −60 dBm, good SNR), high PHY rate | Not RF as primary |
| High download, low upload | Asymmetric ISP plan / uplink saturation |
| Idle latency OK, **Responsiveness Medium/Low under load** | Bufferbloat / load sensitivity (feels slow in real use) |
| Huge swap used, compressor high, many heavy apps | **Mac RAM pressure** masquerading as "slow internet" |
| Gateway ping spikes, internet fine | Router/Wi-Fi local |
| Gateway fine, loss/latency from hop 2+ | ISP/path |
| VPN connected (Tailscale etc.) | Re-test once disconnected before blaming ISP |

**Common dual fault:** Mac thrashing (swap) **plus** weak upload + medium RPM under load.

## Phase 2 — Explain simply (before raw tables dump)
For non-expert follow-ups, explain in order:
1. One-sentence verdict
2. What each key metric means in plain German
3. Top resource hogs: table `# | app | ~RAM | what it does in 5 words`
4. Then optional deep numbers

Key phrases users ask about:
- **Asymmetrischer Upload** = rein viel schneller als raus (Straße 18 Spuren rein, 1 raus)
- **Responsiveness unter Last** = wie schnell kleine Anfragen noch durchkommen, **während** die Leitung beschäftigt ist (nicht nur Speedtest-Mbit)
- **Swap** = Not-Speicher auf SSD wenn RAM voll → alles fühlt sich zäh an

## Phase 3 — Monitoring variants (offer, don't install silently)

Full comparison: `references/monitoring-variants.md`.

| | A Script/Cron | B + brew | C GUI parallel |
|---|---|---|---|
| Agent autonomy | High after path/interval OK | After brew+sudo setup | Low (user-driven) |
| Extra install | No | `mtr`, `vnstat`, optional `bandwhich` | Usually already there |
| Best for | 4–7d proof Mac vs link | Hop faults + GB/day history | Live "which app" + block |
| Weak at | Per-app kb/s live, block | Needs install | Exportable multi-day correlation |

**Default recommend:** start **A**, use **C** only when it feels slow now; add **B** if path/ISP still unclear.

A sample fields every 15–30 min → `~/Logs/net-health/YYYY-MM-DD.jsonl`:
`networkQuality -c`, ping gw+1.1.1.1, Wi-Fi snap, swap/load, top RSS/CPU, coarse connection counts.

**Load note:** `networkQuality` stresses the link ~30–45s — do not run more often than 15–30 min for multi-day jobs.

Hermes: local cron/`deliver=local` OK on CLI (no live terminal delivery of cron output unless configured). Prefer LaunchAgent or cron writing files the next session reads.

## Phase 4 — Safari tabs, Web Apps, RAM (user asks this often)
- **Tab groups ≠ free:** group sidebar is cheap; **loaded** tabs cost RAM. Proxy: count `WebKit.WebContent` + Safari/WebKit RSS sum. High WebContent count (50–200+) = many tabs truly loaded, not labels only.
- **Unloaded / never opened / Safari quit:** little or no RAM for those tabs; tab list usually restores after reboot.
- **Safari Web Apps** (`~/Applications/*.app` via `Web App.app`): only **running** instances use RAM (~30–60MB each typical). Icons on disk alone do not.
- Detail: `references/safari-tabs-and-webapps.md`

## Phase 5 — Swap clear + restart impact (live-check before reboot)
- There is **no safe "delete swap file only"** path. **Swap clear = reboot** (after quitting heavies).
- Before reboot, live-check what would be lost: open editors (`lsof` + running apps), terminals/SSH, AI chats mid-generation, Hermes sessions. See `references/swap-reboot-impact.md`.
- **Safe:** files on disk, installed apps, Hermes config/skills/profiles, most cloud chat history, Safari tab *lists*.
- **At risk:** unsaved docs, input-box drafts, running jobs/SSH, in-flight agent runs, form fields in tabs.

## Phase 6 — Optimizations (priority order)
1. Free RAM / quit duplicate browsers & idle local AI (Ollama, LM Studio, llama-server)
2. Safari: close loaded tabs (groups may stay); verify WebContent count drops
3. Hermes: quit **extra sessions/profiles** — kill **session parent tree**, not lone Hivemind children (watchdog respawns). Biggest Hermes RAM is often **multiple Hivemind MCP `server.js`**, not the chat window (`references/hermes-ram-patterns.md`)
4. Reboot if multi-day uptime + massive swap
5. TripMode/Snitch: curb cloud sync during work
6. A/B test VPN off
7. Ethernet isolate vs Wi-Fi
8. Router QoS/bufferbloat; confirm plan upload
9. Only then ISP ticket — attach A/B logs

## Phase 7 — Full Network Audit (user requests network scan)
User wants comprehensive network scan, device inventory, and configuration review.

### Discovery
1. **Ping sweep** — `nmap -sn <subnet>/24` (fast, discovers all hosts)
2. **Port scan** — `nmap -sV <IP>` (service detection, version, OS fingerprint)
3. **ARP table** — `arp -an` (MAC addresses, OUI lookup for vendor identification)
4. **Router web UI** — `curl -s http://<router_ip>` (model, firmware, open ports)
5. **Device fingerprinting** — `curl -s https://api.macvendors.com/<MAC>` (vendor lookup)

### Analysis
- Identify all devices, their roles, and open ports
- Flag outdated firmware (e.g., Boa HTTPd, old OpenSSH)
- Check for unusual open ports (e.g., port 514 = shell/telnet)
- Verify DHCP, DNS, and gateway configuration
- Cross-reference with known infrastructure (Yeastar TG400, FreePBX, etc.)

### Report format
| IP | Device | MAC | Ports | Details |
|---|---|---|---|---|---|
| x.x.x.x | Role | Vendor | open | Service/version |

### Recommendations
- Prioritized by security risk (open ports, outdated firmware)
- Configuration improvements (DNS, DHCP, service-Order)
- Device identification for unknown hosts

### Pitfall
- `nmap -sV` can take 30-60s per host — warn user about scan duration
- MAC vendor API rate-limits — cache results locally
- Router web UIs often require login — don't assume access
- Xiaomi Router: Cloud/Remote-Access oft standardmäßig aktiviert — prüfen
- Yeastar/Asterisk-Gateway: Port 514 oft Telnet/Shell — prüfen und deaktivieren wenn möglich
- Same MAC on multiple IPs = alte DHCP-Lease oder virtuelle Interface, kein neues Gerät
- nmap manchmal scheitert auf macOS Firewall (Little Snitch, etc.) — ggf. temporär deaktivieren

### CleanMyMac vs "Memory Cleaner"
If CleanMyMac is installed, do **not** also require Nektony Memory Cleaner. CMM covers performance/background/junk UI. Memory Cleaner is a thin RAM menu-bar free-up; it does not fix multi-Hermes/Hivemind trees or replace reboot for huge swap. Prefer Activity Monitor / hygiene apply for process trees.

### Recommendation table format (user prefers)
When advising actions, use two tables **unless user forbids the don't-list**:
1. **Do:** Name | What it does | ~cost now | Action | Impact (what you gain / what you lose)
2. **Don't need:** Name | What it is | Recommendation | Impact if followed  
Default avoid as primary fix: RAM-cleaner apps, manual swap-file deletion, deleting unused Web App icons for RAM, deleting tab groups for RAM.

## Pitfalls
- Hub skill search (`npx skills find`, `hermes skills search`) for "network/wifi" returns low-fit generic skills — do not block diagnosis on installing them.
- Gerät „im gleichen Netz“ aber keine UI: oft **anderes Subnetz** (Werk-IP), nicht ISP. IoT/GSM-Gateway → `yeastar-tg-gateway` (Alias + `nmap -sn`, nie `-Pn`).
- `network-endpoint-diagnostics` is **HTTP service** debug, not ISP/Wi-Fi/Mac health.
- High load average + high CPU idle often means **wait/memory**, not compute bound.
- RSS sum can be high while swap is the real pain — always report `vm.swapusage`.
- Tailscale DNS (`100.100.100.100`) as first resolver is normal when TS is up; measure both default and 1.1.1.1.
- Do not install brew packages or start multi-day crons without explicit user OK (dry-run / plan first).
- After brew install: tools work without macOS reboot; Hermes skills need new session/reload, not reboot.
- "I barely have Hermes open" can still mean multi-GB RAM via background gateway + N× Hivemind node + leftover profile CLIs.
- Cannot list "which file is in swap" on macOS — swap holds anonymous memory pages; explain that plainly when asked.

## References
- `references/metric-meanings.md` — plain-language metrics + attribution
- `references/monitoring-variants.md` — A/B/C diff table + evaluation uses
- `references/safari-tabs-and-webapps.md` — tab groups vs RAM, Web Apps
- `references/swap-reboot-impact.md` — how to free swap, pre-reboot live checklist
- `references/hermes-ram-patterns.md` — multi-session / Hivemind MCP bloat
- `scripts/macos-net-health-scan.sh` — one-shot live scan
