#!/usr/bin/env bash
# Install open-plugin skill trees into Hermes default + all profiles via symlinks.
# Usage:
#   hermes-open-plugin-to-profiles.sh owner/repo [--category NAME] [--skip-npx] [--dry-run]
# Example:
#   hermes-open-plugin-to-profiles.sh vercel/vercel-plugin
#   hermes-open-plugin-to-profiles.sh vercel/vercel-plugin --category vercel --skip-npx
set -euo pipefail

IDENT="${1:-}"
shift || true
CATEGORY=""
SKIP_NPX=0
DRY_RUN=0

while [[ $# -gt 0 ]]; do
  case "$1" in
    --category) CATEGORY="${2:-}"; shift 2 ;;
    --skip-npx) SKIP_NPX=1; shift ;;
    --dry-run) DRY_RUN=1; shift ;;
    -h|--help)
      sed -n '2,8p' "$0"
      exit 0
      ;;
    *) echo "Unknown arg: $1" >&2; exit 2 ;;
  esac
done

if [[ -z "$IDENT" ]]; then
  echo "Usage: $0 owner/repo [--category NAME] [--skip-npx] [--dry-run]" >&2
  exit 2
fi

REPO_NAME="${IDENT##*/}"
CATEGORY="${CATEGORY:-$REPO_NAME}"
# strip -plugin suffix for nicer category when defaulted from repo name
if [[ "$CATEGORY" == "vercel-plugin" ]]; then
  CATEGORY=vercel
fi

HERMES_HOME="${HERMES_HOME:-$HOME/.hermes}"
SHARED="$HERMES_HOME/plugins/$REPO_NAME"
CLONE_URL="https://github.com/${IDENT}.git"

run() {
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY: $*"
  else
    "$@"
  fi
}

if [[ "$SKIP_NPX" -eq 0 ]]; then
  if command -v npx >/dev/null 2>&1; then
    echo "== npx plugins add $IDENT (non-Hermes agents) =="
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "DRY: npx plugins add $IDENT -y --scope user"
    else
      npx plugins add "$IDENT" -y --scope user || echo "WARN: npx plugins partial failure (e.g. Grok) — continuing"
    fi
  else
    echo "WARN: npx not found; skipping open-plugin agent targets"
  fi
fi

echo "== shared clone: $SHARED =="
if [[ -d "$SHARED/.git" ]]; then
  run git -C "$SHARED" pull --ff-only || true
elif [[ -d "$SHARED" ]]; then
  echo "Shared dir exists without .git — reusing as-is"
else
  run mkdir -p "$(dirname "$SHARED")"
  run git clone --depth 1 "$CLONE_URL" "$SHARED"
fi

SKILLS_SRC="$SHARED/skills"
if [[ ! -d "$SKILLS_SRC" ]]; then
  echo "ERROR: no skills/ under $SHARED — not an open-plugin skill tree?" >&2
  exit 1
fi

link_into() {
  local skills_root="$1"
  local label="$2"
  local cat_dir="$skills_root/$CATEGORY"
  local n=0
  if [[ "$DRY_RUN" -eq 1 ]]; then
    echo "DRY: link skills into $cat_dir ($label)"
    return
  fi
  mkdir -p "$cat_dir"
  for d in "$SKILLS_SRC"/*; do
    [[ -d "$d" ]] || continue
    local name dest
    name=$(basename "$d")
    dest="$cat_dir/$name"
    rm -rf "$dest"
    ln -s "$d" "$dest"
    n=$((n + 1))
  done
  echo "$label: $n skills -> $cat_dir"
}

echo "== Hermes skills symlinks (category=$CATEGORY) =="
link_into "$HERMES_HOME/skills" "default"

if [[ -d "$HERMES_HOME/profiles" ]]; then
  for p in "$HERMES_HOME/profiles"/*/; do
    [[ -d "$p" ]] || continue
    name=$(basename "$p")
    link_into "$p/skills" "$name"
    if [[ "$DRY_RUN" -eq 1 ]]; then
      echo "DRY: plugin symlink $p/plugins/$REPO_NAME"
    else
      mkdir -p "$p/plugins"
      ln -sfn "$SHARED" "$p/plugins/$REPO_NAME"
    fi
  done
fi

echo "== done =="
echo "Verify: hermes skills list | rg '$CATEGORY'"
echo "Note: hermes plugins enable may still fail without plugin.yaml — skills are the SoT."
