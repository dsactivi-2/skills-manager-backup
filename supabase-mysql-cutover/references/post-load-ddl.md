# Post-load DDL on hosted Supabase

After a bulk load as a dedicated login role (not dashboard `postgres`).

## Ownership

- Loader role owns `schema.table`.
- MCP `apply_migration` and `execute_sql` start as `postgres`.
- Check: `select tableowner from pg_tables where schemaname='…' limit 3;`
- Check membership: `pg_auth_members` → `admin_option` / `inherit_option` / `set_option`.
- If `set_option` is false: `grant <loader> to postgres with inherit true, set true;`
- Then in the same SQL batch: `set role <loader>; alter table … add primary key …;`
- `SET ROLE` is denied until SET is granted even when `pg_has_role(…,'MEMBER')` is true.

## Indexes

- Source of truth: live MySQL `information_schema.statistics`, not a repo dump.
- Skip UNIQUE indexes whose columns equal the PRIMARY KEY.
- Skip FULLTEXT. Expect no nullable PK columns.
- Target count ≈ PK count + remaining btree indexes.

## Extensions

```sql
create extension if not exists pg_trgm with schema extensions;
create extension if not exists vector with schema extensions;
```

Use `extensions.gin_trgm_ops` and `extensions.vector(…)`. Creating GIN trgm as the loader role often hits `42501 permission denied for schema extensions` — run those indexes as `postgres` after `grant create on schema <target> to postgres`.

## Verify

```sql
select count(*) from information_schema.table_constraints
 where table_schema='<s>' and constraint_type='PRIMARY KEY';
select count(*) from pg_index i
  join pg_class c on c.oid=i.indrelid
  join pg_namespace n on n.oid=c.relnamespace
 where n.nspname='<s>';
```

Row counts on the big tables must match pre-DDL.