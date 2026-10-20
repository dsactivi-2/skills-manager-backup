# Org STT/TTS/LLM config API (voiceeu + Cloud)

Workflow TS does **not** hold voice/locale. Use user configuration endpoints.

## Auth

| Instance | Header |
|----------|--------|
| voiceeu | `X-API-Key: $MCP_DOGRAH_VOICEEU_API_KEY` |
| Cloud | `Authorization: Bearer $MCP_DOGRAH_API_KEY` |

## Endpoints

```text
GET  /api/v1/user/configurations/user
PUT  /api/v1/user/configurations/user
GET  /api/v1/user/configurations/user/validate
GET  /api/v1/user/configurations/defaults
```

Base voiceeu: `https://voiceeu.activi.io`

## BS Stufe 1 TTS (live 2026-07-30)

```json
{
  "tts": {
    "provider": "azure_speech",
    "api_key": "<masked-from-GET-or-real-if-new>",
    "model": "neural",
    "region": "germanywestcentral",
    "voice": "bs-BA-VesnaNeural",
    "language": "bs-BA",
    "speed": 0.95
  }
}
```

- Same `provider` + masked `api_key` from GET → merge restores real secret.
- Male alt: `bs-BA-GoranNeural`.
- Do **not** use `hr-HR-GabrijelaNeural` for BiH prod.

## Verify

1. GET config → assert voice/region/language/speed  
2. `GET .../validate` → empty/ok status  
3. Real call (org-wide applies to every workflow)

## Not this API

- Agent SSML tags (escaped by Pipecat)  
- Workflow publish  
- Personal Voice clone (Speech Studio + gated access)

## Related

- SSML runtime: `dograh-azure-ssml-runtime.md`  
- Stack pick: `balkan-voice-agent-stack`  
