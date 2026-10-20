# pre-main vs voiceeu on the same FreePBX

Two Dograh worlds can sit on `ari.activi.io` at once. Mix them and the phone rings then dies.

## Two cables

| Cable | Where | Must match the instance that **started** the run |
|---|---|---|
| Control | inbound ARI WS `:8088`, `ari show websocket sessions` App `dograh` | originate + StasisStart |
| Media | PBX outbound `websocket_client.conf` `[dograh]` | externalMedia |

Live fail (2026-08-18 11:51): voiceeu originated (run 330 / wf 45), user answered SIP 200, media WS went to **pre-main** with those voiceeu IDs → `WebSocket closed by remote` in 5 ms → `Couldn't find dograh-ext-…` → hangup 16.

Live ok (11:58): pre-main originated (run 25 / wf 1), media stayed on pre-main, speech ~8 s.

`ari show websocket sessions`: pre-main can be `Up` **without** App `dograh`. That is only a socket, not the controller. voiceeu may still own `dograh`.

## This box SoT

| | |
|---|---|
| Dograh | `https://pre-main.activi.io` — MCP `https://pre-main.activi.io/api/v1/mcp/` |
| Auth | `X-API-Key` from `~/.hermes/secrets/dograh-pre-main.env` |
| MCP Accept | `application/json, text/event-stream` or 406 |
| Do not | voiceeu MCP / Cloud MCP / Infobip for this PBX |

MCP tools are workflow/docs only — no telephony-config. Configs via REST `X-API-Key`.

## Inbound DID

Trunk 897 context must be **`from-pstn`** (not typo `from-pst` — that context did not exist). Empty `incoming` + catchall = Playback `ss-noservice` (“kein Anschluss”).

DIDs `493075435897` / `03075435897` / `+49…` → `from-pstn-custom` → `from-dograh-stasis` → `Stasis(dograh)`. Alias context `[from-pst]` includes `from-pstn`.

pre-main phone number `493075435897` on ARI config 1 → inbound workflow 1.

## Explain to user

Short plain German, one table. No ARI/Stasis lecture unless asked. After a working call: who started it, whether audio stayed up, hangup cause.
