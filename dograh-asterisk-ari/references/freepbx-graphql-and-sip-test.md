# FreePBX GraphQL + Sipgate-Test (Activi)

Nicht in die Projektbrief. Secrets nur Env.

## GraphQL M2M

- App-Typ: **Machine-to-Machine**. Scopes-Feld leer oder `gql rest`.
- Authorize-URL ungenutzt. Token-URL + GraphQL-URL.
- Env: `~/.hermes/secrets/freepbx-api.env` (chmod 600). `FREEPBX_SCOPES="gql rest"` **quoten**.
- Token: POST body `grant_type=client_credentials` + `client_id` + `client_secret` + `scope`. Nicht Secret aus MySQL `api_applications` (kann ≠ GUI, Token 401).
- Nach Mutations: `fwconsole reload`.

## Sipgate nur Test

TG bleibt Prod-SoT. PJSIP-Trunk, nicht chan_sip.

| Feld | Wert |
|---|---|
| SIP Server | Basic `sipgate.de` / Trunking `sipconnect.sipgate.de` |
| Port | 5060 |
| Registration | Send |
| Codecs | ulaw + alaw |
| Outbound CID | oft `49…` ohne `+` |

`pjsip show registrations` → **Registered**. Endpoint Unavailable/NonQual ohne Qualify ≠ tot. Gespräch braucht Extension + Outbound Route.

## GUI vs ARI

`https://ari.activi.io/` = FreePBX. `http://ari.activi.io:8088` = ARI (Dograh). Debian `index.html` ist Testseite — weg, dann 302 `/admin`. Let's Encrypt für GUI; ARI bleibt HTTP :8088, FW nur voiceeu.

Dashboard „HTTP Bind → Localhost“ nicht übernehmen.

## Nicht

ari-py, AMI/Panoramisk, winfunc asterisk-mcp (Security-Scanner), voip-pentest-Skills, FreePBX-Admin-API mit Dograh-ARI verwechseln.
