# Centralized Remote MCP Architecture

**User preference (June 2026):** All MCP servers should be centralized and accessible remotely via HTTP/StreamableHTTP. No local stdio duplication across clients, no Cloudflare Tunnels.

## Core Principles
- Single source of truth for MCP server definitions
- All servers exposed as HTTP endpoints (Workers preferred)
- Clients (Hermes, Codex, VS Code, cluster) only use `url` + `headers`
- Cloudflare Workers is the default hosting platform (user already maintains `cfat_` tokens and infrastructure)
- Avoid Tunnel-based solutions

## Recommended Config Pattern (Remote)
```yaml
mcp_servers:
  github:
    url: "https://github-mcp.<account>.workers.dev/mcp"
    headers:
      Authorization: "Bearer ${GITHUB_MCP_TOKEN}"
```

## When to Use This Pattern
- User has multiple agents across machines (MacBook + VPS + k3s)
- User already uses Cloudflare heavily
- Goal is minimal config duplication

## Pitfall
Do not default to stdio `command` + `args` when the user has expressed preference for remote HTTP architecture. Always offer the `url` + `headers` variant first.