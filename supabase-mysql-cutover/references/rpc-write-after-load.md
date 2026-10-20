# RPC write after a MySQL load

Do this **before** the first status/RPC write test.

## Sequences

pgloader copies AUTO_INCREMENT values but not sequences. Integer PKs have no `DEFAULT`. INSERT that omits the id → `23502`.

Fix on each table the RPC inserts into (typical: `*_log*`, audit):

```sql
set role <loader>;
create sequence if not exists <schema>.<table>_<col>_seq;
alter sequence <schema>.<table>_<col>_seq owned by <schema>.<table>.<col>;
alter table <schema>.<table> alter column <col>
  set default nextval('<schema>.<table>_<col>_seq');
select setval('<schema>.<table>_<col>_seq',
              (select coalesce(max(<col>), 1) from <schema>.<table>));
```

A failed RPC in one MCP statement rolls back the candidate row. Still snapshot first.

## Write-test rules

- Only the RPC (`set_candidate_*`), never `UPDATE` on status columns.
- Read live lookup tables. Do not invent ATS paths (`new → hired`).
- One candidate. Snapshot nalog/partner fields — some RPCs null them when the new status is not reserved.
- If the user says „mach du die zeile“ after a recommended ID+path, execute that line.

## REST vs SQL

`execute_sql` can see a private load schema. PostgREST often cannot: `anon` / `authenticated` / `service_role` have no `USAGE`. Do not `GRANT` to `anon`. Dedicated reader role + views.
