---
name: langfuse-voice-call-quality-optimization
description: "Optimize voice-call warmth, naturalness, opening quality, short-backchannel recovery, locale fit, and runtime voice settings using Langfuse evidence plus Dograh/TTS checks."
trigger: "Use when a voice agent is formally correct but sounds robotic, uses stale greetings, hangs after short replies, drifts language/accent, or has mismatched persona and voice."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019ef6e0-05a6-76a2-a0e3-4a1f3d2c61ac
  - activi_dsactivi's Organization_default_019ef037-b0d1-73d1-b671-6dce15e8dc52
  - activi_dsactivi's Organization_default_019ef092-5dee-79b0-87d1-d28d617c86c9
  - activi_dsactivi's Organization_default_019ef06b-a7c8-7cc0-bf04-bbe153177903
  - activi_dsactivi's Organization_default_019ef067-a681-7a53-95b0-55c080d7a846
  - activi_dsactivi's Organization_default_019ef043-fd75-7410-b115-4b262e75f569
contributors:
  - activi
version: 10
created_by_agent: codex
created_at: 2026-06-22T17:02:12.599Z
updated_at: 2026-06-23T23:48:47.846Z
---

# Langfuse voice-call quality optimization

## When to use
Use when the agent is structurally correct but sounds robotic, rushed, emotionally flat, in the wrong language, unstable after short caller replies, or live production does not match the expected prompt.

Typical signals:
- Production greeting is older than the latest draft or candidate prompt.
- Langfuse shows normal LLM/TTS latency, but the call feels skipped, hung, or interrupted.
- Short inputs like `da`, `aha`, `ciao`, fragments, or noisy ASR cause stalls, repeated openings, or language drift.
- The voice timbre is acceptable, but delivery, pace, pronunciation, accent, persona name, or gender presentation feels wrong.
- The user asks whether Langfuse alone can fix a robotic voice.

## Workflow
1. Inspect the latest production trace first.
- Start with the opening observation and first 10 to 20 seconds.
- Compare live `production` prompt version against `latest` or candidate.
- Check `turn.was_interrupted`, short utterances, language drift, and the active workflow id/version.

2. Separate what Langfuse can and cannot fix.
- Langfuse can manage prompt versions, production labels, scores, annotation queues, judges, comments, and regression evidence.
- Langfuse cannot directly change acoustic delivery. Voice ID, TTS speed, pauses, SSML/prosody, provider, STT locale, and telephony runtime live in Dograh/Foundry/ElevenLabs/Azure/runtime config.
- If the user reports robotic sound, plan both measurement in Langfuse and runtime voice inspection.

3. Fix and measure the opening explicitly.
- First turn should include role, reason for the call, brief context, and a permission question.
- Score the opening separately with `Greeting correctness`, `Naturalness`, `Warmth`, `Humanness`, and optional `Prosody impression`.
- Put annotation queues and judge scores on the opening observation, not only the full trace.

4. Treat repeated hangs as turn-handling first.
- If LLM and TTS latency are normal, do not call it a speed problem.
- Add explicit recovery for short confirmations, fragments, and noisy transcripts.
- Use dedicated opening, clarification/slow-down, qualification, objection/recovery, summary, and close states when needed.
- Keep short backchannels from triggering long restarts.

5. Align voice persona with the actual voice.
- Match agent name and gender presentation to the active TTS voice.
- Anchor locale with local names, orthography, and wording, for example Bosnian Latin script and place names such as `Cazin`.
- If accent drift remains, slow the TTS, shorten sentences, add pause guidance, and then consider a voice swap.

6. Verify runtime language and voice settings.
- Inspect whether the active provider receives the intended language/locale and voice settings.
- For wrong-language replies after mixed or short inputs, verify STT language anchoring before rewriting prompts.
- If a specific voice sounds too neutral or regionally wrong, test 2 to 3 provider voices against the same opening.

7. Re-test only against the active workflow.
- Draft is not production.
- If a workflow is archived, unpublished, or returns runtime errors, stop quality scoring until the active/published workflow is runnable.
- After publish, verify live opening, early turns, interruptions, pace, pronunciation, and persona fit with a short heard call.

## Anti-patterns
- Scoring only task correctness while ignoring warmth, humanness, or opening quality.
- Assuming Langfuse scores can change TTS acoustics.
- Editing prompt, flow, and runtime voice at the same time without trace evidence.
- Treating normal-latency hangs as model slowness.
- Leaving a female voice with a male persona name, or vice versa.
- Calling success before the published workflow is the one being tested.
- Declaring a locale or accent fix done without hearing the opening and short-backchannel turns.
