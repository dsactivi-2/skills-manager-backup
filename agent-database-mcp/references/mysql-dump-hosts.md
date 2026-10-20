# Host a MySQL dump, then attach agents via Composio

None of these hosts give Composio SQL by themselves. Composio is the gateway; the host is only storage. Verified 2026-08.

## Verdict for a classic mysqldump (MySQL 8, InnoDB, AUTO_INCREMENT, ~1 GB+)

| Host | What it is | Dump in | Composio SQL? | Use when |
|---|---|---|---|---|
| **Aiven MySQL** | Managed MySQL 8 | `mysql < dump.sql` | No toolkit — MCP in front | 1:1 restore, EU/GDPR, PITR on paid plans |
| **Railway MySQL** | Official `mysql` Docker + volume, **unmanaged** | `mysql < dump.sql` | No — but MCP can sit in the same project (private net) | Fast dump + MCP together |
| **PlanetScale Vitess** | Not vanilla MySQL | Live import needs GTID + ROW binlog; not a `.sql` upload | No toolkit (404) | Do not use for a static CRM dump |
| **TiDB Cloud** | MySQL protocol, different engine | Possible; AUTO_INCREMENT / procs differ | No toolkit (404) | Overkill below multi-GB HTAP |
| **Supabase** | Postgres + Auth/Storage/Realtime | **Migration** (pgloader/Colab from a **running** MySQL). Docs: https://supabase.com/docs/guides/platform/migrating-to-supabase/mysql | Yes (`supabase` toolkit: Execute SQL, read-only SQL, Select) | Only after a deliberate engine change |

Links (live):

| | |
|---|---|
| Aiven MySQL | https://aiven.io/mysql |
| Aiven Console | https://console.aiven.io/ |
| Aiven get-started | https://aiven.io/docs/products/mysql/get-started |
| Railway MySQL | https://docs.railway.com/databases/mysql |
| Supabase | https://supabase.com |
| Supabase MySQL migrate | https://supabase.com/docs/guides/platform/migrating-to-supabase/mysql |

## Free-tier trap (do not copy stale comparison tables)

| Claim often seen | Live (2026-08) |
|---|---|
| Supabase Free holds the dump | **No.** Free = 500 MB DB, 500 MB RAM, pause after 1 week. A 1.4 GB dump needs Pro + disk. |
| Aiven Free = 1 GB RAM + 5 GB disk | **Not verified.** Postgres pricing table: Free = 1 GB RAM + **1 GB** disk; Developer = 8 GB disk. Re-open https://aiven.io/pricing?product=mysql before quoting. |
| “Supabase is simpler” | True for greenfield Postgres. False for an existing MySQL dump. |

## Composio Custom MCP (own host → Grok bots)

Register a **public HTTPS** MCP; Composio does not host it.

```
POST https://backend.composio.dev/api/v3.1/custom/toolkits/upsert
Header: x-api-key
Body: slug, toolkit_config.app_url, auth_schemes
```

Returns `CUSTOM_<SLUG>`. Sync via `POST /api/v3.1/custom/toolkits/sync`. Experimental; `app_url` and `auth_schemes` are immutable after register. Docs: https://docs.composio.dev/docs/extending-sessions/custom-mcp

## Not a database host

- **Browserbase** (https://www.browserbase.com) — browser-as-a-service. Composio `/toolkits/browserbase` = 404.
- **Baserow** — Composio toolkit exists (list DBs/tables). Not a 179-table CRM SQL restore.
