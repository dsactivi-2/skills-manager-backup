# Eraser remote MCP + skills (Hermes)

Verified 2026-08 against https://docs.eraser.io/mcp and a live Hermes OAuth login.

## Endpoint

- URL: `https://app.eraser.io/api/mcp`
- Transport: Streamable HTTP
- Auth: OAuth 2.1 PKCE (recommended). API key `Authorization: Bearer` = team credits, CI/headless only.

## Hermes register

```bash
hermes config set mcp_servers.eraser.url "https://app.eraser.io/api/mcp"
hermes config set mcp_servers.eraser.auth oauth
hermes config set mcp_servers.eraser.enabled false
hermes mcp login eraser
hermes config set mcp_servers.eraser.enabled true
hermes mcp test eraser
```

`add --auth oauth` can save only `url` + `enabled: false` and drop `auth`. Then `hermes mcp login eraser` refuses (`auth=None`). Set `auth` first.

Tools go live after `/reload-mcp` or a new session. Green `test` is not enough — one real call (`get_me` / `list_files`).

Codex may already have a bare `[mcp_servers.eraser] url = "…"` entry with no OAuth. Hermes still needs `auth: oauth` + login.

## Skills

Official docs: `npx skills install eraserlabs/eraser-io`.
Skills CLI: `npx skills add eraserlabs/eraser-io -g -y --skill '*' --agent hermes-agent`.

Five skills: `eraser-diagrams` (DSL refs), `aws-diagrams`, `azure-diagrams`, `bicep-diagrams`, `terraform-diagrams`.

Vendor instructions call `POST https://app.eraser.io/api/render/elements` with `ERASER_API_KEY`. On Hermes that is wrong: use `mcp__eraser__create_diagram` (NL), `manually_create_diagram` (DSL), `update_diagram`, `export_diagram`. Pairing skill `eraser` encodes that.

`npx skills add` again overwrites the five vendor copies (curl text comes back). Re-patch MCP routing after a reinstall. The pairing skill is not in that repo.

## Tool routing

| Intent | Tool |
|---|---|
| New from natural language | `mcp__eraser__create_diagram` — `text` only; `diagramType` only if the user named a type |
| Edit existing (NL) | `mcp__eraser__update_diagram` |
| Verbatim DSL | `mcp__eraser__manually_create_diagram` / `manually_update_diagram` |
| PNG/JPEG | `mcp__eraser__export_diagram` |
| Identity / team | `mcp__eraser__get_me` |
