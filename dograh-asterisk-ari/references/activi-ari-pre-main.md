# Activi: Dograh host for ari.activi.io

Live SoT for the **new** FreePBX (`ari.activi.io` / `pbx-tg400` / `178.105.149.160`):

| Role | Host | IP |
|---|---|---|
| Dograh (this ARI chain) | `pre-main.activi.io` | `178.105.247.102` |
| Other OSS Dograh (Gono / old ARI) | `voiceeu.activi.io` | `167.233.126.212` |
| New PBX | `ari.activi.io` | `178.105.149.160` |
| Gono PBX | `pbx.activi.io` | do not overwrite |

User correction (2026-08-18): Dograh UI/calls for this box are **pre-main**, not voiceeu. voiceeu still exists; do not point this PBX media-WS or Hetzner 8088 at voiceeu.

## Two directions

| Path | Where | Must be |
|---|---|---|
| Dograh → Asterisk ARI | Hetzner FW `pbx-tg400` in TCP 8088 | **only** `178.105.247.102/32` (pre-main). Not 0.0.0.0/0. Not voiceeu. |
| PBX → Dograh media WS | `/etc/asterisk/websocket_client.conf` `[dograh]` | `uri = wss://pre-main.activi.io/api/v1/telephony/ws/ari` |

`connection_type = per_call_config` → no persistent outbound client until a call. Inbound ARI session from pre-main + `ari show apps` = `dograh` is the live “connected” check.

## Asterisk 22 CLI (this box)

These **do not exist**: `websocket_client show clients`, `websocket_client show client dograh`.

Use:

```
asterisk -rx "ari show apps"
asterisk -rx "ari show app dograh"
asterisk -rx "ari show websocket sessions"
asterisk -rx "ari show outbound-websockets"
asterisk -rx "module show like websocket"
```

`ari show websocket sessions`: inbound from `178.105.247.102` + App `dograh` = Dograh reached :8088.

## Errors — do not mix

| Symptom | Meaning | Fix |
|---|---|---|
| `Allocation failed` / endpoint not found | Originate string is not an endpoint on **this** box. Only `100` and `sipgate-test`. | Dograh dest `49…@sipgate-test` (no `+`, no `@trunk-ep-3`) |
| REGISTER `Rejected` / SIP `401` | Sipgate auth or IP whitelist | Portal secret + allow `178.105.149.160`. Not an Allocation-failed cause |
| Qualify `outbound proxy URI 'sipgate.de' is not valid` | FreePBX stored host without `sip:` | `pjsip.outbound_proxy` / live `outbound_proxy` = `sip:sipgate.de` |

Qualify Avail ≠ Registered. 401 Register ≠ Allocation failed.

## Secrets

ARI user `dograh` password lives in `/etc/asterisk/ari_additional_custom.conf`. Copy to `~/.hermes/secrets/freepbx-ari-dograh.env` (chmod 600). Never paste into chat. Claimed chat passwords often ≠ live file (verify with localhost `:8088` 200 vs 401).

## Telephony on voiceeu DB (do not confuse)

Org2 default outbound `dograh_eu` still points at `https://pbx.activi.io` (Gono). Config `pbx-tg400` → `http://ari.activi.io:8088` is the new box and is **not** default. Test calls must select `pbx-tg400`.
