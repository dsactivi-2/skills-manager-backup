---
name: vps-reverse-proxy
description: "Use when VPS HTTP ingress must keep service ports closed."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [caddy, firewall, ingress, vps, n8n, hermes]
---

# VPS reverse proxy (firewall)

Use when the user wants one public entry so n8n, Hermes, webhooks, and later APIs are not each opened in the firewall.

## Decide first (do not skip)

| User said | Pick | Why |
|-----------|------|-----|
| 80+443 **must stay open** | **Caddy** | Classic reverse proxy, auto HTTPS, one Caddyfile line per host |
| Open **no** HTTP ports (SSH only) | cloudflared **named** tunnel | Outbound-only; not a Mac quick tunnel |
| "Proxy Hermes can steer / tools / MCP" | **Not this skill** — Toolport / `hermes mcp add` | MCP gateway ≠ firewall |
| Ad-hoc public file/link | `public-quick-tunnel-hosting` | Ephemeral trycloudflare URL |

Do **not** offer Toolport or cloudflared quick tunnel for "don't open every service port". The user corrected this twice.

## Caddy (default when 80/443 stay)

Firewall after: `22`, `80`, `443` only. Backends bind `127.0.0.1`.

Debian/Ubuntu (root) — official Cloudsmith repo:

```bash
apt-get install -y debian-keyring debian-archive-keyring apt-transport-https curl
curl -1sLf "https://dl.cloudsmith.io/public/caddy/stable/gpg.key" | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf "https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt" > /etc/apt/sources.list.d/caddy-stable.list
apt-get update && apt-get install -y caddy
```

Caddyfile (`/etc/caddy/Caddyfile`): one block per hostname. DNS A to the VPS **before** reload (this stack: `activi-apps.io`, never `activi.io`; no AAAA unless v6 peer).

```
n8n.activi-apps.io {
	reverse_proxy 127.0.0.1:5678
}
hermes.activi-apps.io {
	reverse_proxy 127.0.0.1:8642
}
```

Then: `caddy validate --config /etc/caddy/Caddyfile && systemctl enable --now caddy && systemctl reload caddy`

### DNS does not auto-wire routes

New DNS alone does nothing. Caddy auto-gets the cert **only if** the hostname is already in the Caddyfile and A/AAAA points here.

There is **no** Caddy that sees a new DNS record and guesses the backend port.

Closest automation (only if services are Docker): `lucaslorentz/caddy-docker-proxy` labels, or Dokploy/Traefik on the boxes that already run that stack. On-demand TLS = certs on first request, still needs a proxy rule; do not enable without an `ask` check.

## Pitfalls

- Mixing MCP-proxy (Toolport) with HTTP ingress. User: "ich will ein proxy für den vps damit ich nicht alle ports in der firewall öffnen muss".
- Pushing cloudflared after the user said 80+443 stay open.
- Inventing hostnames that are not created in Cloudflare yet.
- Binding n8n/Hermes on `0.0.0.0` after Caddy is up.

## Related

- `public-quick-tunnel-hosting` — Mac/ad-hoc file share only
- `mcp-hub-management` — Toolport/ToolHive for MCP tools
- `simple-agent-manager` — activi-apps.io Cloudflare zone
