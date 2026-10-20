---
name: dograh-voice-workflow-optimizer
description: "Optimize Dograh voice-agent workflows from live traces, drafts, and language-specific call behavior."
trigger: "Use when iterating on Dograh outbound voice workflows or agents from trace evidence, draft versions, or model/provider tuning."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019eef49-694c-7742-962a-1bc44d0d40b8
  - activi_dsactivi's Organization_default_019ee821-a84c-7312-b59e-d7ad3eb051cf
  - activi_dsactivi's Organization_default_019ee75e-63e8-7d72-9790-d07a91d74ef1
  - activi_dsactivi's Organization_default_019ee815-8c7a-7651-bccc-68b8a33ca62c
  - activi_dsactivi's Organization_default_019ee804-9e82-7b03-8913-9fe0b9984a97
  - activi_dsactivi's Organization_default_019ee7f9-8f7b-7662-9e69-582055e676b4
  - activi_dsactivi's Organization_default_019ee7e7-1e50-7920-ab5d-f2de5d84626d
  - activi_dsactivi's Organization_default_019ee7d8-cc9e-7392-b3c4-4b270ccb03f0
  - activi_dsactivi's Organization_default_019ee7ce-f7d9-7031-b189-3685b32031a3
  - activi_dsactivi's Organization_default_019ee7c3-52ef-7843-a326-f5e474431075
contributors:
  - activi
version: 1
created_by_agent: codex
created_at: 2026-06-22T12:34:17.912Z
updated_at: 2026-06-22T12:34:17.912Z
---

# Dograh voice workflow optimizer

## When to use
Use when iterating on Dograh outbound voice workflows or agents based on live traces, especially when tuning greetings, objection handling, language-specific speech, or model/provider choices.

## Workflow
1. Confirm MCP access and current workflow IDs.
   - `~/.codex/skills/dograh-mcp/scripts/check_dograh_mcp.sh`
   - Read the live workflow definition before changing anything.
2. Inspect recent production traces before editing.
   - Read the last 3 Langfuse traces for the workflow.
   - Classify the failure as one of: prompt/flow, STT/ASR, TTS/voice, or model.
3. Optimize minimally.
   - For sales flows, do not end on the first "no"; add a second polite objection-handling turn.
   - For multilingual agents, tune greeting and closing in the target language, not English.
   - Make numbers and dates sound natural; do not force digit-by-digit speech.
   - Treat short backchannels, questions, and ASR noise as non-rejection unless clearly negative.
4. Save as draft, then verify the new version in the UI.
   - Save through MCP as a draft.
   - Open the workflow in Safari at `https://voiceeu.activi.io/workflow` and confirm the draft/version increment.
5. Re-check traces after a test call and repeat if the same failure persists.

## Model and provider heuristics
- Do not switch models first. Fix prompt, language handling, and STT boundary rules before moving the LLM.
- Standardize a pinned lightweight model when behavior is already good and cost matters.
- For languages with frequent ASR mistakes, prefer tighter STT language settings and a better-fitting voice before a larger LLM.
- If the agent sounds depressed or robotic, adjust TTS/voice tuning before increasing model size.

## Anti-patterns
- Publishing before draft validation.
- Treating one short "no", a question, or a backchannel as a full rejection.
- Changing prompt, model, STT, and voice at the same time.
- Using multilingual STT for a single-language sales flow.
- Telling the model to pronounce multi-digit numbers one digit at a time.
- Claiming the UI draft is visible without verifying the version in the frontend.
