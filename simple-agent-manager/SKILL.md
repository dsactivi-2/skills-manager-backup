---
name: simple-agent-manager
description: "Use when self-hosting SAM on Cloudflare."
---

# Simple Agent Manager (SAM) self-host

Class skill for deploying [Simple Agent Manager](https://github.com/raphaeltm/simple-agent-manager) on this Cloudflare account. Official guide: https://www.simple-agent-manager.org/docs/guides/self-hosting

When the user is in the SAM wizard and asks for Cloudflare data, live-verify zones, then paste a table. Do not invent token or R2 values.

## Step 1 — Domain and account

`BASE_DOMAIN` must be an apex TLD. SAM creates `api.`, `app.`, and `*`. Free Universal SSL covers `*.example.com`, not nested `*.sam.example.com`. The apex itself is unused.

On this account use **`activi-apps.io`**. Never `activi.io` (would collide with live `api`/`app`/`*`) and not `camino-school.com`.

| Field | Value |
|---|---|
| Account | `ds@activi.io` |
| Account ID | `2f8c7ae79d6d316eac3961585f5c2f5b` |
| BASE_DOMAIN | `activi-apps.io` |
| Zone ID | `7c7bc2162ed80d8a2b921a2dabb59507` |

Re-list zones with the Cloudflare API before quoting IDs if the account may have changed.

## Step 3 — API token and R2 keys

The Mac env `CLOUDFLARE_API_TOKEN` can `wrangler whoami`, list zones, and list Workers scripts. It cannot create user/account tokens, edit DNS, or use R2/D1. Do not retry token minting with that token.

R2 S3 keys appear **once**, on the same dashboard screen as the new API token (because the token includes Workers R2 Storage). Pulumi later uses `${RESOURCE_PREFIX}-pulumi-state`. User creates the token in the dashboard and pastes `CF_API_TOKEN`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY`. Zone ID is already known.

Enable first:

- R2: `https://dash.cloudflare.com/2f8c7ae79d6d316eac3961585f5c2f5b/r2/overview`
- Analytics Engine (free): `https://dash.cloudflare.com/2f8c7ae79d6d316eac3961585f5c2f5b/workers/analytics-engine`

Token page: `https://dash.cloudflare.com/profile/api-tokens` → Create Custom Token. Name: `sam-activi-apps`.

Account resources = this account. Zone resources = **only** `activi-apps.io`.

Account | Access
---|---
Cloudflare Workers: D1 | Edit
Workers KV Storage | Edit
Workers R2 Storage | Edit
Workers Scripts | Edit
Workers Observability | Read
Cloudflare Pages | Edit
AI Gateway | Edit
Containers | Edit
SSL and Certificates | Edit

Zone | Access
---|---
DNS | Edit
Workers Routes | Edit
SSL and Certificates | Edit
Zone | Read

Optional if Artifacts beta is on the account: Account → Artifacts → Edit.

## Pitfalls

- Filling SAM with `activi.io` will try to take `api.activi.io`, `app.activi.io`, and `*`.
- A working Wrangler token is not a token-creator token.
- Do not store the one-time token/R2 secret in git or memory.

## References

- `references/wizard-values.md` — copy-paste field map for the SAM form
