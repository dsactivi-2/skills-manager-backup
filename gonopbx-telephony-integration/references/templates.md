# Output Templates

Use these templates when the user asks for a concrete plan, audit result, or handoff artifact. Keep placeholders until the user confirms real values.

## Infobip Registered Trunk Mapping

| Field | Value | Status | Notes |
|---|---|---|---|
| Architecture | Infobip registered SIP trunk -> GOno PBX custom trunk | derived from source | Prefer when Infobip provides username/password. |
| GOno PBX `provider` | `custom` | derived from source | Unless the deployed GOno PBX version has an Infobip provider. |
| GOno PBX `auth_mode` | `registration` | derived from source | Requires username and password. |
| GOno PBX `sip_server` | Needs user confirmation | account value | Infobip SBC FQDN/IP from account. |
| GOno PBX `username` | Needs user confirmation | secret-bearing | Do not print in reports. |
| GOno PBX `password` | Needs user confirmation | secret | Do not print or decode. |
| GOno PBX `number_block` | Needs user confirmation | account value | DID or DID block format as received by GOno PBX. |
| GOno PBX `caller_id` | Needs user confirmation | policy value | Must match Infobip/account caller-ID rules. |
| GOno PBX `codecs` | `ulaw,alaw,g722` or confirmed policy | source/default | Keep `ulaw` when Dograh is in the path. |

## Infobip Static Trunk Mapping

| Field | Value | Status | Notes |
|---|---|---|---|
| Architecture | Infobip static trunk -> GOno PBX fixed-IP trunk | Needs user confirmation | Use only with stable public dedicated PBX IP. |
| GOno PBX `provider` | `custom` | derived from source | Unless native Infobip provider exists in live version. |
| GOno PBX `auth_mode` | `ip` | derived from source | No registration/auth block generated. |
| GOno PBX `sip_server` | Needs user confirmation | account value | Infobip destination/SBC target. |
| Infobip source IP allowlist | Needs user confirmation | account value | Must match public PBX/SBC IP design. |
| GOno PBX public SIP endpoint | Needs user confirmation | environment value | Requires SIP/RTP firewall/NAT checks. |

## Dograh ARI Handoff

| Field | Value | Status | Notes |
|---|---|---|---|
| Call path | Infobip DID -> GOno PBX/Asterisk -> Stasis -> Dograh | derived from source | Use only after inbound trunk path is understood. |
| ARI endpoint URL | Needs user confirmation | environment value | Do not expose broadly. |
| Stasis app name | Needs user confirmation | Dograh/Asterisk value | Must match dialplan and Dograh config. |
| WebSocket client name | Needs user confirmation | Dograh/Asterisk value | Must match `websocket_client.conf`. |
| Required modules | `chan_websocket`, `res_websocket_client`, ARI/HTTP modules | source/runtime | Verify with preflight before promising compatibility. |
| Codec | `ulaw`/PCMU available | source/runtime | Needed for Dograh external media path. |
| Persistence strategy | Needs user confirmation | deployment value | Must survive container restart/recreate. |

## Compact Report Skeleton

```text
Status: PASS | PASS_WITH_GAPS | WARN | FAIL

Architecture:
...

Confirmed values:
- ...

Needs user confirmation:
- ...

Preflight evidence:
- Report path: ...
- PASS: ...
- WARN: ...
- FAIL: ...

Approval gate before live changes:
- Planned change:
- Expected effect:
- Rollback:
- Test calls:
```
