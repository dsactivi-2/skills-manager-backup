# File Decision Matrix

Verify the current Codex documentation before relying on this matrix.

| Need | Recommended file | Ask before recommending | Typical dependency or warning |
| --- | --- | --- | --- |
| Stable personal working preferences | Codex-home `AGENTS.md` | Does it belong in every project? | Keep project-specific build commands out. |
| Useful recall from previous Codex chats | Codex Memories, configured and controlled by Codex | Is generated local recall appropriate for this user and chat? | Do not create or manually rely on `memory.md`; mandatory rules stay in `AGENTS.md`. |
| Temporary, stronger global exception | Codex-home `AGENTS.override.md` | Is the exception truly temporary and broader than one project? | It can replace the global `AGENTS.md` at the same level. |
| Codex behavior, profiles, tools, or MCP setup | Codex-home `config.toml` | What capability is needed and what are its side effects? | Do not place secrets here; tool changes may need separate approval. |
| Rules for one repository | `<project>/AGENTS.md` | What is unique to this repository? | It should complement, not repeat, global guidance. |
| Rules for one subdirectory or service | `<project>/<path>/AGENTS.md` | Does this folder really need different commands or constraints? | Its scope is limited to work under that path. |
| Temporary, stronger local exception | `<path>/AGENTS.override.md` | Can the rule be a normal local rule instead? | It takes precedence at its directory level. |
| Reusable personal Codex workflow | `<user home>/.agents/skills/<name>/SKILL.md` | What repeats often enough to justify a skill? Which tools are required? | Required tools/configuration must already exist or be separately approved. |
| Reusable repository workflow | `<project>/.agents/skills/<name>/SKILL.md` | Which repository or subdirectory needs it? | Its discovery scope is the repository path, not every project. |

## Decision rules

1. Recommend no file when a normal user request or one-time plan is enough.
2. Use global files only for stable preferences or Codex-wide configuration.
3. Use project files for repository facts, commands, and local constraints.
4. Create a skill only for a reusable, scoped workflow with a clear outcome.
5. If files would repeat the same rule, keep it at the narrowest appropriate
   level and reference the higher-level rule only when necessary.
