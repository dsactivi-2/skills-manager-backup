# Hermes phone via PBX (not AgentCall)

AgentCall MCP is not the Activi path. Hermes-on-the-phone = FreePBX ext → Guarddograh Stasis on `ari.activi.io`.

## Ext hop (user correction)

Do not switch 320→310→300 mid-task. Wait for the last explicit extension. Never delete a just-created ext because another number was named. 320 Hermes PJSIP may exist unused (`~/.hermes/secrets/freepbx-ext320.env`) — leave it unless the user names 320.

## Live inbound (verified)

| Ext | Role |
|---|---|
| 310 | Guarddograh default CID + inbound WF 2; TG registered; `from-internal-custom` → `from-guarddograh-stasis` → `Stasis(dograh_cba9558c7e96)` |
| 300 | TG `tg400` register **and** extra Guarddograh inbound (`hermes-ext-300`, WF 2, not default CID). Same Stasis. Internal dial hits AI first, not TG ring |
| 320 | leftover Hermes PJSIP, no Stasis |

Sipgate 897/898 stay on `Stasis(dograh)` (voiceeu). Do not invent TG GSM dest.

## Guarddograh phone API

```
GET/POST https://guarddograh.activi.io/api/v1/organizations/telephony-configs/2/phone-numbers
```

Org-root `/api/v1/organizations/phone-numbers` = **404**. Create: `{address, label?, inbound_workflow_id?, is_active, is_default_caller_id}`. Address immutable. Do not flip 310 default CID.

## GraphQL / secret (ownfreepbx is user-owned — also here)

```
{ fetchAllExtensions { status message extension { extensionId tech user { name } } } }
```

`addExtension` requires `extensionId`, `name`, `email`. `fwconsole mysql` has no `-e`/`-N`. Pull `password=` from `/etc/asterisk/pjsip.auth.conf` `[NNN-auth]` into `~/.hermes/secrets/freepbx-extNNN.env` (600). Never chat.

Dialplan: only `extensions_custom.conf` + `dialplan reload`. See `from-internal-custom-stasis.md`.
