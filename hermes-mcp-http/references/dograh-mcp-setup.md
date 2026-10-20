# Dograh MCP Setup (updated 2026-07-28)

## Two instances (Activi)

| Role | URL | Hermes server | Env |
|------|-----|---------------|-----|
| Cloud | `https://api.dograh.com/api/v1/mcp/` | `dograh` | `MCP_DOGRAH_API_KEY` |
| Self-host | `https://voiceeu.activi.io/api/v1/mcp/` | `dograh-voiceeu` | `MCP_DOGRAH_VOICEEU_API_KEY` |

Session tool prefixes: `mcp__dograh__*` vs `mcp__dograh_voiceeu__*` (underscores).

Full dual-instance skill: `dograh-dual-instance`.

## Auth header (critical)

Dograh **OSS API keys** (`dgr_…` from `/api-keys` on that host):

| Header | Self-host OSS (voiceeu) |
|--------|-------------------------|
| `X-API-Key: dgr_…` | **OK** — REST + MCP tools |
| `Authorization: Bearer dgr_…` | **401** on tools/REST; `initialize` / `hermes mcp test` may still look green |

```yaml
# Self-host — correct
dograh-voiceeu:
  url: https://voiceeu.activi.io/api/v1/mcp/
  headers:
    X-API-Key: ${MCP_DOGRAH_VOICEEU_API_KEY}
  enabled: true
```

Key UI: `https://voiceeu.activi.io/api-keys` (not app.dograh.com).
Store only in `~/.hermes/.env` and profile `.env` if needed — never chat.

## Install / add

```bash
printf 'Y\nY\n' | hermes mcp add dograh --url https://api.dograh.com/api/v1/mcp/ --auth header
hermes mcp test dograh
hermes mcp test dograh-voiceeu   # must show X-API-Key
```

Prefer editing `config.yaml` + `.env` for dual servers.

## Pitfalls

- `hermes mcp test` green ≠ session tools authenticated — wrong header or stale session → 401 on tool call.
- After yaml/env change: **MCP reload or new session** (headers do not hot-reload reliably).
- `hermes mcp configure` is interactive; prefer `mcp add` with piped Y or direct yaml.
- MCP2Skill Gateway not needed when native `mcp_servers` in config.yaml.
- Codex may name a server `dograh-voiceeu` but still point at **cloud** URL — fix URL when wiring self-host.
- REST probe: `X-API-Key` → `GET /api/v1/workflow/fetch` should be 200 (never print the key).

## Tools (16 typical)

create_workflow, get_workflow, get_workflow_code, save_workflow, list_workflows, list_node_types, get_node_type, list_tools, create_tool, list_credentials, list_documents, list_recordings, get_voice_prompting_guide, list_docs, read_doc, search_docs.

## See also

- `dograh-dual-instance` + `references/mcp-x-api-key-401.md`
- Offline: `dograh-selfhost-guides/references/mcp.mdx`
