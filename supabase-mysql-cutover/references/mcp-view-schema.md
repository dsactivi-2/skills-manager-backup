# MCP / PostgREST after a private load schema

Do not expose the load schema (`crm`) on the Data API. `anon` / `authenticated` stay without USAGE.

## Views

Create a view schema (e.g. `crm_api`) as the loader role. Default views (not `security_invoker`) use the owner’s rights on base tables. REVOKE from public/anon/authenticated. GRANT USAGE+SELECT to `service_role` only.

SAFE candidate views: ids, names, status ids, timestamps. No phone, mail, JMBG, password.

Map MCP `idk_*` paths to view names. Check live columns (`kj_nivo` may not exist).

## Two schemas in the MCP

- SELECT `Accept-Profile` = view schema (`JOBSTEP_CRM_SCHEMA=crm_api`)
- RPC `Content-Profile` = load schema (`JOBSTEP_CRM_RPC_SCHEMA=crm`) because `set_candidate_*` live there

## Extra schemas

Dashboard → Settings → Data API → Extra schemas = **view schema only**.

REST probe (publishable key, do not print it):

- 406 `Invalid schema` → not in Extra schemas
- dummy key 401 → useless for this check
- never add the load schema to Extra schemas
