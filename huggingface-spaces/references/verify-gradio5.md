# Verify a Gradio 5.x Space without gradio_client

gradio_client 1.3.0 (latest on PyPI) is incompatible with Gradio 5.x Spaces: it requests the legacy API-info path and cannot parse the 5.x info schema, so `client.predict()` fails. The raw `/gradio_api/call` SSE endpoint 404s on ZeroGPU (replica routing), so it cannot return the result either. For Gradio 5.x, verify output by logging inside the app and reading the runtime logs.

## 1. Add logging to the handler (and after model load)
```python
# at module scope, after model + LoRA load:
print("[startup] base model + LoRA loaded", flush=True)

# inside the @spaces.GPU-decorated handler, before returning:
print(f"[generate] produced image size={image.size}", flush=True)
```
Commit + push; wait for RUNNING (watch `hf spaces info <id> --expand runtime`).

## 2. Trigger one generation (proves the handler runs end-to-end)
```bash
curl -sS -X POST -H "Content-Type: application/json" \
  -d '{"data":["PERVERSA, portrait, soft studio light",28,42,3.5]}' \
  "https://<ns>-<name>.hf.space/gradio_api/call/generate"
# returns {"event_id":"..."}  — the events endpoint 404s on ZeroGPU; ignore it
```

## 3. Read the runtime logs for the success line + no traceback
```bash
/opt/homebrew/bin/hf spaces logs <ns>/<name> --tail 60
# expect: "[startup] base model + LoRA loaded" and
#         "[generate] produced image size=(1024, 1024)"
# and NO Traceback.
```
Success line with no traceback ⇒ the Space generates images correctly. Visual confirmation in the browser UI is still recommended for the final user-facing check.

## Notes
- The browser UI uses WebSockets, not the `/gradio_api/call` API, so the UI works even when the call API is flaky.
- `/gradio_api/info` is the correct API-info path for Gradio 5.x (returns `named_endpoints` JSON).
- `gradio_client.Client` param is `hf_token=` (NOT `token=`); public Spaces need no token; the `api_info=` kwarg does not exist in 1.3.0.
