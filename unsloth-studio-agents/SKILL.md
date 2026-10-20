---
name: unsloth-studio-agents
description: "Use when running unsloth start for Hermes or other agents."
version: 1.0.0
---

# Unsloth Studio coding agents

Launch Claude Code, Codex, Hermes, OpenClaw, OpenCode, or Pi against a model served by Unsloth Studio (`unsloth start <agent>`).

Docs: https://unsloth.ai/docs/integrations/unsloth-start and https://unsloth.ai/docs/integrations/hermes-agent

## When to use

- User says `unsloth start hermes` (or claude/codex/openclaw/opencode/pi)
- Point Hermes at the Unsloth Studio server instead of cloud/Ollama

Not this skill: Unsloth LoRA/QLoRA training, llama.cpp CLI, vLLM.

## Gate (do this before launch)

1. Confirm CLI: `unsloth start --help` then `unsloth start hermes --help`.
2. Confirm Studio is up (Unsloth.app and/or `unsloth studio` on 127.0.0.1:8888).
3. Dry-run: `unsloth start hermes --no-launch`
   - Success: prints env + command. Then launch in a **new** terminal/tmux, not inside the current Hermes TUI.
   - Fail `No model is currently resident in Unsloth`: **stop**. Do not guess a model. Do not start a large GGUF download. Ask for a model id / `--gguf-variant`, or tell the user to load one in the Unsloth dropdown.
4. Only then: `unsloth start hermes` (add `--persist` if they need resume).

`--serve` auto-starts a server for `--model` when none is running. `--no-serve` errors instead.

## Do not

- Auto-pick docs defaults like `unsloth/Qwen3.8-27B-GGUF:UD-Q4_K_XL` without confirmation (big download, RAM).
- Load unrelated local GGUFs (LM Studio roleplay, embeddings, Whisper) as the Hermes backend.
- Run the interactive agent TUI in the parent Hermes session (blocks / nests). Use tmux or a new Tabby/Terminal window.
- Print Unsloth API keys, desktop tokens, or bootstrap passwords.

## Flags that matter

| Flag | Role |
|------|------|
| `--no-launch` | Print env/command only |
| `--model` / `-m` | HF id or path if nothing is loaded |
| `--gguf-variant` | e.g. UD-Q4_K_XL; default UD-Q4_K_XL for unsloth/* GGUF |
| `--persist` | Keep Unsloth-managed Hermes home (default is throwaway) |
| `--yolo` | Auto-approve agent tools for this session |

See `references/start-prereqs.md`.
