#!/usr/bin/env bash
# OpenCodex launcher that never uses the live Codex.app home.
set -euo pipefail

APP_CODEX_HOME="${HOME}/.codex"
ISOLATED_CODEX_HOME="${HOME}/.opencodex/codex-home"
REAL_OCX="${HOME}/.local/lib/node_modules/@bitkyc08/opencodex/bin/ocx.mjs"

export OPENCODEX_HOME="${OPENCODEX_HOME:-${HOME}/.opencodex}"

resolved_codex_home="${CODEX_HOME:-${APP_CODEX_HOME}}"
if [ "${resolved_codex_home}" = "${APP_CODEX_HOME}" ]; then
  export CODEX_HOME="${ISOLATED_CODEX_HOME}"
fi

mkdir -p "${OPENCODEX_HOME}" "${CODEX_HOME}"

if [ ! -f "${REAL_OCX}" ]; then
  echo "opencodex binary missing: ${REAL_OCX}" >&2
  echo "Reinstall with: npm install -g @bitkyc08/opencodex" >&2
  exit 1
fi

exec /usr/bin/env node "${REAL_OCX}" "$@"
