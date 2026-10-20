---
name: huggingface-spaces
description: Build, deploy, debug Hugging Face Spaces (Gradio/ZeroGPU).
version: 1
author: Hermes Agent
license: mit
tags: [huggingface, spaces, gradio, zero-gpu, diffusers, lora]
---

# Hugging Face Spaces

Host ML demo apps on HF Spaces. Canonical entry: the HF modal / `curl https://huggingface.co/new-space/agents.md` tells the agent to install this skill and log in.

## When to Use
- The user asks to create or host an app/demo on Hugging Face, or pastes the "Build a Space with an AI agent" modal text / `curl https://huggingface.co/new-space/agents.md`.
- Building a demo for a specific HF model (text-to-image LoRA, diffusers, transformers, etc.).
- Debugging a Space that won't build or run (`RUNTIME_ERROR`, gated-model 403, ZeroGPU issues).

## 0. Local CLI facts (this environment)
- `hf` CLI lives at `/opt/homebrew/bin/hf` (v1.25.1). **Call it by absolute path** whenever a Python venv is active in the working dir (Pitfall A).
- This version has no `hf spaces logs`/`hf spaces secrets` subcommands that newer docs reference. `hf spaces logs <id> --tail N` DOES work with the real binary; secrets are set via the REST API.

## 1. Auth
- `hf auth whoami` → `user=` and `orgs=`. That account is the one that can push AND whose token the Space runtime uses.
- Login: `hf auth login` prints a URL + one-time code; the user opens it in a browser and authorizes (OAuth, no token needed). Or `hf auth login --token hf_xxx`.
- The Space runtime uses a Space-scoped token that is SEPARATE from the owner's personal token and does NOT inherit the owner's accepted gated-model licenses. Gated-model access in the runtime is solved with an `HF_TOKEN` secret (Pitfall B), not by accepting the license on the website alone.

## 2. Decide SDK + hardware
- Default for a public ML demo: **Gradio + ZeroGPU** (`--flavor zero-a10g`). On a free account ZeroGPU is the only way to host a Gradio Space (cpu-basic is also gated).
- `hardware:` in README YAML is silently ignored — set hardware only via `--flavor` at create, or later `hf spaces settings <id> --hardware <name>`.
- Before creating a Space that **loads** a model, compare FP8/weight GiB from the model card to the flavor VRAM. ZeroGPU `zero-a10g` is 24 GB. Do not create that flavor for a checkpoint whose weights already exceed 24 GB (e.g. OUI-1 FP8 ~25.8 GiB) — it will OOM at startup. Offer paid `--flavor` (a100-large, l40sx1, …) only after the user accepts billing, or point a thin client at an existing OpenAI-compatible `/v1` URL.

