---
name: mcp-scraper-server
description: Build Python MCP servers that scrape websites with requests+BeautifulSoup (no JS/CAPTCHA). Use when the user asks to scrape a site and expose it as MCP tools, or when building a new data-source MCP server from scratch.
---

# MCP Scraper Server

Build MCP servers that wrap website scraping behind clean tool interfaces. Prefer `requests` + `BeautifulSoup` over Puppeteer when the target site doesn't require JavaScript — it's faster, lighter, and avoids browser overhead.

## Trigger

- "Baue einen MCP-Server für [Website]"
- "Scrape [Site] und mach es als MCP-Tool verfügbar"
- "Ich brauche einen Scraper für [Datenquelle]"

## Decision: requests vs Puppeteer

| Signal | Use |
|--------|-----|
| Static HTML, no JS rendering needed | `requests` + `BeautifulSoup` |
| Form-based search, session cookies | `requests.Session()` |
| CAPTCHA present and active | Puppeteer + stealth plugins (or abort) |
| JS-rendered content (React, Vue, etc.) | Puppeteer/Playwright |
| Login required | `requests.Session()` with form POST |

**Rule**: Start with `requests`. Only escalate to Puppeteer if the site proves JS-dependent.

## Project scaffold

```
project-mcp/
├── server.py          # MCP server + scraper in one file
├── requirements.txt   # mcp, requests, beautifulsoup4, lxml
└── .venv/
```

Minimal `server.py` structure:

```python
from mcp.server import Server
from mcp.server.stdio import stdio_server
from mcp.types import Tool, TextContent

server = Server("my-scraper-mcp")

@server.list_tools()
async def list_tools() -> list[Tool]:
    return [
        Tool(name="my_search", description="...", inputSchema={...}),
    ]

@server.call_tool()
async def call_tool(name: str, arguments: dict) -> list[TextContent]:
    # dispatch to scraper methods
    ...

async def main():
    async with stdio_server() as (read_stream, write_stream):
        await server.run(read_stream, write_stream, server.create_initialization_options())
```

## Session-based scraping pattern

```python
class Scraper:
    def __init__(self):
        self.session = requests.Session()
        self.session.headers.update({
            "User-Agent": "Mozilla/5.0 ...",
            "Accept-Language": "bs,en;q=0.9",
        })
        self._init_session()

    def _init_session(self):
        r = self.session.get(BASE_URL, timeout=15)
        r.raise_for_status()
```

## Pitfalls

### Liferay/Java portals with dynamic form actions

Portals like Liferay generate form action URLs with session-specific `p_auth` tokens. **Never hardcode the action URL** — always extract it from the page:

```python
def _extract_form(self, html: str) -> dict:
    soup = BeautifulSoup(html, "lxml")
    form = soup.find("form", action=lambda a: a and "portal" in a)
    action = urljoin(BASE_URL, form.get("action", ""))
    return {"action": action, ...}
```

### Different form actions per search mode

Some portals use different `javax.portlet.action` values per tab (e.g., `search` for persons, `searchformnumber` for reverse lookup). Always navigate to the specific tab page first, then extract its form action.

### Field name discovery

Field names vary by mode. Always inspect the form on the specific tab page:
- Person search: `_portal_..._ime_prezime`
- Business search: `_portal_..._naziv_korisnika` (not `naziv`!)
- Number search: `_portal_..._pozivni` + `_portal_..._telefon`

### Result table identification

Pages often have multiple tables (canton lists, emergency numbers). Identify the result table by its column headers, not by position:

```python
def _parse_results(self, html, mode):
    tables = soup.find_all("table")
    for table in tables:
        headers = [th.get_text(strip=True) for th in table.find_all("th")]
        if mode == "person" and "Ime i prezime:" in headers:
            return self._parse_person_table(table)
```

### Rate limiting

Always add `time.sleep(1.0)` between requests. Aggressive scraping triggers CAPTCHA even on sites where it's normally inactive.

### CAPTCHA footer text ≠ active CAPTCHA

Some sites mention reCAPTCHA in their footer but don't enforce it. Test with a real request before assuming it's a blocker.

## Registering with Hermes

```bash
hermes mcp add <name> --command /path/to/.venv/bin/python3 --args /path/to/server.py
```

Answer `y` to enable all tools. Tools are available in the next session.

## References

- `references/bhtelecom-implementation.md` — Full BH Telecom Imenik implementation with Liferay form details
