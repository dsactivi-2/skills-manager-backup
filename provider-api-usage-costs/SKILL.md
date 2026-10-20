---
name: provider-api-usage-costs
description: "Use when checking spend of a named API."
version: 1.0.0
---

# Provider API usage costs

User wants to see how much a **named provider API** already consumed. Do not invent prices. Query that provider's usage/billing endpoint with the matching key type.

## When to use

- "wie viel habe ich bei X verbraucht"
- "kleines Tool für Kosten über eine API"
- OpenRouter / OpenAI / xAI / Deepgram / ElevenLabs spend or credits

## When not to use

- Azure/Foundry **model pick + deploy cost** → `foundry-model-ops`
- Voice-stack provider **selection** (STT/LLM/TTS) → `balkan-voice-agent-stack`
- Langfuse trace scores ≠ invoice

## Default tool

CLI already exists. Use it first, do not rebuild:

```bash
python3 /Users/activi/Code/Projects/api-cost/api_cost.py list
python3 /Users/activi/Code/Projects/api-cost/api_cost.py openrouter
python3 /Users/activi/Code/Projects/api-cost/api_cost.py all
```

Names: `openrouter`, `openai`, `xai`, `deepgram`, `elevenlabs`. `--days N`, `--json`.

Keys come from the environment or `~/.hermes/.env` / `~/.openclaw/.env`. Never print key values.

If the user says "eine bestimmte API" without a name: ask. Do not assume xAI because the session model is Grok.

## Key types (live-verified)

| Provider | Works for usage | Does not work |
|---|---|---|
| OpenRouter | `OPENROUTER_API_KEY` → GET `/api/v1/key` (this key's spend) | Account `/credits` needs `OPENROUTER_MANAGEMENT_KEY` |
| OpenAI | `OPENAI_ADMIN_API_KEY` with `api.usage.read` → GET `/v1/organization/costs` | Normal user `OPENAI_API_KEY` → 403 |
| xAI | `XAI_MANAGEMENT_KEY` + `XAI_TEAM_ID` → management-api billing | `XAI_API_KEY` is inference only |
| Deepgram | Owner/admin key → `/v1/projects` + `/usage` | STT-only key lists projects, usage 403 |
| ElevenLabs | `ELEVENLABS_API_KEY` → GET `/v1/user/subscription` | — |

## Rules

1. Official usage API only. No local token×price estimate unless the provider has no usage API and you say so.
2. Live-call before claiming a number.
3. German, compact table. No secret dump.
4. Adding a provider: official docs first, then one adapter in `api_cost.py` + a mocked test + one live call.

Endpoints and request bodies: `references/usage-endpoints.md`.
