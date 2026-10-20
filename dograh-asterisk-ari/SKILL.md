---
name: dograh-asterisk-ari
description: "Use when wiring Dograh self-host to Asterisk ARI."
---

# Dograh ↔ Asterisk ARI

Self-host without Twilio/Telnyx as the Dograh provider: **only Asterisk ARI**. ARI is the Dograh↔PBX cable. GSM/SIP gateways (Yeastar TG) hang off the PBX via SIP. Telnyx is a **separate** Dograh provider, not that SIP trunk.

TG LAN/SIM/TAR: skill `yeastar-tg-gateway` (user-owned — adopt before curator patches).

## Version gate

`chan_websocket` exists only from Asterisk **20.16 / 21.11 / 22.6 / 23.0**. Dograh docs: 22+ or 20 LTS with `chan_websocket` + `res_websocket_client`. Media **ulaw**.

```
asterisk -rx "core show version"
asterisk -rx "module show like chan_websocket"
asterisk -rx "module show like res_websocket_client"
```

Both modules **Running**. A generic “22” below 22.6 is not enough.

## What to install

| Choice | Role |
|---|---|
| FreePBX **17** + Asterisk **≥22.6** on Debian **12 x86** | GUI for extensions. Official: `FreePBX/sng_freepbx_debian_install` |
| VitalPBX 4.5 | second; WS trunk in GUI unclear |
| Asterisk 22.6 bare | no extension GUI |
| GonoPBX (`ankaios76/gonopbx`) | **not** this chain. AMI :5038, `andrius/asterisk:20`, no ari.conf/Stasis. Replace unless someone upgrades image + ARI |

Install (30–90 min, not 10–15):

```
DEBIAN_FRONTEND=noninteractive ASTVERSION=22 bash sng_freepbx_debian_install.sh --opensourceonly
```

No `--dahdi` without a card. Official script is one-shot, not idempotent — do not wrap it in Ansible on day one. No random 0-star playbooks.

VICIdial = optional layer **on** ARI (hangup / in-group / `update_lead`). VICIdial site prefers Asterisk 18 — conflicts with chan_websocket. Phase 2, not VICIbox instead of FreePBX. Code: SVN trunk / nightly zip, not GitHub SoT.

## New box, not existing app VPS

Never overlay FreePBX on `hermes` or `dograh-vps`. New Hetzner Debian 12, DE location, ≥8 GB (`cx33`).

SSH: project must contain the key used at **create**. Encrypted `id_ed25519` + 1Password agent → server accepts pubkey, BatchMode cannot sign. Dedicated key with empty passphrase; `rebuild` does **not** inject later keys — delete+create.

## Ports

| Proto | Port | Source | Why |
|---|---|---|---|
| TCP | 8088 | Dograh host only (`dig +short` the Dograh A) | ARI URL `http://HOST:8088` |
| — | media WS | **outbound** PBX → Dograh `websocket_client.conf` | no extra inbound |
| UDP+TCP | 5060 | GSM gateway (home WAN often dynamic) | SIP |
| UDP | 10000–20000 | RTP | |
| TCP | 22 / 80 / 443 | SSH + GUI | |
| — | 5038 / 3306 | closed | AMI/DB |

Hetzner Cloud Firewall > host iptables alone. Fail2ban ships with the FreePBX script. Unattended upgrades **after** the installer.

## DNS

ARI hostname: A+AAAA, **DNS only (grey)**. Orange cloud breaks SIP/ARI/RTP. A Wrangler token can list zones and still return DNS **10000** — need Zone.DNS Edit. `flarectl` reads `CF_API_TOKEN`, not `CLOUDFLARE_API_TOKEN`.

## SIP mode vs host

| Field | Meaning |
|---|---|
| Host | IP/name of **this** FreePBX — only after the box exists |
| Register | gateway registers to PBX — usual when gateway is at home |
| Peer | both know each other’s IP — needs static home WAN, DDNS, or VPN |

Do not fill the gateway trunk until Host is real.

See `references/ports-and-dns.md`.
