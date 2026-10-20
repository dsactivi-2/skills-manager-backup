# Building Python MCP Servers

Patterns and pitfalls from building custom MCP servers in Python.

## Minimal Server Template

```python
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent

server = Server("my-server")

@server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(
            name="my_tool",
            description="What this tool does",
            inputSchema={
                "type": "object",
                "properties": {
                    "param": {"type": "string", "description": "..."},
                },
                "required": ["param"],
            },
        ),
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    result = do_something(arguments["param"])
    return [TextContent(type="text", text=str(result))]

async def main():
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, server.create_initialization_options())

if __name__ == "__main__":
    import asyncio
    asyncio.run(main())
```

## Registration in Hermes

```bash
# Non-interactive (pipe "y" to auto-enable all tools)
echo "y" | hermes mcp add myserver --command /path/to/.venv/bin/python3 --args /path/to/server.py

# Verify
hermes mcp list
hermes mcp test myserver
```

## Scraping Liferay/Java Portals Without Browser

When the target is a server-rendered Java portal (Liferay, JSF, Spring MVC):

1. **Use `requests.Session()`** — not Puppeteer/Selenium. JSESSIONID cookie is all you need.
2. **Extract form actions dynamically** — Liferay portlets embed `p_auth` tokens in form action URLs that change per session. Parse them from the HTML, don't hardcode.
3. **Rate-limit** — 1 second between requests minimum to avoid triggering CAPTCHA.
4. **Check for CAPTCHA** — many portals mention reCAPTCHA in the footer but never activate it. Test live before adding CAPTCHA-solving overhead.

### Dynamic Form Extraction Pattern

```python
from bs4 import BeautifulSoup
from urllib.parse import urljoin

def extract_form_action(html: str, base_url: str) -> str:
    soup = BeautifulSoup(html, "lxml")
    form = soup.find("form", action=lambda a: a and "portlet_id" in a)
    action = form.get("action", "")
    if action.startswith("/"):
        action = urljoin(base_url, action)
    return action
```

## Venv Pitfall on macOS

Hermes Agent's own venv (`~/.hermes/hermes-agent/venv`) can leak into subprocess `sys.path`. This causes version conflicts (e.g., `requests` from Hermes venv vs. project venv). Fix:

```bash
# Use -I flag for isolated mode
.venv/bin/python3 -I server.py

# Or in hermes mcp config, use absolute venv python path
hermes mcp add myserver --command /absolute/path/.venv/bin/python3 --args server.py
```

## Testing MCP Servers

```python
# Quick integration test without MCP protocol overhead
import json
from server import MyScraper

scraper = MyScraper()
result = scraper.some_method("test input")
print(json.dumps(result, indent=2, ensure_ascii=False))
```
