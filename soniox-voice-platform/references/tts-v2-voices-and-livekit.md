# Soniox TTS v2 + LiveKit (2026-08-24)

## Voices
- List: `GET https://api.eu.soniox.com/v1/tts-models` (EU key).
- `GET /v1/models` = STT only. `GET /v1/voices` = clones (often `[]`).
- **`Maya` + `tts-rt-v2` = HTTP 400.** Maya only on `tts-rt-v1` (deprecated 2026-08-31).
- v2 default for Amina: **Nina** + `language=bs` + `speed=0.9`. Also Mina/Emma/Grace.
- Plugin default is still Maya/`en`/`tts-rt-v1-preview`/`1.0` — never rely on it. Maya + `tts-rt-v2` = HTTP 400.
- REST: `POST https://tts-rt.eu.soniox.com/tts`

## LiveKit
- Plugin `livekit-plugins-soniox` only. No extra Soniox SDK for the agent.
- Docs MCP = docs only (no OAuth/account).
- Env: `SONIOX_API_KEY`, `SONIOX_TTS_WS=wss://tts-rt.eu.soniox.com/tts-websocket`, `SONIOX_TTS_VOICE=Nina`, `SONIOX_TTS_MODEL=tts-rt-v2`, `SONIOX_TTS_LANGUAGE=bs`, `SONIOX_TTS_SPEED=0.9`.
- `scripts/write_env_local.py` must default Nina, not Maya.
- EU key: `api.eu` 200 / `api.soniox.com` 401.
- Parallel Amina: leave Fish Ela; no Fish hyphen lexicon on Soniox v1 path.
- Hermes preview blocks `.env.local`.
