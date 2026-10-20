# Ghost STT / PAS Open stuck (voiceeu WF22 evidence 2026-07-29)

## Symptom
- Transcript shows user lines nobody said (e.g. `Ako. I. Ali ovo. Ako?`)
- Call stays on **PAS Open**; `permission_granted=false`; user hangup
- User may blame recent **TTS** change (Vesna/speed)

## Root cause class
**STT hallucination / echo / noise** — not Azure Vesna voice config.

Typical runtime (run detail `initial_context.runtime_configuration`):
```text
stt: speechmatics / enhanced   (language often hr — no bs in Dograh SM list)
tts: azure_speech / neural
llm: azure / gpt-4.1-mini
```

### Evidence pattern (run 132)
```text
assistant: Dobar dan, ovdje Amina…
user:      Ako. I. Ali ovo. Ako?   # final span ~33s → silence/noise/echo
```
Events: `rtf-user-transcription` with long timestamp span.

### Timeline note
Azure Speech Vesna/GWC was already org TTS before speed 0.95. Speed does not invent STT text.

## Debug recipe
1. `GET /api/v1/workflow/{id}/runs?limit=10` + run detail
2. Fetch `transcript_public_url`
3. Inspect `logs.realtime_feedback_events` for `rtf-user-transcription`
4. Read `runtime_configuration` stt vs tts
5. Do **not** revert Vesna first

## Fixes (order)
1. **STT**: Deepgram Nova-3 `bs` + EU host (needs Dograh factory `base_url` patch) — see `balkan-voice-agent-stack` → `references/deepgram-eu-endpoint.md`
2. Or Azure Speech STT `bs-BA` on `vesna` GWC (EU now, no Deepgram patch)
3. Reduce WebRTC echo (mic hears bot) / VAD
4. WF Open prompt: unclear STT → re-ask permission; only clear no/DNC → exit

## Related runs (voiceeu WF22, re-list live)
- 132, 133, 134, 135 — Open-only / ghost or weak STT patterns
- 131 — progressed further despite one unclear `Ako.?`
