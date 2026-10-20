# OpenAI Python Library Connection Workaround (macOS)

## Problem

The `openai` Python library sometimes fails with `APIConnectionError: Connection error` on macOS even though `curl` to `https://api.openai.com/v1` works fine (HTTP 200). The library's internal HTTP client can have issues with certain macOS network configurations.

## Solution

Use `urllib.request` directly instead of the `openai` library:

```python
import json, urllib.request

data = json.dumps({
    "model": "gpt-4.1",
    "messages": [{"role": "user", "content": "..."}],
    "max_tokens": 4000,
    "temperature": 0.7,
}).encode("utf-8")

req = urllib.request.Request(
    "https://api.openai.com/v1/chat/completions",
    data=data,
    headers={
        "Authorization": f"Bearer {api_key}",
        "Content-Type": "application/json",
    }
)

with urllib.request.urlopen(req, timeout=120) as resp:
    result = json.loads(resp.read())
    content = result["choices"][0]["message"]["content"]
```

## Verification

```bash
# Test if key works at all
curl -s https://api.openai.com/v1/models \
  -H "Authorization: Bearer $OPENAI_API_KEY" | head -1

# If HTTP 200: key is valid, use urllib workaround
# If HTTP 401: key is invalid/expired
```

## When to use

- `openai` library raises `APIConnectionError` but `curl` works
- macOS environment where the library's HTTP stack has issues
- Background scripts that need reliable API access without library dependencies
