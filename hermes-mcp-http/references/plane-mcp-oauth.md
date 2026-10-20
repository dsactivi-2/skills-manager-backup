# Plane MCP OAuth Fallback (2026-06-15)

## Working Config (when API-key returns 401 + "Auth: none")
```toml
[mcp_servers.plane]
url = "https://mcp.plane.so/http/mcp"
```

```yaml
mcp_servers:
  plane:
    url: https://mcp.plane.so/http/mcp
```

## Observed Pattern
- API-key endpoint (`/http/api-key/mcp`) → 401 + "Auth: none" despite correct headers
- OAuth endpoint (`/http/mcp`) succeeds without headers or client_id
- Codex is source of truth; sync to Hermes after change

## When to Use
- API-key variant fails with authentication errors
- User has no valid long-lived API key or workspace requires OAuth flow

## Source
Session where hermes mcp test plane repeatedly returned 401 on API-key config.