# Live-check: Dograh official ARI prerequisites vs this PBX

Use when the user asks whether `ari.activi.io` / FreePBX meets Dograh External-PBX / Asterisk-ARI docs.

Docs SoT: MCP `read_doc` `integrations/telephony/asterisk-ari`.
PBX SSH: skill `ownfreepbx`. Org REST: `X-API-Key` (MCP has no telephony-config).

## Two boxes — do not collapse

| Box | Question | Not the same as |
|---|---|---|
| Asterisk | Modules, ARI, HTTP :8088, `websocket_client.conf`, ulaw, Stasis dialplan | Dograh UI flag |
| Dograh org | `external_pbx_integrations_enabled` + `provider=ari` rows | Module-OK on the PBX |

Official docs: **Stasis App Name = `ari.conf` user**. Live Activi: `dograh`. Ignore copy that says the name is auto-generated.

## PBX commands (redact passwords)

```
asterisk -rx "core show version"                    # ≥22.6
asterisk -rx "module show like chan_websocket"
asterisk -rx "module show like res_websocket_client"
fwconsole setting ENABLE_ARI                        # true
fwconsole setting HTTPBINDADDRESS                   # 0.0.0.0
asterisk -rx "http show status"                     # 0.0.0.0:8088
asterisk -rx "ari show users"
asterisk -rx "ari show websocket sessions"
asterisk -rx "ari show app dograh"
asterisk -rx "dialplan show from-dograh-stasis"
# websocket_client.conf: print names+uri only
```

`127.0.0.1` holding App `dograh` is usually systemd `ari-dest-rewrite` (`:8090` → `:8088`), not a Dograh VPS.

`:8088`/`:8090` from a Mac may TCP-connect or time out — neither is SoT. Probe: unauth **401**, auth user `dograh` **200**.

## Dograh REST

```
GET /api/v1/organizations/preferences
# external_pbx_integrations_enabled

GET /api/v1/organizations/telephony-configs
GET /api/v1/organizations/telephony-configs/{id}
GET /api/v1/organizations/telephony-configs/{id}/phone-numbers
```

Not `/telephony-configurations`. Never PUT a GET-masked `app_password`.

Flag `false` + `provider=ari` = ARI already usable; External-PBX UI hidden.
Flag `true` + no `ari` row = switch only (Cloudonix-only is possible).
Several orgs with `app_name=dograh` = last registrant steals Stasis.

Always read live `websocket_client.conf` `uri` — do not assume voiceeu.
