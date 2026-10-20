# n8n Docs MCP (GitBook)

Verified 2026-09-01. Public, no auth.

| | |
|---|---|
| Hermes name | `n8n-docs` |
| URL | `https://docs.n8n.io/~gitbook/mcp` |
| Auth | none |
| Tools | `searchDocumentation`, `getPage`, `sendFeedback` |

Install (non-interactive):

```bash
printf 'n\nY\n' | hermes mcp add n8n-docs --url "https://docs.n8n.io/~gitbook/mcp"
hermes mcp test n8n-docs
```

**Not** `n8n-livekit` (`https://n8n-lk.activi.io/mcp-server/http`). Docs MCP cannot list/edit workflows.

Plain GET/web_extract on the URL → JSON-RPC `-32000 Method not allowed`. Probe with MCP `tools/call`.

Data Table upsert (docs): only **mapped** columns are written. Unmapped columns on an existing row stay. Energy F1 N06 zeros counters because those fields are in the mapping, not because upsert wipes the row.
