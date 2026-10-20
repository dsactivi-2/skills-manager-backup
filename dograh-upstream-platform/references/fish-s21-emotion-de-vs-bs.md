# Fish S2.1-Pro emotion tags: DE vs BS (verified 2026-08)

Not a Dograh UI field. Tags live in the **spoken LLM text**. Org TTS only sets model/voice/speed/latency/language-hint.

## Model + syntax

| Model | Syntax | Free-form | Official production string |
|---|---|---|---|
| s2.1-pro / s2-pro | `[brackets]` | yes (`[whispers sweetly]`) | `s2.1-pro` (API default if header omitted) |
| s1 | `(parentheses)` | no, fixed list | legacy |

Sources: https://docs.fish.audio/developer-guide/core-features/emotions.md · https://docs.fish.audio/developer-guide/models-pricing/models-overview.md

Placement (S2): sentence emotion at **start**; tone/effects anywhere. Max 1 primary emotion/sentence. Not SSML. `xml_function_tag_filter` does not strip `[calm]`.

## Pipecat (public main)

`FishAudioTTSService` (`src/pipecat/services/fish/tts.py`):
- WS `wss://api.fish.audio/v1/tts/live`, header `model` (default **s2.1-pro**)
- StartEvent: voice/reference_id, format, latency, normalize, prosody — **no language field sent**
- TextEvent sends text 1:1. Tags must already be in the string.

Fish TTSRequest has no `language` field. Autodetect from text.

## dograh-hq vs forks

| | dograh-hq | dsactivi-2/dograhV2 · dograh-devshift |
|---|---|---|
| Provider | **absent** (registry ends LMNT; Cloud doc `configurations/voice` has no Fish) | `FISH_AUDIO = "fish_audio"` |
| Factory default model | — | **s2-pro** (must set `s2.1-pro` explicitly) |
| language=bs | — | `Language.BS` or raw string (do not enum-lock like Rime) |

## German — officially listed

- S1 emotion “Language Support” 13 langs **includes German**: EN, ZH, JA, **DE**, FR, ES, KO, AR, RU, NL, IT, PL, PT. **No Bosnian.**
- S2.1 blog names German among examples: https://fish.audio/blog/s2-1-pro-free-api
- Fish Agents `speaking_language`: only `en, ja, zh, ko, es, fr, de` — https://docs.fish.audio/agents/build/voice-language.md
- fish-speech README: **Tier 2** `de`. Phoneme control: EN/ZH/JA only. `normalize`: EN+ZH only.

DE org: `model=s2.1-pro`, `language=de`, German clone. Prompt: English Fish tags (`[calm]`, `[empathetic]`) at sentence start.

## Bosnian — not the same support

- Not in the 13-language emotion list.
- Not named on the S2.1 blog list; docs say “83 languages” + autodetect without publishing `bs`.
- Not in Agents `speaking_language`.
- fish-speech README: `bs`/`hr`/`sr` only under **Global Coverage**, not Tier 1/2.
- Fork registry *claims* autodetect including Bosnian — fork text, not Fish SoT.

BS org: `model=s2.1-pro`, `language=bs`, local clone, keep čćšžđ. Keep **English** tags until a listening test proves otherwise. Fewer tags than DE. Names: respell (`Đenita`→`Dženita`), no Fish lexicon.

## Where to set

| Place | Emotion? |
|---|---|
| Org PUT `/api/v1/user/configurations/user` TTS | no (voice/tempo only) |
| globalNode + agentNode + greeting text | yes (`[tag] Satz`) |
| `text_filters` respell | pronunciation only |
| Azure SSML in HQ | opposite path — agent tags escaped |
