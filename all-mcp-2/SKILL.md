---
name: all-mcp
description: >-
  Use when the agent needs access to MCP tools from: Dograh Voiceeu, Langchain Docs, Langfuse Docs, Node Repl, Telnyx, Zyla Api Hub. Total 38 tools available.
---

# ALL Tools

All enabled MCP tools

## How to Call Tools

```bash
python3 scripts/call-tool.py <tool_name> '<arguments_json>'
```

**IMPORTANT:** Before calling any tool, you MUST first read its reference documentation under `references/` to learn the available tools, required parameters, and usage examples. Do NOT guess tool names or parameters.

## Available Services

### Dograh Voiceeu

Tools: create_tool, create_workflow, get_node_type, get_voice_prompting_guide, get_workflow, get_workflow_code, list_credentials, list_docs, list_documents, list_node_types, list_recordings, list_tools, list_workflows, read_doc, save_workflow, search_docs.

**Read [references/dograh-voiceeu-mcp.md](references/dograh-voiceeu-mcp.md) for parameters and usage before calling.**

### Langchain Docs

Tools: query_docs_filesystem_docs_by_lang_chain, search_docs_by_lang_chain.

**Read [references/langchain-docs-mcp.md](references/langchain-docs-mcp.md) for parameters and usage before calling.**

### Langfuse Docs

Tools: getLangfuseDocsPage, getLangfuseOverview, searchLangfuseDocs.

**Read [references/langfuse-docs-mcp.md](references/langfuse-docs-mcp.md) for parameters and usage before calling.**

### Node Repl

Tools: js, js_add_node_module_dir, js_reset.

**Read [references/node-repl-mcp.md](references/node-repl-mcp.md) for parameters and usage before calling.**

### Telnyx

Tools: get_api_endpoint_schema, invoke_api_endpoint, list_api_endpoints, open_number_intelligence, open_usage_cost_explorer, open_voice_monitor.

**Read [references/telnyx-mcp.md](references/telnyx-mcp.md) for parameters and usage before calling.**

### Zyla Api Hub

Tools: account_status, browse_catalog, call_api, get_api_info, get_payment_url, list_categories, register, search_catalog.

**Read [references/zyla-api-hub-mcp.md](references/zyla-api-hub-mcp.md) for parameters and usage before calling.**

