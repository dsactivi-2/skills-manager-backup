---
name: update-md-files
description: Review and improve existing global, project, or task-scoped Markdown instruction and operations files. Use when the user wants existing Codex guidance, skills, runbooks, evals, or task documents optimized from current evidence—not for ordinary prose edits.
---

# Update MD Files

Improve existing Markdown files only after understanding the selected scope, the real working context, and the rules that already govern the files. The aim is a small, evidence-based patch, not a generic rewrite.

## Start by selecting a category

Ask the user to choose exactly one scope for the current pass:

1. **Global** — personal Codex instructions and user-level skills that apply across projects.
2. **Project** — repository instructions, runbooks, manual evals, decisions, templates, and repository skills.
3. **Session** — documentation for a concrete task or work phase, including task plans and local guidance in the current subtree.

Then discover and show only the existing eligible Markdown files in that scope. Use [references/update-scope-catalog.md](references/update-scope-catalog.md) for the discovery boundary. Do not invent a standard file because it appeared in an old convention, and do not offer files outside the chosen scope.

Do not treat `memory.md`, `projekt.md`, or similar names as automatically
loaded Codex files. Codex Memories are generated local state and are outside
the Markdown update scope unless the user explicitly changes Codex settings.

Ask which listed file or files the user wants updated. If the user has not named a target, do not edit yet.

## Required workflow

1. **Discover without writing.** Read the effective global and project instruction hierarchy, the selected files, and only the relevant local evidence. Preserve unrelated uncommitted changes.
2. **Refresh official evidence once per activation.** Read [references/source-policy.md](references/source-policy.md), then obtain the current sources for this exact use case. Do it once at activation, not once per follow-up question, unless the user asks for a refresh or an important gap remains.
3. **Analyze the real context.**
   - For **global**, inspect the active Codex global instructions and relevant non-Markdown configuration as context (for example profiles, enabled tools, and skill locations). Update only Markdown unless the user explicitly expands the request.
   - For **project**, inspect the repository layout, project `AGENTS.md` hierarchy, existing decisions, runbooks, eval documentation, available commands, and relevant project files that establish the actual stack, workflow, goal, and constraints.
   - For **session**, inspect the current task goal, project documentation, selected old task documents, and any local subtree instructions. Treat old session files as evidence, not as automatically correct policy.
4. **Assess before proposing edits.** Explain what is accurate, obsolete, duplicated, missing, or conflicting. State the evidence for each material recommendation. Do not turn a generic OpenAI pattern into a project rule without a project-specific reason.
5. **Maintain precedence.** Global guidance must not contradict higher-priority system or user constraints. Project guidance must extend rather than duplicate global guidance. Session guidance must not weaken global or project safety, permissions, secret handling, or approval requirements. If a conflict already exists, identify it and stop for the user's decision.
6. **Use existing companion skills.** If the update changes file scope or requires a new file, recommend the applicable existing advisory skill—`create-global-md-files`, `create-project-md-files`, or `create-session-md-files`—when it is available. Do not create a new structure silently in an update pass.
7. **Show a reviewable patch.** Present the exact target paths, concise findings, proposed diff, source-informed rationale, validation plan, and any migration or retention consequence. Get explicit approval before writing.
8. **Apply only approved changes.** Keep edits narrow; retain accurate local conventions. Never overwrite unrelated user changes, remove content, or change a `SKILL.md` invocation policy without explicit approval.
9. **Validate and report.** Check Markdown links and structure, YAML front matter for `SKILL.md`, scope precedence, and relevant project checks. Report successful checks and gaps separately.

## Optimization criteria

- Make instructions actionable, scoped, and testable; remove repetition rather than copying global rules into project files.
- Use facts observed in the selected environment: actual commands, paths, tooling, services, risks, and ownership—not assumptions.
- Keep `AGENTS.md` concise. Put a substantial, conditional workflow in its own skill or in a focused runbook when the existing project structure supports that split.
- For a skill, keep its name and description discriminating, preserve valid front matter, and move conditional detail into linked references only when that reduces unnecessary context.
- For a runbook, retain prerequisites, safe diagnosis, reversible actions, rollback, validation, and escalation boundaries.
- For manual evals, preserve observable input, expected result, and pass/fail evidence. Never label them automated without an executed runner.

## Safety boundaries

- Do not add secrets, credentials, private data, invented commands, or unverified tool integrations.
- Do not run deployments, publish releases, mutate external systems, or change global non-Markdown configuration as an indirect effect of documentation work.
- Do not remove a file merely because it seems stale. Explain the impact and ask for separate explicit deletion approval.
- If current official sources conflict with existing local policy, show the conflict and ask which policy should govern before editing.
