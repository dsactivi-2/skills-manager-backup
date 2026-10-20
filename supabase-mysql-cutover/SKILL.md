---
name: supabase-mysql-cutover
description: "Use when loading MySQL into hosted Supabase Postgres."
version: 1.1.0
license: MIT
metadata:
  hermes:
    tags: [supabase, mysql, pgloader, pooler, cutover]
    related_skills: [supabase-postgres-connectivity, supabase, verify-first-workflow]
---

# MySQL → hosted Supabase cutover

Class-level: move a MySQL database into a hosted Supabase schema. SSL/pooler hosts are `supabase-postgres-connectivity`. Schema/RLS after load is hub `supabase`.

Proven load detail lives in `supabase-postgres-connectivity` → `references/mysql-to-supabase-load.md`. This skill is the cutover sequence and the Freigabe gates.

## User preference

- Direct DE, tables, live verify. No password print.
- „In einfachen Worten“ / „was heißt das“ → one jargon table, no runbook repeat.
- No DDL/write without explicit Freigabe. No second full reload while counts match.

## Sequence

1. Live-count source and target (MCP `execute_sql` + MySQL **TCP**, not the unix socket).
2. Create empty tables once.
3. Load with chunked `COPY` from the Mac (`pymysql` + `psycopg`, commit ~2000, keepalives, official CA).
4. Index/PK SoT = live MySQL `information_schema.statistics`, never a stale repo dump.
5. Count every table, then Advisors. Keep the schema off `anon`/`authenticated`.

## Pitfalls

- pgloader bulk `COPY` of 100k+ rows over the session pooler hangs (`COPY … [0/1]`, CPU 0). Tiny tables can succeed.
- `multiple readers` on million-row tables OOMs the dumped SBCL image. Terminate leftover `application_name=pgloader` backends before retry.
- PHP CRM repos often ship a tiny old `CREATE TABLE` dump. That is not schema SoT.
- Autologik is usually hardcoded PHP/cron/ajax, not a settings table. Extract before inventing RPCs.
- Do not reset the dashboard `postgres` password just to load. Dedicated login role + hex password via `supabase db query --linked --file`.
- Management API dollar-quoting breaks (`42601`). Use `openssl rand -hex 32` and a plain `'…'` literal.
