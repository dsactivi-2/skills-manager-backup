---
name: existing-db-ops-ui
description: >
  Use when Forest Admin, Directus, or CRM wrap for JSI/Energy.
---

# Ops-UI on existing databases (JSI + Energy)

Not a CRM. Not an ATS. A human screen on databases you already run.

JSI SoT: Jobstep Postgres (JSI Base `oohbgrajwxdotalijmih`) + PHP Autologik until ported + `crm_api.*_safe` + skill `recruiting-crm` MCP.
Energy SoT: n8n-lk, `energy_leads` / `energy_dnc`, LiveKit. Skill `energy-warmup-session`.
One purpose = one Supabase project. Never put Energy tables on JSI Base. Never put 122k candidates into Pipedrive/Sheets.

Child skills for JSI writes/search/status: `jobstep-crm`.

## When the user asks what Forest/Directus “does”

Always four blocks, DE, no jargon first. User missed this once when the answer jumped to “Smart Actions / cheaper search”.

1. **What it takes over** — only the human screen (listen, suchen, filtern, CSV, Login, Rollen). Not the rows. Metaphor: Excel vs the file on disk.
2. **How it is wired** — small agent/server you host (Forest Node agent or Directus). It gets the Postgres URL, introspects tables. Browser → vendor UI → your agent → DB. No copy of `idk_kandidati` into a new CRM.
3. **What stays** — Hermes MCP, n8n F1–F5, RPC `*_safe`, PHP crons until each rule is an RPC+job. Buttons must call RPC, not `UPDATE idk_kandidati`.
4. **Vs cheaper** — search/filter/CSV exist in Directus and NocoDB on the same Postgres, self-host, no Forest Starter fee. Pay Forest only if you need code buttons + second-person approval + two datasources in one login + audit.

## Wrap vs replace

| Ask | Answer |
| --- | --- |
| New sales CRM for JSI (Pipedrive, HubSpot, Twenty, Zoho CRM) | No. Wrong objects (leads/deals). |
| Zoho Recruit / Bullhorn / Vincere / zvoove | Only if PHP is deliberately killed and 122k are migrated. |
| PHP ablösen | Port Autologik → `crm_api.*_safe` + n8n/Temporal. UI wrap does not port crons. Skill `jobstep-crm-autologik`. |
| One product for JSI **and** Energy | Yes as **two datasources** in Forest/Directus. No as one table. |

## Default pick

- Humans on JSI and/or Energy: Forest (paid, approval knobs) or Directus (OSS).
- Agenten: recruiting-crm MCP, not the ops UI.
- Energy Abläufe: n8n-lk. F2 never Execute.

Links and 2026 pricing snapshot: `references/forest-directus.md`.
