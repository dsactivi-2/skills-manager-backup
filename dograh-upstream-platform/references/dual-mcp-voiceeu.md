# Dual MCP: Cloud vs voiceeu

| | Cloud | Self-host |
|--|-------|-----------|
| UI | https://app.dograh.com | https://voiceeu.activi.io |
| MCP | https://api.dograh.com/api/v1/mcp/ | https://voiceeu.activi.io/api/v1/mcp/ |
| Hermes name | dograh | dograh-voiceeu |
| Env | MCP_DOGRAH_API_KEY | MCP_DOGRAH_VOICEEU_API_KEY |
| Key UI | Cloud /api-keys | https://voiceeu.activi.io/api-keys |

User pastes key only in `~/.hermes/.env`. Header: `Authorization: Bearer ${…}`. Restart Hermes. Test: `hermes mcp test dograh-voiceeu`.

Mental model for user (DE): zwei Fernbedienungen, zwei Schlüssel — Cloud sieht Self-Host-Logs nicht.
