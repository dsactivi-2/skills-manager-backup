# Bare number → Sipgate trunk (ari.activi.io)

Dograh ARI (`providers/ari/provider.py`) does `PJSIP/{to_number}` unless the string already starts with `SIP/` or `PJSIP/`. A UI number `491778022488` therefore allocates endpoint `491778022488` — that object does not exist → Allocation failed / UI error.

`@Sipgate_Trunk_897` in the UI works. Users want digits only.

## Live SoT (2026-08-18)

| | |
|---|---|
| Proxy | `/usr/local/sbin/ari-dest-rewrite.py` systemd `ari-dest-rewrite` |
| Listen | `0.0.0.0:8090` → `http://127.0.0.1:8088` |
| pre-main ARI URL | `http://ari.activi.io:8090` (config id 1 `ARI`, default outbound) |
| voiceeu | stays on raw `:8088` |

Rewrite (only if no `@`):

| Input | Output |
|---|---|
| `PJSIP/491778022488` | `…@Sipgate_Trunk_897` |
| `PJSIP/+49…` / `%2B49…` | strip plus, then trunk |
| `PJSIP/0177…` | `49` + rest without leading 0, then trunk |
| `PJSIP/200` | unchanged (short ext) |
| already `@trunk` | unchanged |

## Do not

- Point voiceeu at :8090 unless intended.
- PUT pre-main ARI config with the **masked** `app_password` from GET — that breaks ARI. Use `~/.hermes/secrets/freepbx-ari-dograh.env`.
- Treat scanner INVITEs as the user’s call. Originate: `grep "HTTP Request URI is /ari/channels" /var/log/asterisk/full`.
