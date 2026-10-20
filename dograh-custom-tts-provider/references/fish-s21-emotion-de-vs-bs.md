# Fish S2.1-Pro emotion tags: DE vs BS (verified 2026-08)

Official Fish + public Pipecat + dograh-hq vs dograhV2 / dograh-devshift.

## Where tags live
Tags are **in the spoken LLM text**, not in Org TTS config. Dograh has no emotion UI field.
Pipecat `FishAudioTTSService.run_tts` sends `{"event":"text","text": text}` unchanged.
`XMLFunctionTagFilter` strips XML function tags only — `[calm]` passes.
Factory `prosody_speed` / `prosody_volume` = global tempo/volume, not scene emotion.

## Syntax by model
| Model | Syntax | Free-form |
|---|---|---|
| `s2.1-pro` / `s2-pro` | `[brackets]` | yes (`[whispers sweetly]`) |
| `s1` | `(parentheses)` | no, fixed list |

Public Pipecat default model is now **`s2.1-pro`** (`pipecat/src/pipecat/services/fish/tts.py`).
dograhV2 `FishAudioTTSConfiguration` default is still **`s2-pro`** — pin `s2.1-pro` in Org TTS.

Sentence emotion at **sentence start**. Tone/effects anywhere. Max 1 primary emotion/sentence.
Wrong for 2.1: `(calm)`, `Fish[calm]`, Azure SSML `<break/>`.

Sources:
- https://docs.fish.audio/developer-guide/core-features/emotions
- https://docs.fish.audio/developer-guide/models-pricing/models-overview
- https://docs.fish.audio/api-reference/endpoint/websocket/tts-live.md

## Language is NOT equal (do not treat bs like de)
| | German | Bosnian |
|---|---|---|
| S1 official emotion-language list (13) | yes | **no** |
| Named on S2.1 blog language list | yes | not named |
| Fish Agents `speaking_language` | `de` allowed | **no `bs`** (only en, ja, zh, ko, es, fr, de) |
| fish-speech README | Tier 2 `de` | Global Coverage code `bs` only |
| Phoneme / lexicon | none (EN/ZH/JA only) | none |
| `normalize` numbers/dates | EN+ZH only | EN+ZH only |
| Pipecat `Language` enum | `DE` | `BS` exists |
| Fish HTTP TTSRequest `language` field | **does not exist** — autodetect from text | same |

Pipecat Fish Settings has `language` but **does not send it** in the WebSocket StartEvent (only voice, format, latency, normalize, prosody). Autodetect = text diacritics + clone language.

DE: official sentence-start English tags (`[calm] Guten Tag…`).
BS: not officially emotion-hardened. Keep English tags (`[calm]` not `[smireno]`), fewer tags, Hörtest required. Keep čćšžđ. Respell OOV names (`Đenita` → `Dženita`).

Sources:
- https://docs.fish.audio/agents/build/voice-language
- https://fish.audio/blog/s2-1-pro-free-api
- https://github.com/fishaudio/fish-speech README (tiers)
- https://docs.fish.audio/developer-guide/core-features/fine-grained-control

## Repo split
| Tree | Fish TTS |
|---|---|
| dograh-hq (`configurations/voice` + registry ends at LMNT) | **not shipped** |
| dsactivi-2/dograhV2 | `FISH_AUDIO`, factory branch, tests `language=de` / `language=bs` |
| dograh-devshift `/Users/activi/Projects/dograh-devshift` | fork workdir (not `~/Code/Projects`) |

Org TTS PUT `/api/v1/user/configurations/user`: `model`, `voice` (reference_id), `speed`, `latency`, optional `language` hint. Tags go in globalNode / agentNode / greeting text.
