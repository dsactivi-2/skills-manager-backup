# Load path (pooler session)

Sister write-up: `supabase-postgres-connectivity` / `references/mysql-to-supabase-load.md`.

- MySQL 8 Docker: socket `root` without password can 1045; use `mysql -uroot -h127.0.0.1 --protocol=TCP`. pgloader needs `mysql_native_password`.
- Target: IPv4 session pooler + official `prod-ca-2021.crt`. Not `db.<ref>` on IPv6-only Direct.
- After OOM/hang: `pg_terminate_backend` where `application_name='pgloader'`.
- Resume partial tables with `WHERE id > max(id)`. Never TRUNCATE a half-loaded table.
- `ALTER DATABASE SET search_path` as non-owner → 42501. Expected on Cloud. Not a failed import.
