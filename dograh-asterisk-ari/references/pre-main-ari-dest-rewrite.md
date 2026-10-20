# pre-main ↔ ari.activi.io: Dest-Rewrite + Split-Brain

Live 2026-08-18. Dograh ARI (`providers/ari/provider.py`) baut `PJSIP/{to_number}` **ohne** `@trunk`. Auf dieser Box gibt es kein Endpoint `49177…` → Allocation failed / UI 500. Mit `@Sipgate_Trunk_897` geht der Call.

## Dest-Rewrite (Nummer allein)

| | |
|---|---|
| Service | `ari-dest-rewrite.service` auf `pbx-tg400` |
| Script | `/usr/local/sbin/ari-dest-rewrite.py` |
| Listen | `0.0.0.0:8090` → `127.0.0.1:8088` |
| pre-main `ari_endpoint` | `http://ari.activi.io:8090` (Config **ARI**, default) |
| Regel | `PJSIP/<pstn>` ohne `@`: `387…` → `@300` (TG), sonst `@Sipgate_Trunk_897`. pre-main Config `pbx-tg400` nutzt `:8090`. |
| Normal | `+`/`%2B`/`00` weg; `0[1-9]…` → `49…`; Intern `200`/`555` unangetastet |

**HTTP-only Proxy ist falsch.** `GET /ari/events` ist WebSocket (101). Ohne TCP-splice: Originate 200 + Klingeln, dann UI Internal Server Error, App `dograh` leer, Abheben → Hangup. Proxy muss Upgrade tunneln, nicht als HTTP puffern.

Journal nicht mit vollem Request-URI loggen (`api_key=dograh:…` = ARI-Secret).

Hetzner-FW `pbx-tg400` Regel :8090 nur `178.105.247.102/32` — prüfen ob Firewall **am Server hängt** (`applied_to` war leer).

## Split-Brain (Klingeln, dann tot)

| Symptom | Ursache |
|---|---|
| SIP 200, dann `WebSocket closed by remote` ~5 ms | Media-WS `[dograh]` zeigt auf **pre-main**, Stasis-App hängt an **voiceeu**. Run-IDs der anderen Instanz → 403/close |
| `Couldn't find dograh-ext-…` | Media-Kanal schon tot, Bridge scheitert |
| App `dograh` an `167.233.126.212` | voiceeu steuert; pre-main Sessions oft **ohne** App-Spalte |

Steuerung und Media müssen **dieselbe** Dograh-Instanz sein. SoT dieser Box: pre-main. voiceeu-Config `pbx-tg400` nicht default; Gono `dograh_eu` nicht überschreiben.

## Inbound DID

`context=from-pst` existierte nicht. Catchall `ext-did-catchall` spielt `ss-noservice`. Fix: `from-pstn` + `extensions_custom.conf` `[from-pstn-custom]` → `[from-dograh-stasis]` / `Stasis(dograh)`. Alias `[from-pst]` include `from-pstn`. pre-main Phone `493075435897` + `inbound_workflow_id` setzen.

## CLIP (sipconnect)

`from_user` = SIP-ID. Sichtbare DID nur `P-Preferred-Identity: <sip:493075435897@sipconnect.sipgate.de>` in `pjsip.endpoint_custom_post.conf`. `sendrpid=no` — sonst ARI `callerId=200` → PAI `sip:200@…`. Siehe `sipgate-403-untrusted-route.md`.

## pre-main MCP

`https://pre-main.activi.io/api/v1/mcp/` + `X-API-Key` aus `~/.hermes/secrets/dograh-pre-main.env`. Accept: `application/json, text/event-stream` (sonst 406). Nicht voiceeu-MCP, nicht Infobip, nicht Cloud. Tools = gleiche 16 wie Dograh OSS (kein Telephony-Initiate).

## UI-Call

Config **ARI (default)**, From **Sipgate DID 03075435897**. Ziel ohne Extra-Ziffern (`491778022488`, nicht `…48889`).
