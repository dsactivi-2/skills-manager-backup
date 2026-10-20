# VS Code MCP + Continue Synchronization

## Target Formats

**Native VS Code MCP** (`~/Library/Application Support/Code/User/mcp.json`):
- Uses stdio transport exclusively in this session.
- Env vars can use `${input:xxx}` prompts or hardcoded values.
- Servers appear under `servers.<name>` with `type`, `command`, `args`, `env`.

**Continue LLM Providers** (`~/.continue/config.yaml`):
- Models listed under `models:` with `provider`, `model`, `apiKey: ${ENV_VAR}`.
- MCP servers can also be declared under `mcpServers:` (Continue-specific).

## Verified Mapping (Hermes → VS Code)

- `command` + `args` map 1:1.
- `env` block preserved; use `${input:xxx}` for secrets that should prompt on first use.
- Context7 server: hardcoded key from user profile worked; Firecrawl/Cloudflare used prompt inputs.
- Continue providers: xAI (grok-4), Anthropic, OpenAI, DeepSeek, Groq, Gemini all registered via env placeholders.

## Example mcp.json Addition (from session)

```json
"context7": {
  "type": "stdio",
  "command": "npx",
  "args": ["-y", "@upstash/context7-mcp@latest"],
  "env": {
    "CONTEXT7_API_KEY": "ctx7sk-..."
  }
}
```

## Example Continue config.yaml Addition

```yaml
models:
  - name: Grok 4 (xAI)
    provider: xai
    model: grok-4
    apiKey: ${XAI_API_KEY}

mcpServers:
  - name: context7
    command: npx
    args: ["-y", "@upstash/context7-mcp@latest"]
    env:
      CONTEXT7_API_KEY: ${CONTEXT7_API_KEY}
```

## Pitfall

VS Code native MCP does not hot-reload; requires window reload or restart after mcp.json change. Continue reads config.yaml on startup.

## Source of Truth Recommendation

Keep master MCP list in Hermes `~/.hermes/config.yaml`, generate VS Code mcp.json + Continue snippets from it when syncing.