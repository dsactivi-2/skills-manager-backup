# n8n-lk MCP OAuth refresh

Verified 2026-08-28. Tokens live in `~/.hermes/mcp-tokens/n8n-livekit.{json,client.json,meta.json}`. Never print token values.

## Symptom

- UI `https://n8n-lk.activi.io` → HTTP 200
- `hermes mcp test n8n-livekit` → Auth OAuth 2.1 PKCE, Connection failed (~30010ms), empty reason
- Session MCP reload may omit `n8n-livekit` even though `hermes mcp list` shows enabled

Cause: `expires_at` in `n8n-livekit.json` is in the past (`expires_in` is 3600s).

## Trap

`n8n-livekit.meta.json` `token_endpoint` / `issuer` can be `https://vmi….contaboserver.net/mcp-oauth/token`. That host TLS-fails (`TLSV1_ALERT_INTERNAL_ERROR`). Project rule: never use the Contabo hostname for n8n-lk.

## Fix

POST `https://n8n-lk.activi.io/mcp-oauth/token`

- `grant_type=refresh_token`
- `refresh_token` from `n8n-livekit.json`
- `client_id` from `n8n-livekit.client.json` (no `client_secret`; public PKCE client)

200 returns `access_token`, `refresh_token`, `expires_in`, `scope`, `token_type`. Merge into `n8n-livekit.json`, set `expires_at = now + expires_in`. Then `hermes mcp test n8n-livekit` (Connected, 39 tools including `search_workflows` / `get_workflow_details`).

If the session still has no n8n-livekit tools (config present, catalog empty): do **not** wait on `/reload-mcp` for a read-only Ist-check, and do **not** use `voice-ops-console` or `N8N_API_KEY` (often another host). JSON-RPC POST `https://n8n-lk.activi.io/mcp-server/http` with `Authorization: Bearer <access_token>`, `Accept: application/json, text/event-stream`:

1. `initialize` (protocolVersion `2025-03-26`)
2. `notifications/initialized`
3. `tools/call` `search_workflows` `{ "query": "Energy F" }` and `{ "query": "MONOLITH" }`
4. optional `search_data_tables`

Never print token values. SSE `data:` lines are JSON-RPC results.

If refresh 4xx: user must run `hermes mcp login n8n-livekit` in a TTY, then `/reload-mcp`.

## Audit after connect

Search live, do not hardcode IDs as eternal: `Energy F` and `MONOLITH`. Report `name`, `id`, `active` only from this call. Expect a five-flow Energy set plus a monolith name that can stay unpublished, plus a leftover error workflow that may still be `active=true` with 0 triggers. Data table names, if present, look like `energy_leads` / `energy_dnc` / `energy_events` — confirm via `search_data_tables`, do not assume count 0.
