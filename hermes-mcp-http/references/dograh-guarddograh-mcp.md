# Guarddograh MCP (third Dograh)

OSS self-host, same auth as voiceeu.

| | |
|---|---|
| URL | `https://guarddograh.activi.io/api/v1/mcp/` |
| Hermes name | `dograh-guarddograh` |
| Env | `MCP_DOGRAH_GUARD_API_KEY` in `~/.hermes/.env` |
| Header | `X-API-Key` (Bearer → tools 401) |
| Tools | `mcp__dograh_guarddograh__*` |
| Key UI | `https://guarddograh.activi.io/api-keys` |

```yaml
dograh-guarddograh:
  url: https://guarddograh.activi.io/api/v1/mcp/
  headers:
    X-API-Key: ${MCP_DOGRAH_GUARD_API_KEY}
  enabled: true
```

`hermes config set` for url / headers / enabled. GET `/api/v1/mcp/` → 405 is OK. `hermes mcp test` then `/reload-mcp` — test green ≠ current session tools until reload.
