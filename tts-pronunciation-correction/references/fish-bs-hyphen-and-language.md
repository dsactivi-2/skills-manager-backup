# Fish bs: hyphens, locale, playground votes (2026-08-24)

LiveKit Amina / Ela (`d9b1befa09a34947b8c334268767abb6`), s2.1-pro plugin.

## Locale
- Fish TTS API + LiveKit `fishaudio.TTS`: **no language field**.
- Inference Fish language list: `en zh ja de fr es ko ar ru nl it pl pt` — **no bs**.
- Dashboard voice chip **BS** = ISO 639-1 `bs`. Not `bs-BA` (Azure BCP-47) and not `BA` (country).
- Deepgram Nova-3 (LiveKit STT table): **`bs`**. Keep STT on `bs`.
- Sending undocumented `language=BS|bs|bs-BA` still HTTP 200; file-size variance matches repeated `none` (temperature). macOS HFS is case-insensitive (`lang-BS.wav` == `lang-bs.wav`).

## Hyphens (ear + code)
User playground text that sounded right hyphenated **only** Ami-na / pita-nja / trenu-tak.
Agent v2 (`prepare_tts_text`): lexicon first (đ→dž + those forms), then last-syllable split if ≥3 vowels; `do_not_touch` includes kratkog/kratko/kratak, Firmira, Aquaphor, Smile.
Playground “good” sample did **not** hyphenate Recite / pijete / flaširanu. Full auto can over-split (`Reci-te`) — raise vowel threshold to 4 if choppy.
`normalize=false` (EN/ZH only). `normalize_loudness=true`. Playground speed **1.1×**; agent unset = 1.0.

## Playground Take 1 / Take 2
UI: two free takes + “Take 1 better / Take 2 better / both good / both bad” → “helps us improve the model.”
That is **pairwise preference for Fish’s global s2.x RLHF/GRPO** (S1 blog, S2 paper). It does **not** retrain Ela. No published N. Typical DPO/RLHF needs thousands of pairs before a new model ship. Vote if already listening; do not wait on votes for Amina quality.

## Proof of LiveKit Inference region
Dashboard “restrict models to project data region” is a **catalog filter**, not proof of compute region.
Live call metrics: `inference_deployment: azure_francecentral_datazone` on `openai/gpt-4.1` + `provider=azure` — that string is the residency evidence.
`provider=azure` ≠ user’s Foundry `rgdsds` / `activids` endpoint.
