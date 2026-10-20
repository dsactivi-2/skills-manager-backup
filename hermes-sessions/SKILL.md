---
name: hermes-sessions
description: "Use when finding or resuming Hermes sessions by ID."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [hermes, sessions, resume, banner, state.db, cli]
    related_skills: [hermes-config-persistence, hermes-skills]
---

# Hermes sessions — identify & resume

Find the right conversation and continue it. Do **not** confuse install/version markers with session IDs.

## When to use

- User pastes a Hermes banner / terminal dump and asks "which session is this?"
- User asks what `upstream abc123` means
- User wants to resume a past chat (`--resume`, `/resume`)
- Need to map unique dialogue text → session row in `state.db`

## When NOT to use

| Need | Use instead |
|------|-------------|
| Model/provider persist | `hermes-config-persistence` |
| Skills install/browse | `hermes-skills` |
| Profile inventory | `hermes-profile-capability-audit` |

## User preference

- German, direct, one ID + resume command — no lecture
- Live-verify against `hermes sessions list` / `~/.hermes/state.db`, never invent IDs

## Banner anatomy (critical)

Hermes startup UI has **two different identifiers**:

| UI text | Meaning | Example shape |
|---------|---------|----------------|
| `Hermes Agent vX · upstream <sha>` | **Git commit** of the installed Hermes code | `d71033a4` (7–12 hex) |
| `Session: <id>` (left column under model/cwd) | **Session ID** | `20260727_131223_d436e8` |

**Pitfall:** Users treat `upstream <sha>` as the session id. It is not. Never resume with a short git SHA.

Full shapes and paste-matching recipes: `references/banner-and-id-match.md`.

## Resume

```bash
hermes --resume 20260727_131223_d436e8
# or most recent:
hermes --continue
# in-session:
/resume 20260727_131223_d436e8
```

List:

```bash
hermes sessions list
hermes sessions browse   # interactive picker
```

## Match pasted chat → session (agent workflow)

1. Prefer explicit `Session: …` line in the paste → done.
2. Else extract unique user lines (typos OK) and search `messages` in `~/.hermes/state.db` (profile home if not default).
3. Confirm with title + first user messages + message_count.
4. Reply: **ID**, title, open/closed, resume command.

Do **not** derive session id from `upstream` SHA, model name, or skill counts in the banner.

## Profile note

Default DB: `~/.hermes/state.db`.  
Named profile: `~/.hermes/profiles/<name>/state.db` (or that profile's `HERMES_HOME`).

## Pitfalls

- Short hex (`d71033a4`, `4b4d2ae4`) = git, not session
- Banner commit can lag `git rev-parse HEAD` after update mid-session
- Closed sessions (`end_reason` set) still resume via `--resume`
- This chat's own session is a *new* id when the user pastes an *old* transcript — match the paste, not the current session
