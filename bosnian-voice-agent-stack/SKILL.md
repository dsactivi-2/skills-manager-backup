---
name: bosnian-voice-agent-stack
description: "Live-verified full voice-agent stack comparison for Bosnian (bs-BA) — STT, LLM, TTS, architecture, and training datasets. Use when selecting any layer of a Bosnian-language voice agent, especially for Dograh outbound telesales."
trigger: "Use when evaluating any provider or model for Bosnian-language voice agents, Dograh telesales, or any voice AI project targeting Bosnian speakers. Covers STT, LLM, TTS, cascaded vs speech-to-speech architecture, and training datasets."
author: activi
version: 2
created_at: 2026-07-09
updated_at: 2026-07-10
---

# Bosnian Voice Agent Stack — Full Provider & Model Comparison

Live-verified against official docs on 2026-07-10.

## Architecture Decision: Cascaded (STT → LLM → TTS)

For Bosnian telesales, use a **cascaded pipeline**, not speech-to-speech. Reasons:
- Bosnian STT errors are unavoidable — you need per-stage transcripts to debug
- Sales optimization requires prompt-level control over LLM behavior
- Compliance/auditing needs readable text output at each stage
- Speech-to-speech (GPT-Realtime-2, Gemini Flash Live) has no explicit Bosnian support listing and is a black box for debugging

Cascaded observability: each stage produces readable intermediate output. STT log shows what was heard, LLM log shows what was decided, TTS log shows what was spoken. This lets you pinpoint whether a failure was STT (misheard), LLM (wrong response), or TTS (robotic delivery).

## STT (Speech-to-Text)

### Deepgram Nova-3 — TOP PICK
- **Bosnian (`bs`)**: ✅ Explicitly supported since January 2026
- **Croatian (`hr`), Serbian (`sr`)**: ✅ Also supported
- **Latency**: Sub-300ms streaming
- **Keyterm Prompting**: Yes — register "Aquaphor", "Smile" etc. to improve recognition
- **Pricing**: ~$0.46/hour streaming
- **Verdict**: Best latency + Keyterm Prompting. New for `bs` — test with real Bosnian audio before committing.

Source: https://developers.deepgram.com/changelog/2026/1/21

### Azure Speech — ENTERPRISE FALLBACK
- **Bosnian (`bs-BA`)**: ✅ Long-established, Fast Transcription supported
- **Croatian (`hr-HR`), Serbian (`sr-RS`)**: ✅
- **Custom Speech**: Available for domain fine-tuning
- **EU Regions**: Yes (DSGVO)
- **Verdict**: Safer enterprise choice, higher latency than Deepgram. Use if Deepgram `bs` quality disappoints.

Source: https://learn.microsoft.com/en-us/azure/ai-services/speech-service/language-support

### ElevenLabs Scribe v2
- **Serbian**: ✅ (3.1% WER on FLEURS)
- **Bosnian**: ❌ Not explicitly listed
- **Verdict**: Not viable for Bosnian. Good for Serbian-only flows.

## LLM (Language Model)

### GPT-4.1 — TOP PICK
- **Provider**: OpenAI
- **Why**: Industry standard for voice agents (40M+ calls/month on Retell AI). Best balance of latency, instruction following, function calling, and cost.
- **Context**: 1M tokens
- **Pricing**: $2.00/1M input, $8.00/1M output
- **Bosnian quality**: GPT-4.1 full model is robust for non-English. Nano/Mini variants have known quality issues with non-English languages (community reports: Italian, Romanian).
- **Verdict**: Use GPT-4.1 full, NOT Mini/Nano for Bosnian production.

Source: https://www.retellai.com/blog/best-llm-for-voice-ai-agents

### GPT-4.1 Mini — BUDGET OPTION
- **Pricing**: $0.40/1M input, $1.60/1M output (~80% cheaper)
- **Risk**: Known non-English quality degradation. MUST test with real Bosnian calls before production.
- **Verdict**: Only for high-volume, simple-script flows after Bosnian validation.

### Claude (Anthropic)
- No speech-to-speech model. Cascaded only.
- Claude Sonnet 4.6 is strong at multi-turn instruction following but GPT-4.1 is better optimized for voice latency.
- **Verdict**: Second choice if OpenAI unavailable.

### The real LLM decision criterion for Bosnian voice: DIACRITICS, not MMLU
For a `bs-BA` TTS pipeline the LLM's job is to emit clean Bosnian with **correct diacritics (č ć š ž đ)**. Missing/wrong diacritics → wrong pronunciation, **audible instantly** in TTS. This is the real A/B test, not benchmark scores. Always pin the system prompt: *"Antworte ausschließlich in korrektem Bosnisch mit vollständiger Diakritik (č, ć, š, ž, đ). Kurze, natürliche Sätze für Sprachausgabe."* Then route each candidate's output through `bs-BA-VesnaNeural`/`GoranNeural` and listen.

