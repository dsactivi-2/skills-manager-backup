# Camb.ai TTS + Dograh (verified 2026-07-30)

## Dograh integration (no VPS SDK install)

| Item | Value |
|------|--------|
| Provider enum | `camb` (`ServiceProviders.CAMB`) |
| Config class | `CambTTSConfiguration` in `api/services/configuration/registry.py` |
| Factory | `create_tts_service` → `pipecat.services.camb.tts.CambTTSService` |
| Models | `mars-flash` (default, ~22.05 kHz), `mars-pro` (~48 kHz), `mars-instruct` |
| Voice | integer string, default `"147320"` → cast to `int` |
| Language | BCP-47 string (default `en-us`); set on `tts._settings.language` |
| API key header | `x-api-key` |
| Live image | voiceeu `dograhai/dograh-api:1.43.0` — `CambTTSService` import OK |

**Do not** deploy a separate `camb-sdk` container on DograhEUV2 for call audio. Put the key in Dograh org/user TTS config (or workflow model config), same as other BYOK providers.

Local Mac SDK (clone/batch only): venv `~/Code/Tools/camb-sdk/.venv`; package `camb-sdk`. Store key in project env files mode 600 — never re-print full key in chat.

## Residenz / hosting (public evidence)

| Check | Result |
|-------|--------|
| `client.camb.ai` DNS/IP | GCP **US Iowa** (`35.202.222.91`, AS396982 Google) |
| Privacy Policy | Data may be stored/processed in **UAE** or **any other country** of facilities |
| Legal entity | **Ento.ai FZ LLC**; governing law **Dubai, UAE** |
| Docs | No EU data-residency / region-selector in llms.txt index |
| Cert claims | SOC 2 Type II — **not** EU residency |
| Blog "operations in Europe" | Business presence, **not** EU inference pin |

## Open-source MARS self-host (not BS)

| | MARS5-TTS | MARS6-turbo |
|--|-----------|-------------|
| Params | AR ~750M + NAR ~450M | ~70M (paper) |
| VRAM | **≥20 GB** (HF/README) | ~4–8 GB batch-1 est. |
| Language | **English only** open ckpt | English-centric |
| License | AGPL-3.0 (commercial → help@camb.ai) | check repo |
| voiceeu DograhEUV2 | no NVIDIA GPU, ~7.6 GiB RAM | same — unfit on app host |

Cloud Camb = multilingual; OS weights ≠ BS prod path.

## Prod decision matrix (Activi DE/BS)

| Use case | Camb | Azure bs-BA/de-DE Neural (Vesna/Goran) |
|----------|------|----------------------------------------|
| Strict EU audio / customer residenz claim | ❌ until written EU region + DPA | ✅ |
| Voice clone / mars-instruct emotion A/B | ✅ experiment (cloud) | Personal/Custom Neural for EU clone |
| Default live telesales BS/DE | keep off prod default | ✅ SoT |
| Dograh wiring effort | key + provider only | already freigegeben paths |
| OS MARS5/6 on voiceeu | ❌ | — |

## Best EU path for BS quality + control (session conclusion)

1. **Now:** Azure Speech GWC `bs-BA-VesnaNeural`/`GoranNeural` + lean SSML (speed/prosody/breaks).
2. **Clone + expressivity EU:** Personal Voice on same Speech resource (gated).
3. **Max emotion + EU:** ElevenLabs Enterprise EU residency API (Dograh `elevenlabs`).
4. Foundry OpenAI `tts`/`gpt-realtime` = wrong surface for BS clone.

## Wiring checklist

1. Confirm Camb in registry on target image (import `CambTTSService`).
2. Org TTS: `provider=camb`, API key, `model=mars-flash`, `voice=<id>`, `language=bs-BA|de-DE|…`.
3. Side-by-side test call vs Azure; measure TTFB + naturalness in Langfuse.
4. Clone offline with SDK → use returned `voice_id` in Dograh.
5. Residenz-strict customers: do not enable without Camb sales/legal confirmation.

## Pitfalls

- macOS PEP 668: install SDK in a venv, not system pip.
- Shell tools that reject `set -a` / bare `&` — write env files with Python when needed.
- Never print full API keys in chat after storage; verify via suffix/len + API 200 only.
- Sample-rate mismatch: mars-flash 22050 vs telephony ulaw — watch ARI quality.
