# Legacy CRM source layout (after MySQL load)

Not Jobstep-only: typical PHP CRM dump + app host.

## Counts

- Live `COUNT(*)` on each person ledger. `information_schema.table_rows` is an estimate.
- Highest PK can be far above COUNT (deleted ids).
- A second ledger (diploma / ND / visa) often holds the “missing” 80k+ rows.

## Files

- Document tables store `varchar` names (`5db4….pdf`), not `bytea`.
- App download path pattern: `private/<crm_subdomain>_files/<folder>/<document_file>`.
- Folders follow `document_group` (candidates / companies / projects / employees).
- Files live on the **PHP host**, not in the MySQL dump and not in Supabase. Hunt via SSH on that host.

## Dashboard

Table Editor default schema is `public`. After a private-schema load it is empty. Switch dropdown to the load schema.