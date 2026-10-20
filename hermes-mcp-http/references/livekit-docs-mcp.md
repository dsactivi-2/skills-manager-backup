# LiveKit Docs MCP (public HTTP)

Verified 2026-08-23.

Official coding-agent Docs MCP is **one** server: `https://docs.livekit.io/mcp` (`livekit-docs`). `lk docs` is the same surface via CLI, not a second MCP.

```bash
printf 'n\nY\n' | hermes mcp add livekit-docs --url "https://docs.livekit.io/mcp"
hermes mcp test livekit-docs
# tools live after /reload-mcp or a new session
```

Auth: none. Tools: `get_docs_overview`, `get_pages`, `docs_search`, `code_search`, `get_changelog`, `get_sdks`, `get_pricing_info`, `submit_docs_feedback`, deprecated `get_python_agent_example`.

Prefer overview/`get_pages` over search. Do not dump `llms.txt` (~94 KB, ≈ overview) or `llms-full.txt` (~3.8 MB) into a project.

Official skills: `livekit-agents` + `livekit-simulations`. See `voice-ai-infrastructure` → `references/livekit-coding-agent-stack.md`.
