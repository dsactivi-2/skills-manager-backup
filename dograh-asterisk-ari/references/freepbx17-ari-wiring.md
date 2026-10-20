# FreePBX 17 ARI + GUI (survives reload)

FreePBX **generates** `http_additional.conf` / `ari_general_additional.conf`. Do not edit those.

## Bind + enable (required)

`http_custom.conf` with a second `[general] bindaddr=0.0.0.0` does **not** win. Set SoT in FreePBX settings, then reload:

```
fwconsole setting HTTPBINDADDRESS 0.0.0.0
fwconsole setting ENABLE_ARI 1
fwconsole reload
asterisk -rx "http show status"   # Bound to 0.0.0.0:8088
```

Default after install: `HTTPBINDADDRESS=127.0.0.1`, `ENABLE_ARI=0`. voiceeu cannot reach ARI until this.

TLS 8089 can stay `127.0.0.1`. Dograh uses **HTTP** `http://HOST:8088` (Hetzner FW: 8088 only from Dograh A).

## User + media + dialplan (custom files)

| File | Content |
|---|---|
| `ari_additional_custom.conf` | `[dograh] type=user read_only=no password=…` (plaintext; not in Projektbrief) |
| `ari_general_custom.conf` | `enabled=yes` + `allowed_origins=*` (additional often has `enabled=no`) |
| `websocket_client.conf` `[dograh]` | `uri=wss://<dograh-host>/api/v1/telephony/ws/ari` `protocols=media` `tls_enabled=yes` `connection_type=per_call_config` `ca_list_file=/etc/ssl/certs/ca-certificates.crt` |
| `extensions_custom.conf` | context `from-dograh-stasis` → `Stasis(dograh)` — **do not** hang on `from-pstn` until the SIP trunk exists |

Dograh UI: ARI URL `http://<host>:8088`, Stasis App Name = ARI user section (`dograh`), WebSocket Client Name = `[dograh]`.

Verify from the **Dograh VPS** (`curl -u dograh:… http://HOST:8088/ari/asterisk/info` → 200). From the public net, 8088 must time out.

## GUI vs ARI

| URL | What |
|---|---|
| `https://host/` | Apache/FreePBX login → `/admin` |
| `http://host:8088` | ARI API only — not a browser page |

Debian ships `/var/www/html/index.html` (“It works!”). That is **not** a PBX failure. Move it aside so FreePBX `index.php` can 302 to `/admin`.

Let’s Encrypt on **443** for the GUI (`certbot --apache -d host`). Need `a2enmod ssl rewrite headers expires` or `freepbx.conf` (`ExpiresActive`) fails configtest. Do **not** point Dograh at `:443`.

First-run wizard = GUI admin only. Module updates: **Email Only**; security updates Enabled. Not SIP/ARI.

## Commercial leftovers

Endpoint Manager = desk-phone provisioning. Not TG, not Dograh. Keep it gone.
