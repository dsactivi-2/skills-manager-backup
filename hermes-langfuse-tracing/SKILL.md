---
name: hermes-langfuse-tracing
description: "Use when adding Langfuse tracing/observability to the Hermes agent codebase itself (not to user applications). Targets the single lazy OpenAI proxy point in process_bootstrap.py so every OpenAI-compatible provider automatically inherits tracing."
version: 1.0.0
author: agent
license: MIT
---

# Hermes + Langfuse Tracing

## When to Use
- Instrumenting the Hermes core (run_agent, providers, etc.) with Langfuse.
- The goal is automatic tracing of all chat.completions.create calls across OpenRouter, Azure, Groq, custom OpenAI-compatible endpoints, etc.

## Core Pattern
Hermes deliberately uses a lazy proxy (`_OpenAIProxy` + `_load_openai_cls`) in `agent/process_bootstrap.py` so the heavy `openai` import is deferred and tests can patch `run_agent.OpenAI`.

**Patch location**: `_load_openai_cls()` — this is the single creation site.

```python
if os.environ.get("LANGFUSE_PUBLIC_KEY"):
    from langfuse.openai import OpenAI as _cls
else:
    from openai import OpenAI as _cls
```

This gives:
- Model name, token usage, cost, latency, errors (baseline requirements from langfuse skill)
- No changes needed in 20+ provider directories
- Works with the existing `client = _ra().OpenAI(**client_kwargs)` call site

## Environment
- Requires `LANGFUSE_PUBLIC_KEY` / `LANGFUSE_SECRET_KEY` (and optionally `LANGFUSE_BASE_URL`)
- `pip install langfuse` (Langfuse SDK)

## References
- `references/proxy-patch.md` — exact diff and rationale
- langfuse skill `references/instrumentation.md` (loaded in the originating session) for the broader Langfuse best-practice checklist

## Pitfalls
- Do not scatter OpenAI client creation across provider plugins — the proxy is the only place that survives future refactors.
- Import order: env vars must already be loaded (Hermes does this early via `load_hermes_dotenv`).
- The proxy must still satisfy `isinstance` checks and `mock.patch("run_agent.OpenAI")` used by ~28 test files — the conditional import preserves this.
- **HERMES_ prefix**: The Hermes config UI and `hermes setup` store Langfuse credentials as `HERMES_LANGFUSE_PUBLIC_KEY` / `HERMES_LANGFUSE_SECRET_KEY`. The condition **must** check both `LANGFUSE_PUBLIC_KEY` **or** `HERMES_LANGFUSE_PUBLIC_KEY` (same for SECRET/BASE_URL). Using only the standard prefix will silently fall back to plain `openai` even when keys exist in `.env`. Always include the fallback when patching for Hermes core.

## Verification Workflow (after setting LANGFUSE_* keys)
1. Ensure both `LANGFUSE_PUBLIC_KEY`/`LANGFUSE_SECRET_KEY` (and optional `LANGFUSE_BASE_URL`) exist in `~/.hermes/.env` (standard names, not only HERMES_ prefixed).
2. Restart the gateway so the proxy loads with the new env: `hermes gateway restart`.
3. Trigger a test trace with an OpenAI-compatible provider:  
   `hermes chat -q "Langfuse Test-Trace: Was ist 2 + 2?" -m openrouter/auto --provider openrouter --quiet`
4. Check gateway log for "Langfuse tracing enabled..." and inspect traces at https://cloud.langfuse.com.

This pattern guarantees the lazy `_load_openai_cls()` sees the keys on first import after restart.