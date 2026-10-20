# Jobstep CRM catalog (`productioncrmdb`)

MySQL 8 dump of the Jobstep production CRM. Use this so agents know **which table is which** — do not paste dump rows or secrets into prompts.

Engine: MySQL 8.0.41. ~179 InnoDB tables, prefix `idk_`. Typical dump size ~1.4 GB (schema + data). PII-heavy: JMBG, passport, emails, phones, password hashes, API tokens (`idk_api_clients`), telephony logins on `idk_employees`. Restore **read-only**, privately. Never upload the dump to Composio/SaaS.

## Prefix → module

| Prefix | Module |
|---|---|
| `idk_kandidat*` | Bewerber + CV, Sprachen, Status, Finanzen |
| `idk_nalog*` | Stellenauftrag / Auftrag |
| `idk_nd_*` | Nostrifikation Diplome |
| `idk_pp_*` | Partner-Portal, Casting, Visa-Docs |
| `idk_tf_*` | Task-Force Anrufe / Reservierungen |
| `idk_partner*` | Partner-App Notifications / Meetings |
| `idk_skladiste*` | Lager |
| `idk_racuni` / `idk_predracuni` / `idk_obracuni` | Rechnung, Angebot, Provision |
| `users` | App-Login der Kandidaten |

## Agent vocabulary

| User/agent says | Table | Key |
|---|---|---|
| Bewerber / Kandidat | `idk_kandidati` | `kandidat_id` |
| Status Bewerber | `idk_kandidat_status` | `status_id` |
| Auftrag / Stelle | `idk_nalozi` | `nalog_id` |
| Firma / Arbeitgeber | `idk_companies` | `company_id` |
| Mitarbeiter / Agent | `idk_employees` | `employee_id` |
| Sales-Lead (DIPL/DAK) | `idk_clients` | `client_id` |
| Ansprechpartner | `idk_contacts` | `contact_id` |
| Projekt | `idk_projects` | `project_id` |
| Partner-Portal User | `idk_pp_users` | `pu_id` |
| Casting-Termin | `idk_pp_appointments` | `pap_id` |
| Nostrifikation-Fall | `idk_nd_kandidata` | `id_broj_nd_kandidata` |
| Behörde Nostrifikation | `idk_nd_ustanove` | `id_ustanove_nd` |
| Rechnung | `idk_racuni` | `racun_id` |
| Angebot / Rate | `idk_predracuni` | `pr_id` |
| Provision | `idk_obracuni` | `id` |

## Core FKs

- `idk_nalozi.kompanija_id` → `idk_companies`
- `idk_nalozi.employee_id` → `idk_employees`
- `idk_kandidati.kandidat_status` → `idk_kandidat_status`
- `idk_pp_partners.ppa_nalog_id` → `idk_nalozi`
- `idk_pp_users.pu_company_id` → `idk_companies`
- `idk_nd_kandidata.skola_*` → `idk_skole` / `idk_skole_smjerovi`
- `idk_racuni.racun_kandidat_id` → `idk_kandidati`
- `users.kandidat_id` → `idk_kandidati`

## MCP tools for this DB

Expose catalog first: `catalog_search`, `list_tables` (by module), `describe_table`. Then `query_readonly` with SELECT + LIMIT. Strip or refuse: `kandidat_jmbg`, `kandidat_broj_pasosa`, `*_password`, `client_token`, `employee_vicipass`, reset tokens.

If AWS CRM replica exists, point the MCP at that instead of re-importing the dump.
