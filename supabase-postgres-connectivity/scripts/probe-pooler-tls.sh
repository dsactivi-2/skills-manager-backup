#!/usr/bin/env bash
# Probe Supabase shared-pooler Postgres TLS (no password).
# Usage: probe-pooler-tls.sh [host] [port] [optional-ca.pem]
set -euo pipefail

HOST="${1:-aws-1-eu-west-1.pooler.supabase.com}"
PORT="${2:-5432}"
CA="${3:-}"

if [[ -x /opt/homebrew/opt/openssl@3/bin/openssl ]]; then
  OPENSSL=/opt/homebrew/opt/openssl@3/bin/openssl
elif [[ -x /opt/homebrew/bin/openssl ]]; then
  OPENSSL=/opt/homebrew/bin/openssl
else
  echo "Need Homebrew OpenSSL 3 (LibreSSL has no -starttls postgres)" >&2
  exit 2
fi

echo "openssl=$OPENSSL host=$HOST port=$PORT"
"$OPENSSL" version

extra=()
if [[ -n "$CA" ]]; then
  extra+=(-CAfile "$CA")
  echo "CAfile=$CA"
fi

echo | "$OPENSSL" s_client -starttls postgres \
  -connect "${HOST}:${PORT}" -servername "$HOST" \
  -showcerts "${extra[@]}" 2>&1 \
  | awk '/s:|i:|Verify return|depth=|Verification|subject=|issuer=|Protocol:|Cipher is/'
