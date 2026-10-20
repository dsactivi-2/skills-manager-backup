---
name: agent-database-mcp
description: "Use when wiring Grok/Hermes to a DB via Composio or MCP."
version: 1.0.0
author: Agent
license: MIT
metadata:
  hermes:
    tags: [MCP, Composio, Grok, database, CRM]
    related_skills: [hermes-mcp-http, native-mcp, grok-build]
---

# Agent access to databases (Composio + MCP)

Use when the user wants Grok bots, Hermes, or other agents to filter/search a database, "upload a dump to Composio", or attach a DB via MCP.

## Decision (do this first)

| The data lives in | Path | Not this |
|---|---|---|
| Supabase Postgres | Composio toolkit `supabase` → hosted MCP | Own SQL server |
| Snowflake | Composio toolkit `snowflake` (`Execute SQL`) | Dump upload |
| Neon | Composio toolkit `neon` (admin/schema; not a generic SQL host) | Treat as "any Postgres" |
| Airtable / Sheets / Notion | Matching Composio toolkit | Call it a SQL DB |
| Own MySQL / Postgres / dump / LAN / k3s | Restore privately + **your** HTTPS MCP (catalog + read-only SELECT). Optional: hang that MCP on Composio Gateway | Upload dump to Composio |

Composio is a **tool/auth gateway**, not a database host. Verified 2026-08: `/toolkits/postgres` and `/toolkits/postgresql` are **404**. There is no generic connection-string toolkit.

## Grok attachment (verified)

| Surface | How |
|---|---|
| Grok Build | `grok mcp add --transport http composio https://connect.composio.dev/mcp` then OAuth in `/mcps` |
| xAI API | Remote MCP: Streaming HTTP or SSE only. Pass `server_url` + `headers` (`x-api-key` for Composio). Docs: `https://docs.x.ai/developers/tools/remote-mcp` |
| grok.com "bots" product page | Not verified (docs 404). Do not assume a dump-upload UI |

Composio hosted MCP shape:

```
https://backend.composio.dev/v3/mcp/<server_id>?user_id=<id>
Header: x-api-key: <COMPOSIO_API_KEY>
```

Sessions: `composio.sessions.create(..., mcp=True)` → `session.mcp.url` + `session.mcp.headers`. Scope tools (`SESSION_PRESET_DIRECT_TOOLS`) so the model does not load 100+ admin actions.

## Hard limits (do not fight these)

1. **Custom Composio tools stay local.** `experimental_createTool` / `LOCAL_*` run in the SDK process. Hosted MCP does **not** expose them (`docs.composio.dev/docs/sessions-via-mcp`).
2. **xAI must reach the MCP.** Private LAN MySQL is invisible unless a public HTTPS MCP sits in front (or Composio Gateway fronts that MCP).
3. **Prod dumps are not a platform.** Do not upload CRM/PII dumps (JMBG, passports, password hashes, API tokens) to Composio, Supabase, or any SaaS. Restore privately; replica > dump when a live DB exists.
4. **Agents need a catalog, not raw table names.** Ship `catalog_search` / `list_tables` / `describe_table` / `query_readonly` (SELECT + LIMIT, strip PII columns). Free-form write SQL is out.

## Own-DB MCP shape

1. Restore MySQL/Postgres read-only (OrbStack or AWS replica — never prod write).
2. MCP tools: catalog first, then bounded SELECT.
3. Optionally register the same URL as custom MCP behind Composio Gateway so Grok bots keep one Composio connection.

Kette: Grok → Composio Gateway (optional) → dein MCP → DB (read-only).

## Pitfalls

- Asking Composio for "Postgres/MySQL toolkit" — does not exist; pick SaaS toolkit or own MCP.
- Putting a connection string in a bot prompt.
- Enabling full Supabase/Neon admin tool lists on a Grok bot (delete project, migrate, keys).
- Treating Neon toolkit as "run any SQL on Neon" — mostly management API.
- Converting a 1GB+ MySQL dump to Supabase just to get Composio SQL tools — usually the wrong trade. **Exception (User 2026-08-18):** Jobstep `productioncrmdb` wird bewusst auf **Supabase** gehostet. Folge `/Users/activi/Documents/Handover-CRM-productioncrmdb-Agent-Zugang.md` + Session-Prompt. Trotzdem: Zwischen-MySQL + pgloader, Paid-Plan, read-only, kein Dump-Direktimport.

## Support

- `references/composio-db-limits.md` — toolkit/SQL matrix + MCP URLs
- `references/jobstep-crm-catalog.md` — `productioncrmdb` prefix map for Jobstep CRM dumps
