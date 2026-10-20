# Peer-agent CRM work vs intended MCP

Live-checked 2026-08-19, project `oohbgrajwxdotalijmih`.

## Mass row audit (wrong)

- Function: `crm_audit.log_row_change` AFTER INSERT/UPDATE/DELETE
- Coverage seen: all 188 `crm` tables + 6 `crm_auth`; `idk_kandidati` had **two** triggers
- Auto-attach: event trigger `trg_auto_attach_row_audit` also targeted **`public`**
- Effect: every change stores full old+new row JSON. On `idk_logs` (millions) this is a second log of the log.

Keep: `crm_api._audit_action` → `crm_audit.agent_action_log` (action audit, IP/UA if HTTP headers exist).

Fix order (Freigabe): count triggers → drop event trigger → drop all `log_row_change` on `crm`/`crm_auth` → recount 0. Do not truncate `agent_action_log` without extra Ja.

## Dashboard RPCs (extra, not the MCP)

Seen later: `get_audit_dashboard`, `get_audit_dashboard_light`, `get_user_activity`, `get_error_activity`, `get_data_changes`, `healthcheck_auth`. Read-only. `activi` often has no EXECUTE. Not the three status tools.

## Autologik still in PHP

Not in Supabase as jobs. Inventory from `/Users/activi/crm-local/src/crm`: `changeStatusAndInsertLog`, `cron_automatic_go_online.php`, `projects.php` `go_online_checker`, `cron_provjera_termina.php`, `cron_dipl.php`, finance crons, `jobstep_pp/cron_reminders.php`.

## Counts that confuse people

- `idk_kandidati` ≈ 122004 (CRM) ≠ max `kandidat_id`
- `idk_nd_kandidata` ≈ 81330 (DIPL), mostly unlinked
- Documents: `idk_documents.document_file` hash names on the old PHP host, not bytes in Postgres
