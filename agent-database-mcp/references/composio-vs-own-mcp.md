# Composio vs eigener DB-MCP

Use when wiring Hermes, Codex, Grok, or other agents to a database. Composio is a gateway, not a database host.

## Do not

- Recommend uploading a MySQL dump to Composio, Browserbase, or Supabase Free.
- Recommend Supabase only because Composio has a SQL toolkit, when the source is a MySQL dump.
- Expect Composio custom tools (`experimental_createTool`) to appear on hosted MCP / Grok / Codex. They run in-process only.
- Give agents write SQL or 100+ admin tools (Supabase/Neon catalogs).

## Composio toolkit reality (live-checked)

| Toolkit | Hosts your dump? | Agent SQL? |
|---|---|---|
| mysql / postgres / planetscale | No (404) | No |
| supabase | Only after MySQL→Postgres migration from a *running* MySQL (pgloader/Colab), not `mysql < dump.sql` | Yes, including writes |
| snowflake | If data is already there | Yes |
| neon | Postgres only; mostly admin API | Weak |
| railway | Railway hosts MySQL; Composio toolkit is deploy/logs only | No |
| browserbase | Not a DB | No |

Supabase official MySQL path: https://supabase.com/docs/guides/platform/migrating-to-supabase/mysql  
Supabase Free DB size: 500 MB (pauses after 1 week). Multi-GB dumps need paid disk.

## Host for a MySQL dump (1:1)

Prefer in this order for a classic InnoDB dump (`utf8mb3`, AUTO_INCREMENT):

1. Existing private MySQL (Hetzner/k3s/OrbStack/AWS replica)
2. Aiven MySQL (real MySQL 8, `mysql < dump.sql`, EU cloud on paid plans) — https://aiven.io/mysql
3. Railway MySQL Docker (unmanaged; good to colocate MCP)

Avoid PlanetScale (Vitess + live GTID import, not SQL-file upload) and TiDB (compatibility/AUTO_INCREMENT) for dump restore.

## Target architecture

One CRM-MCP, many clients. Composio optional.

```
Hermes / Codex / Claude / OpenCode  --direct HTTPS MCP-->
Grok-Bots / other Composio agents   --Composio CUSTOM_*-->  CRM-MCP (read-only)
                                                         --> MySQL copy, user SELECT-only
```

MCP tools (keep ≤4, not one per table):

- `catalog_search` — table meaning (`idk_nalozi` = Stellenauftrag)
- `list_tables` — filter by module prefix
- `describe_table`
- `query_readonly` — SELECT/SHOW/EXPLAIN only, hard LIMIT, timeout, reject DML/DDL, PII column blacklist

Custom MCP register: `POST https://backend.composio.dev/api/v3.1/custom/toolkits/upsert` (public HTTPS required). Docs: https://docs.composio.dev/docs/extending-sessions/custom-mcp

## Client config (same URL)

| Client | Where |
|---|---|
| Codex App | `~/.codex/config.toml` `[mcp_servers.crm]` — often SoT here |
| Hermes | `mcp_servers.crm` url + headers; `hermes mcp test crm` |
| Grok Build | `grok mcp add --transport http crm <url>` or Composio `https://connect.composio.dev/mcp` |
| xAI API | Remote MCP, Streaming HTTP/SSE only — https://docs.x.ai/developers/tools/remote-mcp |

Handovers and Zielketten must list Hermes + Codex + Grok + others, never Grok-only.

## PII

Production CRM dumps (JMBG, hashes, API tokens, vici logins) stay private. Rotate leaked tokens on prod. Agent user: SELECT only + views without password/token/jmbg/passport/vici columns.
