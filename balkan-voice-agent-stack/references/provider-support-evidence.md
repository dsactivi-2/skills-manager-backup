# Provider Support Evidence — Live-Verified (July 2026)

All claims verified by live web_extract against official documentation.
Do not rely on memory — re-verify if docs may have changed.

## Deepgram Nova-3: Bosnian/Croatian/Serbian Support

**Source:** https://deepgram.com/learn/nova-3-adds-12-new-languages-across-europe-and-south-asia
**Date:** January 21, 2026

Language codes added: `hr, bs, mk, sr, sl, be, bn, mr, ta, te, kn, tl`

Keyterm Prompting is supported for all these languages.
API usage: `?model=nova-3&language=bs`

**Source:** https://developers.deepgram.com/changelog/2026/1/21
Confirms: `bs`, `hr`, `sr` all listed as newly supported.

## Azure Speech: Bosnian Support

**Source:** https://learn.microsoft.com/en-us/azure/ai-services/speech-service/language-support?tabs=stt
**Date:** Last updated 2026-06-19

| Locale | Language | Fast Transcription |
|--------|----------|-------------------|
| `bs-BA` | Bosnian (Bosnia and Herzegovina) | ✅ |
| `hr-HR` | Croatian (Croatia) | ✅ |
| `sr-RS` | Serbian (Cyrillic, Serbia) | ✅ |
| `sr-ME` | Serbian (Montenegro) | ❌ |
| `sr-XK` | Serbian (Kosovo) | ❌ |

Custom Speech: `bs-BA` supports Plain text customization only (no audio+transcript).

## OpenAI TTS: Bosnian Support

**Source:** https://developers.openai.com/docs/guides/text-to-speech

Bosnian explicitly listed in supported languages.
Voices: 13 built-in, `marin` and `cedar` recommended.
Caveat: "Voices are currently optimized for English."
Pricing: NOT publicly listed for standalone TTS — check OpenAI Dashboard.

## Google Cloud TTS: No Bosnian

**Source:** https://cloud.google.com/text-to-speech/docs/list-voices-and-types

- Bosnian (bs-BA): ❌ NOT in voice list
- Croatian (hr-HR): ✅ 30 Chirp 3 HD voices
- Serbian (sr-RS): ❌ NOT in voice list

## ElevenLabs Scribe v2: Serbian Only

**Source:** https://elevenlabs.io/speech-to-text/serbian

Serbian listed with 3.1% WER on FLEURS benchmark.
Bosnian and Croatian NOT explicitly listed as supported languages.
Scribe v2 Realtime supports 90+ languages but BKS coverage is partial.

## GPT-4.1 Non-English Quality Concerns

**Source:** https://community.openai.com/t/latest-gpt-models-are-providing-very-poor-results-in-many-languages/1354039

Community reports: gpt-4.1-nano and gpt-5-nano produce poor results in Italian, Romanian.
Issues: misgendered plurals, loss of diacritics (ă→a, ț→t).
Workaround: gpt-4o-mini still provides better non-English results than nano variants.
Implication: GPT-4.1 Mini/Nano MUST be tested with Bosnian before production use.

## Retell AI Voice Agent LLM Recommendation

**Source:** https://www.retellai.com/blog/best-llm-for-voice-ai-agents

GPT-4.1 is the most popular LLM across 40M+ calls/month on Retell AI.
Wins because it balances latency, 1M context window, instruction following, and cost.
"Newer is better" assumption breaks for voice — GPT-5.x adds 800ms latency per turn.

## Coval Voice AI Architecture Analysis

**Source:** https://www.coval.ai/blog/voice-ai-models-2026

Key findings:
- Cascaded pipelines still dominate enterprise (observability advantage)
- Speech-to-speech winning latency-sensitive use cases
- TTS choice often matters more than LLM choice for caller perception
- LLM has 200-700ms budget between STT and TTS
- Model selection should be empirical, not benchmark-driven
