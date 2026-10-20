---
name: tts-pronunciation-correction
description: "Use when TTS mispronounces names or foreign words."
version: 1.0.0
author: Agent
license: MIT
---

# TTS Pronunciation Correction (OOV / G2P errors)

Class-level skill for fixing words that a TTS engine speaks wrong — proper
names, brand terms, loanwords, and locale-specific letters — in production
voice agents. Verified against Fish Audio + Dograh, Bosnian (bs-BA), 2026-08.

## Name the problem precisely
- **G2P error** (Grapheme-to-Phoneme): the engine maps *spelling → sound*
  wrong. This is the technical root.
- **OOV (Out-of-Vocabulary)**: the trigger — rare words/proper names the model
  never learned. That's why **names** fail most.
- **Phonetic respelling**: the fix — rewrite the word how it should *sound*
  (e.g. Bosnian `Đenita` → `Dženita`).
- **Pronunciation dictionary / lexicon (SSML `<phoneme>` / IPA)**: the
  "clean", scalable fix — a fixed `word → pronunciation` map. Only some engines
  have it (ElevenLabs, Amazon Polly, Retell). **Fish Audio does NOT** — no
  SSML, no IPA, no lexicon. Fish's own docs say "rewrite hard terms
  phonetically", so respelling is the *official* path there, not a hack.

## Two respelling techniques (least-destructive first)
1. **Single-letter sound swap** for one unknown grapheme:
   `đ → dž` (works because `dž` appears in known words like "džezva").
   Also try `đ → dj`, `đ → j` and pick by ear.
2. **Syllable hyphens** for long proper names: `Baščaršije → Baš-čar-ši-je`.
   Forces the model to segment WITHOUT destroying correct letters.

### Critical pitfall — keep letter integrity
Do **NOT** swap correct diacritic letters (`č ć š ž`) for English digraphs
(`ch/sh`). If the model recognises the language, those letters are already
right; ASCII-ising them BREAKS language detection and makes it worse. Prefer
syllable hyphens + targeted single-letter swaps. Change as FEW words as
possible — rewriting already-correct words regresses quality.

## Where the fix lives at runtime (Dograh / Pipecat)
The live correction is a **static search-and-replace applied just before text
hits the TTS**, via `text_filters` in `create_tts_service`
(`api/services/pipecat/service_factory.py`). Every provider block already
passes `text_filters=[xml_function_tag_filter]`; add a second filter carrying
your replacement map `{"Đenita": "Dženita", ...}`.
- Latency: **~zero** — local string replace, no network hop.
- **Never** do a second live LLM pass for pronunciation — that adds a full
  round-trip of latency. Correction must be a static list.
- Handle inflection/case: Bosnian names decline (`Đenita/Đenite/Đeniti`) — add
  each surface form.
- Emotion tags (Fish `(excited)`, `[whispering]`) are a *separate* concern;
  the LLM writes them into the text. `xml_function_tag_filter` only strips XML
  function tags — round/square brackets pass through untouched.

## Two ways to drive respelling in an agent (combine them)
- **Static replacement list (`text_filter`)** — reliable anchor for known
  problem words. Always wins (runs last). Maintain the list.
- **LLM prompt instruction** — net for new/unseen names; tell the agent to
  respell listed names. Unreliable ("forgets") — never the sole mechanism for
  real customer names.
- Best: static list for knowns + prompt as a fallback net.

## Auto-building the list — round-trip test (OFFLINE only)
You can't tell from text alone which words sound wrong — you need the audio.
The **round-trip / closed-loop** technique:
```
target text → Fish TTS → audio → STT (bs-capable) → heard text
compare heard-text vs INTENDED word  →  divergence = mispronunciation candidate
```
- Score by **phonetic** distance, not raw string distance: convert both to IPA
  (`epitran`) and measure feature distance (`panphon`); align words with
  `difflib` for per-word scores.
- Candidate generation: rule-based variants per problem word (`đ→dž/dj/j`,
  syllable hyphens, vowel doubling) → TTS each → score → keep best.
- **This is prep-time, NOT live.** It runs over recorded calls (Dograh saves
  recordings); output is a static list for the `text_filter`. Far too slow for
  the call path.
