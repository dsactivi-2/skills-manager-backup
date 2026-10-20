---
name: playbook-conductors
description: "Use when playbook builds need choices and drafts."
version: 1.0.0
---

# Playbook conductors

Use when the user wants a wizard/MCP/skill that walks choices, builds Hermes agents/skills/profiles, or runs a multi-session construction marathon.

## User bar (this host)

- German, tables, terms in one plain sentence first.
- Multi-choice = `clarify` form. Do not replace an open form with a chat list. If the form times out, re-offer the form — they may have been mid-answer.
- Long work: files are source of truth, not the chat.
- Tools must think: `conflicts_with` / `requires` / `implies`. No yes/no trees that apply option 1+3 blindly.
- Write drafts only until explicit Freigabe. Never `~/.hermes/profiles/` without backup + yes.

## File SoT (marathon)

One project folder (example: `~/Code/Projects/hermes-meta-builder`):

| File | Rule |
|---|---|
| `SPEC.md` | rare, versioned |
| `DECISIONS.md` | append-only |
| `STATE.md` | overwrite, short |
| `HANDOFF.md` | rewrite at session end |
| `CHECKLIST.md` | DoD |
| `playbooks/*.yaml` | steps + graph |
| `drafts/` | apply output |
| `reviews/` | PASS / FAIL / gaps |
| `scripts/resume.sh` `gate.sh` | start / write-gate |

Session start: resume → SPEC + HANDOFF → gate. Do not reload the whole chat.

Repo-root `AGENTS.md` may be blocked; use `OPS.md`.

## Playbook shape

Each option: `id`, `label`, `implies`, `conflicts_with`, `requires`.
After every answer: evaluate the graph. Reject pairs stop. Warns get a written resolution in `DECISIONS.md` — never swallow.

**Job vs how:** `kanban` is an execution model. It needs worker drafts, not that the primary job is `run_team`. Do not reject "bauen + Board".

## Apply

1. Signed plan JSON under `drafts/`.
2. Review checklist against the same SPEC version.
3. Apply writes only `drafts/`.
4. Desktop may block `SOUL.md` / `AGENTS.md` even under `drafts/`. Use `SOUL.draft.md` / `OPS.draft.md`. Do not retry the blocked names.

## Surfaces

Chat, wizard menu, MCP are doors to the same playbook. MCP has no brain — the agent + graph do. Scripts apply a signed plan only.

## Do not

- Abort clarify while the user is selecting.
- Invent unanswered choices.
- Install live profiles as a shortcut.
- Put phase status in Memory/Honcho.

## Pointers

- Worked tree: `~/Code/Projects/hermes-meta-builder`
- SOUL quality: `hermes-profile-soul-agents` (user-owned — adopt before patching)
- Supervision reports: `file-driven-multi-session-supervision` (user-owned)
