# Composio + Grok: database limits

Verified 2026-08 against composio.dev + docs.x.ai. Re-check toolkit URLs if a year has passed.

## Toolkits that can actually query

| Toolkit | Auth | Query tools | Notes |
|---|---|---|---|
| `supabase` | OAuth2 / API key | Execute SQL, read-only SQL, Select From Table | Best Composio path for Postgres-as-SaaS |
| `snowflake` | OAuth / Basic | Execute SQL, Show Databases/Schemas/Tables | Warehouse SQL |
| `neon` | API key | Schema/DDL, connection URI, project/branch admin | Not a generic SQL runner |
| `airtable` / `googlesheets` / `notion` | OAuth | Table/row APIs | Fine if that *is* the store |

Missing (404): `https://composio.dev/toolkits/postgres`, `.../postgresql`. No MySQL / generic DSN toolkit.

## MCP endpoints

| Kind | URL |
|---|---|
| Grok Build one-liner | `https://connect.composio.dev/mcp` |
| Per-server hosted | `https://backend.composio.dev/v3/mcp/<id>?user_id=<user>` |
| Auth header | `x-api-key: <COMPOSIO_API_KEY>` (default for new orgs) |
| Dashboard MCP configs | `https://dashboard.composio.dev/~/org/connect/clients` |
| Sessions-over-MCP docs | `https://docs.composio.dev/docs/sessions-via-mcp` |
| Custom tools (in-process only) | `https://docs.composio.dev/docs/custom-tools` |
| xAI Remote MCP | `https://docs.x.ai/developers/tools/remote-mcp` — HTTP stream + SSE only |

## What hosted MCP will not do

- Run `experimental_createTool` / `LOCAL_*` custom tools (those stay in the SDK process).
- Reach a private MySQL/Postgres that Composio cannot see.
- Store or restore a `.sql` dump.

## Grok Build

```bash
grok mcp add --transport http composio https://connect.composio.dev/mcp
```

First toolkit use triggers Composio OAuth. Scope allowed tools; do not enable Neon/Supabase admin deletes on a bot.
