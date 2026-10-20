#!/usr/bin/env bash
set -euo pipefail

CONFIG_FILE="${HOME}/.codex/config.toml"
DOGRAH_URL="https://api.dograh.com/api/v1/mcp/"
TIMESTAMP="$(date '+%Y-%m-%dT%H-%M-%S')"
LOG_DIR="${TMPDIR:-/tmp}/dograh-mcp-checks"
REPORT_FILE="${LOG_DIR}/check-${TIMESTAMP}.log"

mkdir -p "${LOG_DIR}"

status="PASS"

log() {
  printf '%s\n' "$1" | tee -a "${REPORT_FILE}"
}

mark_warn() {
  if [[ "${status}" == "PASS" ]]; then
    status="PASS_WITH_GAPS"
  fi
}

fail() {
  log "FAIL $1"
  log "RESULT FAIL"
  log "REPORT ${REPORT_FILE}"
  exit 1
}

pass() {
  log "PASS $1"
}

warn() {
  mark_warn
  log "WARN $1"
}

log "CHECK dograh-mcp ${TIMESTAMP}"

[[ -f "${CONFIG_FILE}" ]] || fail "config_missing ${CONFIG_FILE}"
pass "config_present ${CONFIG_FILE}"

rg -q '^\[mcp_servers\.dograh\]$' "${CONFIG_FILE}" || fail "dograh_block_missing"
pass "dograh_block_present"

rg -q "^url = \"${DOGRAH_URL//\//\\/}\"$" "${CONFIG_FILE}" || fail "dograh_url_mismatch expected=${DOGRAH_URL}"
pass "dograh_url_matches"

rg -q '^http_headers = \{ "X-API-Key" = ".+" \}$' "${CONFIG_FILE}" || fail "dograh_api_key_header_missing"
pass "dograh_header_present"

if command -v codex >/dev/null 2>&1; then
  if codex mcp list | rg -q '^dograh[[:space:]]'; then
    pass "codex_lists_dograh"
  else
    warn "codex_does_not_list_dograh_yet restart_codex_may_be_required"
  fi
else
  warn "codex_cli_missing"
fi

http_code="$(curl -sS -o /dev/null -w '%{http_code}' "${DOGRAH_URL}" || true)"
if [[ "${http_code}" == "000" ]]; then
  warn "endpoint_unreachable"
else
  pass "endpoint_reachable_http_${http_code}"
fi

log "RESULT ${status}"
log "REPORT ${REPORT_FILE}"
