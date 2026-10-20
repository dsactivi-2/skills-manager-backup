# Live verify — Bosnian telesales stack (2026-07)

Session re-check against official docs (web_extract). Re-run if choosing providers months later.

## Confirmed

| Layer | Finding | Source |
|-------|---------|--------|
| STT | Deepgram **Nova-3** lists Bosnian `bs` (also hr, sr) | developers.deepgram.com/docs/models-languages-overview |
| STT | Deepgram **Flux** multi = en,es,fr,de,hi,ru,pt,ja,it,nl only — **no bs** | same overview |
| STT | Azure Speech STT locale `bs-BA` + fast transcription | learn.microsoft.com speech language-support |
| TTS | OpenAI TTS languages include **Bosnian**; model `gpt-4o-mini-tts`; recommend marin/cedar; voices EN-optimized | developers.openai.com/docs/guides/text-to-speech |
| TTS | Azure Neural: `bs-BA-VesnaNeural` (F), `bs-BA-GoranNeural` (M) | Azure language-support TTS table |

## SKILL.md matrix drift (next edit)

Main SKILL.md still says Azure TTS "check locale" — outdated. Apply:
- Azure TTS row → VesnaNeural / GoranNeural confirmed
- Pitfall: Flux ≠ bs; use Nova-3 `language=bs`
- Pitfall: provider stack ≠ GitHub repo discovery (`repo-by-usecase`)
- References: point at this file

```bash
hermes curator adopt balkan-voice-agent-stack bosnian-tts-provider-comparison repo-by-usecase github-agent-tooling
```

## Telesales default (unchanged after verify)

Cascaded: **Deepgram Nova-3 `bs` + keyterms → GPT-4.1 full → gpt-4o-mini-tts cedar/marin**

Fallbacks: Azure STT `bs-BA`; Azure TTS Vesna/Goran; LLM Mini only after real-call A/B.

## Do not

- Flux for bs agents
- Google Cloud TTS for Bosnian
- S2S as primary sales path
- Treat provider questions as GitHub repo search
