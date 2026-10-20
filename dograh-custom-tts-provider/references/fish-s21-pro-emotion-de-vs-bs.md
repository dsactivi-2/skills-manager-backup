# Fish S2.1-Pro: emotion tags, Pipecat, DE vs BS

Verified 2026-08 against live Fish docs, public Pipecat `main` `FishAudioTTSService`, dograh-hq checkout `133fdf0`, and dsactivi-2/dograhV2 factory/registry/tests. Companion to `fish-emotion-and-g2p-in-dograh.md`.

## Three levers (do not conflate)

| Lever | Where | Does emotion? |
|---|---|---|
| Org TTS `PUT /api/v1/user/configurations/user` | `model`, `voice` (clone `reference_id`), `speed`, `latency`, `language` | No — voice/tempo only |
| Spoken LLM text | globalNode + agentNode + startCall greeting | Yes — `[tags]` in the sentence |
| `text_filters` respell | factory, before Fish | Pronunciation only |

Dograh has no emotion UI field. Azure HQ builds SSML and **escapes** agent text. Fish is the opposite: tags must survive as plaintext.

## Pipecat `FishAudioTTSService` (public main)

Source: `https://github.com/pipecat-ai/pipecat/blob/main/src/pipecat/services/fish/tts.py`

- Default **model is `s2.1-pro`** (changelog 5246; was `s2-pro`).
- Transport: `wss://api.fish.audio/v1/tts/live`, header `model`.
- StartEvent: `reference_id`/`voice`, `format`, `latency`, `normalize`, `prosody.{speed,volume}`. **No `language` field is sent.**
- TextEvent: `{"event":"text","text": ...}` verbatim. Tags must already be in `text`.
- Fish HTTP/WS `TTSRequest` has **no language parameter** (OpenAPI). Detection is from the text.

## dograh-hq vs dograhV2

| | dograh-hq | dsactivi-2/dograhV2 |
|---|---|---|
| Fish provider | **Absent** (enum ends at LMNT; Cloud doc `configurations/voice` lists no Fish) | `FISH_AUDIO = "fish_audio"` |
| Factory | no `elif` | `FishAudioTTSSettings` + `output_format="pcm"` |
| Default model | — | **`s2-pro`** if unset — pin `s2.1-pro` explicitly |
| `language=de` / `bs` | — | `Language.DE` / `Language.BS`; unknown codes stay raw (not coerced to EN like Rime) |
| `XMLFunctionTagFilter` | strips XML function tags only | same — `[calm]` passes |

HQ Cloud cannot “add voice ID” to invent Fish. Fork only.

## Tag syntax (`s2.1-pro`)

Sources: https://docs.fish.audio/developer-guide/core-features/emotions.md · models-overview.md

| Model | Syntax | Sentence emotion | Tone/FX | Free-form |
|---|---|---|---|---|
| `s2.1-pro` / `s2-pro` | `[square]` | start of sentence | anywhere | yes (`[whispers sweetly]`) |
| `s1` | `(round)` | start required | anywhere | no — fixed list |

- One primary emotion per sentence; max 3 combined.
- Tags are performed, never spoken. Wrong generation → spoken or ignored.
- Not SSML. Not `Fish[calm]`. Not `<break/>`.
- Official examples use **English** tag words even for other languages.

## German (official)

| Fact | Evidence |
|---|---|
| DE in S1 “13 languages can use emotion markers” | emotions.md Language Support: EN, ZH, JA, **German**, FR, ES, KO, AR, RU, NL, IT, PL, PT |
| DE named on S2.1 | https://fish.audio/blog/s2-1-pro-free-api |
| Fish Agents `speaking_language` includes `de` | voice-language.md — only `en ja zh ko es fr de` |
| fish-speech Tier 2 | `de` (github.com/fishaudio/fish-speech) |
| Phoneme lexicon | **No** — only EN/ZH/JA (fine-grained-control.md) |
| `normalize` numbers/dates | EN+ZH only (TTS OpenAPI) |

Org: `provider=fish_audio`, `model=s2.1-pro`, German clone, `language=de`.
Prompt: German speech + English `[calm]` / `[empathetic]` / `[emphasis]` / `[break]` at sentence start.

## Bosnian (not the same support)

| Fact | Evidence |
|---|---|
| `bs` in emotions.md 13-language list | **No** |
| `bs` named on S2.1 blog | **No** (“dozens more”, no bs) |
| Fish Agents `speaking_language` | **No `bs`** |
| fish-speech | `bs`/`hr`/`sr` in **Global Coverage**, not Tier 1/2 |
| Official 83-language table with `bs` | **Not published** on docs.fish.audio |
| Phoneme / lexicon / normalize | none for bs |
| dograhV2 “auto-detect including Bosnian” | **Fork claim + unit test**, not Fish SoT |

Treat bs emotion as **empirical**. Keep diacritics `čćšžđ`. Respell OOV names (`Đenita`→`Dženita`). Use short English tags, fewer than DE. Do not set `language=de` on a bs agent.

## Hörtest (required)

DE: `[calm] Guten Tag…` / `[empathetic] Das tut mir leid.` / `Das ist [emphasis] wichtig.`
BS: `[calm] Dobar dan…` / same pattern.
Negatives: `(calm)`, `<break>`, `Fish[calm]`, mid-sentence sentence-emotion.

Tag spoken aloud → wrong model (s1) or escaped brackets. No affect on bs → coverage/voice, not a missing org “emotion” field.
