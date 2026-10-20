---
name: cloud-crm
description: Use when the user starts Cloud CRM; searches CRM candidates, people, or CVs; explores CRM tables or schema; queries companies, nalozi, or SELECT stats; mentions crm-remote, crm-mysql worker, or crm-pipedrive-worker. Always call MCP crm-remote (mcp__crm_remote__*), never crm-suche-2 or Neon.
---

# Cloud CRM

Zuerst [references/mcp.md](references/mcp.md) lesen. Dann Token. Dann Route.

## MCP (fest)

Server: **crm-remote**
Tools: nur **mcp__crm_remote__***
Worker-URL: https://crm-pipedrive-worker.6f484zn9bd.workers.dev/mcp

Nicht: mcp__crm_suche_2__*, search_candidates, Neon, Supabase, lokales crm-mysql.

Fehlt mcp__crm_remote__*: "Cloud-CRM-MCP ist in dieser Session nicht geladen. Neue Session." Kein Fallback.

## Start

1. `python3 "$HOME/.codex/skills/cloud-crm/scripts/token_store.py" status`
2. Token da: "Token endet auf LAST4. Bestehenden verwenden oder neuen setzen?" Sonst Token erfragen.
3. Neu: `python3 "$HOME/.codex/skills/cloud-crm/scripts/token_store.py" save --token "$TOKEN"`
4. Smoke-Test: **mcp__crm_remote__crm_stats**

## Route

| Anfrage | Datei | Erstes Tool |
|---|---|---|
| Kandidaten / Profile | references/suche.md | mcp__crm_remote__crm_search_kandidaten |
| Schema / 0 Treffer | references/explorer.md | mcp__crm_remote__crm_list_tables |
| Firmen / Nalozi / SQL | references/queries.md | mcp__crm_remote__crm_stats oder crm_query |

Token-Stores: references/stores.md

## Red Flags

- Toolname enthält crm_suche_2, Neon, supabase oder search_candidates.
- Du rufst ein CRM-Tool ohne Prefix mcp__crm_remote__ auf.
