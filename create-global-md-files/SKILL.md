---
name: create-global-md-files
description: Advise on and safely create or update Codex global, project, and skill instruction files when the user explicitly requests configuration help.
---

# Create Global MD Files

Help the user decide whether to create or update Codex configuration and
instruction files. This skill is advisory first: do not write anything until a
specific diff and validation plan have been approved.

## Scope

Use only for Codex configuration, guidance, and skill files, including:

- global `AGENTS.md` or `AGENTS.override.md` in the active Codex home;
- global `config.toml`;
- project or directory-local `AGENTS.md` or `AGENTS.override.md`;
- a personal or repository `.agents/skills/<name>/SKILL.md` folder.

Codex Memories are optional generated local state, not a manually maintained
`memory.md`. Keep mandatory rules in `AGENTS.md` and project documentation.

Do not use this skill for ordinary project documentation, application source
code, or third-party agent configurations unless the user explicitly includes
them in scope.

## First: understand and inspect

1. Ask what the user wants Codex to do, where the result should apply, and
   whether the user wants advice only, creation, or an update.
2. Inspect only the relevant existing files and their effective hierarchy.
   Do not create, replace, or delete files during discovery.
3. At each activation, perform one fresh source review before recommending a
   design. Follow [the source policy](references/source-policy.md). Keep that
   source snapshot for later questions in this activation; do not repeat broad
   research for every question. If the user changes to an unreviewed file type,
   fetch only the additional source needed for that type.
4. Read [the decision matrix](references/file-decision-matrix.md) for the
   selected file type. Treat it as a routing aid, not as a substitute for the
   fresh source review.

## Recommend before editing

Explain in plain language:

- the recommended file or files and the reason;
- the scope and precedence of each selected file;
- actual dependencies, conflicts, or unnecessary duplication; and
- any missing context needed to create a useful file.

Never invent a dependency. For example, a skill that requires a configured
tool may depend on `config.toml`; an `AGENTS.md` usually does not. Prefer the
smallest set of files that meets the user's goal.

## Write gate

Before any write, present:

1. exact target paths;
2. a concise diff or complete content for new files;
3. validation commands and expected checks;
4. the backup plan for each existing file; and
5. changes that require a separate user decision, such as enabling a tool,
   changing permissions, or adding an MCP server.

Obtain explicit approval after that preview. Approval for one target does not
authorize changes to other files, external services, credentials, or tools.

## Safety and correctness

- Never place API keys, tokens, passwords, private URLs, or decoded secrets in
  these files, previews, backups, or reports.
- Preserve unrelated existing configuration and user changes.
- Do not install plugins, enable remote tools, change permissions, or make
  network/service changes unless the user explicitly asks and approves them.
- Do not overwrite an existing file. Create a dated local backup only when the
  user approved the planned edit and a backup is appropriate.
- Keep rules short, non-duplicative, and scoped to the file's directory.

## Validate and report

After an approved change:

1. validate TOML syntax and the selected configuration fields;
2. validate any new or changed skill with the available skill validator;
3. re-read the target files to confirm the effective result; and
4. report changed paths, backup paths, validation results, source links, and
   any remaining manual step.

If validation cannot run, state the gap and do not claim success.