## 2b. Inference Endpoints
- CLI: `/opt/homebrew/bin/hf endpoints` (`list`, `hardware`, `deploy`, `pause`, …). Hub login is not enough: `403` with `missing permissions: inference.endpoints.read` means the token lacks Inference Endpoints scopes. Device OAuth (`hf auth login --force` → https://hf.co/oauth/device + code) can succeed `whoami` and still 403 endpoints. A user-access token with Endpoints read/write, saved via `hf auth login` without echoing the token, is what `endpoints ls` needs. Token files: `~/.cache/huggingface/token` and `stored_tokens` — report the path, never the value. Tokens pasted in chat are leaked: rotate after login.
- Do not say a model is hosted until `hf endpoints ls` shows that repo in a running (or scaledToZero) row. Paused/failed/scaledToZero is not a live OUI-1 API.
- `hf endpoints deploy` is paid GPU. Do not deploy until the user confirms cost. Then `--repo <model> --framework vllm` plus vendor/region/instance from `hf endpoints hardware`. Probe `{endpoint}/v1/models` with the stored token; 503 means not ready.

## 3. Create
```
/opt/homebrew/bin/hf repos create <ns>/<name> --type space --space-sdk gradio \
    --flavor zero-a10g --public --exist-ok
```
`<ns>` must be an account/org the logged-in user can push to; default to the `user=` from `hf auth whoami`.

## 4. Build the app (FLUX / diffusers LoRA example)
Use `templates/app.py`, `templates/requirements.txt`, `templates/README.md`. Rules:
- `import spaces` MUST come before `import torch`/`import diffusers` (ZeroGPU monkey-patches CUDA).
- Load the model at module scope and call `.to("cuda")` eagerly, so ZeroGPU streams weights on the first `@spaces.GPU` entry.
- Decorate the Gradio-bound function with `@spaces.GPU(duration=<worst-case seconds>)`.
- `requirements.txt`: list `diffusers`, `accelerate`, `safetensors`, and — for ANY FLUX pipeline (`FluxPipeline`, including FLUX.1-dev LoRAs) — also `transformers`, `sentencepiece`, and `peft`. Omitting `transformers` lets the base model download fine and then crash with `ImportError: FluxPipeline requires the transformers library`; omitting `peft` lets the base model AND the LoRA download fine and then crash at `load_lora_weights()` with `ValueError: PEFT backend is required`. Use `templates/requirements.txt`. **Do NOT** list `gradio`, `spaces`, `huggingface_hub` (platform-managed). Leave `torch` unpinned — the ZeroGPU runtime provides an accepted version.
- README frontmatter: `sdk: gradio`, a real `sdk_version` (look up latest stable; 5.x e.g. 5.50.0 supports `mcp_server=True`), `app_file: app.py`, `startup_duration_timeout: 1h` for big models (FLUX.1-dev ~24 GB downloads at app start).
- Launch with `demo.launch(mcp_server=True)`.

## 5. Push
```
/opt/homebrew/bin/hf upload <ns>/<name> . --repo-type space --exclude "**/__pycache__/**"
```
`--repo-type space` is REQUIRED (defaults to a model repo). **Pitfall C:** `hf upload .` sweeps the ENTIRE directory — if you built a venv inside the Space dir, ~1800 files pollute the repo. Keep the Space working dir free of venvs (put smoke-test venvs elsewhere) or exclude them.

## 6. Verify (don't trust RUNNING)
- Stage: `hf spaces info <ns>/<name> --expand runtime` → `runtime.stage` (`BUILDING`→`RUNNING`, or `RUNTIME_ERROR`).
- Logs: `/opt/homebrew/bin/hf spaces logs <ns>/<name> --tail 100` (runtime) / `--build` (build). Read the FIRST error.
- Smoke test: for Gradio 4.x Spaces a venv with `gradio_client` (kept OUTSIDE the Space dir) works; for Gradio 5.x it does NOT (Pitfall G) — verify via in-app logging + runtime logs (see `references/verify-gradio5.md`). The 4.x `scripts/smoke_test.py <ns>/<name>` asserts the returned file's first 8 bytes are a PNG. It asserts the returned file's first 8 bytes are `\x89PNG\r\n\x1a\n`.

## 7. Pitfalls (generalizable)
- **A. Venv shadows `hf`.** Creating a venv in the working dir and `pip install huggingface_hub`/`gradio_client` prepends a DIFFERENT `hf` (huggingface_hub's own entry point) to PATH that lacks `spaces logs` → "No such command 'logs'". Call `/opt/homebrew/bin/hf` by absolute path, and create smoke-test venvs OUTSIDE the Space directory.
- **B. Gated base model (401/403).** A 401/403 on `<model>/resolve/main/model_index.json` means no access to the gated base model. The Space runtime uses a Space-scoped token that does NOT carry the owner's accepted gated licenses — so accepting the license on the website (even as the owner) is NOT enough; the runtime still 401s. The deterministic fix is an `HF_TOKEN` secret carrying a token that HAS access:
  - Verify the token first: `tok=$(cat ~/.cache/huggingface/token); curl -sI -H "Authorization: Bearer $tok" "https://huggingface.co/<model>/resolve/main/model_index.json"` → `200` = access, `401/403` = none. The token must come from an account that accepted the license.
  - Set it: `curl -X POST -H "Authorization: Bearer $tok" -H "Content-Type: application/json" -d '{"key":"HF_TOKEN","value":"<tok-with-access>"}' "https://huggingface.co/api/spaces/<id>/secrets"`.
  - Restart by re-uploading a trivial change (e.g. a README status line). Re-check the runtime log — it should now download `model_index.json` (100%) instead of a `GatedRepoError`.
  Note: a 403 = license never accepted on that account; a 401 = authenticated but not granted. Both are fixed the same way.
- **C. `hf upload .` repo pollution** — see §5.
- **D. Deleting remote files needs the right kwarg.** `HfApi().delete_folder(path_in_repo=".venv", repo_id=..., repo_type="space")` — the param is `path_in_repo`, not `path`/`folder_path`. The `hf` CLI v1.25.1 has no delete subcommand; use a `huggingface_hub` venv for this.
- **E. Gradio evals string return type hints when it wires the UI.** A handler annotated `-> "PIL.Image.Image"` without `import PIL` in the module raises `NameError: name 'PIL' is not defined` at `btn.click(...)` time (`gradio.utils.get_type_hints` evaluates the forward ref). Drop the annotation or `from PIL import Image` — keep every handler signature free of un-imported forward refs. `templates/app.py` already omits it.
- **F. A rebuild re-downloads the base model.** The base model loads at app STARTUP, not at build, so every rebuild — including a trivial README bump to restart — re-pulls the full ~24–34 GB. Batch all code fixes into ONE push instead of restarting per edit. Watch `runtime.stage`: `BUILDING`→`APP_STARTING` (model download happens here)→`RUNNING`; a Space stuck in `RUNTIME_ERROR` means the startup traceback in `hf spaces logs <id> --tail N` is the real error, not the stage.
- **G. gradio_client 1.3.0 cannot verify a Gradio 5.x Space.** It fetches API info from the legacy path `info?serialize=False` (→ 404, empty body, `Expecting value: line 1 column 1` on `r.json()`) and, even patched to `/gradio_api/info`, cannot parse the 5.x info schema (`argument of type 'bool' is not iterable` from its `e.pop('show_api', True)`), so `client.predict()` is unusable for Gradio 5.x. The raw `POST /gradio_api/call/<api_name>` returns only `event_id`, and `GET /gradio_api/call/<event_id>/events` 404s on ZeroGPU (replica routing), so the raw call API can't return the result either. **Verify a Gradio 5.x Space via in-app logging + runtime logs instead** (see `references/verify-gradio5.md`): add a `print()` inside the handler, trigger one generation with `curl`, then read `hf spaces logs <id> --tail N` for the success line and the absence of a traceback.

## 8. Content policy
If the target model is adult/NSFW, flag the HF Content Policy before publishing. Build the demo, but require an explicit user decision: private + "Sensitive Content" flag (recommended), public as-is (HF may block), or local-only. Add a content warning to the README regardless.
