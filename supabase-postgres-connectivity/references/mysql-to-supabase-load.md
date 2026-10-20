# MySQL → hosted Supabase (IPv4 pooler)

Use when moving a local MySQL database into a hosted Supabase schema over the **shared session pooler**. Hub `supabase` covers schema/RLS after the data is in.

## Password without leaking it

MCP/`supabase db query --linked` runs as `postgres` via Management API. Set a login role from a 600 file, never from chat:

```bash
supabase db query --linked --file /private/tmp/alter_role.sql
# file: grant create on database postgres to <role>;
#       alter role <role> with login password '<hex-only>';
```

Pooler user is `<role>.<project-ref>`. Do not reset the dashboard `postgres` password unless that is the intended login.

## Source: MySQL 8 in Docker

- `MYSQL_ALLOW_EMPTY_PASSWORD=yes` does **not** mean `mysql -uroot` on the unix socket works. Live pattern: `root@localhost` → `1045` with `using password: NO`; `mysql -uroot -h127.0.0.1 --protocol=TCP` succeeds.
- pgloader/qmynd cannot do `caching_sha2_password`. Create a dedicated user `IDENTIFIED WITH mysql_native_password` and, if the handshake still fails, set `default_authentication_plugin=mysql_native_password` and restart the same data volume.
- From another container use `host.docker.internal:<published-port>` (TCP), not the socket.

## Target: pooler session, not Direct

This Mac often has no IPv6 to AWS. `db.<ref>.supabase.co:5432` is the wrong path for the load. Use `aws-<n>-<region>.pooler.supabase.com:5432` + CA (`prod-ca-2021.crt`) + `sslmode=verify-full`. Mount the CA into tools that honor `SSL_CERT_FILE`.

`--no-ssl-cert-verification` on `dimitri/pgloader` does **not** fix pooler PKI 2021.

## Do not bulk-COPY large tables with pgloader over this pooler

Verified split:

| Size | pgloader COPY over session pooler |
|------|-----------------------------------|
| Tiny (single-digit rows) | Completes |
| Large (100k+) | Logs `COPY … [0/1]`, CPU ~0, almost no NetIO, no commit |

`multiple readers per thread` plus million-row tables also OOMs the dumped SBCL image (~1 GiB heap; `--dynamic-space-size` is not a flag on this binary). After an OOM, leftover backends stay in `COPY … FROM STDIN` (`application_name=pgloader`, `ClientRead`). Terminate them before retrying:

```sql
select pg_terminate_backend(pid)
from pg_stat_activity
where usename = '<role>' and application_name = 'pgloader' and pid <> pg_backend_pid();
```

pgloader may still emit `ERROR 42501 must be owner of database postgres` on `ALTER DATABASE … SET search_path`. Expected on Cloud. Treat as WARN; do not fail a successful row import for that line.

## Working load

Chunked `COPY` from the Mac (not from the pgloader container): `pymysql` → MySQL TCP, `psycopg` → pooler session, `prepare_threshold=None`, keepalives on, commit every ~2000 rows, `sslrootcert` = official CA.

- Match columns from `information_schema` on the **already created** `crm` tables.
- Convert `0000-00-00` / year `< 1` to NULL (`sql_mode` allow invalid dates on the MySQL session).
- Resume: if `0 < pg_count < mysql_count`, `WHERE id > (select max(id) …)` — **never TRUNCATE** a partial table.
- Reconnect and retry the same chunk on `AdminShutdown` / lost connection (pooler can drop a long session).
- Skip when counts already match.

Create tables once (pgloader schema-only or SQL). Indexes/PKs are a separate pass; a data-only load leaves `crm` without indexes.

## After load

- Count-check the handover tables against MySQL.
- MCP `get_advisors` security + performance.
- Keep `crm` unused by `anon`/`authenticated` until an access model exists. No blanket Grants.
