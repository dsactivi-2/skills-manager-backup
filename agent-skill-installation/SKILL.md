---
name: agent-skill-installation
description: Use when managing Agent Skills installs or inventory.
---

# Agent Skill Installation

## Procedure

1. If the user supplies an `npx skills` command, run it exactly as supplied unless it is syntactically invalid.
2. Preserve a `--skill <name>` selector. It intentionally narrows installation to one skill; never replace it with a repository-wide installation.
3. For a named package but no command, install the narrowest requested scope:

   ```bash
   npx skills add <owner/repository> --skill <skill-name>
   ```

4. Read the command result, then verify the target installation path or enumerated installed-skill state before reporting completion.
5. When asked which repository skills remain uninstalled, obtain the repository's current skill inventory and compare it against the verified local installation state. List only the difference.

## Scope and reporting

- Do not add `-g` or `-y` unless the user explicitly requests their effects or interactive execution is impossible and the user has authorized installation.
- Report the exact skills installed, and say plainly when none remain uninstalled.
- Keep descriptions short: one practical sentence per skill, focused on when it is useful.
