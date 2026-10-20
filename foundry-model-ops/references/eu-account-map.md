# EU AIServices inventory (verify with az before acting)

Last verified: 2026-07-30 (embeddings + TTS/clone + QA). Re-run az commands; do not treat as forever-true.

## Accounts seen

| Account | RG | Region | Notes |
|---------|----|--------|-------|
| dsselmanovic-6165-resource | rg-dsselmanovi | swedencentral | Warm. Preferred EU DZ deploy target. Embeddings: 3-small DZ + 3-large Standard. |
| dsselmanovi-resource | rg-dsselmanovi | swedencentral | Has Global gpt-4.1-mini — not for EU-residency QA. |
| activids | rg-dsselmanovi | westeurope | Warm. gpt-4.1-mini DZ + gpt-4o-mini DZ. |
| ai-dsselmanovic5281ai539762383096 | rg-dsselmanovic-1052_ai | germanywestcentral | Was empty; **deploy blocked** `715-123420` unusual activity for gpt-5-nano and gpt-4.1-mini. Do not spam. |
| voicebs182503 | rg-voicebs-182503 | westeurope | Check before use. |
| ai-dsselmanovic-9034 | rg-dsselmanovic-1052_ai | swedencentral | Check before use. |
| rgdsds | rg-dsselmanovi | westeurope | Check before use. |

Speech-only (not for chat LLM deploy): `vesna` (germanywestcentral), `mujo` (westeurope).

## Deployments confirmed

### dsselmanovic-6165-resource (swedencentral)
- gpt-4.1 / GlobalStandard
- gpt-4.1-mini / DataZoneStandard / 250
- gpt-5.4-mini / DataZoneStandard / 100
- gpt-5-nano / DataZoneStandard / 100 / ver 2025-08-07
- text-embedding-3-large / Standard / 120 / caps.area EUR
- text-embedding-3-small / **DataZoneStandard** / 50 / caps.area EUR / **Dograh KB path** (smoke 1536d OK on `*.openai.azure.com`)
- Endpoint (az): `https://dsselmanovic-6165-resource.cognitiveservices.azure.com/`
- Dograh BYOK host: `https://dsselmanovic-6165-resource.openai.azure.com/`

### activids (westeurope)
- gpt-4.1-mini / DataZoneStandard / 250
- gpt-4o-mini / DataZoneStandard / 150
- o4-mini / GlobalStandard / 500
- Endpoint: `https://activids.cognitiveservices.azure.com/`

### dsselmanovi-resource (swedencentral)
- gpt-4.1-mini / GlobalStandard / 50
- text-embedding-3-small / DataZoneStandard (re-list before relying)
- Endpoint: `https://dsselmanovi-resource.cognitiveservices.azure.com/`

## Outcomes
- Sweden `gpt-5-nano` DataZone deploy: OK
- Sweden `text-embedding-3-small` DataZone deploy: OK (Standard SKU rejected for 3-small in SE)
- Germany West empty account any OpenAI deploy: blocked `715-123420`
- Fallback for "deploy to Germany" when blocked: report block + offer warm Sweden/West Europe DZ already live
- Dograh embeddings: use 3-small + openai.azure.com — not 3-large (3072d)

## Dograh QA pointer for Sweden nano
```text
qa_use_workflow_llm: false
qa_provider: azure
qa_model: gpt-5-nano
qa_endpoint: https://dsselmanovic-6165-resource.cognitiveservices.azure.com/
```

## Dograh Embedding pointer for Sweden small
```text
Provider: Azure OpenAI
Model: text-embedding-3-small
Endpoint: https://dsselmanovic-6165-resource.openai.azure.com/
Api Version: 2024-02-15-preview
```
See `references/dograh-embedding-byok.md`.
