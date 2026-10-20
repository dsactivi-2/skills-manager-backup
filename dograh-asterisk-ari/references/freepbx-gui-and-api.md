# FreePBX 17 GUI + GraphQL (Activi chain)

Companion to SKILL.md ports/DNS. No secrets in Projektbrief.

## HTTP bind (ARI reachable)

`http_custom.conf` `[general] bindaddr=0.0.0.0` does **not** reliably override generated `http_additional.conf`.

```
fwconsole setting HTTPBINDADDRESS 0.0.0.0
fwconsole setting ENABLE_ARI 1
fwconsole reload
asterisk -rx "http show status"   # Bound to 0.0.0.0:8088
```

Dashboard yellow **“Updated Asterisk Mini HTTP Server Bind Address to Localhost”**: do **not** apply. That undoes voiceeu ARI.

ARI user: `ari_additional_custom.conf` section `[dograh]` (plaintext password). GUI TLS (Let’s Encrypt :443) ≠ ARI `http://HOST:8088`.

## --opensourceonly leftover

Script `xargs fwconsole ma -f remove` exits **123** on `oracle_connector` uninstall scripts. OSS is already there. Finish by hand: remove leftover Commercial, `ma installlocal`, `ma upgradeall`, `reload`/`restart`, purge `sysadmin17` `ioncube-loader-82`. UCP upgrade may fail without `g++` — skip (not this chain).

## GraphQL M2M (admin, not calls)

Machine-to-Machine, scopes `gql rest` or blank. Authorize URL unused.

Token: POST `…/admin/api/api/token` `grant_type=client_credentials` + client_id/secret in **body**. DB `api_applications.client_secret` may not match the GUI one-time secret → 401; use the GUI secret.

Store: `~/.hermes/secrets/freepbx-api.env` mode 600. Never chat/brief.

GraphQL = extensions/trunks/routes. ARI = live calls (Dograh). SSH `asterisk -rx` = register/logs. Do not add ari-py beside Dograh.

## Sipgate test

PJSIP trunk + Register is a **test path**. Yeastar TG remains SoT. `Registered` ≠ audio path (needs extension + outbound route).
