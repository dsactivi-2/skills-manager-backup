---
name: cloudflare-mcp
description: "Use when deploying MCP or Hermes via Cloudflare Workers."
---

# Cloudflare MCP / tokens / Worker exposure

Activi ops skill. For Workers/Pages/R2/D1/platform docs use skill `cloudflare`.

## Token Management

Cloudflare API tokens (cfut_/cfat_), permission groups, MCP server keys.
Minimal sufficient permissions. Account ID + scopes required.

See original `cloudflare-token-management` and `references/permission-groups.md` if present.

## MCP Deployment

Deploy MCP servers (GitHub, Cloudflare, Context7, Firecrawl, …) as Cloudflare Workers for centralized HTTP access.

Master-config pattern, thin proxy Workers, wrangler. Prefer thin proxies over custom logic.

See original `cloudflare-mcp-deployment` and `references/master-config-example.md` if present.

## Worker Exposure

Workers as the public HTTP layer for Hermes API Server, MCP servers, and internal endpoints — not tunnels or open ports.

Never expose internal ports directly. Auth header injection; Hermes API Server specifics in original `cloudflare-worker-exposure` / `references/hermes-api-server.md` if present.

## Pitfalls

- Always use minimal sufficient permissions for tokens.
- Prefer thin proxies over custom logic.
- Never expose internal ports directly.
- Account ID and proper token scopes are required for many operations.
- Do not load this skill for general Cloudflare product work — use `cloudflare`.
