# Metric meanings (plain language + attribution)

## networkQuality
- **Downlink capacity**: how fast data can come *in* (Mbps). High ≠ "feels fast" if RAM/swap or uplink is bad.
- **Uplink capacity**: how fast data can go *out*. Calls, sync, backups, many APIs need this. Asymmetric plans (e.g. ~300 down / ~20 up) are common.
- **Idle latency**: ping-like delay when the link is quiet. OK idle can still feel bad under load.
- **Responsiveness / RPM under load**: how quickly small requests still complete *while* the link is busy. Medium/Low → UI and browsing feel sticky during real work even if headline Mbps look fine.
- **RPM**: round-trips per minute; higher is better. Pair with latency ms in explanations.

## Wi-Fi (system_profiler SPAirPortDataType)
- **Signal (RSSI)**: closer to 0 is stronger. Roughly: ≥ −60 strong, −70 usable, < −80 weak.
- **Noise**: more negative is quieter. **SNR ≈ signal − noise** (e.g. −49 and −97 → ~48 dB = excellent).
- **Channel / width / PHY (ax etc.) / MCS / tx rate**: confirm band (5/6 GHz vs crowded 2.4) and that the Mac is not stuck on a weak link rate.
- Strong Wi-Fi + bad experience → look at Mac load, uplink, VPN, ISP path — not "buy a new router" first.

## Ping / path
- **Gateway only bad**: home router / local Wi-Fi / buffer on LAN.
- **Gateway good, 1.1.1.1 bad**: beyond the router (ISP/path). Jitter spikes matter as much as averages.
- **0% loss** with high latency under load still feels broken (queueing), especially with saturated upload.
- **traceroute/mtr**: first public hop after gateway starts ISP domain; recurring loss on one hop is actionable evidence.

## DNS
- `scutil --dns` order: Tailscale MagicDNS (`100.100.100.100`) often precedes 1.1.1.1/8.8.8.8 when TS is up.
- Compare `dig +stats @1.1.1.1` vs default resolver. Slow default only → VPN/DNS path, not "whole internet dead".

## Mac memory (the usual fake-network culprit)
- **RAM full + swap used (many GB)**: macOS pages to SSD. Tabs, clicks, and "loading" stutter; users report "internet slow".
- Always print `sysctl vm.swapusage` next to RSS tops. Multi-day uptime + huge swap → reboot is a valid diagnostic step.
- **Load high, CPU idle high**: processes waiting (I/O, memory), not pure CPU burn.
- Group top consumers by app (Safari/WebKit tabs, Chrome, local AI llama/Ollama/LM Studio, agent Node/Python stacks, multiple chat apps).

## VPN / overlays
- Tailscale, ProtonVPN, corporate VPN add path and DNS complexity. Attribution rule: one retest with VPN disconnected before ISP blame.
- Historical interface byte counters (netstat -I en0 -b) show volume since boot, not instantaneous guilt.

## Quick verdict templates (DE)
- Wi-Fi stark, DL hoch, Swap voll → "Mac-Speicher, nicht Funk."
- DL hoch, UL niedrig, RPM medium → "Leitung einseitig + unter Last träge."
- Beides → "Mac und Leitung; erst RAM, dann Upload/Last."
