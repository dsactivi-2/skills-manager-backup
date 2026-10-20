# Hermes Langfuse Prefix Pitfall

## Problem
Hermes stores Langfuse credentials as `HERMES_LANGFUSE_PUBLIC_KEY`, `HERMES_LANGFUSE_SECRET_KEY`, and `HERMES_LANGFUSE_BASE_URL`.

The `hermes-langfuse-tracing` proxy in `process_bootstrap.py` only checks for the **standard** names:

```python
if os.environ.get("LANGFUSE_PUBLIC_KEY"):
    from langfuse.openai import OpenAI as _cls
```

Because of this, tracing remains inactive even when `hermes config check` shows the keys as ✓.

## Fix
Duplicate the values under the standard names in `~/.hermes/.env`:

```env
LANGFUSE_PUBLIC_KEY=pk-lf-...
LANGFUSE_SECRET_KEY=sk-lf-...
LANGFUSE_BASE_URL=https://cloud.langfuse.com
```

After adding these, restart Hermes so the proxy detects the keys on next load.

## Why this happens
Hermes uses the `HERMES_` prefix to namespace its own configuration. Third-party libraries (including langfuse SDK) expect the unprefixed standard names. The proxy was written against the standard names.

## Verification
After restart, the first OpenAI-compatible call should log:
"Langfuse tracing enabled for OpenAI-compatible providers"
```