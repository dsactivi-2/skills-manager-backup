# ARI ports and DNS

Source: dograh-hq `docs/integrations/telephony/asterisk-ari.mdx`.

- ARI HTTP: `http.conf` `bindport = 8088`. Dograh field **ARI Endpoint URL** = `http://HOST:8088`.
- Restrict 8088 to the Dograh host A record (`dig +short` that hostname).
- Media: Asterisk **connects out** via `websocket_client.conf` to `/api/v1/telephony/ws/ari`. No inbound media port.
- Self-host URI may be `ws://` on a private net; HTTPS Dograh uses `wss://` + `tls_enabled = yes`.
- Codec on trunks that touch Dograh: `allow=ulaw`.
- AMI 5038 and DB ports stay closed to the internet.

DNS for the ARI hostname: A + AAAA, **proxied=false**. Orange cloud breaks SIP/ARI/RTP.

`flarectl dns create --zone <zone> --name ari --type A --content <ipv4>` needs `CF_API_TOKEN` and Zone.DNS Edit. Wrangler’s `CLOUDFLARE_API_TOKEN` can be zone-read-only (API 10000).
