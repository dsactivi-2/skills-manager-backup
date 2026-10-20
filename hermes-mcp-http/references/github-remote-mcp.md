# Official GitHub remote MCP in Hermes

Do **not** add by default — authenticated `gh` is enough. Product facts and toolsets: skill `github-agent-tooling` → `references/github-mcp-official.md`.

Remote URL: `https://api.githubcopilot.com/mcp/`
Auth: OAuth (preferred) or PAT `Authorization: Bearer …`
Read-only: `https://api.githubcopilot.com/mcp/readonly` or header `X-MCP-Readonly: true`

If the user explicitly wants it:

```bash
hermes mcp add github --url "https://api.githubcopilot.com/mcp/" --auth oauth
hermes config set mcp_servers.github.auth oauth   # add often drops this
hermes mcp login github                           # USER, interactive TTY
hermes config set mcp_servers.github.enabled true
hermes mcp test github
```

PAT alternative: `http_headers.Authorization: Bearer <PAT>` (same OAuth-drop pitfall does not apply). Tools live only after `/reload-mcp` or a new session.

GHES: local Docker only, not this URL. GHE Cloud data residency: `https://copilot-api.SUBDOMAIN.ghe.com/mcp`.
