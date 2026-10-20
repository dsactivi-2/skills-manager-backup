# pre-main → ari.activi.io → Sipgate (live SoT)

Nicht voiceeu-MCP, nicht Infobip, nicht Cloud-MCP für diese Box. MCP: `https://pre-main.activi.io/api/v1/mcp/` + `X-API-Key` aus `~/.hermes/secrets/dograh-pre-main.env`.

## UI (pre-main Call starten)

| Feld | Wählen |
|---|---|
| Telephony | **ARI (ari) – default** — nicht Trunk 898 |
| From | **Sipgate DID 03075435897** — nicht Extension 200 |
| Nummer | nackt: `491778022488` / `+49…` / `0177…` — keine Extra-Ziffern (`…48889` war Tippfehler) |

## Dest-Rewrite (nackte Nummer)

Dograh ARI baut `PJSIP/{to}` ohne `@trunk` → Allocation failed.

Live: systemd `ari-dest-rewrite` auf der PBX `:8090` → `127.0.0.1:8088`. pre-main `ari_endpoint=http://ari.activi.io:8090`.

- PSTN (≥8 Ziffern, `+`/`00`/`0…`) → `PJSIP/<e164>@Sipgate_Trunk_897`
- Ext `200`/`555` unverändert
- Script: `/usr/local/sbin/ari-dest-rewrite.py`

**Pflicht:** Proxy muss **WebSocket tunneln** (`Upgrade: websocket` → TCP splice). Reines HTTP-`urlopen` gibt 101 und killt `/ari/events` → UI 500, Klingeln, Auflegen beim Abheben.

## CLIP / Inbound

- `from_user` = SIP-ID; CLIP = `P-Preferred-Identity: <sip:493075435897@sipconnect.sipgate.de>` in `pjsip.endpoint_custom_post.conf`; `sendrpid=no` (sonst PAI=`200`)
- Trunk-Context `from-pstn` (nicht `from-pst`). Fehlt der Context → Catchall `ss-noservice`
- DID-Routen in `extensions_custom.conf` `[from-pstn-custom]` → `Stasis(dograh)`
- pre-main phone `493075435897` inbound → WF 1

## Diagnose

Nicht `grep ERROR` auf `full` (Scanner). Echte Calls: `HTTP Request URI is /ari/channels`. INVITE: Request-URI + Route + From + Ziel-IP. `fwconsole mysql -e` existiert nicht — PHP/FreePBX::Database oder `fwconsole mysql 'SQL'`.
