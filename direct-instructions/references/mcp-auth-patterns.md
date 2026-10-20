# MCP Authentication Patterns (Hermes config.yaml)

## HTTP Remote MCP with Bearer Token

```yaml
  <mcp-name>:
    url: https://example.mcp.provider.com/mcp
    http_headers:
      Authorization: Bearer <token>
```

## Common Providers

- **Cloudflare** (builds, bindings, observability): Use `cfat_*` API token
- **Langfuse, OpenAI Docs**: Usually no token needed for public docs MCPs
- **Infobip / n8n**: Often require `Authorization: Bearer` or custom header

## Testing Pattern

```bash
curl -sI -H "Authorization: Bearer <token>" https://<endpoint>/mcp
```

Expected successful responses:
- 405 Method Not Allowed (normal for MCP endpoints)
- 200 OK

401 = token missing or invalid.