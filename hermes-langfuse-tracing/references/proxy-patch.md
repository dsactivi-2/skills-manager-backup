## Exact Patch Applied (2026-06-16 session)

**File**: `agent/process_bootstrap.py`
**Function**: `_load_openai_cls()`

```diff
 def _load_openai_cls() -> type:
-    """Import and cache ``openai.OpenAI``."""
+    """Import and cache ``openai.OpenAI`` or langfuse.openai.OpenAI if Langfuse keys are set (best practice for tracing)."""
     global _OPENAI_CLS_CACHE
     if _OPENAI_CLS_CACHE is None:
-        from openai import OpenAI as _cls
+        if os.environ.get("LANGFUSE_PUBLIC_KEY"):
+            from langfuse.openai import OpenAI as _cls
+            try:
+                from agent.agent_runtime_helpers import _ra
+                _ra().logger.info("Langfuse tracing enabled for OpenAI-compatible providers")
+            except Exception:
+                pass
+        else:
+            from openai import OpenAI as _cls
         _OPENAI_CLS_CACHE = _cls
     return _OPENAI_CLS_CACHE
```

**Why this location**:
- Single creation site for every OpenAI-compatible client in Hermes.
- Preserves lazy loading, `isinstance` checks, and all existing `mock.patch("run_agent.OpenAI")` tests.
- Works for OpenRouter, Groq, Azure, custom base_url providers, etc. without touching 20+ provider plugins.

**Verification**:
- After patch, setting `LANGFUSE_PUBLIC_KEY` causes all subsequent `chat.completions.create` calls to be automatically traced with model, tokens, cost, and latency.
- No change to call sites in `run_agent.py` or `agent_runtime_helpers.py` required.