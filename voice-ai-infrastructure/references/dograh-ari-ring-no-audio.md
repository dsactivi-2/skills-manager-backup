# Dograh ARI: rings, no audio

## Pattern

- Browser / in-app agent test: audio OK
- Outbound (or inbound) via Asterisk ARI: phone rings, silence

→ Control path works; **media WebSocket / codec / modules** fail.

Not: prompts, AGENTS.md, model BYOK (if browser already speaks).

## Hosts

| Host role | Example name | Has Asterisk CLI? |
|-----------|--------------|-------------------|
| Dograh app | DograhEUV2 | No — Docker api/ui only |
| PBX | GonoPBX | Yes — container or /usr/sbin |

Never install Ubuntu `asterisk` package to “get the CLI” when phones already ring.

## Media path

```
SIP endpoint ↔ Asterisk bridge ↔ externalMedia (chan_websocket, ulaw)
                                    ↕
                     websocket_client.conf → Dograh
                     /api/v1/telephony/ws/ari
                                    ↕
                              Dograh telephony transport
```

Browser path uses WebRTC (+ optional coturn). ARI handset path does **not** depend on TURN the same way.

## PBX checks (inside real Asterisk)

```bash
module show like chan_websocket      # Running?
module show like res_websocket_client
module show like res_ari
```

`websocket_client.conf`:
- section name = Dograh **WebSocket Client Name**
- uri base only (no query); Dograh adds workflow/org/run via transport data
- Cloud: `wss://api.dograh.com/api/v1/telephony/ws/ari`, `tls_enabled=yes`, CA file
- Self-host: Asterisk must route to Dograh host/port; firewall both ways as needed

PJSIP/trunk: `allow=ulaw`.

Reload after edits:
```bash
ari reload
dialplan reload
module reload res_websocket_client.so
```

## Dograh checks

Telephony → Asterisk ARI: endpoint, app name/password, ws client name, from extensions.

During silent call:
- API container logs (ari, websocket, externalMedia, traceback)
- Workflow run status / empty transcript
- Asterisk CLI verbose (`asterisk -rvvv`) for externalMedia / WS errors

## apt trap

```
asterisk: command not found
→ apt install asterisk   # WRONG if PBX already exists
```

Correct: find container/binary on PBX host; `docker exec … asterisk -rx "…"`.

If apt already prompted: answer `n`. If mistakenly installed: remove package and restore prior PBX — do not dual-run two Asterisks.

## Docs

https://docs.dograh.com/integrations/telephony/asterisk-ari
