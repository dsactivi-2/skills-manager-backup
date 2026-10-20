#!/bin/bash
# ============================================
# ENDPOINT DOCTOR - HTTP 404 / Verbindungs-Fehler Diagnose
# Nutzung: chmod +x endpoint_doctor.sh
#          ./endpoint_doctor.sh http://localhost:11434/api/generate
#          ./endpoint_doctor.sh https://api.example.com/webhook
# ============================================

set -uo pipefail

# --- Farbcodes ---
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# --- Abbruch wenn keine URL ---
if [ $# -lt 1 ]; then
    echo "Usage: $0 <URL> [Port]"
    echo "Beispiele:"
    echo "  $0 http://localhost:11434"
    echo "  $0 http://192.168.1.50 8080"
    exit 1
fi

URL="$1"
MANUAL_PORT="${2:-}"

# curl checken
if ! command -v curl &>/dev/null; then
    echo -e "${RED}Fehler: curl ist nicht installiert.${NC}"
    exit 1
fi

# Protokoll normalisieren
if [[ ! "$URL" =~ ^https?:// ]]; then
    URL="http://$URL"
fi

# Bestandteile extrahieren
BASE_HOST=$(echo "$URL" | sed -E 's|https?://||; s|/.*||; s|:.*||')
URL_PATH=$(echo "$URL" | sed -E 's|https?://[^/]+||')
BASE_URL=$(echo "$URL" | sed -E 's|(https?://[^/]+).*|\1|')

# Port bestimmen
if [ -n "$MANUAL_PORT" ]; then
    TARGET_PORT="$MANUAL_PORT"
elif [[ "$URL" =~ :([0-9]+) ]]; then
    TARGET_PORT="${BASH_REMATCH[1]}"
elif [[ "$URL" == https* ]]; then
    TARGET_PORT=443
else
    TARGET_PORT=80
fi

echo -e "${BLUE}╔════════════════════════════════════════════════════╗${NC}"
echo -e "${BLUE}║       ENDPOINT DOCTOR - Fehleranalyse              ║${NC}"
echo -e "${BLUE}╚════════════════════════════════════════════════════╝${NC}"
echo -e "Ziel-URL:      ${CYAN}$URL${NC}"
echo -e "Host:          $BASE_HOST"
echo -e "Port:          $TARGET_PORT"
echo -e "Pfad:          ${URL_PATH:-/}"
echo ""

# ============================================
# 1. DNS / Namensauflösung
# ============================================
echo -e "${YELLOW}[1/7] DNS & Netzwerk-Layer...${NC}"
if command -v nslookup &>/dev/null; then
    DNS_IP=$(nslookup "$BASE_HOST" 2>/dev/null | awk '/^Address: / { print $2; exit }')
elif command -v dig &>/dev/null; then
    DNS_IP=$(dig +short "$BASE_HOST" 2>/dev/null | head -n1)
else
    DNS_IP=$(getent hosts "$BASE_HOST" 2>/dev/null | awk '{print $1}')
fi

if [ -n "$DNS_IP" ]; then
    echo -e "  ${GREEN}✔ DNS aufgelöst:${NC} $BASE_HOST → $DNS_IP"
else
    echo -e "  ${RED}✘ DNS-Fehler:${NC} Hostname nicht auflösbar!"
    echo -e "     → Prüfe /etc/hosts, DNS-Server oder Tippfehler im Hostnamen"
fi

# ============================================
# 2. TCP Port erreichbar?
# ============================================
echo -e "${YELLOW}[2/7] TCP-Verbindungstest (Port $TARGET_PORT)...${NC}"
if timeout 4 bash -c "echo >/dev/tcp/$BASE_HOST/$TARGET_PORT" 2>/dev/null; then
    echo -e "  ${GREEN}✔ Port $TARGET_PORT ist offen${NC} (Verbindung akzeptiert)"
else
    echo -e "  ${RED}✘ Port $TARGET_PORT NICHT erreichbar${NC}"
    echo -e "     → Firewall, Docker-Port-Mapping falsch oder Dienst läuft nicht"
fi

# ============================================
# 3. HTTP Status + Metadaten
# ============================================
echo -e "${YELLOW}[3/7] HTTP-Status abfragen...${NC}"
CURL_META=$(curl -s -o /dev/null -w "%{http_code}|%{size_download}|%{content_type}|%{redirect_url}|%{num_redirects}|%{time_total}" \
    --connect-timeout 8 --max-time 15 "$URL" 2>/dev/null || echo "000|0|||0|0")

HTTP_CODE=$(echo "$CURL_META" | cut -d'|' -f1)
SIZE=$(echo "$CURL_META" | cut -d'|' -f2)
CTYPE=$(echo "$CURL_META" | cut -d'|' -f3)
REDIR=$(echo "$CURL_META" | cut -d'|' -f4)
NUM_REDIR=$(echo "$CURL_META" | cut -d'|' -f5)
TIME=$(echo "$CURL_META" | cut -d'|' -f6)

echo -n "  Status: "
case "$HTTP_CODE" in
    200|201|202|204) echo -e "${GREEN}$HTTP_CODE OK${NC}" ;;
    301|302|307|308) echo -e "${YELLOW}$HTTP_CODE Redirect${NC}" ;;
    400) echo -e "${RED}$HTTP_CODE Bad Request${NC}" ;;
    401) echo -e "${RED}$HTTP_CODE Unauthorized (Auth fehlt/falsch)${NC}" ;;
    403) echo -e "${RED}$HTTP_CODE Forbidden (keine Berechtigung)${NC}" ;;
    404) echo -e "${RED}$HTTP_CODE Not Found${NC}" ;;
    405) echo -e "${RED}$HTTP_CODE Method Not Allowed${NC}" ;;
    500|502|503|504) echo -e "${RED}$HTTP_CODE Server-Fehler ($HTTP_CODE)${NC}" ;;
    000) echo -e "${RED}Verbindungsfehler / Timeout${NC}" ;;
    *)   echo -e "${YELLOW}$HTTP_CODE${NC}" ;;
