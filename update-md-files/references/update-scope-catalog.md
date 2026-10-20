# Update scope catalog

Use this catalog to find candidates. It is a discovery guide, not a list of files that must exist. Show the user the actual existing files before asking which one to update.

## 1. Global

Discover user-level Markdown that governs Codex or reusable personal workflows, such as:

- the effective `~/.codex/AGENTS.override.md` or `~/.codex/AGENTS.md`;
- `SKILL.md` and directly linked references in user-level skills under `~/.agents/skills/`;
- other user-owned Markdown explicitly referenced by the effective global instructions.

Read `~/.codex/config.toml` and profile files only as contextual evidence for tools, profiles, and workflow. They are not Markdown update targets in this skill.
Codex Memories are generated local state, not an eligible `memory.md` target.

## 2. Project

Discover repository Markdown that affects the selected repository:

- root and nested `AGENTS.md` or `AGENTS.override.md` on the target path;
- existing `docs/runbooks/`, `docs/evals/`, `docs/decisions/`, and `docs/templates/` files;
- `SKILL.md` and directly linked references under `.agents/skills/`;
- other project Markdown explicitly referenced by a selected file.

Do not list generated documentation, dependency documentation, vendored files, or every README unless it directly controls the selected workflow.

## 3. Session

Discover only files connected to the active task or current subtree:

- the selected task plan, typically under `docs/plans/` when that convention exists;
- current or prior task-specific manual eval notes under `docs/evals/`;
- a nested `AGENTS.md` or `AGENTS.override.md` in the affected subtree;
- a task-specific temporary note that the project already explicitly references.

State that a local `AGENTS.md` is path-scoped and remains active until removed. A runbook or repository skill is durable project documentation, so switch to the Project category before updating one.
Do not classify a manually named `memory.md` or `projekt.md` as a Codex session
file unless the project already explicitly references it.
