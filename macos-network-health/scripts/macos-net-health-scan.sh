#!/usr/bin/env bash
# One-shot macOS network + local health scan (no extra deps).
# Usage: bash scripts/macos-net-health-scan.sh [--quick]
# --quick skips networkQuality (faster, no link stress)
set -euo pipefail

QUICK=0
[[ "${1:-}" == "--quick" ]] && QUICK=1

section() { printf '\n===== %s =====\n' "$1"; }

section "HOST"
date
sw_vers 2>/dev/null || true
sysctl -n machdep.cpu.brand_string 2>/dev/null || true
sysctl -n hw.memsize 2>/dev/null | awk '{printf "RAM_GB %.1f\n", $1/1024/1024/1024}'
uptime

section "MEMORY"
sysctl vm.swapusage 2>/dev/null || true
memory_pressure 2>/dev/null | head -25 || true

section "ROUTE_AND_IF"
route -n get default 2>/dev/null | head -20 || true
networksetup -listallhardwareports 2>/dev/null | head -40 || true

section "WIFI"
system_profiler SPAirPortDataType 2>/dev/null | head -100 || true

section "DNS"
scutil --dns 2>/dev/null | head -50 || true

section "PING_GATEWAY"
GW=$(route -n get default 2>/dev/null | awk '/gateway:/{print $2; exit}')
if [[ -n "${GW:-}" ]]; then
  echo "gateway=$GW"
  ping -c 20 -i 0.2 "$GW" 2>&1 | tail -8
else
  echo "no_default_gateway"
fi

section "PING_WAN"
ping -c 10 -i 0.3 1.1.1.1 2>&1 | tail -8
ping -c 5 -i 0.3 8.8.8.8 2>&1 | tail -6

section "TRACEROUTE"
traceroute -n -w 2 -q 1 -m 12 1.1.1.1 2>&1 | head -20 || true

section "TOP_CPU"
ps -Ao pid,pcpu,pmem,rss,comm -r 2>/dev/null | head -20 || true

section "TOP_RSS"
ps -Ao pid,pcpu,pmem,rss,comm -m 2>/dev/null | head -20 || true

section "LSOF_CONN_COUNTS"
lsof -nP -i 2>/dev/null | awk 'NR>1{print $1}' | sort | uniq -c | sort -rn | head -20 || true

section "VPN_NC"
scutil --nc list 2>/dev/null | head -20 || true

section "APPS_HINT"
ls /Applications 2>/dev/null | egrep -i 'stats|trip|snitch|tailscale|wireguard|proton|orbstack|docker' || true

if [[ "$QUICK" -eq 0 ]]; then
  section "NETWORK_QUALITY"
  if command -v networkQuality >/dev/null 2>&1; then
    networkQuality -v 2>&1
  else
    echo "networkQuality_unavailable"
  fi
else
  section "NETWORK_QUALITY"
  echo "skipped (--quick)"
fi

section "DONE"
echo "scan_complete"