- Reproducibility: Fish output is slightly random — set low `temperature`, use
  a seed if the version supports it, or average 2–3 samples per candidate.
  Cache by hash(text+params) to save API cost.
- The evaluator STT is itself fallible → an STT miss ≠ a TTS error. End with a
  quick **human ear-check** on the top candidates; the human choice overrides
  the auto-score.

### Verified result (2026-08, Fish "Ela" bs voice, `Đenite`)
Round-trip on real audio, four variants of `Đenite` in a bs carrier sentence:
- `Đenite` (raw) → heard "Deníte" — `đ` collapses to a plain **d**. ❌
- `Dženite` (`đ→dž`) → heard Cyrillic "Џените" — correct **dž** affricate. ✅
- `Djenite` (`đ→dj`) → also "Џените" — correct. ✅ (but `dž` preferred: real BiH digraph)
- `Jenite` (`đ→j`) → heard "Jeníte" — a **j/“y”** glide. ❌
So `đ → dž` (`Đenite → Dženite`) is **confirmed on audio**, not just theory.

### CRITICAL read-the-transcript, not-the-score caveat
Two traps bit here, both reinforcing "auto-score is not the arbiter":
1. **Fish's own `pro` STT is a WEAK Bosnian evaluator.** It drifted language
   AND script per call — emitted Macedonian ("господин", "разговарам"), a Czech
   carrier ("Dobrý den"), and flipped Latin↔Cyrillic. Use **Azure `bs-BA`** as
   the machine ear, not Fish STT, for a clean signal.
2. **Naive string-similarity ranked the WRONG variants highest** — the two
   incorrect ones stayed in Latin script so they string-matched "Đenite"
   better, while the correct `dž` ones came back as Cyrillic Џ (similarity 0.0).
   Cyrillic **Џ *is* the `dž` affricate** — reading `heard_full` reveals the
   right answer that the score column hides. Always inspect the transcript text
   and the onset consonant; never rank by raw `difflib` ratio alone.

### Driving Fish MCP directly (tools not in live session)
When the `mcp__fish-audio__*` tools aren't in the running agent session (added
after session start; Hermes won't hot-swap the live toolset — prompt cache is
sacred), drive the endpoint directly with the on-disk OAuth token instead of
waiting for a restart:
- Token store: `~/.hermes/mcp-tokens/fish-audio.json` (has `access_token` +
  `refresh_token`, ~1h expiry). Bearer it into `streamablehttp_client` +
  `ClientSession` from `mcp` (>=1.26). If it 401s: `hermes mcp login fish-audio`.
- Fish `text_to_speech` returns a JSON **text block** with a public
  `audio_url` (r2.fish.audio) + `credits_charged`. That URL feeds straight into
  `speech_to_text` (`model: pro|flash`, optional `language`) — chain TTS→STT
  with zero file handling. Browse voices with `search_voices` (omit `query`
  for recommended; `self:true` for your workspace voices).
- Full setup + chicken-and-egg fix for `hermes mcp add --auth oauth`: see
  `references/fish-mcp-oauth-and-direct-client.md`.

See `references/roundtrip-optimizer-and-fish-bosnian.md` for the full
closed-loop optimizer design (write → speak → hear → score → refine) and the
Fish/Bosnian respelling specifics.

## STT evaluator choice (the "machine ear")
Must itself handle the target language. For Bosnian: Azure Speech STT `bs-BA`
(bs-capable, and user already has westeurope/germanywestcentral keys) primary;
faster-whisper large-v3 as offline second opinion. Two STTs = more robust
signal.

## Pitfalls
- No LLM pronounces reliably "for free" — it emits *text*, not *sound*; it
  can't know how the TTS will voice a word. No model has an auto-pronounce
  switch; a bigger LLM does not fix this.
- Over-correction regresses quality — only touch words that demonstrably fail.
- Don't confuse this with SSML prosody/emotion (see `tts-ssml-prompt-hardening`
  for engines that DO have SSML).

## Related
- `tts-ssml-prompt-hardening` (user-owned) — SSML/prosody for engines that
  support it.
- `soniox-voice-platform`, `balkan-voice-agent-stack` (user-owned) — STT/TTS
  provider selection; Soniox is a candidate bs-capable evaluator STT.
