# Langfuse Docs Tools Reference

## getLangfuseDocsPage

Fetch the raw Markdown for a single Langfuse docs page. Accepts a docs path (e.g., /docs/observability/overview) or a full https://langfuse.com URL. Returns the exact Markdown (may include front matter). Use when you need a specific page content (Integration, Features, API, etc.) or code samples. Prefer searchLangfuseDocs for broader questions where there is not one specific page about it.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| pathOrUrl | string | Yes | Docs path starting with "/" (e.g., /docs/observability/overview) or a full URL on https://langfuse.com. Do not include anchors (#...) or queries (?foo=bar) — they will be ignored. |

### Example

```bash
python3 scripts/call-tool.py getLangfuseDocsPage '{"pathOrUrl":"..."}'
```

---

## getLangfuseOverview

Get a high-level, machine-readable index by downloading https://langfuse.com/llms.txt. Use this at the start of a session when needed to discover key docs endpoints or to seed follow-up calls to searchLangfuseDocs or getLangfuseDocsPage. Returns the plain text contents of llms.txt. Avoid repeated calls within the same session.

### Parameters

No parameters required.

### Example

```bash
python3 scripts/call-tool.py getLangfuseOverview '{}'
```

---

## searchLangfuseDocs

Semantic search (RAG) over the Langfuse documentation. Use this whenever the user asks a broader question that cannot be answered by a specific single page. Returns a concise answer synthesized from relevant docs. The raw provider response is included in _meta. Prefer this before guessing. If a specific page is needed call getLangfuseDocsPage first.

### Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| query | string | Yes | The user's question in natural language. Include helpful context like SDK/language (e.g., Python v3, JS v4), self-hosted vs cloud, and short error messages (trim long stack traces). Keep under ~600 characters. |

### Example

```bash
python3 scripts/call-tool.py searchLangfuseDocs '{"query":"..."}'
```

---

