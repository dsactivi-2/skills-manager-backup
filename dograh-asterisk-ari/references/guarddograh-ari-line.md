# Guarddograh ARI line (third Dograh, same FreePBX)

Not voiceeu. Not Cloud. Same PBX `ari.activi.io` / `178.105.149.160`.

## Isolation (required)

A second Dograh on one Asterisk **must not** reuse the first line. Asterisk gives a Stasis app to whoever registered last — the other goes deaf with no error.

| Layer | voiceeu / pre-main (keep) | Guarddograh (own) |
|---|---|---|
| ARI user | `[dograh]` in `ari_additional.conf` | `[guarddograh]` **only** in `ari_additional_custom.conf` |
| WS client | `[dograh]` → `wss://pre-main.activi.io/api/v1/telephony/ws/ari` | `[guarddograh]` → `wss://guarddograh.activi.io/api/v1/telephony/ws/ari` |
| Stasis | `from-dograh-stasis` → `Stasis(dograh)` | `from-guarddograh-stasis` → generated `dograh_<12hex>` |
| Ext | 200 / **300 tg400** / 555 | **310** `guarddograh` (PJSIP, ulaw). Unavailable without a phone = normal |
| Dograh | voiceeu MCP | MCP `dograh-guarddograh`, config **2** `Guarddograh ARI` |

## Guarddograh fork fields (live metadata)

`app_name` = **ARI Username** (BasicAuth). `stasis_app_name` = readonly, minted on create (`dograh_` + 12 hex). Do not send it. `ws_client_name` + `from_numbers` required.

```
POST https://guarddograh.activi.io/api/v1/organizations/telephony-configs
X-API-Key: ${MCP_DOGRAH_GUARD_API_KEY}
```

Then `GET …/telephony-configs/{id}` → copy `stasis_app_name` into dialplan → `dialplan reload`. Phone number `310` via `POST …/phone-numbers`. Default outbound: `POST …/set-default-outbound`.

## Duplicate `[dograh]` (reload trap)

`ari_additional.conf` already has `[dograh]`. Putting `[dograh]` again in `ari_additional_custom.conf` →

`res_sorcery_config.c: duplicate object: 'dograh' of type 'user'`

Reload aborts; **new** custom users never appear in `ari show users`. Custom file = **only** extra users (`[guarddograh]`). Never duplicate `[dograh]` there.

After edit: `module reload res_ari.so` then `ari show users` must list `dograh` **and** `guarddograh`. Auth probe from the Dograh VPS: `curl -u guarddograh:… http://ari.activi.io:8088/ari/asterisk/info` → 200.

## TG400 later

Do **not** point Sipgate/TG DIDs at `from-guarddograh-stasis` until the user names the number. Inbound then: that DID → `from-guarddograh-stasis`, never `from-dograh-stasis`. Ext 300 stays TG register. Secrets: `~/.hermes/secrets/guarddograh-ari.env` (chmod 600), never chat.
