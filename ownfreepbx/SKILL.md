---
name: ownfreepbx
description: "Use when operating Activi FreePBX on ari.activi.io."
version: 1.0.0
author: Activi
license: MIT
---

# ownfreepbx — Activi FreePBX 17

Nur **diese** Box. Nicht hermes, nicht dograh-vps, nicht GonoPBX.

| | |
|---|---|
| Host | `ari.activi.io` / `178.105.149.160` |
| Name | Hetzner `pbx-tg400` (fsn1, cx33, Debian 12) |
| GUI | `https://ari.activi.io/admin` |
| ARI | `http://ari.activi.io:8088` (nur voiceeu) |
| SSH-Key | `~/.ssh/id_ed25519_pbx_tg400` (kein Passwort) |
| GraphQL-Env | `~/.hermes/secrets/freepbx-api.env` (chmod 600) |

Verwandt: `dograh-asterisk-ari` (Verdrahtung), `yeastar-tg-gateway` (TG400). TG ist Prod-SoT; Sipgate nur Test. Kein ari-py.

## When to Use

FreePBX verwalten, Register prüfen, Logs, Extension/Route/Trunk per API, Apply Config. Nicht für Dograh-Workflows und nicht für TG-Web-UI.

## 1) SSH / echte Asterisk-CLI

Immer diese Flags (sonst 1Password-Agent / Host-* bricht BatchMode):

```
ssh -o IdentityAgent=none -o IdentitiesOnly=yes -o BatchMode=yes \
  -i ~/.ssh/id_ed25519_pbx_tg400 root@178.105.149.160 \
  'asterisk -rx "BEFEHL"'
```

| Befehl | Wozu |
|---|---|
| `pjsip show registrations` | Sipgate/TG Registered? |
| `pjsip show endpoints` | Trunk-Status |
| `core show version` | muss ≥22.6 (live war 22.10.1) |
| `http show status` | ARI Bound **0.0.0.0:8088** |
| `module show like chan_websocket` | Running |
| `core show channels` | laufende Calls |
| `fwconsole -V` | FreePBX-CLI |

Logs: `tail -n 80 /var/log/asterisk/full` — keine Secrets ausgeben.

Nicht: `core stop now`, `module unload`, `database deltree`.

## 2) GraphQL M2M

Env sourcen. Secret nie ins Chat / nie in die Projektbrief.

```
set -a && source ~/.hermes/secrets/freepbx-api.env && set +a
```

Token (client_credentials, Body):

```
curl -sS -X POST "$FREEPBX_TOKEN_URL" \
  -d grant_type=client_credentials \
  -d client_id="$FREEPBX_CLIENT_ID" \
  -d client_secret="$FREEPBX_CLIENT_SECRET" \
  -d scope="$FREEPBX_SCOPES"
```

Erwartung: HTTP 200 + `access_token`. Dann `POST $FREEPBX_GQL_URL` mit `Authorization: Bearer` und `{"query":"…"}`.

Authorize-URL nicht nutzen. Scopes `gql rest` quoten (`FREEPBX_SCOPES="gql rest"`).

Nach Mutations: `fwconsole reload` per SSH. GUI Apply Config gleichwertig.

## 3) ARI nicht anfassen ohne Freigabe

```
fwconsole setting HTTPBINDADDRESS   # muss 0.0.0.0
fwconsole setting ENABLE_ARI        # muss 1
```

Dashboard „HTTP Bind → Localhost“ nicht übernehmen.

User `dograh` in `ari_additional_custom.conf`. Passwort nicht in Brief. Dograh-UI: `http://ari.activi.io:8088`, App `dograh`, WS-Client `dograh`.

Nicht: ari-py, AMI/Panoramisk, winfunc asterisk-mcp, voip-pentest-Skills.

## Dashboard-Notifications (ari.activi.io)

Live prüfen, nicht aus dem Screenshot raten:

```
fwconsole notifications --list
fwconsole mysql -e "SELECT module,id,level,display_text,LEFT(extended_text,400) FROM notifications\G"
fwconsole ma list
fwconsole setting HTTPBINDADDRESS
asterisk -rx "http show status"
```

| Meldung | Bedeutung hier | Aktion |
|---|---|---|
| Tampered files | oft nur PNGs (sipsettings/webrtc Assets), kein Rootkit | Module `--force` neu ziehen + `fwconsole ma refreshsignatures`; nicht Dateien von Hand faken |
| Vulnerable module + disabled module | fast immer **UCP** alt + disabled. UCP≠Calls; 0 Sessions | `fwconsole ma upgrade ucp --skipdisabled` (disabled lassen) oder uninstall. Nicht nur Notification löschen |
| DAHDi not owned by asterisk | leere `/etc/dahdi/*` + `modprobe.d/dahdi.conf` als root | `chown asterisk:asterisk` dann `fwconsole chown`. Kein DAHDi-Hardware auf dieser Box |
| HTTP Bind → Localhost | Sangoma-Security-Hinweis, oft stale | **Nie übernehmen.** Bind muss `0.0.0.0:8088` bleiben |
| API Key Regeneration | Keys nach Security-Fix rotiert | GraphQL-Token testen; wenn 200 nur Notification dismissen |
| E-Mail-Warteschlange | Hetzner blockt outbound :25; Zoho MX timeout | Queue-Mails sind Alerts. Relay über :587 oder Queue leeren. Nicht Port 25 erzwingen |
| Grüne Infos (Extensions-Menü, Browser-Stats, VULNERABILITIES_FIXED) | UI/Info. FIXED kann lügen wenn Version noch alt | nach echtem `ma list` Version prüfen |

Tampered-Details stehen in `notifications.extended_text` und in den hängenden Postfix-Mails (`postcat -q ID`).

## Pitfalls

- `Host *` + 1Password IdentityAgent → Permission denied. Immer IdentityAgent=none + dieser Key.
- Unquoted `FREEPBX_SCOPES=gql rest` zerlegt die Shell.
- Secret aus MySQL kann ≠ GUI-Secret → Token 401. Nur GUI-Secret in die Env.
- Debian index.html = Testseite. GUI ist /admin.
- `--opensourceonly` kann an oracle_connector sterben; Rest per fwconsole nachziehen.
- Sipgate Registered ≠ Gespräch. Extension + Outbound Route nötig.
- Kein FreePBX auf App-VPS.

## Verify

1. `https://ari.activi.io/` → 302 `/admin`
2. SSH: registrations + http show status 0.0.0.0:8088
3. Token 200, GraphQL `{ __typename }` 200
4. Mac :8088 timeout; voiceeu 200 mit Auth
