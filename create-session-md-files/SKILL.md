---
name: create-session-md-files
description: Advise on and, after approval, create task- or work-phase Markdown files that remain consistent with effective global and project instructions. Use explicitly for task plans, manual agent regression cases, temporary local guidance, runbooks, or a reusable project skill.
---

# Create Session MD Files

Create only the smallest useful set of Markdown files for one concrete task or work phase. This is an advisory workflow first: it explains scope, dependencies, and conflicts before it writes anything.

## Scope and important correction

There is no Markdown file that Codex automatically treats as "session-scoped" merely because of its name. Scope comes from the file's directory and from the time the user keeps it.

- `docs/plans/<task>.md` is normally temporary task documentation.
- `docs/evals/<case>.md` is a durable, manual regression case, not an executable Codex eval.
- A nested `AGENTS.md` or `AGENTS.override.md` is local to its directory subtree, not automatically temporary. It remains active until removed.
- A runbook and a repository skill are durable project assets. Do not create them just because the current task happens to need one.
- Do not invent `prompts.md`, `memory.md`, or `context.md` as automatically loaded Codex configuration. Use them only when the project already has an explicit convention.
- Codex Memories, when enabled, are generated local chat context controlled by
  Codex; they are not a session `memory.md` to create or maintain.

## Required workflow

1. **Understand the task.** Ask what outcome is needed, which task or work phase it supports, who will use it, whether it should persist after the task, and the intended target folder. If a file is already named, still confirm its purpose.
2. **Read the effective instruction hierarchy.** Read the applicable global `AGENTS.md` or `AGENTS.override.md`, then every applicable project `AGENTS.md` and `AGENTS.override.md` from repository root to the target directory. Read relevant project documentation such as `docs/evals/README.md`, `docs/runbooks/README.md`, and `docs/templates/` when they exist. Do not modify these files during discovery.
3. **Refresh official guidance once per activation.** Follow [references/source-policy.md](references/source-policy.md) before making recommendations. Refresh it once now; do not repeat the research for every follow-up question in the same activation unless the user asks for a refresh or the source evidence is insufficient.
4. **Classify the request.** Use [references/session-file-decision-matrix.md](references/session-file-decision-matrix.md). Say explicitly if no file is necessary or if a durable project file is the better home.
5. **Explain recommendation and dependencies.** Present the recommended order, the reason, any prerequisite files or project conventions, the scope and retention of each selected file, and conflicts with existing global or project instructions. Never use a local file to weaken safety, approval, secret-handling, or higher-priority instructions.
6. **Let the user choose.** Ask which recommended files to create or update. Do not treat a recommendation as approval.
7. **Show a preview.** Before a write, show the exact target paths, a concise change summary or diff, validation steps, and—when applicable—a retention or cleanup recommendation. Obtain explicit approval.
8. **Create or update only approved files.** Preserve unrelated user changes. Do not overwrite existing instructions without presenting a diff and receiving approval. Do not delete a temporary local instruction file as part of this skill unless the user separately approves deletion.
9. **Validate.** Check Markdown structure, links, target paths, YAML front matter for a new `SKILL.md`, and consistency with the effective instruction hierarchy. Run relevant project checks when available.
10. **Report concisely.** State created or changed paths, validations performed and their results, remaining manual steps, and any retention/cleanup decision.

## Decision rules

- Prefer a task plan when the work has several steps, a handoff, or decisions worth recording. For a simple one-step task, recommend no plan file.
- Add a manual eval case only when changing an agent, prompt, skill, instruction set, or tool behavior. Keep expected results observable and stable.
- Recommend a nested `AGENTS.md` only for enduring rules specific to a service or subtree. For a one-off task, prefer a plan instead.
- Recommend `AGENTS.override.md` only for a narrow, temporary exception that cannot be expressed in the normal local `AGENTS.md`. It cannot contradict higher-priority safety constraints. Ask for an expiry or removal plan.
- Recommend a runbook only for a repeatable operational task, incident, deployment, or recovery path. It belongs in `docs/runbooks/` and is durable.
- Recommend a repository skill only for a repeatable workflow with clear triggers. Store it under `.agents/skills/<skill-name>/SKILL.md`; it is durable and must not be presented as a session-only file.

## Boundaries

- Never put secrets, tokens, private keys, or real production data in a plan, eval, instruction file, or runbook.
- Never deploy, publish, tag, alter production, or contact external services merely because a task document describes it.
- Never claim that an evaluation is automated unless the project has a configured runner and it was actually executed.
- When current official guidance conflicts with existing local instructions, identify the conflict and ask the user which policy should change. Do not silently rewrite either one.
- Keep current official findings separate from project-specific rules. The latter remain authoritative in their own scope unless the user changes them.
