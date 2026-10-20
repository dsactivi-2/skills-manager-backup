---
name: dograh-selfhost-guides
description: "Use when self-hosted Dograh is broken (deploy, health, ARI ring-no-audio, TURN/WebRTC, env, production UI). Bundles offline docs + points to dograh-setup doctor and ARI runbook."
version: 1.0.0
author: activi
license: MIT
metadata:
  hermes:
    tags: [dograh, self-host, deploy, ari, production, telephony]
    related_skills: [dograh-setup, voice-ai-infrastructure, dograh-telephony, dograh-mcp-workflow-ops]
---

# Dograh Self-Host Guides (production / bugs)

## When to use

- Self-hosted Dograh (e.g. DograhEUV2) will not go production-ready
- UI/API health, Docker, ports, HTTPS, TURN
- **ARI: phone rings, no audio** while browser test works
- Env / BYOK / MCP endpoint for self-host

## Authoritative offline copies

Under `references/` (from dograh-hq/dograh docs main):

| File | Topic |
|------|--------|
| `asterisk-ari.mdx` | Asterisk ARI + external media WS + **no audio** troubleshooting |
| `docker-deploy.mdx` | Local/remote Docker, TURN ports, setup scripts |
| `environment-variables.mdx` | Full backend env SoT |
| `deployment-introduction.mdx` | Deploy overview |
| `inference-providers.mdx` | Model config BYOK / S2S / Dograh-managed |
| `mcp.mdx` | MCP client connect (cloud + self-host URL) |

Always prefer live https://docs.dograh.com if online; these files are offline backup.

## Companion skills (already on this machine)

| Skill | Use for |
|-------|---------|
| **dograh-setup** | Orient + drive official setup; run `scripts/doctor.sh` on the server |
| **voice-ai-infrastructure** → `references/dograh-ari-ring-no-audio.md` | ARI ring/no-audio runbook (DograhEUV2 vs GonoPBX) |
| **dograh-telephony** | Carrier configs (Telnyx etc.) — not ARI media path |
| **dograh** / dograh-official | REST API agents/calls/campaigns |
| **dograh-mcp-workflow-ops** | MCP workflow read/write ops |
| **live-stack-verification** | Probe running endpoints before “fixed” claims |
| **k3s-helm-production-deployment** | Only if K8s/Helm path |

## doctor.sh (read-only)

On the **Dograh server** (not PBX), from the compose directory:

```bash
bash /path/to/dograh-setup/scripts/doctor.sh --dir /path/to/compose --mode deploy
```

Local copy:

```bash
bash ~/.hermes/skills/dograh/dograh-setup/scripts/doctor.sh --help
```

Exit: 0 healthy · 1 warnings · 2 failures.

## MCP

- **Cloud workspace MCP** (workflow authoring): `https://api.dograh.com/api/v1/mcp/` — already in default Hermes if configured.
- **Self-host MCP** (same tools against your instance): `<PUBLIC_BASE_URL>/api/v1/mcp/` + API key from that instance.
  - Do not assume cloud MCP can see or fix self-host telephony logs.
  - Add a second server e.g. `dograh-selfhost` only after user provides the public HTTPS base URL and a key from **that** install.

## ARI silence quick path

1. Browser audio OK? → models OK; do not chase BYOK first.
2. Never `apt install asterisk` on PBX that already rings.
3. Find real Asterisk on PBX (`docker ps` / `ps`) → `module show like chan_websocket` etc.
4. `websocket_client.conf` → self-host Dograh `/api/v1/telephony/ws/ari`, name match, **ulaw**.
5. Parallel: Dograh API logs during silent call.

Full runbook: skill `voice-ai-infrastructure` file `references/dograh-ari-ring-no-audio.md` + `references/asterisk-ari.mdx` here.

## Production-ready checklist (self-host)

1. `doctor.sh` clean or only known warnings  
2. HTTPS UI reachable; `/api/v1/health` OK  
3. TURN ports if browser from outside LAN (3478/5349 + relay UDP)  
4. Strong `OSS_JWT_SECRET`, MinIO, Postgres passwords  
5. Telephony: ARI modules + media WS **or** carrier webhooks signed/reachable  
6. Model BYOK keys valid; one test browser call + one PSTN/ARI call with two-way audio  
7. Backups for postgres volume; image pins (`DOGRAH_VERSION`) not only `latest` in prod  

## Do not

- Install random Ubuntu `asterisk` beside an existing PBX  
- Point Asterisk media WS at cloud if the org/config is self-host (or vice versa) without intent  
- Claim production-ready without live verify on the real hosts  
