---
name: project-session-manager
description: "Use for 'new work tree', 'new worktree', 'isolated workspace', 'psm', 'omc teleport', 'feature branch worktree', or any request to create/switch/cleanup git worktrees per AGENTS.md rules. Never work on main checkout."
---
# Project Session Manager (psm / omc)

**Core Rule (non-negotiable):**  
All changes happen in isolated git worktrees. Never edit the main checkout directly.  
Use `psm` (or `omc`) to teleport into a worktree before any implementation.

## Available Commands (run via terminal)

- `psm list` — show registered projects + active worktrees
- `psm register <alias> [path]` — register a git repo (e.g. `psm register livekit .`)
- `psm teleport <alias> <name>` — create worktree + branch, print cd path
- `psm teleport <name>` — auto-detect project from current dir
- `omc teleport <name>` — same as above (alias for compatibility)
- `psm cleanup <name|path>` — safely remove a worktree after merge/PR
- `psm help` — full usage

Worktrees are created under `~/.psm/worktrees/<alias>/<name>` and tracked by git.

Branch naming: if name has no `/`, it becomes `feature/<name>`.

## When User Says "new work tree"

1. Run `psm list` to show current state.
2. If the user did not specify project + name:
   - Default to the most active project (livekit-telesales-agent) unless context clearly points elsewhere.
   - Ask **one** clarifying question: "Feature / branch name? (e.g. realtime-retry or fix-voice)"
3. Execute: `psm teleport livekit <sanitized-name>`
4. After success, tell the user the exact `cd <path>` command.
5. Remind: "Work only inside this worktree. Main checkout stays clean."
6. If the user is inside a TUI session, suggest opening the new directory with `grok .` or the TUI hotkey `Ctrl+Shift+N` while in the worktree dir.

## Auto-Detection

- If the agent CWD is inside a registered project (or any git repo that matches a registered local path), `psm teleport <name>` works without alias.
- The script updates `~/.psm/projects.json` automatically on register.

## Cleanup Flow (after PR merged)

```bash
psm cleanup <name>
# or
psm cleanup /full/path/to/worktree
```

## Integration with Grok TUI Sessions

- For throw-away / subagent work: prefer the TUI's built-in `Ctrl+Shift+N` (new session in worktree) — it uses the internal `x.ai/git/worktree/*` methods.
- For long-lived feature work: use `psm teleport` + open a new persistent TUI session or terminal in that directory.
- After finishing a worktree-backed session, run `psm cleanup` (or let the TUI gc do it).

## Examples the User Might Type

- "new work tree for voice retry logic"
- "omc teleport realtime-fix"
- "/psm new livekit orchestrator-v2"
- "create isolated workspace for the deployment script changes"

In all cases → invoke the psm CLI, create the worktree, hand the user the path.

**Never** create worktrees manually with raw `git worktree add` unless the psm script fails — always go through `~/.psm/bin/psm`.

## Implementation Notes

- The actual logic lives in `~/.psm/bin/psm` (also symlinked as `omc`, `~/bin/psm`, `~/.grok/bin/psm`).
- Config: `~/.psm/projects.json` (human + machine readable).
- All worktrees are plain git linked worktrees — fully compatible with any tool (git, IDE, TUI).
