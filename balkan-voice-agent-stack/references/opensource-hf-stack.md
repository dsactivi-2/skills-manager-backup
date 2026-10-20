# Bosnian telesales — Open Source / HF stack notes

Condensed from live HF API + provider docs. Re-query before major buy decisions.
Last HF CLI sweep: 2026-07-29.

## Architecture

Cascaded STT→LLM→TTS for telesales. S2S only experimental.
HF `speech-to-speech` = modular VAD→STT→LLM→TTS scaffold, not a bs-ready product.

## STT

| Option | Notes | Prod fit |
|--------|-------|----------|
| Deepgram Nova-3 `bs` + keyterms | Cloud | **default** |
| Azure `bs-BA` | Custom Speech, EU | fallback |
| `openai/whisper-large-v3-turbo` (tags hr,sr,bs) | ~809M, ~1.6GB weights; CPU OK quality-wise | med → high after WER |
| `openai/whisper-large-v3` | same family, slower | med-high |
| `classla/wav2vec2-xls-r-parlaspeech-hr` | HR specialist | high for hr-like audio |
| `classla/wav2vec2-xls-r-juznevesti-sr` | SR specialist | high for sr-like audio |
| GoranS / Sagicc Whisper FTs | HR/SR | med |
| `nvidia/parakeet-tdt-0.6b-v3` | hr among langs | med |
| Community `*bosnian*` Whisper | single-digit DL | **low** |

CPU Whisper for **live** multi-call on Dograh host: **no**. Batch/WER: yes (16 GB RAM comfort).
Details: `huggingface-bcs-search` / `references/whisper-turbo-sizing.md`.

## TTS

| Option | bs? | Caveat | Prod fit |
|--------|-----|--------|----------|
| OpenAI gpt-4o-mini-tts | listed | EN-optimized | **default** |
| Azure Vesna/Goran | bs-BA | Azure | **default alt** |
| ElevenLabs v3 | BOS listed | A/B | high |
| Higgs TTS 3 | polished | NC unless commercial | high if licensed |
| daremc86/sr-cv-vits, dedadev/f5-serbian | sr | tiny | lab |
| facebook/mms-tts-srp|hrv|bos | — | **not on Hub** | n/a |

## LLM

| Option | Notes | Prod fit |
|--------|-------|----------|
| GPT-4.1 full | short+stream | **default** live |
| Azure gpt-5-nano DataZone EU | post-call QA | QA — `foundry-model-ops` (Sweden deploy live 2026-07-29) |
| GPT-4.1 Mini | Non-EN risk | A/B only |

## Data

| Dataset | Role |
|---------|------|
| classla/ParlaSpeech-HR|RS | Best open BCS speech |
| ICIP/TeleSalesCorpus + EN call-center | translate/adapt to bs |
| Native bs telesales speech | **not found** |

Translate real EN call-center corpora; do not free-generate sales dialogues.

## Optional Whisper FT (plain language)
1. Run turbo with language=bs/hr/sr on real calls.
2. If WER/names/jargon bad → fine-tune on ParlaSpeech + own BS audio.
3. Skip FT if turbo already good enough.
