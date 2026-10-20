#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'USAGE'
GOno PBX telephony preflight (read-only)

Usage:
  gonopbx_telephony_preflight.sh [options]

Options:
  --root PATH              GOno PBX deployment directory if known.
  --asterisk-container N   Asterisk container name. Default: pbx_asterisk.
  --backend-container N    Backend container name. Default: pbx_backend.
  --infobip-sbc HOST       Optional Infobip SBC FQDN/IP to resolve/check.
  --ari-url URL            Optional ARI URL to check with an HTTP HEAD request.
  --report-dir PATH        Directory for timestamped report. Default: ./reports.
  --help                   Show this help.

Safety:
  This script is read-only. It does not print secrets, decode credentials, edit files,
  restart services, reload Asterisk, or modify trunks/routes.
USAGE
}

ROOT_PATH=""
ASTERISK_CONTAINER="pbx_asterisk"
BACKEND_CONTAINER="pbx_backend"
INFOBIP_SBC=""
ARI_URL=""
REPORT_DIR="./reports"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --root)
      ROOT_PATH="${2:-}"
      shift 2
      ;;
    --asterisk-container)
      ASTERISK_CONTAINER="${2:-}"
      shift 2
      ;;
    --backend-container)
      BACKEND_CONTAINER="${2:-}"
      shift 2
      ;;
    --infobip-sbc)
      INFOBIP_SBC="${2:-}"
      shift 2
      ;;
    --ari-url)
      ARI_URL="${2:-}"
      shift 2
      ;;
    --report-dir)
      REPORT_DIR="${2:-}"
      shift 2
      ;;
    --help|-h)
      usage
      exit 0
      ;;
    *)
      printf 'Unknown option: %s\n' "$1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

STAMP="$(date -u +%Y%m%dT%H%M%SZ)"
mkdir -p "$REPORT_DIR"
REPORT="$REPORT_DIR/gonopbx-telephony-preflight-$STAMP.md"
LOG="$REPORT_DIR/gonopbx-telephony-preflight-$STAMP.log"

pass_count=0
warn_count=0
fail_count=0

redact() {
  sed -E 's/(password|secret|token|key|auth|credential)([[:space:]_:-]*)([^[:space:],;]+)/\1\2[REDACTED]/Ig'
}

log() {
  printf '%s %s\n' "$(date -u +%Y-%m-%dT%H:%M:%SZ)" "$*" | redact >>"$LOG"
}

emit() {
  local status="$1"
  local check="$2"
  local detail="$3"

  case "$status" in
    PASS) pass_count=$((pass_count + 1)) ;;
    WARN) warn_count=$((warn_count + 1)) ;;
    FAIL) fail_count=$((fail_count + 1)) ;;
    *) fail_count=$((fail_count + 1)); status="FAIL" ;;
  esac

  printf '| %s | %s | %s |\n' "$status" "$check" "$detail" >>"$REPORT"
  log "$status $check - $detail"
}

have_cmd() {
  command -v "$1" >/dev/null 2>&1
}

docker_exec_asterisk() {
  local command_text="$1"
  docker exec "$ASTERISK_CONTAINER" asterisk -rx "$command_text" 2>&1 | redact
}

{
  printf '# GOno PBX Telephony Preflight\n\n'
  printf -- '- Timestamp UTC: `%s`\n' "$STAMP"
  printf -- '- Root path: `%s`\n' "${ROOT_PATH:-not provided}"
  printf -- '- Asterisk container: `%s`\n' "$ASTERISK_CONTAINER"
  printf -- '- Backend container: `%s`\n' "$BACKEND_CONTAINER"
  printf -- '- Infobip SBC: `%s`\n' "${INFOBIP_SBC:-not provided}"
  printf -- '- ARI URL: `%s`\n\n' "${ARI_URL:-not provided}"
  printf '| Status | Check | Detail |\n'
  printf '|---|---|---|\n'
} >"$REPORT"

log "Starting read-only GOno PBX telephony preflight"

if [[ -n "$ROOT_PATH" ]]; then
  if [[ -d "$ROOT_PATH" ]]; then
    emit PASS "deployment root" "root path exists"
  else
    emit WARN "deployment root" "root path not found; continue with container-level checks"
  fi
else
  emit WARN "deployment root" "root path not provided"
fi

if have_cmd docker; then
  emit PASS "docker command" "docker is available"
else
  emit FAIL "docker command" "docker is not available; cannot inspect containers"
fi

if have_cmd docker && docker ps --format '{{.Names}}' 2>>"$LOG" | grep -qx "$ASTERISK_CONTAINER"; then
  emit PASS "asterisk container" "$ASTERISK_CONTAINER is running"
else
  emit FAIL "asterisk container" "$ASTERISK_CONTAINER is not running or not visible"
fi

