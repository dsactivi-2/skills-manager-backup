# LiveKit agent as MCP client

Verified 2026-08-25 via Docs MCP + installed `livekit-agents` 1.6 (`llm/mcp.py`).

## Pages

| Use | Path |
|-----|------|
| Canonical | `/agents/logic/tools/mcp` |
| Recipe (stale) | `/reference/recipes/http_mcp_client` |
| Tests | `/agents/start/testing/test-framework` |

## Current API

```python
from livekit.agents import Agent, mcp

class MyAgent(Agent):
    def __init__(self) -> None:
        super().__init__(
            instructions="...",
            tools=[
                mcp.MCPToolset(
                    id="stable-id",
                    mcp_server=mcp.MCPServerHTTP(
                        url="https://example.com/mcp",
                        allowed_tools=["search_products"],  # optional
                        headers={"Authorization": "Bearer ..."},  # optional
                    ),
                )
            ],
        )
```

- Extra: `livekit-agents[mcp]` (imports `mcp` package). Without it: `ImportError`.
- Transport: URL path `/mcp` → streamable HTTP; `/sse` → SSE. Override with `transport_type=`.
- `MCPToolset` on Agent **replaces** session `tools` (same override as STT/LLM). Function tools on the class still combine.
- Server connect failure is logged; agent still starts.

## Do not copy from the recipe

| Recipe still shows | Live fact |
|--------------------|-----------|
| `AgentSession(mcp_servers=[mcp.MCPServerHTTP(url=...)])` | Deprecated. SDK warns. Auto-generated toolset IDs are not stable. |
| `tts="inworld/..."`, `llm="google/gemma-4-31b-it"` | This repo: Soniox Nina + Azure GPT-4.1 + DG Nova-3 EU via `build_session()`. Gemma = A/B only. |
| `https://shayne.app/mcp` | No default URL. |

## This repo

| File | Role |
|------|------|
| `src/amina/mcp_tools.py` | `build_mcp_toolsets()` from env |
| `src/amina/mcp_agent.py` | Worker `mcp-agent` — **not** wired into `amina-soniox-v2` |
| `tests/test_mcp_agent.py` | Constructor / no-`mcp_servers=` / empty URL |

Env: `AMINA_MCP_URL` (required to attach tools), `AMINA_MCP_TOOLSET_ID`, `AMINA_MCP_ALLOWED_TOOLS`, `AMINA_MCP_AUTH_TOKEN`.

```bash
lk agent console src/amina/mcp_agent.py
```

Do not attach an unknown MCP to the sales call path without Freigabe (context + latency).
