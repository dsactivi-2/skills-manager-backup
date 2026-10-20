# OSS Dograh: Bearer vs X-API-Key (401 ladder)

## Symptom

- `hermes mcp test dograh-voiceeu` → Connected, 16 tools
- Session `mcp__dograh_voiceeu__list_workflows` → `401 Invalid or expired API key`
- Or REST `Authorization: Bearer dgr_…` → `401 Invalid or expired token`

## Cause

Self-host OSS treats platform API keys as **X-API-Key**, not JWT Bearer.

MCP initialize can succeed even when tool auth later fails if headers differ or session is stale.

## Fix

1. `~/.hermes/config.yaml` for voiceeu:

```yaml
headers:
  X-API-Key: ${MCP_DOGRAH_VOICEEU_API_KEY}
```

2. Key only in `~/.hermes/.env` (`MCP_DOGRAH_VOICEEU_API_KEY`), from https://voiceeu.activi.io/api-keys

3. Reload MCP / new session

4. Re-test: `hermes mcp test` line must show `X-API-Key`, then live list_workflows

## Do not

- Paste keys into chat
- Reuse Cloud `MCP_DOGRAH_API_KEY` on voiceeu
- Assume Codex TOML matches Hermes (Codex may point voiceeu name at cloud URL)
