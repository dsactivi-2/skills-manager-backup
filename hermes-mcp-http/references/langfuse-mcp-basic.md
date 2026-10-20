# Langfuse MCP Basic auth (Hermes)

## Pattern

Langfuse public MCP: `https://cloud.langfuse.com/api/public/mcp`

```yaml
langfuse-voiceeu:
  url: https://cloud.langfuse.com/api/public/mcp
  enabled: true
  headers:
    Authorization: ${LANGFUSE_VOICEEU_MCP_AUTH}

langfuse-dograh-cloud:
  url: https://cloud.langfuse.com/api/public/mcp
  enabled: true
  headers:
    Authorization: ${LANGFUSE_DOGRAH_CLOUD_MCP_AUTH}

langfuse-docs:
  url: https://langfuse.com/api/mcp
  enabled: true
```

## Build auth (do not print)

```text
LANGFUSE_*_MCP_AUTH=Basic $(printf '%s:%s' "$LANGFUSE_PUBLIC_KEY" "$LANGFUSE_SECRET_KEY" | base64)
```

Same Basic for both = one LF project; split keys when separate LF projects exist.

## Pairing

voiceeu Dograh work → langfuse-voiceeu  
Cloud Dograh work → langfuse-dograh-cloud  

See skill `dograh-dual-instance` → `references/langfuse-dual-routing.md`.

## Verify

```bash
hermes mcp test langfuse-voiceeu
hermes mcp test langfuse-dograh-cloud
hermes mcp test langfuse-docs
```
