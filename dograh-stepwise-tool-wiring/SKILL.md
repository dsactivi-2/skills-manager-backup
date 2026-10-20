---
name: dograh-stepwise-tool-wiring
description: "Stepwise Dograh workflow work that separates localization, prosody, state-machine edits, runtime/provider faults, draft-vs-production state, publish handoffs, archived workflow recovery, and tool wiring."
trigger: "Use when editing a Dograh voice workflow and the task touches localization, pronunciation/prosody, state-machine behavior, runtime errors, publishability, or tool/voice wiring."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019ef6e6-3ac5-7643-91f2-0a593a2ce45e
  - activi_dsactivi's Organization_default_019ef6e0-05a6-76a2-a0e3-4a1f3d2c61ac
  - activi_dsactivi's Organization_default_019ef037-b0d1-73d1-b671-6dce15e8dc52
  - activi_dsactivi's Organization_default_019ef092-5dee-79b0-87d1-d28d617c86c9
  - activi_dsactivi's Organization_default_019ef06b-a7c8-7cc0-bf04-bbe153177903
  - activi_dsactivi's Organization_default_019ef067-a681-7a53-95b0-55c080d7a846
  - activi_dsactivi's Organization_default_019ef043-fd75-7410-b115-4b262e75f569
contributors:
  - activi
version: 12
created_by_agent: codex
created_at: 2026-06-22T17:34:18.028Z
updated_at: 2026-06-23T23:56:00.946Z
---

# Dograh stepwise workflow wiring and localization discipline

## When to use
Use when building or editing Dograh workflows in small verified steps, especially when localization, voice/prosody, state-machine behavior, runtime faults, publish state, and tool wiring can get mixed.

Typical signals:
- Full language pass, for example German to Italian, or place/name changes like `Bremen` to `Cazin`.
- Pronunciation, accent, filler words, pacing, gender/name mismatch, or Bosnian/Italian locale fit.
- Langfuse shows hangs, skipped replies, `turn.was_interrupted = true`, short inputs like `Da`, `Aha`, `Ciao`, or language drift.
- Workflow is a Draft, archived/unpublished, returns `HTTP 500`, or the agent cannot publish and the user must do it.
- The workspace has no tools, credentials, documents, or recordings, so V1 must be safe conversational-only.

## Workflow
1. Discover first.
- Classify the task: localization-only, voice/prosody tuning, prompt hardening, flow redesign, runtime debugging, publish wiring, or tool wiring.
- Check tools, credentials, documents, recordings, active workflow id/version, and Draft vs published state.

2. Preserve behavior for localization-only work.
- Translate visible text layers: `greeting`, node `prompt`s, `extraction_prompt`s, `extraction_variables.prompt`, `qa_system_prompt`, global persona text, and `endCall` text.
- Keep node structure, edges, and variable names unless the user explicitly asks to adapt conversation logic.
- Node names and edge labels may be localized for readability; edge `condition`s should change only when intentionally changing state-machine behavior.

3. Separate concern layers.
- Prompt/persona/localization.
- Voice/prosody and turn-taking.
- Flow/state machine and edge conditions.
- Runtime/provider failures such as STT `503`, wrong STT language, or TTS config.
- Tooling path and integration architecture.

4. Handle publish state explicitly.
- Saving a Draft is not production.
- If the agent cannot publish, prepare the exact workflow name/id and draft version, tell the user what to publish, then test after confirmation.
- If a workflow is archived, unpublished, or returns runtime `HTTP 500`, stop quality scoring and either restore/publish the intended version or create/port into a fresh active workflow.
- Keep a known-good published baseline while testing a richer draft.

5. Diagnose hangs before rewriting prompts.
- Inspect the latest production trace and first 10-20 seconds.
- If LLM/TTS latency is normal, treat hangs/skips as backchannel handling, turn-boundary sensitivity, STT drift, or state-machine routing first.
- Add explicit recovery for short confirmations, fragments, noisy transcripts, and mixed-language inputs.

6. Tune voice/prosody in the runtime path.
- Align persona name and gender with the active voice.
- Anchor locale with standard orthography, local place names, short sentences, slower pace, and natural pauses.
- For file-backed configs, check files like `pipeline.yaml`, `README.md`, `workflow4_code.json`, and workflow creation scripts such as `create_bosnian_natural_voice_workflow.mjs` so legacy voice defaults do not reappear.

7. Verify after publish/deploy.
- Test only the active workflow receiving calls.
- Verify greeting, early turns, interruptions, runtime language, voice/pacing/pronunciation, and any tool path.

## Anti-patterns
- Translating structure, variables, or routing during a localization-only pass.
- Mixing localization, prompt hardening, runtime recovery, and CRM/tool wiring in one step.
- Treating normal-latency hangs as model slowness.
- Assuming a saved Draft is the workflow receiving live calls.
- Continuing to optimize an archived or unpublished workflow instead of resolving publishability.
- Replacing the stable production workflow before the richer draft is proven.
- Declaring an STT/voice fix done without checking the runtime actually receives the language and voice settings.
