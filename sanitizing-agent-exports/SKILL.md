---
name: sanitizing-agent-exports
description: "Use when sanitizing Hermes exports. Remove secrets safely."
---

# Sanitizing Agent Exports

Prepare an agent configuration directory for a different server without carrying credentials, infrastructure identity, runtime history, or previous operator context.

## Procedure

1. **Inventory before editing.** Identify configuration, `.env` files, plugins, skills, cron definitions, output directories, databases, telemetry, locks, and hidden files. Treat logs, SQLite/WAL files, job-output folders, token telemetry, and delivery records as potentially sensitive.
2. **Separate template from runtime state.** Keep only reusable configuration and explicitly requested job definitions. Remove cron execution history, report output, runtime databases, usage telemetry, tickers, locks, and stale backup reminders. A scheduled job definition is configuration; its prior runs are history.
3. **Replace secrets, not just redact them.** Move every API key, token, webhook secret, recipient identifier, provider URL, and deployment-specific endpoint into named environment variables. Write a private `.env` template containing placeholders such as `CHANGE_ME`; config values refer to `${VARIABLE}`.
4. **Neutralize deployment identity.** Remove server names, addresses, user IDs, account IDs, backup locations, private paths, delivery targets, old incident narratives, and infrastructure-specific commands from skills, prompts, SOUL files, and cron definitions. Preserve only reusable procedures.
5. **Make risky defaults safe.** Disable public webhooks and external delivery targets unless the new deployment explicitly needs them. Bind local APIs to a configurable hostname rather than inheriting a public bind.
6. **Verify the result.** Parse YAML and JSON, assert that deleted runtime paths do not exist, search retained text for known former deployment markers and common credential prefixes, and confirm every configured secret reference has a corresponding placeholder in `.env`.
7. **Explain the boundary.** State precisely which schedules remain, which runtime artifacts were removed, and that historical job IDs found only in output/databases are remnants rather than active configuration.

## Pitfalls

- Remove SQLite sidecars (`-wal` and `-shm`) together with a SQLite history database; they can retain the same records after the main file is gone.
- Do not preserve a backup-check job merely because it is a cron setting when the user asked to remove backup reminders; a schedule is still an inherited operational policy.
- Do not create a backup inside the export before sanitizing it; that simply preserves the secrets and history being removed.
- Do not claim a full sanitization if a protected instruction file could not be changed; report the exact remaining file and request the required approval.
- Do not copy realistic old values into `.env` examples; placeholders prevent accidental redeployment against the former environment.
