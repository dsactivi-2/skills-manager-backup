---
name: project-init
description: Assess, recommend, and, after explicit approval, establish the smallest safe foundation for a new or unstructured software project. Use when a user needs project rules, documentation, plans, reusable workflows, project-specific skills, tools, MCP servers, or integrations. Do not use for ordinary feature work in an established project.
metadata:
  short-description: Design and initialize a project foundation
---

# Project Init

Choose the smallest project foundation that meets the stated need. Keep advice, approved local repository changes, package installation, and external activation separate.

## Assess deliberately

Inspect existing repository context and start from the stated goal. Ask one compact group of only unanswered questions, then stop as soon as the recommendation is supported.

1. Is this a new repository, a repository being standardized, or one service/module?
2. What must persist: working rules, product context, an architecture decision, an operational procedure, quality evidence, or a large execution plan?
3. Is the workflow one-off, reusable in this repository, reusable across repositories, or intended for a team?
4. Only when it changes the recommendation or approved plan: which stack, deployment target, data sensitivity, tools, integrations, or credentials are required now?

## Recommend the smallest design

Choose one primary mechanism and only complements that solve a distinct stated need.

| Need | Mechanism | Boundary |
|---|---|---|
| Durable repository rules | Root `AGENTS.md` | Keep it repository-specific; do not duplicate global rules. |
| Service or module rules | Nested `AGENTS.md` | Use `AGENTS.override.md` only for a genuine stronger or temporary exception. |
| Product context and current architecture | `docs/project.md`, referenced from `AGENTS.md` | It is not auto-loaded as instructions and must not become a second `AGENTS.md`. |
| Long-lived architecture decision | `docs/decisions/<topic>.md` | Include context, alternatives, decision, consequences, and verification; exclude disposable notes. |
| Repeatable operation or recovery | `docs/runbooks/<topic>.md` | Include prerequisites, safety, stop criteria, recovery or escalation, and verification. |
| Quality criteria or evidence | `docs/evals/<case>.md` | Evidence is not automatic test execution. |
| Large multi-session change | `PLANS.md` and one living plan | Use only for work that needs a self-contained plan. |
| Repeatable repository workflow | Repo skill in `.agents/skills/<name>/SKILL.md` | Define clear inputs, outcome, and boundary; add a script only when it materially improves reliability. |
| Cross-repository workflow | User-level skill in `~/.agents/skills/` | Keep repository commands and assumptions out of it. |
| Team-wide distribution with optional connectors | Plugin | Stabilize the underlying skill before packaging it. |
| Session-time context or preflight | Read-only session hook | Keep it concise and advisory; never make it an uncontrolled file-creation trigger. |
| Event-driven external work | Guarded automation | Require explicit scope, permissions, secrets handling, validation, and review. |

Present the recommendation in this order:

1. Primary mechanism, its location, and why it fits.
2. Optional complements with a distinct purpose.
3. Explicitly not recommended now and why.
4. Proposed next action: advisory design, draft, or an exact requested write.

## Plan capabilities and integrations

For every candidate skill, MCP server, tool, or integration, record the concrete task it enables; repository, development, or production scope; data it can read or change; authentication method without secret values; owner; cost implications; configuration location; verification; and removal path.

Prefer project-local configuration when supported. Inspect a skill before relying on it. Before registering an MCP server, verify its executable or endpoint, available tools, required credentials, and least-privilege scope. Use the repository's established package manager and lockfile.

## Apply with explicit authorization

Present the exact local file changes before writing and obtain approval for that plan. Treat these as separate actions:

1. Read-only discovery.
2. Approved local repository changes.
3. Local package or tool installation.
4. External, credentialed, OAuth-backed, paid, production, deployment, or automation actions.

Obtain explicit approval immediately before actions in groups 2, 3, or 4. Preserve existing files and conventions. Never overwrite user work, write secrets to repository files, alter global configuration, register MCP servers, connect OAuth accounts, create cloud resources, deploy, or enable paid services without explicit approval.

## Verify and report

After approved work, verify the resulting structure and run only install, test, lint, typecheck, build, CI, or deployment checks supported by the selected stack. Report unavailable checks as gaps, not successes. For current Codex-specific behavior, consult official OpenAI documentation before proposing exact configuration.
