# Guardian-Dograh VPS first install

SoT on the branch: `custom/DEPLOY.md` + `custom/scripts/deploy.sh`.
Repo: `https://github.com/dsactivi-2/dograhfork` branch `Guardian-Dograh`.

Not: official `curl setup_remote.sh` (defaults **prebuilt**, no `custom/`).
Not: bare `docker compose up` (stock image, no overlay).

## Fresh VPS sequence

```bash
# Docker Engine + Compose plugin first (DEPLOY.md §15). setup_remote does not install Docker.
git clone -b Guardian-Dograh --recurse-submodules https://github.com/dsactivi-2/dograhfork.git
cd dograhfork
git remote add upstream https://github.com/dograh-hq/dograh.git
git submodule update --init --recursive

# setup_remote lives in scripts/ — DEPLOY.md's ./setup_remote.sh is wrong
SERVER_IP=<public-v4> \
DEPLOY_MODE=build \
REPO_SOURCE=existing \
CERT_MODE=self-signed \
FASTAPI_WORKERS=2 \
TURN_SECRET="$(openssl rand -hex 32)" \
./scripts/setup_remote.sh </dev/null

bash custom/scripts/deploy.sh remote
bash custom/scripts/diagnose.sh
```

`DEPLOY_MODE=build` + `REPO_SOURCE=existing` keeps the already-cloned overlay tree.
`CERT_MODE=self-signed` writes `.env` + certs and **does not** start the stack.
`CERT_MODE=auto/sslip` (Docker already present) calls `remote_up.sh --build` **without** `custom/compose.overlay.yaml` — double-build and stock start. Avoid on first install; overlay comes from `deploy.sh remote`.

SSH with a TTY: unset `TURN_SECRET` hangs on `read -sp`. Always preset it and `</dev/null`.

## After start

| Check | Expect |
|---|---|
| Image | `dograh-guardian-api:local` (not `dograhai/dograh-api:latest`) |
| `ServiceProviders.DEEPGRAM_EU` / `FISH_AUDIO` | both present |
| `curl -sS http://127.0.0.1:8000/api/v1/health` | 200 |
| `curl -sS http://127.0.0.1:8787/api/health` | `ok` |
| UI | Hub `dograhai/dograh-ui:latest` is intended (overlay rebuilds API only) |
| HTTPS | self-signed → browser warning once; 307 to login is live |

## Pitfall — API exit 1 / `ormsgpack`

`custom/providers/fish_audio/factory.py` imports `FishAudioTTSService` at module load.
`api/Dockerfile` pipecat extras historically omit `fish` → `No module named 'ormsgpack'` → uvicorn/arq/campaign die.

Fix on the checkout, then rebuild API only:

```bash
# add ,fish to the uv pip install '/tmp/pipecat[...]' extras line
export COMPOSE_FILE=docker-compose.yaml:custom/compose.overlay.yaml
docker compose --profile remote build api
docker compose --profile remote up -d
```

Upstream that extras line if still missing on the branch.

## Verify

```bash
docker compose -f docker-compose.yaml -f custom/compose.overlay.yaml exec api \
  python -c "from api.services.configuration.registry import ServiceProviders; print(ServiceProviders.DEEPGRAM_EU, ServiceProviders.FISH_AUDIO)"
```
