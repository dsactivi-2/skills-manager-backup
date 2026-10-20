# Recruiting-CRM HTTP MCP (Hermes)

Repo skill (user-owned, do not curator-patch): `recruiting-crm` from `dsactivi-2/recruiting-crm-mcp`.
HTTP MCP is separate. Skill = how to talk. MCP = live tools (`hermes mcp test` / `tool_search`), not the skill catalog.

## Add (no secrets in this file)

User pastes YAML with `url` + `headers.Authorization: Bearer …`. Write via `hermes config set mcp_servers.recruiting-crm.*` (field `headers`, not `http_headers`). Then `hermes mcp test recruiting-crm`.

Tools live in the chat after `/reload-mcp` or a new session — **except** when this session's deferred catalog already lists `mcp__recruiting_crm__*`. Then probe immediately; do not ask for reload.

"verbinde MCP / aktiviere Skills" when already on: `hermes mcp list` (✓ enabled) + `hermes mcp test recruiting-crm` + `tool_search`. Do not re-`config set`. Jobstep-crm child skills are separate and already enabled locally — connecting this MCP is not a skill reinstall.

## Live tools

`hermes mcp test recruiting-crm` is the server list. Session `tool_search` can lag until `/reload-mcp` unless the catalog already has the prefix.

Verified 2026-09-01 later same day: **13 tools** (Worker beyond 1.2.0's 9). Trust `hermes mcp test`, not the user-owned `recruiting-crm` SKILL.md (still may list 9).

- `count_candidates` (filters[], query)
- `search_candidates` (filters[], query, limit, cursor)
- `get_candidate` (candidate_id) — profile without Ausweis fields
- `list_occupations` (query, limit)
- `search_candidates_by_occupation` (occupation_slug, min_years, limit)
- `list_candidate_jobs` (candidate_id)
- `list_occupation_review_queue` (limit)
- `remap_job_occupation` (kri_id; target slug **or** id **or** new_label_bs)
- `unmap_job_occupation` (kri_id; optional remove_alias)
- `get_allowed_transitions` (status number → draft edges)
- `get_allowed_candidate_transitions` (candidate_id)
- `get_status_history` (candidate_id)
- `set_application_status` (pipeline; default `dry_run=true`) — **Freigabe** for live writes

If `hermes mcp test` shows a tool but `tool_describe` is not_found: session catalog is stale — ask `/reload-mcp`. Do not remap or `set_application_status` until that tool exists **in this chat**.
The on-disk skill may omit status/remap tools (user-owned). Trust the server list.

## Probe then explain

Read-only first: `list_occupations` (tiny limit) + `count_candidates` with no filters.
If Denis asks what that meant: Alltagssprache. Probe 1 = Berufe gehen. Probe 2 = Zählen geht (Gesamtpool, keine Suche).
Never lead with tool names and raw integers.

## Worker env vs Hermes client

Worker `index.ts` does `env.SUPABASE_URL.replace(...)`. If that secret is missing, **every** `tools/call` returns `Cannot read properties of undefined (reading 'replace')` while `initialize` / `tools/list` / `hermes mcp test` stay green.

Fix: Cloudflare Worker secrets `SUPABASE_URL` + `SUPABASE_SECRET` (+ MCP_READ_KEY). Not a Hermes header bug. Do not loop `list_occupations` in-session after 3 failures. Do not invent occupation counts.

Fallback when session MCP tools fail but CLI test is green: JSON-RPC POST to `/mcp` (plain JSON, not SSE) with `Authorization` from config. Same error string means Worker env, not transport.

## Sourcing counts (verified 2026-09-01)

Filter that works:

```json
[{"field":"occupation","op":"in","value":["elektricar"]}]
```

Same `op`+`field` with several slugs = unique candidates who have **any** of those mapped jobs. Per-slug counts can sum higher than the bucket (overlap). `{"id":12,...}` → RPC `filter missing field`.

Do **not** use `count_candidates` `query` or `job_title` `contains` until the RPC is fixed: `22025 invalid escape string`. That is why Freitext-Titel (ungemappt) are missing from occupation totals — two stores: raw job text vs mapped slug; only the slug store is countable.

Catalog has no DE names Tiefbauer / Glasfasermonteur / HDD. Use nearest BS slugs (`gradevinski_radnik_niskogradnje`, `monter_optickih_kablova`, …). If a slug is missing, say 0 = Katalog kennt den Beruf nicht, not "es gibt niemanden".

## Review queue (read-only)

`list_occupation_review_queue`: groups by `raw_title`, `job_count` = Jobzeilen not Personen, `sample_kri_id`, `method` unmapped|trgm. Worker/RPC returns max **100 groups** even if `limit` is 2000. Do not report that as total unmapped candidates. Empty `raw_title` is a real bucket (121 jobs in the 2026-09-01 sample).

Remap/unmap: exists on the Worker (READ key can call remap in `index.ts`). Still **Freigabe**. "nur prüfen nicht handeln" = no `remap_job_occupation` / `unmap_job_occupation`.

## Rules from the skill (still apply at the MCP)

Nur CRM-RPCs via these tools. No raw SQL. No JMBG/password/Ausweis in answers. Count → search → profile. Remap/unmap only after `list_candidate_jobs` and only if those tools exist **in this chat**.
