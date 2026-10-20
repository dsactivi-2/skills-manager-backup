# girl-agent on OrbStack

Repo: `https://github.com/AnnenkovLabs/girl-agent` (image labels still TheSashaDev). Clone target: `~/Code/Projects/girl-agent`.

## Do not merge upstream compose

`docker-compose.yml` is incomplete: `build: .`, volume `./data:/app/data`, no ports. The image uses `GIRL_AGENT_DATA=/data` and `WORKDIR /home/app`. Compose merge **appends** volumes, so an overlay cannot fix the bad bind.

Use a **standalone** `docker-compose.orbstack.yaml` (build local image, named volume `/data`, `3000:3000`, `GIRL_AGENT_HOST=0.0.0.0`, `GIRL_AGENT_NO_BROWSER=1`, `extra_hosts: host.docker.internal:host-gateway`).

```
docker --context=orbstack compose -f docker-compose.orbstack.yaml up -d --build
```

Health: `GET http://127.0.0.1:3000/api/system/health` → `{"ok":true}`. Also `http://girl-agent.orb.local:3000`. WebUI auth is off unless `GIRL_AGENT_WEBUI_PASSWORD` / `GIRL_AGENT_WEBUI_TOKEN` is set.

## LLM is per-profile, no BASE_URL env

`configFromEnv()` has `GIRL_AGENT_API_PRESET` / `_API_KEY` / `_MODEL` but **no** `GIRL_AGENT_BASE_URL`. Preset `ollama` is `http://localhost:11434/v1` (container loopback). Persist via `POST /api/profiles` (empty list at first start):

- `llm.presetId`: `ollama`
- `llm.proto`: `openai`
- `llm.baseURL`: `http://host.docker.internal:11434/v1`
- `llm.apiKey`: `ollama` (dummy; `apiKeyRequired: false`)
- `llm.model`: whatever `ollama list` actually has (do not use repo default `llama3.1`)

Verify from the container against `/v1/chat/completions`, not only `/api/version`. Leave runtime `stopped` until a Telegram token exists.

`nationality` in code is only `RU` | `UA`. Timezone can still be `Europe/Berlin`.

## Telegram later

Bot API = BotFather token (`GIRL_AGENT_MODE=bot` / `telegram.botToken`). Userbot = MTProto (`api_id`/`api_hash`/phone); ban risk — extra test account only. Do not start the runtime without a token.
