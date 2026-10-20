---
name: grok-build
description: "Use when installing or running xAI Grok Build CLI (grok)."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [Coding-Agent, Grok, xAI, Headless, ACP, CLI]
    related_skills: [claude-code, codex, opencode, hermes-agent, hermes-config-persistence]
---

# Grok Build CLI (xAI)

xAI coding agent CLI (`grok` / alias `agent`). Full-screen TUI, headless scripting (`-p`), and ACP (`grok agent stdio`). Separate from Hermes `xai-oauth` provider auth.

## When to use

- Install / update / version-check Grok Build
- Login / fix "Not signed in" / expired OIDC
- Headless one-shots, CI, JSON/streaming output
- ACP embedding (`agent stdio`)
- Delegate coding work to Grok like Codex/Claude Code

## Install / update (macOS / Linux)

```bash
curl -fsSL https://x.ai/cli/install.sh | bash
hash -r
grok --version
```

Windows PowerShell: `irm https://x.ai/cli/install.ps1 | iex`

Alt (no curl host): `npm install -g @xai-official/grok` (enterprise/docs note)

### Layout after install

| Path | Role |
|------|------|
| `~/.local/bin/grok` | Symlink on PATH |
| `~/.grok/bin/grok` | Managed binary link |
| `~/.grok/downloads/grok-macos-aarch64` | Actual binary (macOS arm64) |
| `~/.grok/config.toml` | CLI/UI/memory config |
| `~/.grok/auth.json` | OIDC / session creds (mode 600) |
| `~/.grok/sessions` | Headless + TUI sessions |
| `~/.grok/AGENTS.md` | Global agent rules (if present) |
| `~/.grok/skills/`, `plugins/`, `memory/` | Skills / plugins / memory |

Installer may rewrite PATH in `~/.zshrc` (`~/.grok/bin`).

## Auth (do first if headless fails)

```bash
# Browser OAuth (local Mac)
grok login --oauth

# Headless / remote / no browser steal
grok login --device-code   # alias: --device-auth
# → print URL + user_code; wait until "Signed in as …"

# API key path
export XAI_API_KEY=...
```

### Auth pitfall (live-verified)

- Stale OIDC refresh token → IdP `invalid_grant` / "Invalid or unknown refresh token"
- CLI treats as **permanent failure**, **deletes** `~/.grok/auth.json` (log: `cleared credentials after permanent refresh failure`)
- Symptom: `Not signed in` right after an update that still saw an old `auth.json`
- Fix: re-run `grok login --device-code` (or `--oauth`), do **not** restore a dead backup token
- Logs: `~/.grok/logs/unified.jsonl` (`oidc try_refresh_pure`, `auth.permanent_failure`)

Hermes `~/.hermes/auth.json` / `xai-oauth` ≠ Grok Build `~/.grok/auth.json`. Do not copy tokens across.

## Headless (preferred for Hermes orchestration)

```bash
grok -p "Your prompt here"
grok --no-auto-update -p "..." --output-format plain
grok -p "..." --output-format json
grok -p "..." --output-format streaming-json
grok -p "..." -m <MODEL> --always-approve --cwd /path/to/project
grok -c                    # continue most recent session in cwd
grok -r <SESSION_ID>       # resume named/id session
grok -s <ID> -p "..."      # create/resume named headless session
```

| Flag | Effect |
|------|--------|
| `-p, --single <PROMPT>` | One prompt, print, exit |
| `-m, --model <MODEL>` | Model ID |
| `-s, --session-id <ID>` | Named headless session |
| `-r, --resume [<ID>]` | Resume session |
| `-c, --continue` | Most recent session for cwd |
| `--cwd <PATH>` | Working directory |
| `--output-format` | `plain` \| `json` \| `streaming-json` |
| `--always-approve` | Auto-approve tools |
| `--no-alt-screen` | Inline, no fullscreen TUI |
| `--no-auto-update` | Skip background update checks (scripts/CI) |
| `--permission-mode` | `default`, `acceptEdits`, `auto`, `dontAsk`, `bypassPermissions`, `plan` |
| `--best-of-n <N>` | Parallel variants (headless) |
| `--check` | Append self-verification loop (headless) |
| `-w, --worktree` | Session in new git worktree |

Persist no-auto-update: `[cli] auto_update = false` in `~/.grok/config.toml`.

Headless sessions live under `~/.grok/sessions`.

## ACP

```bash
grok agent stdio
```

JSON-RPC on stdin/stdout. Auth via local login or `XAI_API_KEY`. Assistant text arrives as `session/update` chunks (`agent_message_chunk`); `session/prompt` returns completion metadata.

Other agent modes: `grok agent headless`, `serve`, `leader`.

See `references/headless-acp.md` for event shapes and a minimal Node client sketch.

## Interactive TUI

```bash
grok
grok --cwd /path/to/project
grok --always-approve
```

Full-screen agent UI. For Hermes automation prefer `-p` over driving the TUI.

## Verify-first install checklist

1. `which grok` / `grok --version`
2. If already installed: run official install script anyway to upgrade
3. `test -f ~/.grok/auth.json` or try headless; on "Not signed in" → device-code login
4. Smoke: `grok --no-auto-update -p "Reply with OK only" --output-format plain`
5. Report: version, binary path, auth account, headless exit 0

## User prefs (this environment)

- DE, kurz, Tabellen — keine Install-Prosa
- Live verify after install (version + one `-p` smoke)
- Dry-run/HITL only for destructive ops; official curl|bash installer is the documented path
- Do not confuse Grok Build CLI with Hermes model provider `xai-oauth`

## Rules

1. Prefer headless `-p` over TUI when orchestrating from Hermes
2. Scripts/CI: always `--no-auto-update`
3. After upgrade, expect possible auth wipe if refresh token was dead → re-login, don't panic-restore
4. Keep Hermes and Grok auth stores separate
5. Set `--cwd` / project context for coding tasks; honor existing `~/.grok/AGENTS.md` and project `.grok/`