esac

echo "  Größe: ${SIZE} bytes | Zeit: ${TIME}s | Content-Type: ${CTYPE:-?}"
[ -n "$REDIR" ] && echo -e "  ${YELLOW}→ Weiterleitung zu:${NC} $REDIR"

# ============================================
# 4. Verbose Header-Analyse
# ============================================
echo -e "${YELLOW}[4/7] Response-Header analysieren...${NC}"
TMPFILE=$(mktemp)
curl -s -I --connect-timeout 8 --max-time 15 "$URL" >"$TMPFILE" 2>/dev/null || true

SERVER_HDR=$(grep -i "^server:" "$TMPFILE" | head -1 | sed 's/^[Ss]erver: //' || true)
if [ -n "$SERVER_HDR" ]; then
    echo "  Server-Header: $SERVER_HDR"
else
    echo "  (Kein Server-Header)"
fi

# Zeige Location bei Redirects
if [ -n "$REDIR" ]; then
    grep -i "^location:" "$TMPFILE" | head -1 | sed 's/^/  /' || true
fi

rm -f "$TMPFILE"

# ============================================
# 5. Pfad-Varianten testen (404-Analyse!)
# ============================================
echo -e "${YELLOW}[5/7] Pfad-Varianten & API-Pfade testen...${NC}"
if [ -n "$URL_PATH" ] && [ "$URL_PATH" != "/" ]; then
    # Varianten generieren
    declare -a VARIANTS=(
        "${BASE_URL}/"
        "${BASE_URL}${URL_PATH}/"
        "${BASE_URL}$(echo "$URL_PATH" | tr '[:upper:]' '[:lower:]')"
    )
    
    # Wenn URL mit / endet, teste ohne Slash
    if [[ "$URL" == */ ]]; then
        VARIANTS+=("${URL%/}")
    fi

    for V in "${VARIANTS[@]}"; do
        [ "$V" == "$URL" ] && continue  # Original überspringen
        VC=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "$V" 2>/dev/null || echo "000")
        if [ "$VC" == "200" ]; then
            echo -e "  ${GREEN}✔ Alternative funktioniert:${NC} $V (HTTP $VC)"
        else
            echo -e "  ${CYAN}  →${NC} $V (HTTP $VC)"
        fi
    done
else
    echo "  (Kein spezifischer Pfad angegeben)"
fi

# ============================================
# 6. OPTIONS Request (CORS/API-Info)
# ============================================
echo -e "${YELLOW}[6/7] HTTP OPTIONS-Request...${NC}"
OPTS_CODE=$(curl -s -o /dev/null -w "%{http_code}" -X OPTIONS --max-time 5 "$URL" 2>/dev/null || echo "000")
echo "  OPTIONS liefert: HTTP $OPTS_CODE"
if [ "$OPTS_CODE" == "200" ] || [ "$OPTS_CODE" == "204" ]; then
    ALLOW=$(curl -s -I -X OPTIONS --max-time 5 "$URL" 2>/dev/null | grep -i "^allow:" | sed 's/^[Aa]llow: //' | tr -d '\r')
    [ -n "$ALLOW" ] && echo "  Erlaubte Methoden: $ALLOW"
fi

