# Desktop + conductor (2026-08-24)

## Protected filenames

`write_file` can block any `SOUL.md` or `AGENTS.md` (repo root and `drafts/…`). Timeout ≠ consent. Do not retry via terminal.

Use `SOUL.draft.md`, `OPS.draft.md`, repo `OPS.md`. Point playbook `outputs.path` at the files that actually exist.

## Conductor / clarify

User wants the picker UI (`clarify`), recommended choice first.

- Empty timeout → re-offer the **same** form. Backup: one-line `1 bauen, 2 drafts, 3 chat, 4 nachfragen, 5 helfer`. Never invent answers.
- “Ich war fast fertig” → do not abort the form for a markdown table.
- “Auswahlfunktion” → `clarify`, not type-in tables.

## Graph

Run `python3 scripts/check_graph.py`. `kanban` ≠ `job=run_team`; it means worker drafts + `PROFILE.yaml` description (Kanban routes on that line). Wizard lists only existing `playbooks/*.yaml`.
