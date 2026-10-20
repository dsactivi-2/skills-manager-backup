# FreePBX standards + Dograh (Activi)

## GraphQL

- Token: POST body `grant_type=client_credentials` + id + secret + scope. MySQL `api_applications.client_secret` kann ≠ GUI → 401.
- `FREEPBX_SCOPES="gql rest"` quoten.
- Env: `~/.hermes/secrets/freepbx-api.env`
- Es gibt **kein** `addOutboundRoute`. Route: Tabellen `outbound_routes` + `outbound_route_patterns` + `outbound_route_trunks` + `outbound_route_sequence`, dann `fwconsole reload`.
- `doreload` braucht `input`. Lieber `fwconsole reload`.
- `addExtension` legt DB-Zeile an; Endpoint erst nach Reload (`pjsip show endpoint 100`). Unavailable ohne Softphone = normal.

## Standards (ohne nachfragen)

- Test-Ext: `100` / Name `test` / PJSIP / ulaw+alaw / context `from-internal`.
- Sipgate-Testroute: Name `sipgate-out`, Pattern `X.`, Trunk `sipgate-test`.
- NAT: extern = Box-IPv4 (`178.105.149.160`), local `127.0.0.1/8`. Mutations `updateSipNatExternalIp` / `addSipNatLocalIp`.
- HTTPBIND: `fwconsole setting HTTPBINDADDRESS 0.0.0.0` + `ENABLE_ARI 1`. Dashboard „Bind Localhost“ nicht übernehmen.
- Secrets: Ext-Pass nach Create aus `sip` keyword `secret` → `~/.hermes/secrets/freepbx-ext100.env`, nicht Chat/Brief.

## Nachfragen (nicht Standard)

- voiceeu-**Org** für neue ARI-Config. Live alle Configs können noch auf `https://pbx.activi.io` (Gono) zeigen — **nicht** überschreiben. Neue Config `pbx-tg400` → `http://ari.activi.io:8088`, `is_default_outbound=false`.
- TG Register vs Peer.
- Echte Sipgate-/SIM-Nummern, Projekt-Nebenstellen (Lead / Strom / Aquaphor).

## n8n SMS (TG, nicht FreePBX)

- REST `N8N_API_URL` + `N8N_API_KEY` in `~/.hermes/.env`.
- Workflow `TG400 SMS -> n8n` (`O9lkmopuCXCrtR5G`), Webhook-URL in `~/.hermes/secrets/tg400-sms-n8n.env`.
- Mail: an `sms@activi.io`, von `noreply@activi.io` = SMTP am TG, nicht n8n-Gmail raten.
