---
name: hermes-profile-distributions
description: "Use when packaging a reusable Hermes profile."
version: 1.0.0
---

# Hermes Profile Distributions

Package a reusable Hermes profile as a versioned Git repository. Treat it as a template for a new deployment, never as a copy of an existing machine.

## Procedure

1. **Sanitize before packaging.** Remove credentials, auth files, sessions, memories, logs, databases, cron output, delivery targets, backup reports, hostnames, addresses, account IDs, and deployment-specific paths. Replace secret-bearing config values with `${VAR}` references.
2. **Separate template from secrets.** Commit `config.yaml` and `.env.example`; never commit `.env`. Document every required value in `distribution.yaml` under `env_requires`.
3. **Use the official distribution layout.** Include `distribution.yaml`, `.gitignore`, `SOUL.md`, `config.yaml`, `skills/`, optional `cron/`, optional `mcp.json`, `README.md`, and an explicit bootstrap script.
4. **Keep runtime concepts distinct.** Do not package the Hermes Agent Loop as a custom component: it is part of the Hermes runtime and activates automatically when Hermes processes a request. Add a short architecture document only when it helps maintainers understand the profile.
5. **Write a conservative VPS bootstrap.** Use the official Hermes installer, then `hermes profile install <repo>`. Do not run a blanket operating-system upgrade or invent provider/tool dependencies; install optional dependencies only when the distributed feature requires them.
6. **Gate external publication.** Before creating or pushing a GitHub repository, obtain the exact owner, repository name, and public/private visibility. Default to private for any agent template that may later receive infrastructure or business configuration.
7. **Verify before publishing.** Parse YAML/JSON, confirm `.env` and runtime-state paths are ignored, verify no known secrets or old deployment markers remain, and execute the bootstrap script only in a disposable target environment.

## Required `.gitignore` classes

Ignore at minimum: `.env`, `auth.json`, `memories/`, `sessions/`, `logs/`, `state.db*`, `cron/output/`, cron runtime databases, `backups/`, `checkpoints/`, caches, generated workspace files, and local overrides.

## Pitfalls

- Use `.env.example`, not a placeholder-filled `.env`, because a real `.env` is a secret boundary and must remain ignored even when empty.
- Do not claim a profile is installed, live, or has its Agent Loop enabled merely because its distribution files exist; Hermes must be installed and started with valid environment values.
- Keep cron definitions only when their prompts and delivery configuration are deployment-neutral; runtime history and reports are user data, not distribution content.
- Do not copy all skills into every profile; bundle only the skills required by that profile's role to avoid prompt bloat and tool-role confusion.
- Do not expose MCP tools by default without filtering; select only the tools the profile needs because each extra tool expands the agent prompt and attack surface.
