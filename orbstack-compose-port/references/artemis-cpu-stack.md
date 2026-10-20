# Artemis (momori777/Artemis) — OrbStack CPU-Port

Repo: `/Users/activi/Code/Projects/Artemis`
Compose: `orbstack/docker-compose.yml`
State: `.artemis-openclaw/` (nicht `~/.openclaw`)
Image: `artemis-orbstack:cpu` from `orbstack/Dockerfile` (`python:3.12-slim`)

## Start

```
docker --context=orbstack compose -f /Users/activi/Code/Projects/Artemis/orbstack/docker-compose.yml up -d
```

Chat-Modell: Env `ARTEMIS_OLLAMA_CHAT_MODEL` (Default `kimi-k2.6:cloud`).
GW-Token: `.artemis-openclaw/openclaw.json` → `gateway.auth.token`

## Ports (live)

| Dienst | Port |
|---|---|
| LLM-Shim → Host-Ollama | 8080 |
| Embeddings (Ollama all-minilm) | 9999 |
| Live2D Bridge | 19200 / WS 19201 |
| Artemis Bridge (TTS/Comfy API) | 19250 |
| Headroom | 19251 |
| Daemon / Chat-API | 19260 |
| WebChat | 19270 |
| Task Board | 19280 |
| OpenClaw Gateway | 18789 / 18790 |

OpenClaw mount: Repo → `/workspace`, Image bleibt `/app`.

## CPU-Fallbacks

- llama.cpp GGUF: `orbstack/llm_ollama_shim.py`
- GPT-SoVITS: `orbstack/tts_edge.py` (edge-tts + ffmpeg)
- ASR: `orbstack/asr_cpu.py` (faster-whisper tiny)
- Embed: `ARTEMIS_OLLAMA_EMBED_URL` — Vektoren als Python-`list` behandeln

## Auslassungen

GPU-GGUF, SoVITS-Gewichte, ComfyUI-Checkpoints, Cosmos, Sakura-PySide6, Live2D-Modelle (`live2d/model/` gitignored), QQ/TG ohne Token.
