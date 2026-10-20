# Pooler SSL verify (error 19)

Live-verified 2026-08-18 on `oohbgrajwxdotalijmih` (eu-west-1). Pattern is platform-wide, not project-specific.

## What the pooler presents (Postgres STARTTLS)

| Depth | Subject | Issuer |
|-------|---------|--------|
| 0 | `CN=*.pooler.supabase.com` | Supabase Intermediate 2021 CA |
| 1 | Supabase Intermediate 2021 CA | Supabase Root 2021 CA |
| 2 | Supabase Root 2021 CA | self (same) |

SAN: `*.pooler.supabase.com`, `*.pooler.supabase.co`. Root valid ~2021–2031. Issuer field typo `ST=Delware` is on the real certs.

System/Mozilla trust store does **not** contain this root → OpenSSL verify **19**.

HTTPS `:443` on the same hostname can be **Amazon RSA 2048** — ignore it for Postgres.

## Reproduce without a password

```bash
OPENSSL=/opt/homebrew/opt/openssl@3/bin/openssl
HOST=aws-1-eu-west-1.pooler.supabase.com   # copy from Dashboard; digit may be 0 or 1
echo | "$OPENSSL" s_client -starttls postgres -connect "$HOST:5432" \
  -servername "$HOST" -verify_return_error
# expect: verify error:num=19:self-signed certificate in certificate chain
```

With official CA (Dashboard download, not a guessed URL):

```bash
echo | "$OPENSSL" s_client -starttls postgres -connect "$HOST:5432" \
  -servername "$HOST" -CAfile /path/to/prod-ca-2021.crt -verify_return_error
# expect: Verify return code: 0 (ok)
```

Extracting the last PEM from `-showcerts` and using it as `-CAfile` also verifies — same root as `prod-ca-2021.crt`. Prefer the Dashboard file for clients.

## Client mapping

| Client | Wrong | Right |
|--------|-------|-------|
| TablePlus | SSL + Verify CA, no CA file | SSL + CA = `prod-ca-2021.crt`, or SSL without verify |
| libpq / URL | `sslmode=verify-full` alone | add `sslrootcert=/path/prod-ca-2021.crt` |
| “quick local” | disable SSL | `sslmode=require` if enforcement is off |

## Split vs project health

MCP `execute_sql` succeeding means the instance is up. Error 19 is **client trust**, not a down DB, not a bad password, not SSL enforcement (that yields `pg_hba` / SSL off).
