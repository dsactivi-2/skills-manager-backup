#!/usr/bin/env bash
# Host-wide Hermes instance + profile inventory (run ON the target host).
# Usage:
#   bash hermes-remote-instance-inventory.sh
#   ssh myhermi 'bash -s' < hermes-remote-instance-inventory.sh
set -u

echo "=== HOST ==="
hostname 2>/dev/null || true
date -u +"%Y-%m-%dT%H:%M:%SZ" 2>/dev/null || true
echo "public_ip=$(curl -4 -s --max-time 5 ifconfig.me 2>/dev/null || true)"
ip -4 -br addr show scope global 2>/dev/null || true
echo

echo "=== BINARY ==="
command -v hermes 2>/dev/null || true
type -a hermes 2>/dev/null || true
hermes version 2>/dev/null || hermes --version 2>/dev/null || true
echo

echo "=== STICKY / ACTIVE ==="
ls -la "${HOME}/.hermes/active_profile" 2>/dev/null || echo "(no active_profile → default)"
cat "${HOME}/.hermes/active_profile" 2>/dev/null || true
hermes profile 2>/dev/null || true
echo
hermes profile list 2>/dev/null || true
echo

echo "=== WRAPPERS (~/.local/bin) ==="
ls -la "${HOME}/.local/bin" 2>/dev/null | rg -i 'hermes|agent-|creative|dev-op|dograh|secret|orchestr|voice|mlops|research|n8n|prompting|ki-voice|xai-' || true
echo

echo "=== PROCESSES ==="
ps auxww 2>/dev/null | rg -i '[h]ermes' || echo "(none)"
echo

echo "=== SYSTEMD ==="
systemctl list-units --type=service --all 2>/dev/null | rg -i hermes || echo "(none)"
echo

echo "=== DOCKER (hermes-related) ==="
if command -v docker >/dev/null 2>&1; then
  docker ps -a --format 'table {{.Names}}\t{{.Image}}\t{{.Status}}' 2>/dev/null | rg -i 'hermes|nous' || echo "(none)"
else
  echo "docker n/a"
fi
echo

echo "=== HOMES / PROFILES ==="
for base in "${HOME}/.hermes"; do
  [ -d "$base" ] || continue
  echo "HERMES_HOME=$base size=$(du -sh "$base" 2>/dev/null | awk '{print $1}')"
  [ -f "$base/config.yaml" ] && echo "  config.yaml=yes"
  printf '%-28s %-12s %-8s %s\n' PROFILE SIZE CONFIG PATH
  printf '%-28s %-12s %-8s %s\n' default "$(du -sh "$base" 2>/dev/null | awk '{print $1}')" "$([ -f "$base/config.yaml" ] && echo yes || echo no)" "$base"
  if [ -d "$base/profiles" ]; then
    while IFS= read -r pdir; do
      [ -d "$pdir" ] || continue
      pname=$(basename "$pdir")
      psz=$(du -sh "$pdir" 2>/dev/null | awk '{print $1}')
      pcfg=no; [ -f "$pdir/config.yaml" ] && pcfg=yes
      printf '%-28s %-12s %-8s %s\n' "$pname" "$psz" "$pcfg" "$pdir"
    done < <(find "$base/profiles" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | sort)
  fi
done
echo

echo "=== CANDIDATE PATHS (stubs) ==="
find "${HOME}" /opt /srv /var/lib -maxdepth 4 \( -type d -name '.hermes' -o -type d -name 'hermes' \) 2>/dev/null | sort -u || true
echo
echo "DONE"
