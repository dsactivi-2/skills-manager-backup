# MCP-Lock: nur crm-remote

In Codex heißt der Server **crm-remote**.
Der Worker selbst nennt sich crm-mysql. Das ist derselbe Server, nicht das lokale stdio crm-mysql.

URL: https://crm-pipedrive-worker.6f484zn9bd.workers.dev/mcp
Auth: Authorization Bearer aus CRM_REMOTE_MCP_TOKEN

## Erlaubte Tools (exakte Codex-Namen)

Nur diese Prefixes:

- mcp__crm_remote__crm_search_guide
- mcp__crm_remote__crm_stats
- mcp__crm_remote__crm_search_kandidaten
- mcp__crm_remote__crm_kandidat_profile
- mcp__crm_remote__crm_resolve_beruf
- mcp__crm_remote__crm_search_companies
- mcp__crm_remote__crm_search_nalozi
- mcp__crm_remote__crm_query
- mcp__crm_remote__crm_list_tables
- mcp__crm_remote__crm_describe_table

Wenn mcp__crm_remote__* in der Tool-Liste fehlt: Session neu starten. Nicht auf einen anderen CRM-MCP ausweichen. Dieselbe Worker-URL darf ueber scripts/beruf_report.py genutzt werden (ein crm_query). Nicht Neon, nicht Supabase, nicht stdio crm-mysql.

## Verboten

- mcp__crm_suche_2__*  (alter Neon-Bundle, search_candidates)
- mcp__Neon__* und mcp__codex_apps__neon_*
- mcp__codex_apps__supabase_*
- lokales stdio crm-mysql (Kimi-Command, nicht der Worker)
- crm-neon, crm-scout für Kandidatensuche

search_candidates, get_full_profile, run_query vom Neon-Bundle sind falsch, auch wenn sie in dieser Session noch sichtbar sind.

## Query-Trigger (Pflicht)

Immer zusammen mit diesem File lesen: [kandidati-filter-query.md](kandidati-filter-query.md)

Das sind die Kandidaten-Queries (Bevölkerung, Archiv, Beruf über beruf_mapping/kri_pozicija, Sprachen über kj_slusanje, Alter mit TIMESTAMPDIFF, COUNT DISTINCT). CRM-Filter nicht 1:1 als SQL kopieren.
