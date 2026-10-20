---
name: dograh-project-setup-agents-wizard
description: "Create, harden, and verify a secret-safe Dograh first-setup wizard/template pack with project.setup.yaml, .env.example, onepager docs, dry-run checks, and production-ready prompt gates. Use this skill when the user asks to create, improve, or verify a Dograh first-setup/project setup wizard prompt, template pack, onepager, or config checker around project.setup.yaml and .env.example."
trigger: "Use this skill when the user asks to create, improve, or verify a Dograh first-setup/project setup wizard prompt, template pack, onepager, or config checker around project.setup.yaml and .env.example."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019f5cec-d45c-7b60-af14-343af65b95e8
  - activi_dsactivi's Organization_default_019f5c1c-177d-7fa3-b93f-bfb10037fe96
contributors:
  - activi
version: 1
created_by_agent: codex
created_at: 2026-07-13T19:34:02.819Z
updated_at: 2026-07-13T19:34:02.819Z
---

# Dograh project setup agents wizard

## When to use

Use when the user wants a reusable local setup process for new Dograh projects before any live Dograh changes: templates, a copy-paste Codex wizard prompt, a onepager, a checklist, or a verification script for first setup readiness.

This is for project onboarding and prompt/process hardening. It is not for editing, saving, publishing, calling, or deploying Dograh workflows.

## Workflow

1. Stay project-local under `/Users/activi/Documents/Dograh Base Nodes Template` unless the user explicitly approved another path. Read existing files before changing them.
2. Separate fachliche config from secrets. Use `templates/project.setup.template.yaml` or `projects/<project-slug>/project.setup.yaml` for product, market, language, call goal, compliance rules, tools, handoff, tests, and rollout status. Use `templates/project.env.example` for variable names only. Use `.env.local` only as a local user-owned file and never print or store values.
3. Keep the wizard prompt in `prompts/codex-project-setup-wizard-prompt.md`. The prompt must make Codex act as a setup wizard/process controller: clarify scope and risk first, ask block by block, mark every value as `user_provided`, `file_detected`, `dograh_mcp_detected`, or `assumption`, and block Dograh live changes by default.
4. If a user-facing quick-start is needed, mirror the current prompt guidance in `docs/dograh-first-setup-onepager.md` without drifting from the source prompt. The onepager should explain paths, activation, safe defaults, Definition of First Setup, and what remains blocked until approval.
5. For production-ready prompt hardening, require gates for source-of-truth claims, prices, privacy/recording, target languages, node map, edge conditions, tools, write actions, telephony, CRM/webhooks, handoff, rollback/disable path, tests, and status `PASS`, `WARN`, `FAIL`, or `PASS_WITH_GAPS`.
6. Classify tools and actions as `read_only`, `write_action`, `telephony_action`, or `external_write`. Any save, publish, credential, phone, call, webhook, CRM, database, email, or campaign action needs read-only discovery, draft, dry-run/preflight where available, and explicit approval.
7. Prefer script-first for repeatable verification. A read-only checker should use `set -euo pipefail`, timestamps, no secret output, and a structured result. It should verify required files, YAML parseability where possible, core safety markers such as `Keine Dograh-Live-Aenderungen`, no obvious secret patterns, synchronized prompt/onepager content, and status reporting.
8. When reporting readiness, distinguish local setup readiness from live Dograh readiness. `PASS` can mean templates, docs, wizard, dry-run, and read-only MCP work; write actions and calls remain untested unless explicitly performed after approval.

## Quality checks

- The wizard asks one block at a time instead of dumping a huge questionnaire.
- Completed setup files can be saved under `projects/<project-slug>/project.setup.yaml` and local `.env.local` without exposing secrets.
- YAML fields distinguish setup state from Dograh processing state, for example `setup_status` and `dograh_processing_status`.
- The prompt prevents live changes and requires evidence before calling anything production-ready.
- Reports state sources used, open assumptions, gaps, and no live Dograh changes unless approved.

## Anti-patterns

- Treating a filled `.env` as the project plan instead of using `project.setup.yaml` for business context.
- Printing, decoding, or saving API keys, bearer tokens, webhook secrets, credential values, or customer data.
- Letting the wizard perform Dograh saves, publishes, tool creation, calls, or external writes during first setup.
- Calling the prompt production-ready without node/edge criteria, tool risk gates, tests, rollback, and verification.
- Updating the onepager while leaving `prompts/codex-project-setup-wizard-prompt.md` stale, or vice versa.
