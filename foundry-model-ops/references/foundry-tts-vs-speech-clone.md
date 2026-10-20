# Foundry TTS catalog vs Azure Speech clone (live-learned)

## Foundry / AIServices model list (SE/WE/DE)
Audio-related deployables often include:
- `tts`, `tts-hd` — OpenAI-style preset voices, **no sample clone**
- `gpt-audio*`, `gpt-realtime*` — multimodal / S2S; builtin voices; **no sample clone**
- `whisper` / `gpt-4o-*-transcribe*` — STT only
- `gpt-4o-mini-tts` — may be **absent** from a given region catalog (verify live)

No catalog hits for personal voice / custom neural / clone strings.

## Voice clone on Microsoft
| Path | Product | EU | Notes |
|------|---------|-----|-------|
| Personal Voice | Azure **Speech** (e.g. vesna GWC, mujo WE) | yes if region supports | gated access + consent; Dragon*/Phoenix* base models |
| Custom Neural Voice | Speech | yes | long training, gated |
| Foundry `tts` deploy | AIServices/OpenAI | Standard SKU | no clone |
| Camb Cloud | external | **no** proven EU residency | API US (e.g. client.camb.ai → GCP Iowa); lab only for strict residency |

## Dograh wiring
- BS prod default: Org TTS `azure_speech` + `bs-BA-VesnaNeural` / Goran @ `germanywestcentral`.
- Do not install camb-sdk on voiceeu for Dograh calls — Pipecat CambTTS may exist in image, but residency blocks prod.
- OpenAI gpt-4o-mini-tts uses **instructions** (not SSML); Dograh factory may only pass `model` — verify voice/instructions mapping before claiming parity with Vesna.
