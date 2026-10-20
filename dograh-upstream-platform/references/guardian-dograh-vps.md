# Guardian-Dograh VPS (third instance)

Not voiceeu. Not Cloud. Fresh self-host from `dsactivi-2/dograhfork` branch `Guardian-Dograh`.

| | Value |
|--|--|
| Host | `guardiandograh` / `178.104.210.224` |
| UI | **https://guarddograh.activi.io** |
| Guardian UI | http://guarddograh.activi.io:8787 |
| Checkout | `/root/dograhfork` |
| SSH | `Host snapshot-settings` · `IdentityFile ~/.ssh/snapshot_settings` |
| SoT | `custom/DEPLOY.md` on that branch |

`voiceeu.activi.io` stays on `167.233.126.212`. Never point that A-record here.

## First install (empty Ubuntu)

1. Docker Engine + Compose plugin (DEPLOY.md §15) — `setup_remote.sh` does **not** install Docker.
2. `git clone -b Guardian-Dograh --recurse-submodules https://github.com/dsactivi-2/dograhfork.git && git remote add upstream https://github.com/dograh-hq/dograh.git`
3. Non-interactive `scripts/setup_remote.sh` (script lives under `scripts/`, not repo root):

```bash
export SERVER_IP=<public-v4>
export DEPLOY_MODE=build
export REPO_SOURCE=existing
export CERT_MODE=self-signed   # so setup does not remote_up without overlay
export FASTAPI_WORKERS=2
export TURN_SECRET="$(openssl rand -hex 32)"
./scripts/setup_remote.sh </dev/null
```

TTY without `TURN_SECRET` hangs on the secret prompt and exits 1. Non-TTY without `DEPLOY_MODE` defaults to **prebuilt** (stock images, no `custom/`).

4. Start **only** via overlay:

```bash
bash custom/scripts/deploy.sh remote
```

Never bare `docker compose up` or `./remote_up.sh` without
`COMPOSE_FILE=docker-compose.yaml:custom/compose.overlay.yaml`.
Stock `setup_custom_domain.sh` `cd dograh` + `./remote_up.sh` drops the overlay.

## API crash: `No module named 'ormsgpack'`

`custom/providers/fish_audio/factory.py` imports Fish TTS at module load.
`api/Dockerfile` pipecat extras must include `fish`. If missing, add it and rebuild `api` with the overlay compose file. Image name must stay `dograh-guardian-api:local`.

## Custom domain

CF token on this Mac is **zone-read only** for `activi.io` (DNS write → 403). User creates the A record.

| Type | Name | Value | Proxy |
|--|--|--|--|
| A | `guarddograh` | `178.104.210.224` | **off** (grey cloud) |

Then in `/root/dograhfork`: set `PUBLIC_HOST` / `PUBLIC_BASE_URL`, recreate `dograh-init` + `nginx` + `api` **with overlay**, certbot webroot `-w ./certs`, copy to `certs/local.{crt,key}`, restart nginx. ACME HTTP-01 works when `http://<host>/.well-known/acme-challenge/` is served from that bind-mount.
