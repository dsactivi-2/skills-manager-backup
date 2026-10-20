---
name: supabase-postgres-connectivity
description: "Use when Supabase Postgres client SSL/pooler fails."
version: 1.0.0
license: MIT
metadata:
  hermes:
    tags: [supabase, postgres, ssl, pooler, tableplus, ipv6]
    related_skills: [supabase, supabase-postgres-best-practices, network-endpoint-diagnostics]
---

# Supabase Postgres connectivity (hosted)

Class-level: **GUI/CLI client cannot reach hosted Supabase Postgres** (SSL verify, pooler host, IPv4/IPv6). Not schema/RLS (use hub `supabase`) and not HTTP 404 probes (`network-endpoint-diagnostics`).

Hub skill `supabase` is official and **missing this path**. Do not patch it unless adopted (`hermes curator adopt supabase`).

## User preference

- Direct DE, tables, live verify (CLI + MCP). No theory-only diagnosis.
- Do not print DB passwords. Project ref in the username (`postgres.<ref>`) is OK.

## Split the problem first

| Probe | Meaning if OK |
|-------|----------------|
| MCP `list_projects` / `get_project` | Project exists; note `status`, `region`, `database.host` |
| MCP `execute_sql` `select 1` | **Server/DB healthy** — remaining issue is the *client* path |
| `supabase ssl-enforcement get --project-ref REF --experimental` | Whether plaintext is even allowed |
| `supabase network-restrictions get --project-ref REF --experimental` | CIDR allowlist vs open |
| DNS A vs AAAA on `db.<ref>.supabase.co` vs `aws-*-<region>.pooler.supabase.com` | Direct vs pooler reachability |

If MCP SQL works, do **not** reboot the project or reset the DB password for an SSL verify error.

## Hosts (do not mix)

| Mode | Host:port | IP | Use |
|------|-----------|-----|-----|
| Direct | `db.<ref>.supabase.co:5432` | often **IPv6-only** (AAAA) | `pg_dump`, migrations, long session — only if the client has IPv6 to AWS |
| Shared pooler session | `aws-<n>-<region>.pooler.supabase.com:5432` | IPv4 | GUI clients on IPv4-only Macs |
| Shared pooler transaction | same host `:6543` | IPv4 | serverless; no prepared statements |
| User | `postgres.<ref>` on pooler; `postgres` on direct | | |

Hostname shape is `aws-1-eu-west-1…` **or** `aws-0-…` — copy from Dashboard Connect, do not invent the digit.

This Mac often has **no IPv6 route to AWS**. Direct `db.*:5432` then fails (`No route to host`). Use the IPv4 pooler.

## SSL error 19 is expected without the private CA

Pooler Postgres TLS is **Supabase PKI 2021**, not public LE/Amazon:

```
*.pooler.supabase.com
  ← Supabase Intermediate 2021 CA
    ← Supabase Root 2021 CA   (self-signed; not in macOS trust store)
```

Client `verify-ca` / `verify-full` (TablePlus: "Verify CA") without `prod-ca-2021.crt` →

`SSL verify error: 19 X509_V_ERR_SELF_SIGNED_CERT_IN_CHAIN`

String `Failed to connect to pgsql at "…" (port 5432) as user "postgres.<ref>"` is typical **TablePlus**.

HTTPS `:443` on the same pooler hostname may be **Amazon RSA** — that cert is irrelevant to Postgres STARTTLS.

### Fix (strict)

1. Dashboard → Database Settings → SSL Configuration → download **prod-ca-2021.crt**
   `https://supabase.com/dashboard/project/<ref>/database/settings`
2. Client: SSL on, CA file = that cert, `sslmode=verify-full`
3. Keep pooler host + `postgres.<ref>`

### Fix (local, weaker)

`sslmode=require` / GUI SSL on + verify **off**. Encrypts, skips CA. Only if SSL enforcement is off.

Live TLS probe (Homebrew OpenSSL + STARTTLS): `scripts/probe-pooler-tls.sh`. Detail: `references/pooler-ssl-verify.md`.

## CLI flags (order matters)

`--project-ref` is a **subcommand** flag, not global:

```bash
supabase ssl-enforcement get --project-ref REF --experimental
supabase network-restrictions get --project-ref REF --experimental
# WRONG: supabase ssl-enforcement --project-ref REF get
```

Always `supabase <group> <command> --help` first (CLI shape changes).

## Docs

Hub `supabase` still applies: `changelog.md` + MCP `search_docs`. SSL pages: `/docs/guides/platform/ssl-enforcement`, `/docs/guides/database/connecting-to-postgres`, `/docs/guides/database/psql`.

## Pitfalls

- **LibreSSL `s_client` has no `-starttls postgres`.** Raw TLS to `:5432` yields protocol-version / no peer cert. Use `/opt/homebrew/opt/openssl@3/bin/openssl s_client -starttls postgres`.
- **Do not treat error 19 as a broken project** when MCP SQL works.
- **Do not point `sslrootcert` at the Amazon HTTPS cert** or a self-made leaf.
- `prod-ca-2021.crt` is **not** a stable public raw URL — Dashboard download is SoT.
- SSL enforcement **on** + `sslmode=prefer/disable` → different error (`pg_hba` SSL off), not 19.

## Verify

1. MCP `execute_sql` returns a row.
2. `scripts/probe-pooler-tls.sh` with the official CA → `Verify return code: 0`.
3. GUI reconnects with that CA + pooler session port.
