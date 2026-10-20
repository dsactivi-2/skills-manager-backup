#!/usr/bin/env bash
# Live inventory of Hermes profile capabilities (skills / MCP / tools / paths).
# Usage:
#   hermes-profile-inventory.sh                 # all profiles + default
#   hermes-profile-inventory.sh barbares       # one profile
#   hermes-profile-inventory.sh --md out.md    # write markdown report
set -euo pipefail

HERMES_HOME="${HERMES_HOME_ROOT:-$HOME/.hermes}"
OUT=""
TARGETS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --md) OUT="${2:-}"; shift 2 ;;
    -h|--help)
      sed -n '2,6p' "$0"; exit 0 ;;
    *) TARGETS+=("$1"); shift ;;
  esac
done

profiles_all() {
  echo "default"
  if [[ -d "$HERMES_HOME/profiles" ]]; then
    ls -1 "$HERMES_HOME/profiles" 2>/dev/null | sort
  fi
}

resolve_home() {
  local name="$1"
  if [[ "$name" == "default" ]]; then
    echo "$HERMES_HOME"
  else
    echo "$HERMES_HOME/profiles/$name"
  fi
}

count_skill_mds() {
  local skills_dir="$1"
  [[ -d "$skills_dir" ]] || { echo 0; return; }
  find "$skills_dir" -name SKILL.md \
    ! -path '*/.archive/*' ! -path '*/.hub/*' ! -path '*/.curator*' \
    ! -path '*/quarantine/*' 2>/dev/null | wc -l | tr -d ' '
}

manifest_lines() {
  local f="$1/.bundled_manifest"
  [[ -f "$f" ]] || { echo 0; return; }
  grep -cve '^[[:space:]]*$' "$f" 2>/dev/null || echo 0
}

mcp_list_cli() {
  local name="$1"
  if [[ "$name" == "default" ]]; then
    hermes mcp list 2>/dev/null || true
  else
    hermes -p "$name" mcp list 2>/dev/null || true
  fi
}

skills_summary_cli() {
  local name="$1"
  if [[ "$name" == "default" ]]; then
    hermes skills list 2>/dev/null | tail -3 || true
  else
    hermes -p "$name" skills list 2>/dev/null | tail -3 || true
  fi
}

tools_enabled_cli() {
  local name="$1"
  local out
  if [[ "$name" == "default" ]]; then
    out=$(hermes tools list 2>/dev/null || true)
  else
    out=$(hermes -p "$name" tools list 2>/dev/null || true)
  fi
  TOOLS_OUT="$out" python3 - <<'PY'
import os, re
text = os.environ.get("TOOLS_OUT", "")
en, dis = [], []
for line in text.splitlines():
    s = line.strip()
    if "all tools enabled" in s:
        continue
    m = re.search(r"\benabled\s+(\S+)", s)
    if m and "disabled" not in s[:20]:
        name = m.group(1)
        if name not in ("toolsets", "true", "false"):
            en.append(name)
    m = re.search(r"\bdisabled\s+(\S+)", s)
    if m:
        dis.append(m.group(1))

def uniq(xs):
    seen=set(); out=[]
    for x in xs:
        if x not in seen:
            seen.add(x); out.append(x)
    return out
en, dis = uniq(en), uniq(dis)
print(f"enabled={len(en)} disabled={len(dis)}")
for n in en:
    print(f"  + {n}")
for n in dis:
    print(f"  - {n}")
PY
}

yaml_mcp_names() {
  local cfg="$1"
  [[ -f "$cfg" ]] || return 0
  python3 - "$cfg" <<'PY'
import sys, yaml
from pathlib import Path
cfg = yaml.safe_load(Path(sys.argv[1]).read_text()) or {}
mcps = cfg.get("mcp_servers") or {}
for k, v in mcps.items():
    en = True
    if isinstance(v, dict):
        en = v.get("enabled", True)
    print(f"{k}\tenabled={en}")
PY
}

inventory_one() {
  local name="$1"
  local home; home=$(resolve_home "$name")
  if [[ ! -d "$home" ]]; then
    echo "ERROR: profile path missing: $home" >&2
    return 1
  fi

  local skills_dir="$home/skills"
  local cfg="$home/config.yaml"
  local skill_md man show_skills
  skill_md=$(count_skill_mds "$skills_dir")
  man=$(manifest_lines "$skills_dir")
  if [[ "$name" == "default" ]]; then
    show_skills=$(hermes profile show default 2>/dev/null | awk '/^Skills:/{print $2; exit}')
  else
    show_skills=$(hermes profile show "$name" 2>/dev/null | awk '/^Skills:/{print $2; exit}')
  fi

  cat <<EOF

## Profile: $name
- Path: \`$home\`
- config: \`$cfg\`
- skills dir: \`$skills_dir\`
- Skills (profile show): ${show_skills:-?}
- Skills (SKILL.md count, excl. hub/archive): $skill_md
- Skills (.bundled_manifest lines = bundled only): $man
- Skills CLI summary:
$(skills_summary_cli "$name" | sed 's/^/  /')
- MCP (config.yaml):
$(yaml_mcp_names "$cfg" | sed 's/^/  - /' || echo "  (none)")
- MCP (CLI):
$(mcp_list_cli "$name" | sed 's/^/  /')
- Toolsets (CLI counts): $(tools_enabled_cli "$name" | head -1)
$(tools_enabled_cli "$name" | tail -n +2)
- .env exists: $([[ -f "$home/.env" ]] && echo yes || echo no)
- SOUL.md exists: $([[ -f "$home/SOUL.md" ]] && echo yes || echo no)

### Authoritative notes
- \`hermes skills list\` / SKILL.md count = real installed surface for the agent.
- \`.bundled_manifest\` counts **bundled** skills only (not hub/local/agent).
- Global \`skills_list\` tool ≠ this profile.
EOF
}

main() {
  local list=()
  if [[ ${#TARGETS[@]} -eq 0 ]]; then
    while IFS= read -r p; do list+=("$p"); done < <(profiles_all)
  else
    list=("${TARGETS[@]}")
  fi

  local report
  report=$(cat <<EOF
# Hermes Profile Capability Inventory
Generated: $(date -u +%Y-%m-%dT%H:%M:%SZ)
Host: $(hostname)
HERMES_HOME root: $HERMES_HOME

EOF
)
  for p in "${list[@]}"; do
    report+="$(inventory_one "$p")"
    report+=$'\n'
  done

  if [[ -n "$OUT" ]]; then
    printf '%s\n' "$report" >"$OUT"
    echo "Wrote $OUT"
  else
    printf '%s\n' "$report"
  fi
}

main
