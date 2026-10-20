# LiveKit Inference-Toggle + Fish Edge (2026-08-24)

## Dashboard „Inference region restriction = Enabled“
Nur **LiveKit Inference**-Modelle der Projekt-Datenregion. Nicht: Fish-Plugin, Deepgram mit eigener EU-URL, Soniox-Plugin, SIP, Observability.

## Fish: Edge Zagreb ≠ Rechnen USA
Gemessen (Dograh): API-Origin USA, Entry Zagreb. Latenz oft ok, weil STT+LLM länger dauern. Residenz bleibt USA. Primär Fish Ela lassen.

## Soniox A/B (EU)
- ~0,70 USD / h Audio (`tts-rt-v2`)
- Default-WS = US. EU: `wss://tts-rt.eu.soniox.com/tts-websocket` + EU-Projekt-Key
- Keine native bs-Stimme: Maya/Mina + `language=bs` oder Clone
- BiH = latinica **und** ćirilica. Amina = latinica. Soniox liest keine ćirilica (API, nicht Landessprache)
- Tags EN: `[happy]` `[calm]` `[pause]` `[laughs]` `[sighs]` `[breathy]` — Doku `emotion-and-tone`