# ============================================
# 7. SSL/TLS Check (nur bei HTTPS)
# ============================================
if [[ "$URL" == https* ]]; then
    echo -e "${YELLOW}[7/7] SSL/TLS Zertifikat...${NC}"
    if command -v openssl &>/dev/null; then
        SSL_OUTPUT=$(echo | openssl s_client -connect "$BASE_HOST:$TARGET_PORT" -servername "$BASE_HOST" 2>/dev/null | openssl x509 -noout -dates -subject 2>/dev/null || true)
        if [ -n "$SSL_OUTPUT" ]; then
            echo "$SSL_OUTPUT" | sed 's/^/  /'
            echo -e "  ${GREEN}✔ SSL-Handshake erfolgreich${NC}"
        else
            echo -e "  ${RED}✘ SSL-Handshake fehlgeschlagen${NC} (selbst-signiert, abgelaufen oder falsches Zertifikat?)"
        fi
    else
        echo "  openssl nicht installiert - übersprungen"
    fi
else
    echo -e "${YELLOW}[7/7] Kein HTTPS - SSL-Check übersprungen${NC}"
fi

# ============================================
# SPEZIELLE CHECKS: Ollama erkannt?
# ============================================
if [[ "$URL" == *"11434"* ]] || [ "$TARGET_PORT" == "11434" ]; then
    echo ""
    echo -e "${CYAN}--- OLLAMA SPEZIAL-CHECKS ---${NC}"
    for EP in "/api/tags" "/api/version" "/api/generate"; do
        EC=$(curl -s -o /dev/null -w "%{http_code}" --max-time 5 "${BASE_URL}${EP}" 2>/dev/null || echo "000")
        STATUS_COLOR=$([ "$EC" == "200" ] && echo "$GREEN" || echo "$RED")
        echo -e "  $EP → ${STATUS_COLOR}HTTP $EC${NC}"
    done
    echo -e "${YELLOW}Hinweis:${NC} Bei Ollama oft falsch: POST /v1/chat/completions statt /api/chat"
fi

# ============================================
# ZUSAMMENFASSUNG & HANDLUNGSEMPFEHLUNG
# ============================================
echo ""
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"
echo -e "${BLUE}           Z U S A M M E N F A S S U N G             ${NC}"
echo -e "${BLUE}════════════════════════════════════════════════════${NC}"

if [ "$HTTP_CODE" == "404" ]; then
    echo -e "${RED}HAUPTPROBLEM: HTTP 404 Not Found${NC}"
    echo ""
    echo "Mögliche Ursachen:"
    echo "  ① Tippfehler in der URL oder API-Version (/v1/ vs /v2/)"
    echo "  ② Falscher HTTP-Verb (GET statt POST oder PUT)"
    echo "  ③ Der Endpoint existiert nicht mehr oder wurde verschoben"
    echo "  ④ Reverse-Proxy (nginx/traefik) hat falsche Location-Regel"
    echo " ⑤ Ollama: Falsches Modell im JSON-Body oder falscher Path"
    echo ""
    echo -e "${GREEN}Empfohlene Lösung:${NC}"
    echo "  → Prüfe ob Root-URL (${BASE_URL}/) überhaupt antwortet"
    echo "  → Teste die im Skript gezeigten Pfad-Varianten"
    echo "  → Vergleiche mit der offiziellen API-Doku des Dienstes"
    echo "  → Prüfe Webserver/Proxy-Logs auf 'No such file or directory'"

elif [ "$HTTP_CODE" == "000" ]; then
    echo -e "${RED}HAUPTPROBLEM: Keine TCP/HTTP-Verbindung${NC}"
    echo "  → Dienst ist offline oder Firewall blockiert Port $TARGET_PORT"
    echo "  → Bei Docker: Port-Forwarding prüfen (-p $TARGET_PORT:$TARGET_PORT)"
    echo "  → Bei Remote-Host: VPN / Netzwerksegment prüfen"

elif [ "$HTTP_CODE" == "401" ] || [ "$HTTP_CODE" == "403" ]; then
    echo -e "${RED}HAUPTPROBLEM: Authentifizierung / Berechtigung${NC}"
    echo "  → API-Key, Bearer-Token oder Basic-Auth fehlt im Header"

elif [ "$HTTP_CODE" == "405" ]; then
    echo -e "${RED}HAUPTPROBLEM: Falsche HTTP-Methode${NC}"
    echo "  → Dieser Endpoint erlaubt die verwendete Methode nicht"

elif [ "$HTTP_CODE" == "502" ] || [ "$HTTP_CODE" == "503" ] || [ "$HTTP_CODE" == "504" ]; then
    echo -e "${RED}HAUPTPROBLEM: Gateway / Upstream-Fehler${NC}"
    echo "  → Der Proxy erreicht den Backend-Dienst nicht"

else
    echo -e "${GREEN}Status HTTP $HTTP_CODE${NC} - Verbindung grundsätzlich OK."
    [ "$HTTP_CODE" != "200" ] && echo "Prüfe trotzdem ob das erwartete Verhalten wirklich gegeben ist."
fi

echo ""
echo -e "${CYAN}Scan abgeschlossen.${NC}"