### Open-weight LLMs & Azure Voice Live constraint
See `references/open-weight-llm-comparison.md` for the full comparison (Gemma 3, Qwen3, Mistral Large 3, YugoGPT, EuroLLM). Two load-bearing facts:
- **Azure Voice Live API only accepts OpenAI/Phi models as the brain** (Pro: GPT-Realtime/4.1/4o/5; Standard: 4o-mini/4.1-mini; Lite: Phi-4/GPT-5-nano). Any open-weight LLM (Mistral, Gemma, Qwen) forces you to hand-build the cascade and **lose Voice Live's integrated turn-taking/barge-in/VAD** — a real quality hit on live calls.
- **South Slavic ≠ "multilingual breadth".** Per the Slovene arXiv benchmark, **Gemma 3 27B leads open-weights** for South Slavic; Qwen3 is broad (119 langs) but South Slavic is NOT its strength. **YugoGPT** is the only BCMS-specialist but is an aging Mistral-7B base (weak instruction-following, self-host only). For an open-weight Foundry pick, **Mistral Large 3** is the pragmatic choice (Apache-2.0, serverless in Foundry, EU) — but see the latency caveat.
- **Mistral Large 3 is too heavy as a live sales brain**: 673B total / 39B active MoE, TTFT ~0.6–1.5s → cascaded turn latency 1.5–2.5s, over the ~800ms "hakelig" threshold. Use it only as a background "thinker" (dual-model: fast 4.1-mini leads the call, Large 3 plans offer logic/objection strategy async).

## TTS (Text-to-Speech)

### OpenAI gpt-4o-mini-tts — TOP PICK
- **Bosnian**: ✅ Explicitly listed
- **Voices**: `cedar` and `marin` recommended
- **Control**: Accent, emotion, intonation, speed, tone via `instructions`
- **Caveat**: "Voices are currently optimized for English"
- **Pricing**: NOT publicly listed — check OpenAI Dashboard
- **Instructions**: "Speak in Bosnian. Sound human, friendly, concise, confident, and sales-oriented. Keep sentences short. Handle objections calmly. Sound natural on phone calls, not theatrical."

Source: https://developers.openai.com/docs/guides/text-to-speech

### Google Cloud TTS
- **Bosnian**: ❌ NOT in voice list
- **Croatian (hr-HR)**: ✅ 30 Chirp 3 HD voices
- **Verdict**: Not viable for Bosnian.

### Higgs TTS 3 (bosonai/higgs-tts-3-4b)
- **Bosnian**: ✅ "polished, production-quality" (WER/CER <5), 102 languages
- **License**: Research/Non-Commercial only. Commercial needs separate license.
- **Managed option**: Boson AI API (docs.boson.ai)
- **Verdict**: Best Bosnian quality, license hurdle for commercial use.

Source: https://huggingface.co/bosonai/higgs-tts-3-4b

## Recommended Stack

| Layer | Model | Provider | Why |
|-------|-------|----------|-----|
| STT | Nova-3 `bs` | Deepgram | Lowest latency, Keyterm Prompting |
| LLM | GPT-4.1 | OpenAI | Voice agent standard, Bosnian-capable |
| TTS | gpt-4o-mini-tts `cedar` | OpenAI | Bosnian supported, natural prosody |

Fallback: Azure Speech `bs-BA` for STT if Deepgram Bosnian quality insufficient.

## Training Datasets

See `references/telesales-datasets.md` for the full dataset catalog.

Key sources for bootstrapping a Bosnian telesales agent:
1. **CallCenterEN** (91,706 transcripts) — load via `datasets` library, filter for sales keywords, **translate** to Bosnian with GPT-4.1
2. **TeleSalesCorpus** — annotated by sales phase (Opening, Pitch, Objection, Closing)
3. After 100+ live calls: build your own Bosnian dataset from Deepgram transcripts

**CRITICAL: Translate, don't generate.** GPT-4.1 should translate/adapt existing English sales dialogues into Bosnian (with Aquaphor Smile context), NOT generate dialogues from scratch. Generated dialogues lack the structural patterns of real call center conversations. The translation script is at `scripts/translate_datasets.py` in the project.

**OpenAI API Key:** Stored in `~/.hermes/.env` as `OPENAI_API_KEY`. If the `openai` Python library has connection issues (APIConnectionError) but `curl` works, use `urllib.request` directly instead — the library sometimes fails on macOS while direct HTTP succeeds. See `references/openai-urllib-workaround.md`.

## Dograh Configuration

See `references/dograh-configuration.md` for API key setup, voice agent configuration parameters, Dograh instance URL handling, and common pitfalls.

## Dograh MCP Setup

Dograh MCP ist als nativer Hermes MCP-Server konfiguriert. NIE Browser-Login fuer Dograh-Workflow-Arbeiten — immer MCP.

```bash
hermes mcp add dograh --url https://api.dograh.com/api/v1/mcp/ --auth header
```

Workflow 8107 = Aquaphor Smile Telesales (Bosnisch, Outbound). Lesen mit `get_workflow(workflow_id=8107)`, speichern mit `save_workflow(workflow_id=8107, code=...)`.

## PDF/Excel Generation Pitfalls

fpdf2 mit Helvetica (Core-Font) unterstuetzt nur latin-1. Alle non-latin-1 Zeichen (Umlaute, Sonderzeichen, Bullet-Points) muessen vorher ersetzt werden. `multi_cell(w=0)` kann bei falschem X-Offset mit "Not enough horizontal space" fehlschlagen — vorher `set_x(self.l_margin)` setzen. openpyxl braucht existierendes Output-Verzeichnis.

## Verification Method

All claims verified by live web_extract against official docs on 2026-07-10. Do not rely on memory or second-hand summaries — re-verify if docs may have changed.
