# Dograh OSS self-host MCP auth

## Header matrix

| Header | Cloud api.dograh.com | Self-host OSS (voiceeu) |
|--------|----------------------|-------------------------|
| `X-API-Key: dgr_…` | often OK | **Required** for REST + tools |
| `Authorization: Bearer dgr_…` | often OK | **401** on tools/REST; `initialize` / `mcp test` may still look green |

Config shape:

```yaml
dograh-voiceeu:
  url: https://voiceeu.activi.io/api/v1/mcp/
  headers:
    X-API-Key: ${MCP_DOGRAH_VOICEEU_API_KEY}
  enabled: true
```

Key source: `https://voiceeu.activi.io/api-keys` → `MCP_DOGRAH_VOICEEU_API_KEY` in default **and** profile `.env`.

## Failure ladder

1. `hermes mcp test` green but session tool `401 Invalid/Missing API key` → wrong header (Bearer) or session not reloaded.
2. Fix yaml to `X-API-Key`, ensure env non-empty, **new session or MCP reload**.
3. Prove key with REST: `GET /api/v1/workflow/fetch` + `X-API-Key` before blaming MCP stack.

## Related

- Skill body dual-instance MCP table
- `hermes-mcp-http` for general HTTP header patterns
