# Plane MCP – Codex Source of Truth (2026-06-15)

## Codex TOML Format
```toml
[mcp_servers.plane]
url = "https://mcp.plane.so/http/api-key/mcp"
http_headers = { "x-api-key" = "plane_api_...", "x-workspace-slug" = "activi" }
```

## Workflow
1. Edit `~/.codex/config.toml` (never edit Hermes config directly for MCP servers)
2. Run Codex → Hermes sync script (or equivalent generator)
3. Restart Hermes (`hermes gateway restart` or full process restart)
4. Verify with `hermes mcp test plane`

## Why
Codex is the declared source of truth in this environment. Hermes `mcp_servers` section is derived from it. Keeping them in sync prevents drift between the two MCP clients.

## Related Keys Found
- plane_api_a533f72cdcb24b19b3de3b1ce223c398 (active in Hermes)
- plane_api_85da4b4a586b47a6b1607ac34ea636ff (reference example)
