#!/usr/bin/env bash
# EU Deepgram STT smoke — deepctl 0.2.25 cannot dg-listen with custom EU base_url (agent_rest).
# Usage: dg-eu-listen.sh <audio> [language=bs] [model=nova-3-general]
set -euo pipefail
FILE=${1:?audio file}
LANG=${2:-bs}
MODEL=${3:-nova-3-general}
KEY=${DEEPGRAM_API_KEY:-}
if [[ -z "$KEY" && -f "$HOME/Library/Application Support/deepctl/config.yaml" ]]; then
  KEY=$(python3 - <<'PY'
from pathlib import Path
import re
t = Path.home().joinpath("Library/Application Support/deepctl/config.yaml").read_text()
m = re.search(r"api_key:\s*(\S+)", t)
print(m.group(1) if m else "")
PY
)
fi
[[ -n "$KEY" ]] || { echo "DEEPGRAM_API_KEY missing" >&2; exit 1; }
MIME=$(file --mime-type -b "$FILE" 2>/dev/null || echo audio/wav)
curl -sS \
  -H "Authorization: Token ${KEY}" \
  -H "Content-Type: ${MIME}" \
  --data-binary @"$FILE" \
  "https://api.eu.deepgram.com/v1/listen?model=${MODEL}&language=${LANG}"
echo
