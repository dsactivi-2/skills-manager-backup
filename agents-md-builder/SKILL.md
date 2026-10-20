---
name: agents-md-builder
description: Design or review the scope and ownership of durable coding-agent instructions. Use before changing global, repository, or nested AGENTS.md guidance when the right location or mechanism is unclear.
---

# AGENTS.md Scope Builder

Use this skill to decide where a durable instruction belongs before writing it. It is a scope and governance skill; use `agents-md` or `agents-md-toolkit` when the work also needs a finished instruction file.

## Decide the owner

Classify each requested rule independently:

- Conversation: one-off task constraints.
- Global `~/.codex/AGENTS.md`: personal defaults across repositories.
- Repository `AGENTS.md`: durable, team-owned codebase rules.
- Nested `AGENTS.md` or `AGENTS.override.md`: subtree-specific rules only.
- Skill: reusable procedure that deserves progressive loading.
- Config or hook: mechanically enforceable behavior.
- MCP or connector: live external data or actions.
- Automation: scheduled work.

If the request mixes scopes, split the output instead of forcing everything into one file.

## Inspect before proposing a change

1. Find the applicable global, repository, and nested instruction files; closest applicable guidance wins.
2. Inspect project configuration only when the request involves Codex settings, hooks, MCPs, sandboxing, approvals, models, or fallback filenames.
3. Identify whether the requested behavior is better enforced by a test, linter, script, hook, or configuration.
4. Preserve unrelated user-authored rules.

Ask for authorization before writing outside the current workspace. Do not add an instruction merely because it is a generally good practice.

## Quality bar

Prefer concrete, durable rules:

- exact build, test, lint, and verification commands
- repo-specific conventions
- review expectations
- safety rules for secrets, production systems, destructive actions, and approvals
- routing hints that materially reduce discovery cost

Avoid:

- long tutorials
- generic software advice
- duplicated documentation
- secrets, tokens, passwords, decoded credentials, or private keys
- huge pasted references that belong in docs or a skill
- rules that a linter, test, hook, or script can enforce

Before completing, confirm the chosen location, that the content contains no secrets, and that commands and paths are backed by the target repository. Explain any global-behavior change that requires a new Codex task to take effect.
