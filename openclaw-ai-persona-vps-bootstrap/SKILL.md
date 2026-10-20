---
name: openclaw-ai-persona-vps-bootstrap
description: "Bootstrap OpenClaw plus AI Persona OS on a dedicated Hetzner/VPS host with CLI-first setup, MCP/SDK deferral, append-only reporting, and approval gates."
trigger: "Use when installing or auditing OpenClaw + AI Persona OS on a remote VPS rather than as a local runtime."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019ec808-4e4e-7093-aeb9-27e2e7bded9a
  - activi_dsactivi's Organization_default_019ec7f8-39c8-7492-8f28-a60ec6e38f6f
  - activi_dsactivi's Organization_default_019ec7f4-cf83-7373-8dde-79222417d631
  - activi_dsactivi's Organization_default_019ec6d1-fa14-7be2-9a51-8478f5a05f7e
  - activi_dsactivi's Organization_default_019ec6b3-b9ad-7501-84b7-a671a0756d10
  - activi_dsactivi's Organization_default_019ec7e5-6a3c-7092-ad01-eb5293bd0f13
  - activi_dsactivi's Organization_default_019ec7e4-28cd-71f2-a1e6-113b96486206
contributors:
  - activi
version: 1
created_by_agent: codex
created_at: 2026-06-15T01:19:22.581Z
updated_at: 2026-06-15T01:19:22.581Z
---

# OpenClaw AI Persona OS VPS bootstrap

## When to use

Use when installing or auditing OpenClaw plus AI Persona OS on a dedicated Hetzner or other VPS host. This is not for setting up a local OpenClaw runtime, except for local helper tools used only for SSH, documentation review, or remote management.

## Required context

Read first:

- `/Users/activi/Documents/Agent OS Systeme/AGENTS.md` when present
- `/Users/activi/.codex/RTK.md`
- `/Users/activi/Documents/Agent OS Systeme/reports/openclaw-ai-persona-os-install-report.md`

Append to the report; never overwrite prior history. Use current official primary sources for OpenClaw install, CLI, MCP, SDK, security docs, the OpenClaw upstream repository, ClawHub AI Persona OS, and upstream-readable AI Persona OS files.

## Interface roles

- Use the OpenClaw CLI as the primary VPS install, onboarding, health-check, and operations surface. Expected checks include `openclaw gateway status` and `openclaw doctor`; setup may include `openclaw onboard` when official docs require it.
- Do not treat MCP as bootstrap. `openclaw mcp serve` and `openclaw mcp list|show|set|unset` are for connecting MCP clients or managing MCP definitions after an OpenClaw gateway exists.
- Treat `@openclaw/sdk` and plugin SDKs as later automation or extension surfaces, not first-install tooling.
- Install a local CLI only when it has a concrete remote-management purpose. The end state is OpenClaw on the VPS, not a local runtime.

## Workflow

1. Record the target as a Hetzner/VPS system and distinguish local helper tools from VPS-side installation.
2. Collect SSH host/IP, user, port, and auth method. Accept a local key path or SSH alias, not private-key contents. Verify with `ssh -o BatchMode=yes <alias> 'hostname && id'`.
3. Run read-only VPS preflight before any mutation: OS/kernel, CPU/RAM/disk, Node/npm, listening ports, firewall, systemd, existing OpenClaw files/services, backups, and current security posture.
4. Write an install plan with pinned source/version, Node requirement such as recommended Node 24 or supported Node 22.19+, service model, ports, auth, secrets handling, rollback, and verification.
5. Stop for explicit approval before the first mutating action.
6. Install one phase at a time on the VPS, appending report entries before moving on.
7. Verify OpenClaw before AI Persona OS with CLI checks, service status, ports, and authentication behavior.
8. Treat AI Persona OS as trusted-code installation. Before `openclaw skills install ai-persona-os`, inspect source/ClawHub metadata, identify files it may create under `~/workspace/`, such as `memory/`, `config/SOUL.md`, `config/AGENTS.md`, and `persona-config.yaml`, and get approval before overwriting existing workspace files.

## Report discipline

Keep these phases visible:

- `Phase 0 - Orientation`
- `Phase 1 - Documentation Review`
- `Phase 2 - Host Preflight`
- `Phase 3 - Install Plan`
- `Phase 4 - OpenClaw Install`
- `Phase 5 - OpenClaw Verification`
- `Phase 6 - AI Persona OS Install`
- `Phase 7 - AI Persona OS Verification`
- `Phase 8 - Final State`

For every meaningful step append:

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

Always clarify whether only the current phase is complete or the overall objective is complete. If no installation happened, say so explicitly.

## Anti-patterns

- Installing locally as the main system when the target is a VPS
- Treating MCP or SDK documentation as OpenClaw server installation instructions
- Installing before VPS preflight and a written plan
- Running installer scripts or skill installs without source and version review
- Posting SSH private keys, tokens, API keys, or decoded secrets
- Claiming completion after only orientation, documentation review, or preflight
- Overwriting AI Persona OS workspace/config files without explicit approval
