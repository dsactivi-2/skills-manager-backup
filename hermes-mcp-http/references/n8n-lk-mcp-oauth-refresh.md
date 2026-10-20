# n8n-lk MCP OAuth refresh

Verified 2026-08-28. Instance UI `https://n8n-lk.activi.io` can be 200 while MCP is dead.

## When

`hermes mcp test n8n-livekit` → OAuth 2.1 PKCE, Connection failed ~30s.

## Do

1. Tokens: `~/.hermes/mcp-tokens/n8n-livekit.json` (`access_token`, `refresh_token`, `expires_at`).
2. Client: `n8n-livekit.client.json` → `client_id` (public PKCE, no secret).
3. POST `application/x-www-form-urlencoded` to **`https://n8n-lk.activi.io/mcp-oauth/token`**:
   - `grant_type=refresh_token`
   - `refresh_token=…`
   - `client_id=…`
4. Write back `access_token`, `refresh_token`, `expires_in` → `expires_at = now + expires_in`.
5. `hermes mcp test n8n-livekit` (expect Connected, tools including `search_workflows`).
6. This session may still lack n8n-livekit tools until `/reload-mcp`. Direct Streamable-HTTP `tools/call` with the new Bearer works without reload.

## Do not

- Refresh against Contabo `token_endpoint` in `n8n-livekit.meta.json` (TLS internal error).
- Use `N8N_API_KEY` / `N8N_API_URL` (other instance).
- Print tokens.

## Related

Energy WarmUP live audit: MCP `n8n-livekit`, workflow search Energy/MONOLITH. Skill `energy-warmup-session` (user-owned) should stay the session router; this file is only the OAuth fix.
