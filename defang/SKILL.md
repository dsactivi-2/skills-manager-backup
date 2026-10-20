---
name: defang
description: "Use when installing or running Defang CLI or samples."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [macos, linux]
metadata:
  hermes:
    tags: [defang, compose, orbstack, mcp]
    related_skills: [orbstack-compose-port, verify-first-workflow]
---

# Defang CLI and samples

Use when the user wants Defang installed, a sample generated (`defang new` / `generate`), MCP wired into an editor, or a sample started. Default for this user: **local OrbStack first**, Playground/cloud only after explicit Freigabe.

## What the words mean (keep explanations this simple)

| Command | Plain language |
|---|---|
| `defang new SAMPLE` / `defang init` | Copy a ready-made example onto disk. Not a deploy. |
| `defang generate` | Same idea; may prompt for a folder. Typo `ndoejs-http` is wrong; sample ids are exact (`nodejs-http`, `agentic-strands`). |
| `docker compose … up` | Run on this Mac (OrbStack). |
| `defang compose up` | Upload to Defang Playground. Needs `defang login`. |
| `defang mcp setup --client=…` | Write a plug so that editor's AI can call Defang. Hermes is **not** a `--client`. |

## Install (macOS Homebrew)

1. Live-check: `which defang; defang --version`.
2. Prefer `brew install DefangLabs/defang/defang`.
3. If the formula build fails with `go.mod requires go >= 1.25` while the formula still `depends_on "go@1.24"`: upgrade `brew upgrade go`, then locally change the tap formula `/opt/homebrew/Library/Taps/defanglabs/homebrew-defang/Formula/defang.rb` to `depends_on "go" => :build`, then `brew install` / `brew reinstall`. `brew update` can revert the tap — re-patch if it breaks again.
4. Fallback: official script `s.defang.io/install` or GitHub release zip + checksums. Put the binary in a PATH dir.
5. `~/.local/bin` is **before** `/opt/homebrew/bin` on this machine. A leftover `~/.local/bin/defang` shadows Homebrew. Remove the shadow after a brew install.

Do not treat a binary-only install as "Homebrew is fixed".

## Generate a sample

```
cd ~/Code/Projects
defang new <sample-id> -p <sample-id>
```

Do not start or `compose up` to the cloud unless asked. After create, explain **from the repo files** what the app can and cannot do (table). Marketing README is not enough.

## Local OrbStack run

Follow `orbstack-compose-port`. Extra Defang-sample rules:

- Add `compose.orbstack.yaml` (do not fight port 3000 / host 80 / the `llm` gateway).
- Point `LLM_URL` at `http://host.docker.internal:11434/v1/` and a **local** Ollama model (not `:cloud` unless asked).
- Disable the `defangio/openai-access-gateway` service with a Compose profile; override `depends_on` to `[]`.
- Set `COMPOSE_BAKE=0` and `DOCKER_HOST=unix://$HOME/.orbstack/run/docker.sock` plus `docker --context=orbstack`.
- Smoke-test the Dockerfile base image (`uname -m`). Debian `node:*-slim` / `*-bookworm-slim` have failed with `exec format error` here; `node:*-alpine` and `python:3.11-slim` have worked.
- Do not bind-mount `./app:/app` over an image that already ran `npm install` unless you also keep `node_modules` (named volume). The official `compose.dev.yaml` mount hides image deps.
- Optional cloud tools (Tavily etc.) must not crash startup when the key is unset.

Details and a compose stub: `references/orbstack-local.md`.

## MCP

```
defang mcp setup --client=cursor   # also: vscode, claude-code, codex, …
```

Dry-run first. Do **not** run `--client=codex` unless asked — Codex MCP is source of truth for other servers. Hermes is not in Defang's client list; do not invent a Hermes flag.

## Verify

| Check | Command |
|---|---|
| CLI | `defang --version` and `which -a defang` (first hit is the one that runs) |
| Local app | `docker --context=orbstack ps` + HTTP to the published port + one real POST if the app has chat |
| Login | `defang whoami` before any Playground claim |

## Pitfalls

- `defang new` ≠ deploy. Say so.
- Sample IDs are slugs from docs.defang.io/samples, not free text.
- Do not kill unrelated OrbStack containers on a busy port — remap.
