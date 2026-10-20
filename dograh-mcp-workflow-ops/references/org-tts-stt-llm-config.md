# Org TTS/STT/LLM config (voiceeu / Dograh)

## Where voice lives
- **Not** in workflow TS (`@dograh/sdk` graph).
- **Org** `model_configuration_v2` (BYOK pipeline): LLM + STT + TTS.
- Optional rare per-workflow `model_configuration_v2_override` (not in normal PAS TS).

## API (voiceeu)
```bash
# Auth: X-API-Key (service/API key), not Bearer JWT for MCP keys
GET  https://voiceeu.activi.io/api/v1/user/configurations/user
PUT  https://voiceeu.activi.io/api/v1/user/configurations/user
GET  https://voiceeu.activi.io/api/v1/organizations/context   # organization_id
GET  https://voiceeu.activi.io/api/v1/organizations/model-configurations/v2
```

### PUT body (TTS example)
Send full `tts` object. Masked `api_key` from GET is OK if provider unchanged — server merges real secret.
```json
{
  "tts": {
    "provider": "azure_speech",
    "api_key": "<masked-or-real>",
    "model": "neural",
    "region": "germanywestcentral",
    "voice": "bs-BA-VesnaNeural",
    "language": "bs-BA",
    "speed": 0.95
  }
}
```
Validate: `GET .../configurations/user/validate` → expect empty/ok status.

## Call path
1. Call starts on any workflow (e.g. WF 22 published).
2. `get_resolved_ai_model_configuration(organization_id)`.
3. `create_tts_service(user_config.tts)` → Pipecat AzureTTSService.
4. LLM text (prompt-driven language) → TTS voice.

**Draft/publish workflow NOT required** for Org TTS/STT/LLM changes. Next call picks up config.
Draft/publish **only** for graph/prompt/edge/webhook TS edits.

## Activi voiceeu defaults (re-verify live)
| Field | Typical BS |
|-------|------------|
| organization_id | 2 |
| primary login | ds@activi.io (user_id 2) |
| tts.provider | azure_speech |
| tts.region | germanywestcentral |
| tts.voice | bs-BA-VesnaNeural (male: bs-BA-GoranNeural) |
| tts.language | bs-BA |
| tts.speed | ~0.95 |
| stt | verify live (may be Speechmatics `hr` — not ideal for BS) |

## Pipecat Azure SSML (dograh-hq/pipecat + dograhV2)
- Service builds SSML via `_construct_ssml`; agent text is `_escape_text`'d.
- LLM `<break>` / raw SSML tags do **not** control prosody.
- Dograh factory maps Azure `speed` → SSML `rate` only (pitch/style/volume settings exist in Pipecat but not org schema).
- Control delivery via: Org speed, short sentences in prompt, punctuation — not agent SSML.

## Prompt language pattern
- Node/global instructions may be **English** for model clarity.
- Hard rule: **speak only Bosnian** (ijekavian) to customer.
- EN prompt ≠ EN phone audio; TTS voice + LLM output language decide audio.

## Reporting rule (user preference)
When "integrating" voice:
1. State **exactly** what changed: Org config fields / WF TS / local docs only.
2. Never call a docs file or speed-only Org PUT a "workflow save".
3. Name organization_id and whether draft/publish is needed (usually no for TTS).

## Camb / Foundry (not Org TTS)
- Camb Cloud: no proven EU residency; lab only for strict DE/BiH.
- Foundry catalog TTS (`tts`, `tts-hd`, gpt-audio/realtime): **no voice clone**.
- Clone = Azure Speech Personal Voice / Custom Neural (gated), separate from Foundry model deploy.
