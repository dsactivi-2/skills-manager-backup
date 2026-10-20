#!/bin/bash
# ============================================
# OLLAMA FULL DIAGNOSTIC & READ SCRIPT
# Führt ALLE Checks aus: Netzwerk, GET, POST,
# Modell-Erkennung, API-Pfade, SSL
# Nutzung: chmod +x ollama_full_check.sh
#          ./ollama_full_check.sh http://localhost:11434
# ============================================

set -uo pipefail

# --- Farbcodes ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

if [ $# -lt 1 ]; then
    echo "Usage: $0 <URL> [Port]"
    echo "Beispiel: $0 http://localhost:11434"
    exit 1
fi

URL="$1"
[ "${URL%/}" != "$URL" ] && URL="${URL%/}"  # trailing slash entfernen

# Protokoll & Host zerlegen
if [[ ! "$URL" =~ ^https?:// ]]; then URL="http://$URL"; fi
HOST=$(echo "$URL" | sed -E 's|https?://||; s|/.*||; s|:.*||')
PORT=$(echo "$URL" | sed -nE 's|.*:([0-9]+).*|\1|p')
[ -z "$PORT" ] && PORT=$([[ "$URL" == https* ]] && echo 443 || echo 80)
BASE=$(echo "$URL" | sed -E 's|(https?://[^/]+).*|\1|')

echo -e "${BLUE}╔══════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║     OLLAMA FULL DIAGNOSTIC & READ SCRIPT             ║${NC}"
echo -e "${BLUE}╚══════════════════════════════════════════════════════╝${NC}"
echo -e "Ziel: ${CYAN}$URL${NC} | Host: $HOST | Port: $PORT | Base: $BASE"
echo ""

# ============================================
# 1. DNS / Auflösung
# ============================================
echo -e "${YELLOW}[1/8] DNS Auflösung...${NC}"
IP=$(getent hosts "$HOST" 2>/dev/null | awk '{print $1}')
[ -z "$IP" ] && IP=$(timeout 2 getent ahosts "$HOST" 2>/dev/null | awk '{print $1; exit}')
[ -z "$IP" ] && IP=$(ping -c 1 -W 1 "$HOST" 2>/dev/null | sed -nE '1s/.*\((([0-9]+\.){3}[0-9]+)\).*/\1/p')
if [ -n "$IP" ]; then
    echo -e "  ${GREEN}✔${NC} $HOST → $IP"
else
    echo -e "  ${YELLOW}⚠${NC} Keine DNS-Auflösung (bei 'localhost' normal)"
fi

# ============================================
# 2. TCP Port-Check
# ============================================
echo -e "${YELLOW}[2/8] TCP Port $PORT...${NC}"
if timeout 3 bash -c "echo >/dev/tcp/$HOST/$PORT" 2>/dev/null; then
    echo -e "  ${GREEN}✔${NC} Port $PORT ist offen (Verbindung akzeptiert)"
    TCP_OK=1
else
    echo -e "  ${RED}✘${NC} Port $PORT NICHT erreichbar (Firewall/Dienst down?)"
    TCP_OK=0
fi

# ============================================
# 3. Root-URL (GET)
# ============================================
echo -e "${YELLOW}[3/8] GET $BASE/ ...${NC}"
ROOT_CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$BASE/" 2>/dev/null || echo "000")
[ "$ROOT_CODE" == "200" ] && echo -e "  ${GREEN}✔ HTTP $ROOT_CODE${NC}" || echo -e "  ${RED}✘ HTTP $ROOT_CODE${NC}"

# ============================================
# 4. GET Endpoints (Read-Only)
# ============================================
echo -e "${YELLOW}[4/8] GET Endpoints (lesend)...${NC}"
declare -a GET_EPS=("/api/tags" "/api/version" "/v1/models")
for EP in "${GET_EPS[@]}"; do
    CODE=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$BASE$EP" 2>/dev/null || echo "000")
    if [ "$CODE" == "200" ]; then
        echo -e "  ${GREEN}✔${NC} GET $EP → HTTP $CODE"
    else
        echo -e "  ${RED}✘${NC} GET $EP → HTTP $CODE"
    fi
done

# ============================================
# 5. Modell automatisch erkennen
# ============================================
echo -e "${YELLOW}[5/8] Modell-Erkennung...${NC}"
FIRST_MODEL=$(curl -s --max-time 5 "$BASE/api/tags" 2>/dev/null | sed -nE 's/.*"name"\s*:\s*"([^"]+)".*/\1/p' | head -1)
if [ -n "$FIRST_MODEL" ]; then
    echo -e "  ${GREEN}✔${NC} Verfügbares Modell: ${CYAN}$FIRST_MODEL${NC}"
else
    FIRST_MODEL="llama3.2"
    echo -e "  ${YELLOW}⚠${NC} Kein Modell gefunden. Fallback: ${CYAN}$FIRST_MODEL${NC}"
fi

# ============================================
# 6. POST Endpoints (Write+Read)
# ============================================
echo -e "${YELLOW}[6/8] POST Endpoints (schreibend+lesend)...${NC}"

# /api/generate
GEN_PAYLOAD="{\"model\":\"$FIRST_MODEL\",\"prompt\":\"Hi\",\"stream\":false}"
GEN_RESP=$(curl -s -w "\n%{http_code}" -X POST --max-time 15 -H "Content-Type: application/json" -d "$GEN_PAYLOAD" "$BASE/api/generate" 2>/dev/null)
GEN_CODE=$(echo "$GEN_RESP" | tail -n1)
GEN_BODY=$(echo "$GEN_RESP" | sed '$d')
[ "$GEN_CODE" == "200" ] && echo -e "  ${GREEN}✔${NC} POST /api/generate → HTTP $GEN_CODE" || echo -e "  ${RED}✘${NC} POST /api/generate → HTTP $GEN_CODE"

# /api/chat
CHAT_PAYLOAD="{\"model\":\"$FIRST_MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}],\"stream\":false}"
CHAT_RESP=$(curl -s -w "\n%{http_code}" -X POST --max-time 15 -H "Content-Type: application/json" -d "$CHAT_PAYLOAD" "$BASE/api/chat" 2>/dev/null)
CHAT_CODE=$(echo "$CHAT_RESP" | tail -n1)
CHAT_BODY=$(echo "$CHAT_RESP" | sed '$d')
[ "$CHAT_CODE" == "200" ] && echo -e "  ${GREEN}✔${NC} POST /api/chat → HTTP $CHAT_CODE" || echo -e "  ${RED}✘${NC} POST /api/chat → HTTP $CHAT_CODE"

# /v1/chat/completions (OpenAI kompatibel)
OPEN_PAYLOAD="{\"model\":\"$FIRST_MODEL\",\"messages\":[{\"role\":\"user\",\"content\":\"Hello\"}]}"
OPEN_RESP=$(curl -s -w "\n%{http_code}" -X POST --max-time 15 -H "Content-Type: application/json" -d "$OPEN_PAYLOAD" "$BASE/v1/chat/completions" 2>/dev/null)
OPEN_CODE=$(echo "$OPEN_RESP" | tail -n1)
OPEN_BODY=$(echo "$OPEN_RESP" | sed '$d')
[ "$OPEN_CODE" == "200" ] && echo -e "  ${GREEN}✔${NC} POST /v1/chat/completions → HTTP $OPEN_CODE" || echo -e "  ${RED}✘${NC} POST /v1/chat/completions → HTTP $OPEN_CODE"

# ============================================
# 7. Response-Body Preview (Read Output)
# ============================================
echo -e "${YELLOW}[7/8] Response-Vorschau (erste 200 Zeichen)...${NC}"
if [ "$CHAT_CODE" == "200" ] && [ -n "$CHAT_BODY" ]; then
    PREVIEW=$(echo "$CHAT_BODY" | head -c 200)
    echo "  $PREVIEW..."
elif [ "$GEN_CODE" == "200" ] && [ -n "$GEN_BODY" ]; then
    PREVIEW=$(echo "$GEN_BODY" | head -c 200)
    echo "  $PREVIEW..."
else
    echo "  (Kein gültiger Body empfangen)"
fi

# ============================================
# 8. SSL (falls HTTPS)
# ============================================
if [[ "$BASE" == https* ]]; then
    echo -e "${YELLOW}[8/8] SSL/TLS Check...${NC}"
    SSL_OUT=$(echo | timeout 3 openssl s_client -connect "$HOST:$PORT" -servername "$HOST" 2>/dev/null)
    if echo "$SSL_OUT" | openssl x509 -noout -dates -subject &>/dev/null; then
        echo -e "  ${GREEN}✔${NC} Zertifikat gültig und lesbar"
    else
        echo -e "  ${YELLOW}⚠${NC} SSL-Handshake fehlgeschlagen (selbst-signiert?)"
    fi
else
    echo -e "${YELLOW}[8/8] SSL übersprungen (HTTP)...${NC}"
fi

# ============================================
# ZUSAMMENFASSUNG
# ============================================
echo ""
echo -e "${BLUE}══════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}              Z U S A M M E N F A S S U N G            ${NC}"
echo -e "${BLUE}══════════════════════════════════════════════════════${NC}"

ERRORS=0
if [ "$TCP_OK" -ne 1 ]; then echo -e "${RED}✘${NC} TCP-Port nicht erreichbar"; ((ERRORS++)); fi
if [ "$ROOT_CODE" != "200" ]; then echo -e "${RED}✘${NC} Root-URL gibt $ROOT_CODE"; ((ERRORS++)); fi
if [ "$GEN_CODE" != "200" ]; then echo -e "${RED}✘${NC} /api/generate gibt $GEN_CODE (erwartet: POST)"; ((ERRORS++)); fi
if [ "$CHAT_CODE" != "200" ]; then echo -e "${RED}✘${NC} /api/chat gibt $CHAT_CODE"; ((ERRORS++)); fi
if [ "$OPEN_CODE" != "200" ]; then echo -e "${RED}✘${NC} /v1/chat/completions gibt $OPEN_CODE"; ((ERRORS++)); fi

if [ $ERRORS -eq 0 ]; then
    echo -e "${GREEN}✔ ALLE CHECKS BESTANDEN${NC}"
    echo ""
    echo -e "Native API:  ${CYAN}POST $BASE/api/chat${NC}"
    echo -e "OpenAI API:  ${CYAN}POST $BASE/v1/chat/completions${NC}"
    echo -e "Model used:  ${CYAN}$FIRST_MODEL${NC}"
else
    echo ""
    echo -e "${YELLOW}Diagnose:${NC}"
    echo "  • 404 bei POST → Falscher Pfad oder Modellname '$FIRST_MODEL' existiert nicht"
    echo "  • 405 bei GET → Dieser Endpoint erlaubt nur POST"
    echo "  • 000/Timeout → Firewall, Docker-Port oder falscher Host"
    echo "  • 401/403 → Authentifizierung erforderlich (unüblich bei Ollama)"
fi
echo ""
