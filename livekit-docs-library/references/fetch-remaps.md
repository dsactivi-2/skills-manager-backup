# LiveKit docs dump — remaps and stub checks

Library: `/Users/activi/AI Bibliothek/LiveKit llms`  
Do not put `llms.txt` in `~/Code/Projects/LiveKit`.

## curl

```bash
curl -sL --max-time 90 -A "Mozilla/5.0" -o body -w "%{http_code} %{size_download} %{content_type}\n" \
  "https://docs.livekit.io/reference/agents/events.md"
```

No `Accept` header. Must follow 308 (`-L`).

Reject body if it contains `Redirecting (308)` or `Markdown document not found`, or size &lt; 400 after strip.

## Path variants (API / pdoc / typedoc)

For `https://docs.livekit.io/reference/python/livekit/plugins/openai/index.html.md#…`:

1. `…/index.html.md` → 404 markdown
2. `…/index.html` or `…/openai/` → 200 HTML
3. html-to-text; cache one fetch per path

Same for `agents-js/classes/….html.md`, `client-sdk-android/index.html.md`.

## Known remaps

| Requested | Use |
|-----------|-----|
| `https://docs.livekit.io/mcp` | `https://docs.livekit.io/reference/developer-tools/docs-mcp.md` (GET `/mcp/` = 405 JSON-RPC) |
| `https://docs.livekit.io/reference/recipes.md` | `## Recipes` slice from `https://docs.livekit.io/llms.txt` |
| `https://docs.livekit.io/reference/client-sdk-swift.md` | `https://raw.githubusercontent.com/livekit/client-sdk-swift/main/README.md` |

## Filename extras

- `.html.md` and trailing `/index` stripped before dots.
- `llms.txt` URL → file `llms.txt` (do not become `llms.txt.txt`).
- Method fragments: `reference.python.livekit.plugins.openai__livekit.plugins.openai.LLM.with_azure.txt`
