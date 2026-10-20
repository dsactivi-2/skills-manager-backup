---
name: jobstep-crm-supabase
description: "Use when Jobstep CRM on Supabase needs MCP or RPC verify."
version: 1.0.0
license: MIT
metadata:
  hermes:
    tags: [jobstep, crm, supabase, mcp, rpc]
    related_skills: [supabase-mysql-cutover, supabase-postgres-connectivity, verify-first-workflow]
---

# Jobstep CRM on hosted Supabase

Class-level: after MySQL is in schema `crm`, keep MCP/RPCs honest. Load path is `supabase-mysql-cutover`. SSL/pooler is `supabase-postgres-connectivity`.

Overlaps `supabase-mysql-cutover` (`references/jobstep-status-gates.md`, `references/peer-agent-verify.md`). Use this skill for pasted peer-agent CRM work and `crm_api` grant checks.

## User preference

- DE, tables, live verify. Plan/docs first. Deploy only after a Freigabe line.
- Paste from another agent (“fertig, als Nächstes …”) is **not** Freigabe to continue. Verify live, document, push. Do not re-apply SQL. Do not start the offered next step.
- No Data API, no anon, no password print. Integer `kandidat_id`, prijave 1–27 — not UUID/`new→hired`.

## Verify loop

1. MCP SQL: `pg_proc`, `pg_policy`, `has_function_privilege`, counts.
2. Write `docs/NN_*.md` in `dsactivi-2/jobstep-crm-status-mcp`, tick `docs/17_BACKLOG.md`.
3. Commit + push. No `.env`.

## Facts that keep biting

- Two people stacks: `idk_kandidati` vs DIPL `idk_nd_kandidata`. PDFs = hash names on the PHP host, not in Postgres.
- `authorize()` = `auth.uid()` + `user_roles`. Empty map → forbidden. Pooler `activi` is not a JWT user.
- DEFINER revoke-from-anon often drops `activi` EXECUTE. Re-grant whatever stdio MCP must call.
- `*_safe` / `smoke_test_*` may be authenticated+service_role only while old `set_candidate_status` still has `activi`.
- Keep `crm`, `crm_api`, `crm_auth`, `crm_audit` off Data API Extra schemas.

Repo: https://github.com/dsactivi-2/jobstep-crm-status-mcp
