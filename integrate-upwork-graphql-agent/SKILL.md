---
name: integrate-upwork-graphql-agent
description: "Integrate OpenClaw, Hermes, or another agent with Upwork through a guarded MCP adapter over the Upwork GraphQL API."
trigger: "Use when connecting an AI agent to Upwork API data or actions."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019ec929-defa-7853-a751-43b0e435da0f
contributors:
  - activi
version: 3
created_by_agent: codex
created_at: 2026-06-15T14:29:53.399Z
updated_at: 2026-06-16T00:29:38.692Z
---

# Integrate an agent with Upwork GraphQL

## When to use

Use when connecting OpenClaw, Hermes, or another tool-calling agent to Upwork. Prefer a dedicated MCP adapter instead of exposing unrestricted GraphQL access directly to the agent.

## Architecture

```text
Agent -> filtered MCP tools -> upwork-mcp -> OAuth2 + Upwork GraphQL API
```

Use Upwork GraphQL or an Upwork SDK inside the MCP server. Use a CLI only for setup, fixtures, and manual testing.

## Workflow

1. Confirm API access eligibility before implementation. Upwork requires an eligible verified account, valid profile, verified payment method, and an API key request describing whether the app is personal/internal or for third parties.
2. Do not plan around a third-party sandbox; Upwork does not provide one. Develop first against mock data and saved GraphQL fixtures.
3. Send requests to `https://api.upwork.com/graphql`.
4. Implement OAuth2 token storage and refresh without logging token values. Access tokens expire after 24 hours; refresh tokens expire after two weeks of inactivity. Client Credentials is Enterprise-only.
5. Set `X-Upwork-API-TenantId` explicitly for organization operations; do not silently rely on the user's default organization.
6. Request the required scopes, including Common Entities read-only access where applicable.
7. Check both HTTP status and GraphQL `errors`; failures may return HTTP 200, and Upwork SDKs do not handle these errors specially.
8. Enforce documented limits: 300 requests/minute/IP, daily limit 40k requests, bounded retries, audit logging, and caching no longer than 24 hours.
9. Expose narrow read-only tools first, such as `upwork_search_jobs` and `upwork_get_contract`.
10. Require preview and explicit user approval before mutation tools execute.
11. Treat GraphQL subscriptions as a separately reviewed capability requiring Upwork approval.

Example Hermes configuration:

```yaml
mcp_servers:
  upwork:
    command: "uvx"
    args: ["--from", "/path/to/upwork-mcp", "upwork-mcp"]
    timeout: 120
    tools:
      include:
        - upwork_search_jobs
        - upwork_get_contract
```

## Adapter guardrails

- Validate every tool argument with a strict schema.
- Allowlist GraphQL operations; never expose a generic unrestricted query tool.
- Keep tenant selection explicit and verify the requested tenant is authorized.
- Return structured tool errors instead of raw GraphQL responses.
- Never expose access tokens, refresh tokens, client secrets, private keys, or decoded credentials.
- Keep cached Upwork data within the documented maximum retention period.
- Separate read-only and mutation tools for least-privilege grants.
- Build fixtures for successful responses, HTTP failures, HTTP-200 GraphQL errors, missing scopes, expired tokens, rate limits, daily-limit exhaustion, and incorrect tenant context.

## Anti-patterns

- Connecting an agent directly to unrestricted Upwork GraphQL
- Treating HTTP 200 as proof that a GraphQL operation succeeded
- Building against production data before mock fixtures and error handling exist
- Assuming Upwork has a third-party sandbox
- Relying on the default organization instead of setting tenant context
- Enabling proposals, job posts, or other mutations without preview and approval
- Assuming an SDK handles GraphQL errors, token refresh, or tenant selection automatically
- Using an SDK or MCP server to bypass Upwork API access requirements or commercial-use restrictions
