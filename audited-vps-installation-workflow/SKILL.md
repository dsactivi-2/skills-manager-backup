---
name: audited-vps-installation-workflow
description: "Run remote VPS installations through audited phases, guarded SSH recovery, explicit approval gates, and CLI-first bootstrap selection."
trigger: "Use for security-sensitive VPS installation or deployment work requiring documented approval before mutations."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019ec7f8-7ba8-7070-9865-2fc0cbac4eda
  - activi_dsactivi's Organization_default_019ec7f8-39c8-7492-8f28-a60ec6e38f6f
  - activi_dsactivi's Organization_default_019ec7f4-cf83-7373-8dde-79222417d631
  - activi_dsactivi's Organization_default_019ec6d1-fa14-7be2-9a51-8478f5a05f7e
  - activi_dsactivi's Organization_default_019ec6b3-b9ad-7501-84b7-a671a0756d10
  - activi_dsactivi's Organization_default_019ec7e5-6a3c-7092-ad01-eb5293bd0f13
  - activi_dsactivi's Organization_default_019ec7e4-28cd-71f2-a1e6-113b96486206
contributors:
  - activi
  - skillopt
version: 7
created_by_agent: codex
created_at: 2026-06-20T02:26:11.681Z
updated_at: 2026-06-20T02:26:11.681Z
---

# Audited VPS installation workflow

## When to use

Use when installing software on a remote VPS with traceability, secret-safe handling, explicit approval before mutations, and clear separation between local helper tools and the target system.

## Workflow

1. Read project instructions and the append-only report.
2. Confirm target VPS, SSH endpoint, intended software, and permitted local helpers.
3. Review current official primary documentation.
4. Establish trusted SSH access and run a read-only preflight.
5. Select and document the bootstrap interface.
6. Write an install plan with pinned versions, commands, changes, rollback, and verification.
7. Stop for explicit approval before the first mutation.
This approval gate applies only to the first write/mutation step. Do not use it to defer or withhold a concrete command when the user asks for one; for read-only diagnostics or recovery guidance, give the exact command sequence unless a required value is missing.
8. Apply one phase at a time, append results immediately, then run post-install checks.
A response is incomplete while any planned deployment phase remains pending; if a blocker is resolved, continue with the next executable phase instead of ending on the recovery step alone.

Use entries shaped like:

```markdown
### [TIMESTAMP] Phase X - Step Y
- Intent:
- Commands:
  - `...`
- Result:
- Evidence:
- Assessment: `PASS|WARN|FAIL|BLOCKED|SKIPPED|PASS_WITH_GAPS`
- Next action:
```

Prefer scripts with `set -euo pipefail`, timestamps, structured assessments, stop criteria, and no secret output.

## Bootstrap interface selection

When software offers CLI, MCP, SDK, and installer scripts, determine their roles before installation:

- Prefer the product CLI for initial installation, onboarding, status, doctor, and service operations.
- Treat MCP as a runtime integration surface that usually requires an already healthy service.
- Treat SDKs as later automation or extension interfaces, not primary VPS bootstrap tools.
- Do not install a local runtime when the declared target is the VPS; local tools must have a concrete remote-management purpose.
- Pin a version or commit and verify the canonical release artifact and checksum before execution.
- Never run an unverified `curl | sh` installer.
- Run repair or auto-fix commands only after documenting their mutations and receiving approval.

Document the selected interface, rejected alternatives, and rationale in the install plan.

## SSH trust and authentication recovery

Treat host trust and authentication as separate checkpoints.

For a changed host key, record the presented fingerprint and stop. Verify through the provider console or directly on the VPS:

```bash
ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub
```

Only after a match, remove the stale entry with `ssh-keygen -R <host>` and reconnect.

If the error becomes `Permission denied (publickey,password)`, trust is fixed but authentication is not. Compare fingerprints without exposing key contents:

```bash
ssh-keygen -lf /root/.ssh/authorized_keys
ssh-keygen -lf ~/.ssh/*.pub
```

A working key may exist in an external client. If export is authorized, store it with mode `600`, derive its public key, verify the fingerprint, and test it explicitly. Never print or report private-key contents.
## SSH auth recovery obligation

If SSH authentication fails, treat recovery as an intermediate step, not the end of the response. Provide the exact recovery command set for the named key or account, including the file or agent to update, required permissions, and the SSH re-test command. In the same answer, include the next pending deployment-phase command set that will run immediately after the re-test succeeds, unless one single missing value makes that impossible.

After the re-test succeeds, immediately resume the workflow at read-only preflight and continue through the next pending deployment phase; do not treat restored authentication as completion.

If one required input is still missing, ask only for that missing value and keep the rest of the recovery path concrete and executable.
If the user asked for a specific command, return the command directly in the response instead of asking for confirmation, unless the command cannot be formed without that single missing value.

## Status discipline

Distinguish phase completion from the overall objective. State completed and remaining phases, next action, whether installation occurred, and whether mutation approval is pending. Classify user-directed changes as plan-consistent, sensible improvements, or riskier than the plan.

## Anti-patterns

- Installing before discovery, preflight, and a written plan
- Using MCP or an SDK as bootstrap merely because it exists
- Installing an unnecessary local runtime for a VPS-first target
- Running unverified installers or automatic repair commands
- Claiming overall completion when only a phase is complete
- Blindly accepting changed SSH host keys
- Recording passwords, tokens, private keys, or decoded secrets
- Continuing after failed preflight without documenting the blocker
