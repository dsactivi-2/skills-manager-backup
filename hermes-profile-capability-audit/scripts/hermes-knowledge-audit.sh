#!/usr/bin/env bash
# Read-only Hermes knowledge-layout audit. No writes.
# Usage: bash hermes-knowledge-audit.sh
#    or: ssh <host> 'bash -s' < scripts/hermes-knowledge-audit.sh
set -euo pipefail

HOME_DIR="${HERMES_HOME:-$HOME/.hermes}"
printf '=== HERMES KNOWLEDGE AUDIT ===\n'
printf 'host=%s user=%s date=%s\n' "$(hostname -s 2>/dev/null || hostname)" "$(id -un)" "$(date -Iseconds)"
printf 'HERMES_HOME=%s\n\n' "$HOME_DIR"

hr() { printf -- '--- %s ---\n' "$1"; }

exists() {
  local p="$1"
  if [[ -e "$p" ]]; then
    printf 'EXISTS  %s  bytes=%s lines=%s\n' "$p" "$(wc -c <"$p" | tr -d ' ')" "$(wc -l <"$p" | tr -d ' ')"
  else
    printf 'MISSING %s\n' "$p"
  fi
}

hr "CLI / provider"
if command -v hermes >/dev/null 2>&1; then
  hermes --version 2>/dev/null || true
  hermes config path 2>/dev/null || true
  hermes memory status 2>/dev/null || printf 'hermes memory status failed\n'
else
  printf 'hermes CLI not on PATH\n'
fi
printf '\n'

hr "Default home files"
exists "$HOME_DIR/SOUL.md"
exists "$HOME_DIR/config.yaml"
exists "$HOME_DIR/.env"
exists "$HOME_DIR/memories/USER.md"
exists "$HOME_DIR/memories/MEMORY.md"
exists "$HOME_DIR/mem0.json"
exists "$HOME_DIR/honcho.json"
exists "$HOME_DIR/state.db"
printf '\n'

hr "mem0.json (no secrets)"
if [[ -f "$HOME_DIR/mem0.json" ]]; then
  python3 - <<'PY' "$HOME_DIR/mem0.json"
import json, sys
d = json.load(open(sys.argv[1], encoding="utf-8"))
for k in ("mode", "user_id", "agent_id", "rerank", "host"):
    if k in d:
        print(f"{k}={d.get(k)!r}")
print("keys=", sorted(d.keys()))
PY
fi
printf '\n'

hr "Profiles"
command -v hermes >/dev/null 2>&1 && hermes profile list 2>/dev/null || true
PROF_ROOT="$HOME_DIR/profiles"
if [[ -d "$PROF_ROOT" ]]; then
  for d in "$PROF_ROOT"/*/; do
    [[ -d "$d" ]] || continue
    printf 'PROFILE %s\n' "$(basename "$d")"
    exists "${d}SOUL.md"
    exists "${d}memories/USER.md"
    exists "${d}memories/MEMORY.md"
    exists "${d}mem0.json"
  done
else
  printf 'no profiles/ directory\n'
fi
printf '\n'

hr "Git projects (depth 3) AGENTS.md"
find "$HOME" -maxdepth 3 -type d -name .git 2>/dev/null | while read -r gitdir; do
  root=$(dirname "$gitdir")
  case "$root" in */.hermes/*|*/node_modules/*|*/.cache/*) continue ;; esac
  agents=no; hermesmd=no; override=no
  [[ -f "$root/AGENTS.md" ]] && agents=yes
  [[ -f "$root/.hermes.md" || -f "$root/HERMES.md" ]] && hermesmd=yes
  [[ -f "$root/AGENTS.override.md" ]] && override=yes
  printf 'REPO %s  AGENTS.md=%s  .hermes.md=%s  override=%s\n' "$root" "$agents" "$hermesmd" "$override"
done
printf '\n'

hr "Stray AGENTS.md (not global)"
for p in "$HOME/AGENTS.md" "/root/AGENTS.md" "$HOME_DIR/AGENTS.md"; do
  [[ -f "$p" ]] && printf 'STRAY %s\n' "$p"
done

printf '=== END AUDIT ===\n'
