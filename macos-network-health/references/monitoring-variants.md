# Monitoring variants A / B / C

Present as comparison tables: metrics each delivers, exclusive diffs, autonomy, and four evaluation uses. User chooses what is needed — do not force B installs.

## Autonomy

| Variant | Agent can run fully? | After setup with user? | Needs from user |
|---|---|---|---|
| **A** script/LaunchAgent/Hermes cron | Almost yes | Ideal default | Log dir, interval 15–30m, duration 4–7d, OK to load link via networkQuality |
| **B** brew extras | No without install | Yes | `brew install mtr vnstat` (+ optional bandwhich); often sudo for vnstat service / mtr / bandwhich |
| **C** GUI (Stats, TripMode, Little Snitch) | No durable automation | Partial coaching only | User opens tools when slow; agent does not replace multi-day export |

## What is measured

| Data | A | B | C |
|---|---|---|---|
| DL/UL speed (networkQuality) | Yes | Yes | Partial (live throughput, not Apple RPM test) |
| Responsiveness / RPM under load | Yes | Yes | No |
| Ping gateway + internet | Yes | Yes | Partial / manual |
| Loss over time | Partial (ping samples) | Stronger (mtr) | No |
| Wi-Fi signal/noise/channel snaps | Yes | Yes | Live UI, weak export |
| RAM / swap / load | Yes | Yes | Yes (Stats) |
| Top RAM/CPU over time (log) | Yes | Yes | Weak multi-day export |
| Connection counts by process | Coarse | Coarse + bandwhich spots | Strong (Snitch) |
| Live kb/s per app | Weak/No | Partial (bandwhich) | Strong (TripMode/Stats) |
| GB/day traffic history | No | Yes (vnstat) | Partial |
| Which ISP hop hurts | No (one-off traceroute only) | Yes (mtr schedule) | No |
| Block/throttle apps | No | No | Yes |
| JSONL 4–7d + agent stats (median/p95) | Yes | Yes | No |

## Exclusive differences (decision aids)

- **Only A easily:** zero-install automated series of speed+RPM+ping+swap+top procs.
- **Only B:** vnstat volume history; scheduled mtr hop quality; optional live bandwhich.
- **Only C:** instant per-app bandwidth blame and allow/deny without waiting for a report.
- **A/B not C:** correlatable proof "18:40 RPM drop while swap peaked".
- **C not A/B:** fix-in-the-moment with TripMode/Snitch.

## Four evaluation uses (always mention)

1. **Mac vs internet?** Need simultaneous speed/RPM/ping **and** RAM/swap → A or B. C alone cannot prove the correlation.
2. **When does it degrade?** Need timestamps over days → A/B logs. C only if user watches.
3. **Who causes stall?** Per-app bandwidth/connections → C best; A/B give RAM tops and coarse sockets; B bandwhich optional.
4. **Where on the path?** Gateway vs ISP hops → B (mtr) best; A rough split gateway vs 1.1.1.1; C almost none.

## Default package
1. Start **A** (agent-driven).
2. **C** ad hoc when user feels slowness now.
3. Add **B** if after 2–3 days path/ISP still ambiguous or GB/day needed.

## A log recipe
- Path: `~/Logs/net-health/YYYY-MM-DD.jsonl`
- Interval: 15–30 min (networkQuality is heavy — not every minute)
- Fields: ts, networkQuality JSON, ping_gw, ping_wan, wifi snap, load, swap, top_n rss/cpu, conn_counts
- End: medians, p95 latency, RPM trend, swap peaks, co-occurrence with top apps

## Install notes
- brew tools usable immediately; no macOS reboot.
- Confirm before `brew install` and before enabling sudo services.
- bandwhich/mtr often need root for full visibility.
