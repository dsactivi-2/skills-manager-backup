---
name: dograh-huggingface-provider-debug
description: "Diagnose Dograh pipeline errors caused by Hugging Face Inference Provider routing, model-provider enablement, and reasoning-model JSON leakage. Use this skill when Dograh shows a Pipeline Error or Langfuse trace for provider=huggingface with model_not_supported, provider routing, slow first-token latency, or invalid JSON extraction from a Qwen/HF model."
trigger: "Use this skill when Dograh shows a Pipeline Error or Langfuse trace for provider=huggingface with model_not_supported, provider routing, slow first-token latency, or invalid JSON extraction from a Qwen/HF model."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019f6c6b-9f3e-78d2-846e-4c6cfca918f2
contributors:
  - activi
version: 1
created_by_agent: codex
created_at: 2026-07-21T16:18:18.131Z
updated_at: 2026-07-21T16:18:18.131Z
---

# Dograh Hugging Face provider debug

## When to use

Use when a Dograh voice workflow fails or hangs after switching LLM routing through Hugging Face Inference Providers, especially with errors like:

- `Pipeline Error`
- `Error during completion: Error code: 400`
- `model_not_supported`
- `The requested model ... is not supported by any provider you have enabled`
- JSON extraction output containing `<think>` or reasoning text before JSON

## Workflow

1. Identify the exact Dograh agent/workflow first. Do not assume the ID from prior context. In the incident pattern, the correction from `8323` to `8184` changed the investigation target.

2. Inspect Dograh configuration in two places:

- `Agent Settings > Model Overrides > LLM`
- `Dograh Dashboard > Models > BYOK > LLM`

If the workflow code itself has no model override, treat the active model as coming from global BYOK/model settings or agent-level overrides.

3. Open the latest relevant Langfuse trace/generation and record:

- node name, e.g. `llm-otvaranje-+-dozv` or `llm-variable-extraction`
- `gen_ai.provider.name`
- `gen_ai.request.model`
- status/level and exact error payload
- TTFB and total LLM duration
- whether the caller spoke during silence, e.g. `Alio,`
- whether extraction output is strict JSON or includes reasoning text

4. Verify the model on Hugging Face using the HF MCP/docs/model metadata. Confirm:

- the model repository exists, e.g. `AEON-7/Qwen3.6-27B-AEON-Ultimate-Uncensored-BF16`
- which live Inference Providers support it
- whether the only live provider is `featherless-ai`

5. Interpret `model_not_supported` precisely. If HF lists the model but the Dograh call fails with provider `huggingface`, the likely issue is not prompt or spelling. It is usually HF Router provider policy: the needed provider is not enabled, terms/billing are not accepted, or Dograh is using the wrong HF token/account.

6. For OpenAI-compatible HF routing, check these settings:

```text
Base URL: https://router.huggingface.co/v1
Model: AEON-7/Qwen3.6-27B-AEON-Ultimate-Uncensored-BF16:featherless-ai
```

Also verify Hugging Face provider settings at:

```text
https://hf.co/settings/inference-providers
```

7. If adding `:featherless-ai` removes the 400 but the call is slow, reclassify the incident. The routing is fixed, but the model may be unsuitable for live voice. In the observed pattern, first-token latency around 10+ seconds and LLM calls around 50+ seconds caused audible conversation gaps.

8. Check extraction separately from conversational generation. If `llm-variable-extraction` returns text such as `Here's a thinking process...` or `<think>...</think>` before JSON, the model is unsafe for Dograh extraction even if chat completion works.

9. For Qwen/Qwen-derived thinking models, try disabling thinking only if Dograh passes custom params through to HF Router, e.g. `chat_template_kwargs: {"enable_thinking": false}`. If this cannot be configured reliably, switch extraction to a smaller non-thinking JSON-stable model.

10. Recommended resolution pattern:

- fast, low-latency non-thinking model for live voice
- strict JSON-stable model for variable extraction
- provider suffix only when the HF provider routing needs pinning
- HF provider enablement/billing/terms checked under the same token used by Dograh

## Anti-patterns

- Treating `model_not_supported` as a prompt problem
- Assuming a model exists means it is enabled for the current HF token
- Forgetting that HF Router provider availability is account/provider-policy dependent
- Debugging the wrong Dograh workflow ID after a user correction
- Declaring success after the 400 disappears while Langfuse shows unusable latency
- Using Qwen thinking models for strict JSON extraction without disabling thinking
- Ignoring Langfuse timing and transcript evidence when the user reports call silence
