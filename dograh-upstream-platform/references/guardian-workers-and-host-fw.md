# Guardian-Dograh: worker count + host firewall

Live-verified 2026-08-18 on `guardiandograh` / `178.104.210.224`.

## FASTAPI_WORKERS — executable script is SoT

| Quelle | Was sie sagt |
|---|---|
| `scripts/setup_remote.sh` | `read -p "[2]:"` then `${FASTAPI_WORKERS:-2}`; non-TTY sets `"2"` |
| `docs/deployment/docker.mdx` | Enter = default **4** — **stale** vs script |
| `dograh-guardian/RUNBOOK.md` §7.2 | „Enter (4)“ — **stale** vs script |
| `custom/DEPLOY.md` | no count; ~4 vCPU recommended |

This host: `FASTAPI_WORKERS=2` → two uvicorn (`:8000`, `:8001`), nginx `least_conn`. Do not bump to 4 because the MDX/RUNBOOK say 4. Change only on explicit ask, then `.env` + recreate `dograh-init`/`nginx`/`api` with `COMPOSE_FILE=docker-compose.yaml:custom/compose.overlay.yaml`.

## Host not protected

UFW inactive. iptables `INPUT ACCEPT`. Docker publishes on `0.0.0.0`:

- Need: 22, 80/443, TURN 3478/5349 TCP+UDP, UDP 49152–49200
- Optional: 8787 Guardian (no token = public)
- Do not expose: Redis 6379, Postgres 5432, API 8000, UI 3010 (those go through 443)

Two layers: Hetzner Cloud Firewall (in front of the VM; not readable from the guest without `HCLOUD_TOKEN`) then OS. „OS offen“ = a packet that arrives is accepted.

See also `references/guardian-dograh-vps.md`.
