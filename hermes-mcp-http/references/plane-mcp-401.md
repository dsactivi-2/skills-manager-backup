# Plane MCP 401 Fix (2026-06-15)

## Working Config
```yaml
mcp_servers:
  plane:
    url: https://mcp.plane.so/http/api-key/mcp
    http_headers:
      x-api-key: plane_api_85da4b4a586b47a6b1607ac34ea636ff
      x-workspace-slug: activi
```

## Observed Errors
- `Client error '401 Unauthorized'`
- `Auth: none` in `hermes mcp test plane`
- `mcp.client.streamable_http is not available` (uv run with fresh venv)

## Required Steps
1. Use `/http/api-key/mcp` (not `/http/mcp`)
2. Add both `x-api-key` + `x-workspace-slug`
3. Full Hermes restart after any change to `http_headers`
4. Verify with `hermes mcp test plane`

## Source
Conversation with user on macOS using `~/.hermes/hermes-agent/venv/bin/hermes`