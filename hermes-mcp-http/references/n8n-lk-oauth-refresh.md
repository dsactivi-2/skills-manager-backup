# n8n-lk MCP OAuth refresh (verified 2026-08-28)

Instance: `https://n8n-lk.activi.io/mcp-server/http` (OAuth 2.1 PKCE).
Tokens: `~/.hermes/mcp-tokens/n8n-livekit.{json,client.json,meta.json}`.

## Symptom
`hermes mcp test n8n-livekit` → Connection failed ~30s. n8n UI still HTTP 200.

## Cause
Access token `expires_in` 3600. `meta.json` `token_endpoint` can be Contabo (`vmi….contaboserver.net/mcp-oauth/token`) → TLS alert. Project rule: never that hostname.

## Fix
POST `https://n8n-lk.activi.io/mcp-oauth/token`
- `grant_type=refresh_token`
- `refresh_token` from `n8n-livekit.json`
- `client_id` from `n8n-livekit.client.json` (no client_secret)
Write new `access_token` / `refresh_token` / `expires_at` back to `n8n-livekit.json`. Then `hermes mcp test n8n-livekit`.

Do not print tokens. Do not use `N8N_API_KEY` (often n8n-mm).

## Related n8n-lk Google OAuth (user UI, not MCP)
Redirect: `https://n8n-lk.activi.io/rest/oauth2-credential/callback`.
Google Cloud: OAuth client type **Web application**. Same Client ID/Secret for Sheets, Calendar, Gmail. Consent **External + Testing + test user** if personal Gmail; **Internal** blocks it.
n8n MCP cannot create credentials. LiveKit server API: JWT from API Key+Secret, not a static `Authorization: Bearer <key>` Header Auth.
