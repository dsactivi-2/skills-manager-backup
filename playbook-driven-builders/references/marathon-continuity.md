# Marathon continuity (one long Hermes build)

Chat is not the archive. Files are. Use this when the builder work spans many sessions.

## Live project

`/Users/activi/Code/Projects/hermes-meta-builder`

Start every later session with `./scripts/resume.sh` then `./scripts/gate.sh`. Red gate = no writes.

## File set (small, fixed)

| File | Rule |
|---|---|
| `SPEC.md` | Requirements. Version bump + `DECISIONS.md` on change |
| `DECISIONS.md` | Append-only |
| `STATE.md` | Overwrite. ~40 lines. Phase, next, blockers |
| `HANDOFF.md` | Rewrite at **session end**. Done / not / next 3 / evidence |
| `CHECKLIST.md` | DoD. `gate.sh` checks existence, not quality |
| `OPS.md` | Session ritual (see AGENTS.md trap) |
| `playbooks/*.yaml` | Steps + `requires` / `conflicts_with` / `implies` |
| `drafts/` | Only write target until Freigabe |
| `reviews/` | Check against original brief |
| `log/` | Append-only phase reports |

Bootstrap: `git init` + `~/Code/Tools/shared/bin/init-project.sh` + `project_create`.

## AGENTS.md trap (desktop)

Writing repo-root `AGENTS.md` via `write_file` can be **blocked** as a protected agent-instruction file. Timeout ≠ consent. Do not retry via terminal.

Use `OPS.md` as the live ops file. Mention the block in HANDOFF. Only write `AGENTS.md` after the user approves that specific write.

`hermes-profile-soul-agents` still wants project `AGENTS.md` after Freigabe — same trap. Draft as `OPS.md` or `handoff_*/drafts/AGENTS.md` first.

## Conductor

Ask via `clarify`. If the form **times out empty**, stop. Do not invent answers. Repeat the questions in chat.

Memory / Honcho: standing facts only. Never phase status — that is `STATE.md`.

## Related

Overlaps `file-driven-multi-session-supervision` (worker reports) and `project-akte-handoff` (beads/spec-kitty as a store). For this builder marathon the file set above is the Akte. Do not introduce beads unless the user asks.
