# External PBX switch vs Asterisk ARI (Activi)

Official docs: `integrations/telephony/asterisk-ari` + `integrations/telephony/vicidial` § Enable the organization feature.

## Order (docs)

1. Asterisk: ARI user, HTTP `:8088`, `websocket_client.conf` section
2. Dograh `/telephony-configurations` → Asterisk ARI → Save (Stasis name **generated**)
3. Dialplan `Stasis(<generated>)` + `dialplan reload`
4. Phone number + inbound workflow on **that** config

Do not hang `from-pstn` on a new Stasis name until the user asked for inbound cutover.

## Do not share one Stasis app

Asterisk hands a Stasis application to the last ARI registrant. Two Dograh configs with the same `app_name` (often `dograh`) **silently steal** each other's calls — no error.

New instance (guarddograh) needs a **new** `websocket_client.conf` section **and** its own generated Stasis name. Do not retarget the existing `[dograh]` URI (it may point at another Dograh host). Read live:

```
# names + uri only — never print passwords
python3 -c "from pathlib import Path
p=Path('/etc/asterisk/websocket_client.conf')
print(''.join(l if 'password' not in l.lower() else l.split('=')[0]+'=<redacted>\n' for l in p.read_text().splitlines(True)))"
asterisk -rx "dialplan show from-dograh-stasis"
```

ARI reachability from a Dograh VPS: `curl -sS -o /dev/null -w '%{http_code}\n' --max-time 8 http://ari.activi.io:8088/ari/asterisk/info` → **401** = HTTP up (auth required). Timeout = firewall/bind.

## Flag check (no secrets)

```
curl -sS -H "X-API-Key: $KEY" https://<host>/api/v1/organizations/preferences
# look at external_pbx_integrations_enabled
```

OSS DB: `organization_configurations.key = ORGANIZATION_PREFERENCES`.

## Guarddograh vs voiceeu (class, not snapshot)

- Guarddograh can have **no** `provider=ari` row (Cloudonix-only is possible). Module-OK on FreePBX ≠ ARI config exists on that Dograh.
- voiceeu may already own `http://ari.activi.io:8088` + `Stasis(dograh)`. Attaching a third Dograh there without a new app name breaks the first.
- Media URI host ≠ Dograh UI host until someone changes `websocket_client.conf`. Always read the file; do not assume voiceeu or guarddograh.

SSH PBX: skill `ownfreepbx` (IdentityAgent=none + `id_ed25519_pbx_tg400`). SSH Guardian: `snapshot-settings`.
