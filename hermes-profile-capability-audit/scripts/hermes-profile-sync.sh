#!/usr/bin/env bash
# Selective sync of Hermes skills / MCP server blocks between profiles.
# Default is DRY-RUN. Pass --apply to write.
#
# There is NO official global shared skills store across profiles (by design).
# This script is the supported practical pattern: canonical source profile → targets.
#
# Usage:
#   hermes-profile-sync.sh status
#   hermes-profile-sync.sh skills list-diff --from default --to barbares
#   hermes-profile-sync.sh skills copy --from default --to barbares --name hermes-profile-capability-audit
#   hermes-profile-sync.sh skills copy --from default --to barbares --name colab-operator --apply
#   hermes-profile-sync.sh skills copy-many --from default --to barbares --names a,b --apply
#   hermes-profile-sync.sh mcp list-diff --from default --to barbares
#   hermes-profile-sync.sh mcp copy --from default --to barbares --name dograh --apply
#   hermes-profile-sync.sh inventory [profile...]
set -euo pipefail

HERMES_ROOT="${HERMES_HOME_ROOT:-$HOME/.hermes}"
APPLY=0
FROM="default"
TO=""
NAME=""
NAMES=""
CMD=""
SUB=""

die() { echo "ERROR: $*" >&2; exit 1; }

profile_home() {
  local n="$1"
  if [[ "$n" == "default" ]]; then echo "$HERMES_ROOT"
  else echo "$HERMES_ROOT/profiles/$n"
  fi
}

skills_dir() { echo "$(profile_home "$1")/skills"; }
config_path() { echo "$(profile_home "$1")/config.yaml"; }

find_skill_path() {
  local root="$1" skill="$2"
  if [[ -f "$root/$skill/SKILL.md" ]]; then echo "$root/$skill"; return 0; fi
  local hit
  hit=$(find "$root" -type f -name SKILL.md \
    ! -path '*/.archive/*' ! -path '*/.hub/*' ! -path '*/quarantine/*' \
    2>/dev/null | while read -r f; do
      d=$(dirname "$f")
      base=$(basename "$d")
      if [[ "$base" == "$skill" ]]; then echo "$d"; break; fi
    done)
  [[ -n "${hit:-}" ]] && { echo "$hit"; return 0; }
  return 1
}

skill_relative() {
  local root="$1" abs="$2"
  python3 - "$root" "$abs" <<'PY'
import sys, os
root, abs_ = sys.argv[1], sys.argv[2]
print(os.path.relpath(abs_, root))
PY
}

list_skill_names() {
  local root; root=$(skills_dir "$1")
  [[ -d "$root" ]] || return 0
  find "$root" -name SKILL.md \
    ! -path '*/.archive/*' ! -path '*/.hub/*' ! -path '*/quarantine/*' \
    2>/dev/null | while read -r f; do basename "$(dirname "$f")"; done | sort -u
}

backup_file() {
  local f="$1"
  [[ -f "$f" ]] || return 0
  local bdir="$HERMES_ROOT/backups"
  mkdir -p "$bdir"
  local ts; ts=$(date +%Y%m%d-%H%M%S)
  cp -p "$f" "$bdir/$(basename "$f").${ts}.bak"
  echo "$bdir/$(basename "$f").${ts}.bak"
}

copy_skill() {
  local from="$1" to="$2" skill="$3"
  local sroot droot src dst rel
  sroot=$(skills_dir "$from")
  droot=$(skills_dir "$to")
  src=$(find_skill_path "$sroot" "$skill") || die "skill '$skill' not found in $from ($sroot)"
  rel=$(skill_relative "$sroot" "$src")
  dst="$droot/$rel"
  echo "skill copy: $from → $to"
  echo "  src: $src"
  echo "  dst: $dst"
  if [[ $APPLY -eq 0 ]]; then
    echo "  DRY-RUN (pass --apply to write)"
    return 0
  fi
  mkdir -p "$(dirname "$dst")"
  rsync -a --delete "$src/" "$dst/"
  echo "  OK wrote $dst"
}

mcp_names() {
  local cfg; cfg=$(config_path "$1")
  [[ -f "$cfg" ]] || return 0
  python3 - "$cfg" <<'PY'
import sys, yaml
from pathlib import Path
cfg = yaml.safe_load(Path(sys.argv[1]).read_text()) or {}
for k in (cfg.get("mcp_servers") or {}):
    print(k)
PY
}

