# QMD MCP Server Setup

## Install

```bash
npm install -g @tobilu/qmd
qmd collection add ~/path/to/markdown --name myknowledge
qmd embed
```

## Configure MCP Client

**Claude Code** (`~/.claude/settings.json`):
```json
{
  "mcpServers": {
    "qmd": { "command": "qmd", "args": ["mcp"] }
  }
}
```

**Claude Desktop** (`~/Library/Application Support/Claude/claude_desktop_config.json`):
```json
{
  "mcpServers": {
    "qmd": { "command": "qmd", "args": ["mcp"] }
  }
}
```

**OpenClaw** (`~/.openclaw/openclaw.json`):
```json
{
  "mcp": {
    "servers": {
      "qmd": { "command": "qmd", "args": ["mcp"] }
    }
  }
}
```

## Protocol

Installed CLI here is **qmd 2.1.0** HTTP Streamable MCP, not the later
sessionless docs. Trust live behavior over this file if they conflict.

- **stdio** (`qmd mcp`): host launches a subprocess.
- **HTTP** (`qmd mcp --http --port 8181`): Streamable HTTP **with session**.
  First request is `initialize`. Server returns `Mcp-Session-Id`. Later
  `tools/list` / `tools/call` without that header → JSON-RPC `-32000`
  `Bad Request: Missing session ID`. That is correct, not a crash.
  Hermes does the handshake; a browser tab does not.

Do not paste `collection add ~/...` + `qmd embed` as default install on this
machine. Corpus is only the named collection in `~/.config/qmd/index.yml`.

## HTTP Mode

```bash
qmd mcp --http --port 8181
# Hermes: url http://localhost:8181/mcp
hermes mcp test qmd
```

Listen may be IPv6-only (`[::1]:8181`). Probe `http://localhost:8181/mcp` or
`http://[::1]:8181/mcp`, not only `127.0.0.1`. Port **8181**.

GET `/mcp` without a session → 400 Missing session ID (healthy).
Verify with `initialize` (HTTP 200, `serverInfo.name: qmd`) or `hermes mcp test qmd`.

## Tools

### query

Search with pre-expanded queries.

```json
{
  "searches": [
    { "type": "lex", "query": "keyword phrases" },
    { "type": "vec", "query": "natural language question" },
    { "type": "hyde", "query": "hypothetical answer passage..." }
  ],
  "limit": 10,
  "collection": "optional",
  "minScore": 0.0
}
```

| Type | Method | Input |
|------|--------|-------|
| `lex` | BM25 | Keywords (2-5 terms) |
| `vec` | Vector | Question |
| `hyde` | Vector | Answer passage (50-100 words) |

### get

Retrieve document by path or `#docid`.

| Param | Type | Description |
|-------|------|-------------|
| `path` | string | File path or `#docid` |
| `full` | bool? | Return full content |
| `lineNumbers` | bool? | Add line numbers |

### multi_get

Retrieve multiple documents.

| Param | Type | Description |
|-------|------|-------------|
| `pattern` | string | Glob or comma-separated list |
| `maxBytes` | number? | Skip large files (default 64KB) |

### status

Index health and collections. No params.

## Troubleshooting

- **Not starting**: `which qmd`, `qmd mcp` manually
- **No results**: `qmd collection list`, `qmd embed`
- **Slow first search**: Normal, models loading (~3GB)
