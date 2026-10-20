---
name: foundry-multistack-voice-agent
description: "Choose provider combinations for Foundry voice agents, including Azure Speech STT locale selection, Foundry LLM deployment checks, and when to keep TTS native vs custom-orchestrated."
trigger: "Use when designing a Foundry speech-to-speech agent that mixes Azure Speech, Foundry/OpenAI models, and possibly third-party TTS or STT providers."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019eefe6-8ff1-7e12-b7fe-18e30bbec66e
contributors:
  - activi
  - skillopt
version: 3
created_by_agent: codex
created_at: 2026-06-22T23:17:27.197Z
updated_at: 2026-06-22T23:17:27.197Z
---

# Foundry multistack voice agents

## When to use
Use when building a Foundry voice agent and you need to decide which provider owns STT, LLM, and TTS. This applies when mixing Azure Speech, Foundry-hosted/OpenAI models like `gpt-4.1-mini`, and external TTS providers such as ElevenLabs.
## When not to use
Do not use this skill for platform capability or API-support questions that are not actually about Foundry provider-stack selection.
- If the user asks whether Dograh MCP, Dograh APIs, or another platform can run or expose a voice agent, stop and check that platform directly instead of answering from Foundry/Azure assumptions.
- If the task is "does platform X support Y?", first verify X; only use this skill after the task is narrowed back to Foundry STT/LLM/TTS stack choice.

## Workflow
0. Confirm the task matches this skill before giving architecture advice.
- If the request is about Dograh MCP, Dograh API support, or another non-Foundry platform, do not continue with the Foundry stack workflow.
- First answer the platform-support question by checking the target platform's docs/tools; return to this skill only if the remaining question is specifically about Foundry provider selection.
1. Decide the architecture first:
- Lowest integration cost: keep STT, LLM, and TTS inside Azure/Foundry.
- Highest flexibility: use Azure Speech for STT, Foundry/OpenAI for the LLM, and a separate TTS provider only if you accept custom orchestration.

2. For live voice agents, prefer real-time STT, not batch.
- Choose the locale by caller language, not by model brand.
- Examples seen in practice: German `de-DE`, Bosnian `bs-BA`.
- Validate that the locale is supported in the target Speech region before committing.

3. For the LLM layer, verify the deployment before you assume availability.
- `gpt-4.1-mini` is only usable if it is actually deployed in the target Foundry resource.
- Check region, quota, and model availability first.
- For low latency, prefer the smallest model that still meets quality requirements.

4. If you want a single managed speech-to-speech pipeline, keep the output TTS inside Azure Speech / Voice Live.
- Voice Live is the right fit when you want one integrated pipeline and minimal glue code.
- Treat Azure Speech TTS or custom voice as the default output path.
- Use this path when you want the simplest operational model in Foundry.

5. If you want ElevenLabs as the voice, do not expect it to drop into Voice Live as a native output backend.
- Use a custom orchestration instead: Azure Speech STT -> Foundry/OpenAI LLM -> ElevenLabs TTS.
- Accept the added latency, operational complexity, and failure handling.

6. Before committing to a stack, validate three things:
- whether the model or service is deployable in a Europe region,
- whether the STT locale is supported for the target language,
- whether the chosen voice path is native to the pipeline or requires custom code.

## Anti-patterns
- Answering a Dograh MCP or other platform-support question with generic Foundry/Azure stack guidance
- Choosing a provider mix before checking region and quota
- Using batch transcription for interactive voice traffic
- Assuming ElevenLabs is a native Voice Live output option
- Treating `gpt-4.1-mini` as available without verifying deployment in the target Foundry resource
- Optimizing for modularity while ignoring end-to-end latency in live calls
- Mixing providers without a clear fallback and timeout strategy
