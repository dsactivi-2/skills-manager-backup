# Guarddograh = third Dograh, own ARI line

Not voiceeu, not Cloud. UI `https://guarddograh.activi.io`. Hermes MCP `dograh-guarddograh` → `/api/v1/mcp/` with **X-API-Key** (`MCP_DOGRAH_GUARD_API_KEY`). Bearer 401 on tools.

Never reuse voiceeu/pre-main Stasis or WS.

## Split names (this fork)

| Role | Guarddograh live | Must not collide |
|---|---|---|
| ARI username (`app_name`) | `guarddograh` | `dograh` |
| `websocket_client.conf` | `[guarddograh]` → `wss://guarddograh.activi.io/api/v1/telephony/ws/ari` | `[dograh]` → `wss://pre-main.activi.io/...` |
| Stasis (generated) | `dograh_cba9558c7e96` in `from-guarddograh-stasis` | `Stasis(dograh)` / `from-dograh-stasis` |
| From / TG register | PJSIP **310** | 200/300/555 Sipgate/old TG |

Same Stasis name on two Dograh installs = one goes deaf, no error.

## ari_additional_custom.conf

`[dograh]` already lives in FreePBX-generated `ari_additional.conf`. Putting `[dograh]` again in `*_custom.conf` → sorcery **duplicate object dograh** → reload drops the new user. Custom file = **only** `[guarddograh]`. Then `module reload res_ari.so` and `ari show users`.

## Dialplan

`from-internal-xfer` includes `from-internal-custom` first. Steal 310 there:

```
[from-internal-custom]
exten => 310,1,Goto(from-guarddograh-stasis,${EXTEN},1)
```

Do not edit generated `ext-local`. Do not point Sipgate DIDs at the new context.

## Outbound (no code patch)

ARI `initiate_call`: if the dest does not start with `SIP/`/`PJSIP/`, it becomes `PJSIP/<raw>`. `+387…` → missing endpoint → `Allocation failed`.

Official / Cloud-identical form:

`PJSIP/<digits no plus>@310`

From-field 310 is **caller ID only**. A second ARI config does not fix this. User rule: **do not patch Dograh** so E.164 works — Cloud cannot either.

## TG400

SIP Register to **FreePBX** `ari.activi.io:5060`, User/Auth = the PBX ext (310). Never `guarddograh.activi.io` or `:8088`. Secret: `https://ari.activi.io/admin/config.php?display=extensions&extdisplay=310`. Ext must exist before TG register.

## External PBX switch

`/settings` → Preferences. Live flag `external_pbx_integrations_enabled`. Unlocks VICIdial/lead extras only. Base ARI (config, Stasis, ulaw, transfer to `PJSIP/…`) works without it.
