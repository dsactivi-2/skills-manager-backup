# LangChain Docs MCP Setup (Session 2026-06-17)

## Exact Commands Used (non-interactive)

```bash
# Add public no-auth docs MCP server
echo -e "n\nY" | hermes mcp add docs-langchain --url https://docs.langchain.com/mcp

# Verify
hermes mcp test docs-langchain
hermes mcp list
```

## Output Summary

**Add command:**
- Answered "authentication? [Y/n]" with `n`
- Answered "Enable all 2 tools? [Y/n/select]" with `Y`
- Result: `✓ Saved 'docs-langchain' to ~/.hermes/config.yaml (2/2 tools enabled)`

**Test command:**
```
Testing 'docs-langchain'...
  Transport: HTTP → https://docs.langchain.com/mcp
  Auth: none
  ✓ Connected (3308ms)
  ✓ Tools discovered: 2

    search_docs_by_lang_chain                Search across the Docs by LangChain knowledge base...
    query_docs_filesystem_docs_by_lang_chain Run a read-only shell-like query against a virtualized...
```

**mcp list excerpt:**
- `docs-langchain   https://docs.langchain.com/mcp   all   ✓ enabled`

## Tools Registered

- `mcp_docs_langchain_search_docs_by_lang_chain`
- `mcp_docs_langchain_query_docs_filesystem_docs_by_lang_chain`

**Naming rule confirmed:** `mcp_{server_name}_{tool_name}` (hyphens → underscores).

## Key Lessons (for native-mcp skill)

- Public documentation MCP servers (LangChain, Cloudflare-docs, langfuse-docs, openaiDeveloperDocs) require **no auth** → always answer `n` to authentication prompt.
- Use `echo -e "n\nY"` pipe for fully automated addition in scripts.
- No `headers` or `env` section needed in config.yaml.
- Tools appear immediately after session restart (`/new` or agent restart).
- Matches pattern of other docs MCP servers already present in this environment.

## Usage in Agent

After setup, ask questions about LangChain/LangGraph/LangSmith — agent will automatically use the MCP tools for up-to-date answers instead of web_search or stale knowledge.

**Cross-reference:** native-mcp/SKILL.md (Public Documentation MCP Servers section).

**Added:** 2026-06-17 from successful LangChain MCP installation session.
