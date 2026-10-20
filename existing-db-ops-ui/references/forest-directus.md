# Forest Admin vs Directus (snapshot)

Not SoT for prices. Re-open vendor pages before quoting.

## Forest

- Product: https://www.forestadmin.com
- Pricing: https://www.forestadmin.com/pricing
- App: https://app.forestadmin.com
- Node agent: https://github.com/ForestAdmin/agent-nodejs
- Docs (README pointers): https://docs.forestadmin.com/developer-guide-agents-nodejs/
- Quick start: https://docs.forestadmin.com/developer-guide-agents-nodejs/getting-started/quick-start
- Postgres: `@forestadmin/datasource-sql` `createSqlDataSource('postgres://…')`. Introspects tables/views. Disable native CRUD on candidate tables; Smart Actions → `crm_api.*_safe` + approval.
- Sandbox (seen 2026-09): free, 2 users, 2 datasources, 5 MCP connectors, data in your infra.
- Starter (seen 2026-09): 499 USD/month.
- UI layout lives at Forest. Agent GPL-3 on your host. Not a Tailwind/glassmorphism product.

## Directus

- https://directus.io
- https://docs.directus.io/getting-started/overview.html
- https://github.com/directus/directus
- Connect existing Postgres, REST/GraphQL, Flows. Same wrap idea. Default CRUD is dangerous on JSI — lock writes.

## NocoDB

- https://github.com/nocodb/nocodb
- External PG as data source; schema-edit off. Spreadsheet UI. Not a status machine.

## Do not recommend as JSI home

Pipedrive, HubSpot, Twenty, Zoho CRM (sales). OpenCATS/EspoCRM = new schema, second truth.
