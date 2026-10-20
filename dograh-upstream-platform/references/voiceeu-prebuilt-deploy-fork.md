# voiceeu prebuilt deploy from dograhV2 fork

## Live layout (DograhEUV2) — after Deepgram-EU ship 2026-07-30

| | |
|--|--|
| Host | voiceeu.activi.io / `DograhEUV2` |
| Compose dir | `/root/dograh/dograh` |
| **API (live)** | **`dograhv2-api:dg-eu`** (= `dg-eu-83d960f`, fork main PR #6) |
| UI | still `dograhai/dograh-ui:1.43.0` |
| Rollback image | `dograhai/dograh-api:rollback-pre-dg-eu` (= original `1.43.0` digest) |
| Data | Volume `dograh_postgres_data`; MinIO; `.env` |
| Stock update | `update_remote.sh` → **dograh-hq** + Hub — still does **not** track fork |

`.env` may set `DEEPGRAM_BASE_URL=api.eu.deepgram.com` (code default same).

## Fork is not live until image swap

```
dsactivi-2/dograhV2 main  (code, e.g. Deepgram EU PR #6)
        │
        ✗ update_remote.sh does NOT use this
        │
        ▼ build api/Dockerfile  →  dograhv2-api:dg-eu
        │
        ▼ compose pin API image only  →  docker compose up -d --no-deps api
        │
voiceeu running container
```

Verify **inside** container after deploy:

```bash
docker exec dograh-api-1 python -c "from api.constants import DEEPGRAM_BASE_URL; print(DEEPGRAM_BASE_URL)"
# expect: api.eu.deepgram.com

docker exec dograh-api-1 python -c "
import api.services.pipecat.service_factory as sf
print(sf._deepgram_inference_urls())
# ('api.eu.deepgram.com', 'wss://api.eu.deepgram.com/v2/listen', 'wss://api.eu.deepgram.com')
"
curl -fsS -o /dev/null -w "%{http_code}\n" https://voiceeu.activi.io/api/v1/health
```

Pre-deploy stock Hub 1.43.0: no `DEEPGRAM_BASE_URL` attribute.

## Server build without BuildKit (live lesson)

DograhEUV2 Docker often has **no buildx**. Official `api/Dockerfile` uses `# syntax=docker/dockerfile:1` + `RUN --mount=…` → fails legacy builder.

| Step | Action |
|------|--------|
| 1 | Clone `dsactivi-2/dograhV2` + `git submodule update --init --recursive` (pipecat) |
| 2 | Patch Dockerfile: drop `# syntax=…`; replace requirements/pipecat `--mount` with `COPY` + plain `RUN uv pip …` |
| 3 | `DOCKER_BUILDKIT=0 docker build -f api/Dockerfile --build-arg TARGETARCH=amd64 -t dograhv2-api:dg-eu .` |
| 4 | Without `TARGETARCH=amd64`, ffmpeg stage dies: `TARGETARCH: parameter not set` |

Helper used on ship: `/tmp/patch_dockerfile_nobuildkit.py` (session); keep recipe here.

Prefer GH Actions `workflow_dispatch` → ghcr when buildx/registry available.

## Data loss?

| Keep | Touch |
|------|--------|
| Postgres volume, MinIO, `.env`, org model config in DB | API container image only |
| UI image (backend-only change) | short API downtime; active calls drop |

Normal update = image replace, **not** `docker compose down -v`.

## Rollback (simple)

Before switch:

```bash
docker tag dograhai/dograh-api:1.43.0 dograhai/dograh-api:rollback-pre-dg-eu
cp docker-compose.yaml docker-compose.yaml.bak.pre-dg-eu
cp .env .env.bak.pre-dg-eu
```

Fail → pin compose to `dograhai/dograh-api:rollback-pre-dg-eu` or `:1.43.0` →  
`docker compose up -d --no-deps api`.

Scripts (local helpers):  
`~/Code/Tools/dograh-aquaphor-telesales/deploy/voiceeu-deepgram-eu/` (`01`…`04`; default `RUN_REAL=0`).

### Rollback folder (ops + git) — preferred

| | |
|--|--|
| **Server** | `/root/dograh/dograh/rollback/` |
| **Repo** | `dsactivi-2/dograhV2` → `deploy/voiceeu/rollback/` (PR #7) |
| TOC / history | `README.md` + `DEPLOYMENT_LOG.md` |
| One-command rollback | `./rollback-api-to-pre-dg-eu.sh` |
| State check | `./verify-current.sh` |

```bash
ssh dograh-vps
cd /root/dograh/dograh/rollback
./verify-current.sh
./rollback-api-to-pre-dg-eu.sh   # if needed
```

## Verify Deepgram host on a real call (safest/fastest)

```bash
ssh dograh-vps
docker logs -f dograh-api-1 2>&1 | grep -iE 'deepgram|api\.eu\.deepgram|api\.deepgram|/v1/listen'
# then trigger one call
```

| Log | Meaning |
|-----|---------|
| `api.eu.deepgram.com` + listen/wss | **EU STT OK** |
| only `api.deepgram.com` + `/v1/projects` | key validate (US) — normal |
| `api.deepgram.com` + `/v1/listen` without `.eu` | US inference — wrong image/env |

Org must set Transcriber=Deepgram or listen logs stay quiet.

## Dry-run gate

**No real deploy without explicit user Freigabe.** Then `RUN_REAL=1` on server.

## Plain-DE

- Repo = Bauplan; Server = Image muss neu  
- Deploy = nur API-Container tauschen  
- Rollback = Ordner `rollback/` + ein Script  
- DB bleibt im Volume  
- Call-Check = log-grep first, not tcpdump  