if have_cmd docker && docker ps --format '{{.Names}}' 2>>"$LOG" | grep -qx "$BACKEND_CONTAINER"; then
  emit PASS "backend container" "$BACKEND_CONTAINER is running"
else
  emit WARN "backend container" "$BACKEND_CONTAINER is not running or not visible"
fi

if have_cmd docker && docker ps --format '{{.Names}}' 2>>"$LOG" | grep -qx "$ASTERISK_CONTAINER"; then
  if docker_exec_asterisk "core show version" | grep -qi '^Asterisk'; then
    emit PASS "asterisk cli" "Asterisk CLI responds"
  else
    emit FAIL "asterisk cli" "Asterisk CLI did not return a version"
  fi

  if docker_exec_asterisk "pjsip show registrations" | grep -Eqi 'Registered|Rejected|No objects found|Objects found'; then
    emit PASS "pjsip registrations" "PJSIP registration command responds; inspect report/log for status context"
  else
    emit WARN "pjsip registrations" "PJSIP registration command returned unexpected output"
  fi

  if docker_exec_asterisk "pjsip show endpoints" | grep -Eqi 'Endpoint|No objects found|Objects found'; then
    emit PASS "pjsip endpoints" "PJSIP endpoint command responds"
  else
    emit WARN "pjsip endpoints" "PJSIP endpoint command returned unexpected output"
  fi

  for module_name in res_ari.so res_http_websocket.so chan_websocket.so res_websocket_client.so; do
    if docker_exec_asterisk "module show like $module_name" | grep -qi "$module_name"; then
      emit PASS "asterisk module $module_name" "$module_name is loaded or available in module output"
    else
      emit WARN "asterisk module $module_name" "$module_name not found in module output"
    fi
  done

  if docker_exec_asterisk "http show status" | grep -qi 'Server Enabled and Bound'; then
    emit PASS "asterisk http" "Asterisk HTTP server appears enabled"
  else
    emit WARN "asterisk http" "Asterisk HTTP server is not clearly enabled"
  fi

  if docker_exec_asterisk "ari show status" | grep -qi 'enabled'; then
    emit PASS "ari status" "ARI status command reports enabled text"
  else
    emit WARN "ari status" "ARI status is not clearly enabled"
  fi
fi

if have_cmd ss; then
  if ss -lntu 2>>"$LOG" | grep -q ':5060'; then
    emit PASS "SIP listener" "local listener includes port 5060"
  else
    emit WARN "SIP listener" "no local listener on port 5060 detected"
  fi
else
  emit WARN "socket inspection" "ss command not available"
fi

if [[ -n "$INFOBIP_SBC" ]]; then
  if have_cmd getent && getent hosts "$INFOBIP_SBC" >/dev/null 2>&1; then
    emit PASS "Infobip SBC DNS" "Infobip SBC host resolves"
  elif have_cmd dig && dig +short "$INFOBIP_SBC" >/dev/null 2>&1; then
    emit PASS "Infobip SBC DNS" "Infobip SBC host resolves"
  else
    emit WARN "Infobip SBC DNS" "could not resolve Infobip SBC host from this machine"
  fi
else
  emit WARN "Infobip SBC DNS" "Infobip SBC not provided"
fi

if [[ -n "$ARI_URL" ]]; then
  if have_cmd curl; then
    if curl --head --silent --show-error --max-time 5 "$ARI_URL" >/dev/null 2>>"$LOG"; then
      emit PASS "ARI URL reachability" "ARI URL responded to HTTP HEAD"
    else
      emit WARN "ARI URL reachability" "ARI URL did not respond to HTTP HEAD from this machine"
    fi
  else
    emit WARN "ARI URL reachability" "curl command not available"
  fi
else
  emit WARN "ARI URL reachability" "ARI URL not provided"
fi

if [[ "$fail_count" -gt 0 ]]; then
  overall="FAIL"
elif [[ "$warn_count" -gt 0 ]]; then
  overall="PASS_WITH_GAPS"
else
  overall="PASS"
fi

{
  printf '\n## Summary\n\n'
  printf -- '- Overall: `%s`\n' "$overall"
  printf -- '- PASS: `%s`\n' "$pass_count"
  printf -- '- WARN: `%s`\n' "$warn_count"
  printf -- '- FAIL: `%s`\n' "$fail_count"
  printf -- '- Log: `%s`\n' "$LOG"
  printf '\n## Interpretation\n\n'
  printf 'Use this report as preflight evidence only. PASS does not apply live changes. WARN items usually mean missing user/account values or unavailable local visibility. FAIL items need investigation before changing trunks, routes, ARI, or firewall exposure.\n'
} >>"$REPORT"

log "Completed preflight with overall=$overall pass=$pass_count warn=$warn_count fail=$fail_count"
printf '%s\n' "$REPORT"
