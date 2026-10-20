---
name: create-project-md-files
description: Advise on and safely create or update project instruction, runbook, decision, evaluation, and repository-skill Markdown files when explicitly requested.
---

# Create Project MD Files

Help create only the project documentation files that solve the user's stated
need. This skill is advisory first and must preserve the effective global Codex
configuration rather than contradicting or duplicating it.

## Scope

Use for these nine project document types:

1. root or nested `AGENTS.md`;
2. root or nested `AGENTS.override.md`;
3. `docs/runbooks/README.md`;
4. a concrete `docs/runbooks/<topic>.md`;
5. a concrete `docs/decisions/<topic>.md`;
6. `docs/evals/README.md`;
7. a manual `docs/evals/<case>.md` regression test;
8. `.agents/skills/<name>/SKILL.md`; and
9. a service-local `services/<service>/AGENTS.md`.

Do not create all nine by default. Do not use this skill for ordinary source
code, global configuration, or a one-time task that needs no durable file.
`memory.md`, `projekt.md`, and similar names are not automatically loaded by
Codex; use them only when an existing project convention explicitly references
them.

## Per activation: discover and ground

1. Ask what the user wants Codex or the project to achieve, where it applies,
   and whether the user wants advice, a new file, or an update.
2. Read the effective global guidance and only the relevant project files.
   Explain any existing higher-level rule that limits the proposed change.
3. Before making a recommendation, obtain one fresh source snapshot according
   to [the source policy](references/source-policy.md). Keep it for the whole
   activation; do not repeat broad research for every follow-up question.
4. Read [the decision matrix](references/project-file-decision-matrix.md) for
   the selected document type.

## Recommendations and dependencies

Explain in plain language which file is recommended, why, its scope, and any
conflict with effective global or project guidance. State only real
dependencies:

- a local service `AGENTS.md` normally builds on the root `AGENTS.md`;
- a concrete runbook should follow the project runbook convention when one
  exists;
- a manual regression case should follow `docs/evals/README.md` when present;
- a project skill belongs in `.agents/skills` and any tool it needs must already
  be configured or separately approved.

These are recommendations, not invented hard dependencies. A new project may
create one small file without first creating every related file.

## Write gate

Before writing, show exact paths, the proposed diff or full new content, any
global/project rule it follows, the validation plan, and a backup plan for each
existing file. Ask for explicit approval after the preview.

Approval for one file does not authorize edits to global files, credentials,
tools, plugins, permissions, services, or unrelated project files.

## Safety and quality

- Preserve global and existing local rules; do not copy them into a narrower
  file unless the user needs a specific local clarification.
- Never write secrets, tokens, passwords, or private URLs to instructions,
  skills, runbooks, tests, previews, backups, or reports.
- Keep `AGENTS.md` files short and directory-scoped.
- Treat `docs/evals` as manual regression evidence; do not claim it runs
  automatically.
- Do not publish, deploy, install, enable, or configure external tools without
  explicit user authorization.

## Validate and report

After approved edits, re-read the changed files, validate any changed project
skill with the available skill validator, and run the smallest relevant project
check. Report changed paths, validation results, sources consulted, and gaps.
