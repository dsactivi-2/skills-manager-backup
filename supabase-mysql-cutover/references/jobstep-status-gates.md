# Jobstep CRM after MySQL→Supabase load (2026-08-19)

Private MCP repo: `https://github.com/dsactivi-2/jobstep-crm-status-mcp`

## User gates

- Plan + document first. Build/start MCP only after a Freigabe line.
- No Data API for CRM. No OAuth. Pooler + role `activi` + `DATABASE_URL`.
- German, tables. Do not invent ATS paths (`new → hired`).

## Post-load that still bites

- `apply_migration` as `postgres` fails `42501 must be owner` when tables belong to `activi`. `grant activi to postgres with inherit true, set true` then `set role activi` in the same batch.
- pgloader does not create sequences. RPC INSERT → `23502` on `lsp_id`/`lks_id`. `setval(max)` on every MySQL AUTO_INCREMENT column.
- `gin_trgm_ops` lives in `extensions`. Loader often has no USAGE — create those indexes as `postgres` with `extensions.gin_trgm_ops`.
- Dashboard Tables empty = schema dropdown still `public` (0 tables). Switch to `crm`.
- `idk_kandidati` ~122k 1:1 MySQL. “200k+” = plus `idk_nd_kandidata` (~81k DIPL). PDFs are hashes on the PHP host, not in Postgres.

## RPCs / crm_api

- Two overloads of `crm.set_candidate_application_status`. Call the **7-arg** gated form only.
- Wrappers: `crm_api.set_candidate_status`, `get_allowed_transitions` (by **current status**, not candidate_id), `get_status_history`.
- After DEFINER hardening, revoke anon then **grant execute to `activi`** or Pooler MCP dies. Snapshot: repo `docs/sql/crm_api_grants.sql`.
- Option 2: RLS on `candidate_status_transition_rules`, only `service_role` policy, no table GRANT to anon/authenticated.
- Do not put `crm` or `crm_api` in Data API Extra schemas while `authenticated` can EXECUTE writes.

## MCP host

- Stdio + `.env` (`DATABASE_URL`, `PGSSLMODE=require`). Never commit `.env` or put the URL in `ecosystem.config.cjs`.
- PM2 only for a long-lived bridge, not for Hermes/Claude stdio.
- No OAuth in this MCP.
