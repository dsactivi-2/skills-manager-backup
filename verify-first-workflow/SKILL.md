---
name: verify-first-workflow
description: "Enforce live verification on the actual running system and Dry-Run before any mutating/destructive action. Used when the user wants proof from the live stack rather than memory or documentation."
version: 1.0.0
---

# Verify-First Workflow

## Core Principle
Never claim something is true based on memory, previous sessions, or documentation. Always verify **live on the current stack**.

## When to Apply
- User asks to "verifiziere live am stack"
- User expresses doubt about current state ("ich glaube nicht", "alte code")
- Any claim about running services, installed packages, or configuration

## Mandatory Steps
1. **Dry-Run first** for any potentially destructive command (delete, overwrite, reinstall, kill processes that might affect other work).
2. Execute the verification command and show real output.
3. Only after live confirmation, proceed with changes.

## Pitfalls to Avoid
- Do not say "it should be X" or "from memory...".
- Do not rely on previous tool results if the user has restarted processes or changed state since then.
- Always re-verify when the user signals uncertainty.

## Examples of Good Verification Commands
- `which <tool>` + version check
- `lsof -i :<port>` to confirm listening processes
- `ps aux | grep ...` for running processes
- Direct import + execution test for code changes

This workflow takes precedence over speed when the user explicitly asks for live verification.
