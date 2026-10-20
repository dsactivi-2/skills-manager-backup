# Round-trip pronunciation optimizer + Fish/Bosnian specifics

Session-verified detail (2026-08-01). Companion to SKILL.md.

## The problem, named correctly
- **G2P error** (grapheme-to-phoneme): the model maps spelling → wrong sound.
- Triggered by **OOV words** (out-of-vocabulary): proper names, foreign words, rare letters. This is why it hits *names* hardest, not ordinary vocabulary.
- The fix technique is **phonetic respelling** (rewrite the word the way it should sound).

## Two fix families
- **A — pronunciation dictionary / SSML `<phoneme>` / IPA lexicon** (ElevenLabs, Amazon Polly, Retell). Set once, applies everywhere. The clean, scalable way.
- **B — phonetic respelling** in the text itself. No extra system, works anywhere.

## Fish Audio specifics
- Fish has **NO** pronunciation dictionary and **NO** SSML/IPA `<phoneme>`. Family A is unavailable.
- Fish's own guidance for wrong pronunciation is literally *"rewrite hard terms phonetically."* So respelling (family B) is the **official** method there, not a hack.
- Bosnian (`bs-BA`) is **not** an officially listed Fish language (S2/S2.1-pro trained on ~80 langs, `bs` not confirmed). Regular bs words usually read fine; **eigennamen and the letter `đ` reliably break.**

## Verified Bosnian respelling rules
- `đ` → `dž` is the reliable single-letter swap. Example: `Đenite` → `Dženite` (Fish knows `dž` from words like "džezva").
- **KEEP** `č ć š ž` — do NOT convert to English digraphs `ch`/`sh`. Correct diacritics are read correctly when the model detects the language; swapping them to `ch/sh` breaks language detection and is riskier.
- For long eigennamen that "stumble," insert **syllable hyphens** without changing letters: `Baščaršije` → `Baš-čar-ši-je`, `Čekalušu` → `Če-ka-lu-šu`.
- Avoid double vowels introduced by ad-hoc respelling (`Djeenite` → "Dje-e-nite").
- Principle: **change as few words as possible.** Rewriting already-correct words causes more regressions than it fixes.

## Where the fix lives in Dograh (live path)
- Dograh's `create_tts_service` (`api/services/pipecat/service_factory.py`) passes `text_filters=[xml_function_tag_filter]` to every TTS block.
- Add a custom **search-and-replace `text_filter`** there that applies a static map `{"Đenite": "Dženite", ...}` **just before** text reaches Fish. Local, no network hop → **latency-neutral**.
- The XML function-tag filter only strips XML tags; **round `(...)` and square `[...]` emotion tags pass through**, so respelling and Fish emotion tags don't conflict.
- Emotion tags are produced by the **LLM in the answer text** (Agent-node prompt), not by TTS config.

## Latency note
- Static list (family B, local) = ~0 latency.
- LLM-prompt approach (tell the model to respell) = also no extra step but unreliable ("forgets"). Use as a net for unknown names on top of the static list.
- **Never** add a second live LLM pass just to phoneticize — that adds a full round-trip and is the real latency killer.

## Semi-automatic list building (OFFLINE prep, never live)
The hard part is not typing the list — it's **detecting which words sound wrong**, which needs *audio*, not text.

**Round-trip test:**
1. Fish speaks the candidate text → audio.
2. Feed that audio to an STT (Bosnian-capable).
3. STT writes what it *heard*.
4. Compare intended word vs heard word — **divergence = mispronunciation candidate.**

Compare the STT output against the **intended word**, not against the respelling.

**Scoring, simple → robust:**
1. Levenshtein string distance (quick, coarse).
2. **Phonetic distance** (recommended): both words → IPA via `epitran`, feature distance via `panphon`.
3. Word alignment (`difflib`) so each problem word gets its own score.

**Reproducibility:** Fish output is slightly random. Set low `temperature`, use a seed if the version supports it, or average 2–3 samples per candidate. Cache audio by hash(text+params) to save cost. Use **WAV** (not mp3) for the STT stage.

**Bosnian-capable evaluator STT:** Azure Speech `bs-BA` (existing keys: `mujo`/westeurope, `vesna`/germanywestcentral), or Whisper large-v3 as second opinion. Soniox also lists `bs`. Two STTs in parallel = more robust signal.

**Human stays at the end:** a script proposes candidates + respellings; only an ear confirms which respelling actually sounds right and filters STT false positives. Aim ~90% automated (find + propose), keep the final listen manual.

## Closed-loop optimizer tool (the goal)
Offline CLI: input target text + known problem words → for each word generate respelling variants (`đ→dž/dj/j`, syllable hyphens, vowel doubling) → Fish TTS → STT round-trip + optional human listen → score → keep best → output a vetted `{original: respelling}` map (JSON/CSV) ready for the Dograh `text_filter`. Bonus: run it over real Dograh call recordings to auto-discover new problem words.
