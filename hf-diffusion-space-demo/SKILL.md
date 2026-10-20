---
name: hf-diffusion-space-demo
description: Build an HF Space demo for a diffusion or FLUX LoRA model.
version: 1.0.0
author: activi
license: MIT
metadata:
  hermes:
    tags: [huggingface, spaces, gradio, zero-gpu, diffusion, flux, lora, demo]
    related_skills: [huggingface-spaces]
---

# Hugging Face diffusion / LoRA demo Space

Build a Gradio + ZeroGPU Space that loads a base diffusion model plus a LoRA and generates images. The authoritative procedure reference is the external `huggingface-spaces` skill (https://raw.githubusercontent.com/huggingface/skills/main/skills/huggingface-spaces/SKILL.md) — read it for hardware/requirements rules. This skill captures the diffusion-specific procedure and the pitfalls that cost time.

## When to use
- User pastes the HF agent-build command (`curl https://huggingface.co/new-space/agents.md and build me a Space with a demo for <model>`).
- User asks to create/host an HF demo for a `diffusers` model or LoRA.

## Procedure (in order)

1. **Resolve the model first.** `curl -sL "https://huggingface.co/api/models/<repo>"` and read `siblings` (file list: `lora.safetensors`, `config.yaml`), `pipeline_tag`, and `base_model:` tags. Determine the base model + LoRA weight filename. Save the JSON to a temp file and parse it; don't pipe curl straight into an interpreter.
2. **Check auth BEFORE asking for a token.** `hf auth whoami` — if it returns `user=...`, you're already logged in; skip the token. If not, run `hf auth login`: it prints a URL + one-time code the user completes in a browser (OAuth, no token needed). Only request a write token from https://huggingface.co/settings/tokens when the browser flow is impossible. Pitfall: on an already-authed machine `hf auth login` just prints "Already logged in" — do not wait for a code that never comes.
3. **Build the local repo** (README.md, app.py, requirements.txt) — copy `templates/app.py` and `templates/README.md` and edit the repo/name. Rules baked into the template:
   - `import spaces` MUST be the first import, before `torch`/`diffusers` (ZeroGPU monkey-patches CUDA at import).
   - Load the pipeline at module scope with `.to("cuda")` eagerly.
   - Wrap the generation function in `@spaces.GPU(duration=...)`.
   - `demo.launch(mcp_server=True)` (Gradio 5+).
   - requirements.txt lists `diffusers`, `accelerate`, `safetensors` ONLY. Never list `gradio`, `spaces`, `huggingface_hub` (platform-managed). Leave `torch` unpinned — ZeroGPU only accepts 2.8.0/2.9.1/2.10.0/2.11.0 and preinstalls the latest.
   - README frontmatter: `sdk: gradio`, `sdk_version` a real 5.x (e.g. `5.50.0`), `app_file: app.py`, `startup_duration_timeout: 1h` for large models.
4. **Content-policy gate (always-on).** If the model/LoRA is adult/NSFW (name, trigger word, or no safety filtering), flag it to the user BEFORE pushing and require an explicit decision: PRIVATE + Sensitive-Content marking (recommended), PUBLIC as-is (user accepts HF may block/suspend), or local-only. Always add a content-warning section to the README. Do not silently publish an unmoderated adult-generation Space.
5. **Gated base model.** FLUX.1-dev is gated. The Space's runtime token inherits the creator's accepted licenses — confirm the pushing account accepted the base-model license (https://huggingface.co/black-forest-labs/FLUX.1-dev) or the download fails at build.
6. **Namespace must be pushable.** `hf auth whoami` shows `user=` and `orgs=`. The Space repo must sit under one of those. If the user names the model's own repo owner (a different account), creation is refused — ask for a namespace they control.
7. **Create the Space.** `hf repos create <ns>/<name> --type space --space-sdk gradio --flavor zero-a10g --public` (or `--private`). `--flavor zero-a10g` = ZeroGPU (large, 48 GB). On a free account, omitting `--flavor` defaults to `cpu-basic`, which is also gated — always pass `--flavor zero-a10g`.
8. **Push.** `hf upload <ns>/<name> . --repo-type space --exclude "**/__pycache__/**"`. `--repo-type space` is REQUIRED — without it `hf upload` silently creates a *model* repo of the same name.
9. **Verify — don't trust RUNNING.** `hf spaces info <ns>/<name> --expand runtime`; `hf spaces logs <ns>/<name> --tail 200` for a clean boot (no "falling back to CPU" / dtype downgrade); smoke-test with `gradio_client.Client(..., token=os.environ["HF_TOKEN"])`, `c.view_api()`, then `c.predict(...)`, and sniff the returned file header (`\x89PNG`).

## Pitfalls (generalizable)
- `import spaces` after torch/diffusers → ZeroGPU's CUDA patch is missed; it must be the first import.
- README `hardware:` frontmatter is silently IGNORED — hardware is set only via `--flavor` at create or `hf spaces settings <id> --hardware`.
- `hf upload` defaults to `--repo-type model`; forgetting `--repo-type space` creates the wrong repo type and hides the app.
- ZeroGPU rejects `torch` pinned outside {2.8.0, 2.9.1, 2.10.0, 2.11.0} — leave it unpinned.
- FLUX.1-dev is gated — the Space download fails unless the pushing account accepted its license.
- Don't request a HF token before running `hf auth whoami`; a valid session may already exist.
- Adult/NSFW LoRA pushed public and unmoderated violates HF Content Policy — flag it, require a decision, and mark Sensitive Content.
- FLUX.1-dev bf16 is ~24 GB; it fits ZeroGPU large (48 GB) but the download + compile needs `startup_duration_timeout: 1h`.

## Support files
- `templates/app.py` — known-good Gradio + ZeroGPU FLUX-LoRA demo app.
- `templates/README.md` — Space README frontmatter + content-warning template.
- `references/flux-zero-gpu.md` — FLUX LoRA on ZeroGPU: sizing, duration, dtype, sample params, gated-license notes.
