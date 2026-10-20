# MCP matrix (Activi Hermes)

## Dograh product control

| Name | Endpoint | Header | Env |
|------|----------|--------|-----|
| dograh | https://api.dograh.com/api/v1/mcp/ | Authorization Bearer | MCP_DOGRAH_API_KEY |
| dograh-voiceeu | https://voiceeu.activi.io/api/v1/mcp/ | **X-API-Key** | MCP_DOGRAH_VOICEEU_API_KEY |

OSS self-host: Bearer often 401 on tools; X-API-Key required. `hermes mcp test` can look green on wrong auth — always run a real tool (list_workflows).

## Langfuse

| Name | Endpoint | Header | Env |
|------|----------|--------|-----|
| langfuse-voiceeu | cloud.langfuse.com/api/public/mcp | Authorization Basic | LANGFUSE_VOICEEU_MCP_AUTH |
| langfuse-dograh-cloud | same | Authorization Basic | LANGFUSE_DOGRAH_CLOUD_MCP_AUTH |
| langfuse-docs | langfuse.com/api/mcp | — | — |

## Profiles

- **default**: dograh + dograh-voiceeu + LF trio (+ hivemind, bhtelecom)
- **barbares**: dograh + dograh-voiceeu + LF trio (+ composio); default work voiceeu

Put keys in both `~/.hermes/.env` and `~/.hermes/profiles/barbares/.env` when using `-p barbares`.

## Reload

After yaml/env change: MCP reload or **new session**. Headers do not hot-reload reliably.
