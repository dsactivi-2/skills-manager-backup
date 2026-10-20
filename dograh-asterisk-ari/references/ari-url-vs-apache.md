# ARI URL vs Apache GUI (Activi)

Two listeners on the same hostname:

| URL | Process | Role |
|---|---|---|
| `https://ari.activi.io/` | Apache :443 | FreePBX GUI → `/admin` |
| `http://ari.activi.io:8088` | Asterisk `res_http` | ARI REST + `/ari/events` WS |

`fwconsole setting HTTPBINDADDRESS 0.0.0.0` + `ENABLE_ARI 1`. TLS for Asterisk HTTP stays `127.0.0.1:8089`. Hetzner FW: **8088 only from Dograh A**.

Do **not** `ProxyPass /ari` to 8088 on the public vhost.

Create config (voiceeu REST, not MCP):

```
POST /api/v1/organizations/telephony-configs
X-API-Key: …
{"name":"pbx-tg400","is_default_outbound":false,
 "config":{"provider":"ari","ari_endpoint":"http://ari.activi.io:8088",
           "app_name":"dograh","app_password":"…","ws_client_name":"dograh"}}
```

Then `POST …/telephony-configs/{id}/phone-numbers` with `address=sipgate-test` if needed.

Verify: `asterisk -rx "ari show apps"` lists `dograh` after the manager poll (~60s).