mcp_copy() {
  local from="$1" to="$2" mcp="$3"
  local sc dc
  sc=$(config_path "$from")
  dc=$(config_path "$to")
  [[ -f "$sc" ]] || die "missing $sc"
  [[ -f "$dc" ]] || die "missing $dc"
  echo "mcp copy: $mcp  $from → $to"
  if [[ $APPLY -eq 0 ]]; then
    python3 - "$sc" "$dc" "$mcp" <<'PY'
import sys, yaml
from pathlib import Path
src = yaml.safe_load(Path(sys.argv[1]).read_text()) or {}
dst = yaml.safe_load(Path(sys.argv[2]).read_text()) or {}
name = sys.argv[3]
sm = (src.get("mcp_servers") or {})
if name not in sm:
    raise SystemExit(f"ERROR: mcp '{name}' not in source")
print("  would set mcp_servers."+name+":")
print(yaml.safe_dump({name: sm[name]}, default_flow_style=False, allow_unicode=True).rstrip())
print("  DRY-RUN (pass --apply to write)")
PY
    return 0
  fi
  local bak; bak=$(backup_file "$dc")
  echo "  backup: $bak"
  python3 - "$sc" "$dc" "$mcp" <<'PY'
import sys, yaml
from pathlib import Path
src_path, dst_path, name = sys.argv[1], sys.argv[2], sys.argv[3]
src = yaml.safe_load(Path(src_path).read_text()) or {}
dst = yaml.safe_load(Path(dst_path).read_text()) or {}
sm = src.get("mcp_servers") or {}
if name not in sm:
    raise SystemExit(f"ERROR: mcp '{name}' not in source")
dst.setdefault("mcp_servers", {})[name] = sm[name]
Path(dst_path).write_text(yaml.safe_dump(dst, sort_keys=False, allow_unicode=True))
print(f"  OK wrote mcp_servers.{name} into {dst_path}")
print("  NOTE: restart session / gateway for MCP reload; ensure target .env has required keys.")
PY
}

skills_diff() {
  local from="$1" to="$2"
  local tmpa tmpb
  tmpa=$(mktemp); tmpb=$(mktemp)
  list_skill_names "$from" >"$tmpa"
  list_skill_names "$to" >"$tmpb"
  echo "Only in $from (missing on $to):"
  comm -23 "$tmpa" "$tmpb" | sed 's/^/  - /' || true
  echo "Only in $to (extra vs $from):"
  comm -13 "$tmpa" "$tmpb" | sed 's/^/  - /' || true
  echo "Shared:"
  comm -12 "$tmpa" "$tmpb" | wc -l | awk '{print "  count="$1}'
  rm -f "$tmpa" "$tmpb"
}

mcp_diff() {
  local from="$1" to="$2"
  local tmpa tmpb
  tmpa=$(mktemp); tmpb=$(mktemp)
  mcp_names "$from" | sort >"$tmpa"
  mcp_names "$to" | sort >"$tmpb"
  echo "MCP only in $from:"
  comm -23 "$tmpa" "$tmpb" | sed 's/^/  - /' || true
  echo "MCP only in $to:"
  comm -13 "$tmpa" "$tmpb" | sed 's/^/  - /' || true
  echo "MCP shared:"
  comm -12 "$tmpa" "$tmpb" | sed 's/^/  - /' || true
  rm -f "$tmpa" "$tmpb"
}

usage() {
  sed -n '2,18p' "$0"
}

ARGS=()
while [[ $# -gt 0 ]]; do
  case "$1" in
    --apply) APPLY=1; shift ;;
    --from) FROM="${2:-}"; shift 2 ;;
    --to) TO="${2:-}"; shift 2 ;;
    --name) NAME="${2:-}"; shift 2 ;;
    --names) NAMES="${2:-}"; shift 2 ;;
    -h|--help) usage; exit 0 ;;
    *) ARGS+=("$1"); shift ;;
  esac
done

CMD="${ARGS[0]:-}"
SUB="${ARGS[1]:-}"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"

case "$CMD" in
  status)
    hermes profile list
    echo
    echo "default skills home: $(skills_dir default)"
    echo "No global shared store — use this script or profile --clone / skills snapshot."
    ;;
  inventory)
    exec "$SCRIPT_DIR/hermes-profile-inventory.sh" "${ARGS[@]:1}"
    ;;
  skills)
    case "$SUB" in
      list-diff)
        [[ -n "$TO" ]] || die "--to required"
        skills_diff "$FROM" "$TO"
        ;;
      copy)
        [[ -n "$TO" && -n "$NAME" ]] || die "--to and --name required"
        copy_skill "$FROM" "$TO" "$NAME"
        ;;
      copy-many)
        [[ -n "$TO" && -n "$NAMES" ]] || die "--to and --names required"
        IFS=',' read -ra arr <<<"$NAMES"
        for s in "${arr[@]}"; do
          s=$(echo "$s" | xargs)
          [[ -n "$s" ]] || continue
          copy_skill "$FROM" "$TO" "$s"
        done
        ;;
      *) die "skills subcommands: list-diff | copy | copy-many" ;;
    esac
    ;;
  mcp)
    case "$SUB" in
      list-diff)
        [[ -n "$TO" ]] || die "--to required"
        mcp_diff "$FROM" "$TO"
        ;;
      copy)
        [[ -n "$TO" && -n "$NAME" ]] || die "--to and --name required"
        mcp_copy "$FROM" "$TO" "$NAME"
        ;;
      *) die "mcp subcommands: list-diff | copy" ;;
    esac
    ;;
  *)
    usage
    exit 1
    ;;
esac
