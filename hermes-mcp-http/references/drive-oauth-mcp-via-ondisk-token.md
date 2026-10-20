# Driving an OAuth MCP directly via the on-disk token (agent bypass)

Verified 2026-08 against Fish Audio (`https://api.fish.audio/mcp`). Companion
to the "OAuth-based MCP servers" section of SKILL.md.

## The problem this solves

After a user completes `hermes mcp login <name>`, the `mcp__<name>__*` tools do
**not** appear in the *current* running agent session — prompt-cache is sacred,
so Hermes never swaps a toolset mid-conversation. You either `/reload-mcp` (if
the build supports it) or start a fresh session.

But you don't have to wait: once the browser leg is done, Hermes has written a
real bearer token to disk, and an agent can drive the MCP endpoint directly with
a tiny script — same tools, same session, zero reload.

## Where the tokens live

```
~/.hermes/mcp-tokens/<name>.json         # access_token + refresh_token + expires_at
~/.hermes/mcp-tokens/<name>.client.json  # dynamic client registration (RFC 7591)
~/.hermes/mcp-tokens/<name>.meta.json    # cached auth-server metadata
```

`<name>.json` shape: `{access_token, token_type: "Bearer", expires_in: 3600,
scope, refresh_token, expires_at: <unix float>}`. Access token is good ~1h;
check `expires_at - time.time()`. If it's expired, this bypass can't refresh it
cleanly — have the user re-run `hermes mcp login <name>` (or trigger a real
reload so the SDK refreshes via the refresh_token).

## The client (mcp 1.26.0 in the Hermes venv)

The venv already ships `mcp` with `streamablehttp_client` + `ClientSession`:

```python
#!/usr/bin/env python3
import asyncio, json, sys, time
from pathlib import Path
from mcp import ClientSession
from mcp.client.streamable_http import streamablehttp_client

TOKENS = Path.home() / ".hermes" / "mcp-tokens" / "fish-audio.json"
URL = "https://api.fish.audio/mcp"

def _bearer() -> str:
    d = json.loads(TOKENS.read_text())
    if d.get("expires_at", 0) - time.time() < 60:
        print("WARNING: token near expiry — re-login may be needed", file=sys.stderr)
    return d["access_token"]

async def _run(argv):
    headers = {"Authorization": f"Bearer {_bearer()}"}
    async with streamablehttp_client(URL, headers=headers) as (r, w, _):
        async with ClientSession(r, w) as session:
            await session.initialize()
            if not argv or argv[0] == "list":
                for t in (await session.list_tools()).tools:
                    print(f"{t.name}: {(t.description or '').splitlines()[0][:80]}")
                return
            if argv[0] == "call":
                name = argv[1]
                args = json.loads(argv[2]) if len(argv) > 2 else {}
                res = await session.call_tool(name, args)
                for b in res.content:
                    print(b.text if getattr(b, "type", None) == "text" else repr(b))

if __name__ == "__main__":
    asyncio.run(_run(sys.argv[1:]))
```

Run it with the venv python so the SDK imports resolve:

```bash
cd ~/.hermes/hermes-agent && venv/bin/python3 <script> list
cd ~/.hermes/hermes-agent && venv/bin/python3 <script> call get_credit_balance '{}'
```

## Workflow discipline

- **Read the tool's `inputSchema` before spending anything.** Fetch it via
  `session.list_tools()` and inspect `t.inputSchema` — a wrong param silently
  returns empty (e.g. `search_voices` with a bad arg → `{"voices": []}`), which
  looks like a connection failure but isn't.
- **Cheapest read-only calls first** to prove the token end-to-end (balance,
  search) before any billable generate/transcribe call.
- Fish tool-output shape: `text_to_speech` returns a text block with JSON
  carrying `audio_url` (public `r2.fish.audio` URL) + `credits_charged`;
  `speech_to_text` accepts that same public URL — so TTS→STT chains with no
  local file handling.

## Why this is a bypass, not the fix

This is for an agent that needs the tools *now*, in a session that started
before login. It does not replace the reload / new-session path for normal use,
and it depends on the user having already completed the interactive browser leg.
