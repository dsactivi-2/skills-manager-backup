# MultiPersona AI voice agents on OrbStack

Repo: `https://github.com/akkupratap323/MultiPersona-AI-voice-agents`
Clone: `~/Code/Projects/MultiPersona-AI-voice-agents`

Pipecat FastAPI + Vite frontend. Do **not** use `deployment/docker/docker-compose.https.yml` on the Mac (Caddy, Let's Encrypt, host `:80`/`:443`).

## Overlay

Standalone `docker-compose.orbstack.yaml` at repo root (do not merge upstream `deployment/docker/docker-compose.yml` which publishes `:80`).

- backend `7860:7860`, frontend `8088:80`
- `extra_hosts: host.docker.internal:host-gateway`
- `PUBLIC_URL=http://127.0.0.1:7860`, frontend `BACKEND_URL=http://127.0.0.1:7860`
- Override `LIGHTRAG_URL=` and `LIGHTRAG_API_KEY=` empty — `client/docker-entrypoint.sh` otherwise writes a hardcoded LightRAG key into `config.js`

```
docker --context=orbstack compose -f docker-compose.orbstack.yaml --env-file .env.orbstack up -d --build
```

`.env.orbstack` is gitignored. Copy keys from the shell without echoing them.

## Keys (loader wins over README)

`app/config/loader.py` refuses to boot if these YAML fields are empty (no `/health`):

| YAML path | Env | Role |
|---|---|---|
| `stt.config.api_key` | `DEEPGRAM_API_KEY` | STT |
| `tts.config.api_key` | `CARTESIA_API_KEY` | TTS (config.yaml; not ElevenLabs) |
| `conversation.llm.api_key` | `DEEPSEEK_API_KEY` | LLM (config.yaml; `.env.example` says Groq — ignore) |

Non-empty dummy `pending` unblocks HTTP only. Voice stays dead until real Cartesia + DeepSeek (or a yaml change to Groq).

Health: `GET http://127.0.0.1:7860/health` → `{"status":"healthy"}`. UI: `http://127.0.0.1:8088` and `http://personaai-frontend.orb.local` (container port 80, no `:8088` on the orb.local hostname).

## Do not

- Bind host 80/443
- Claim voice works with Deepgram alone
- Pull GHCR `nesterlabs` images for this local port — build from the cloned Dockerfile
