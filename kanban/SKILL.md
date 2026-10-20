---
name: kanban
description: "Class-level umbrella for the full Hermes Kanban multi-agent orchestration system: orchestrator decomposition playbook, worker pitfalls/examples/edge cases, lifecycle, handoff patterns, and workspace/tenant handling."
tags: ["kanban", "multi-agent", "orchestration", "workflow"]
---

# Kanban Umbrella Skill

Consolidated skill for the complete Kanban system used in Hermes for routing work across specialist profiles.

## Orchestrator Role
Decomposition playbook + anti-temptation rules for routing work through Kanban. The "don't do the work yourself" rule and basic lifecycle.

See original `kanban-orchestrator` for profile discovery, task graph sketching, parent linking, goal-mode cards, and recovery actions.

## Worker Role
Pitfalls, examples, and edge cases for Hermes Kanban workers. The lifecycle is auto-injected; this provides deeper detail on handoffs, summaries, block reasons, heartbeats, retry scenarios, and workspace kinds.

See original `kanban-worker` for workspace handling (scratch/dir/worktree), tenant isolation, metadata shapes, claiming created cards, notification routing, and CLI fallbacks.

## Shared Patterns
- Always discover profiles first.
- Use parent links for dependencies.
- Shape metadata for downstream parsers.
- Prefer kanban_block with specific reason over vague "stuck".
- Archive entire original packages in .archive/ for recoverability.

## References
- Original orchestrator and worker SKILL.md bodies preserved in archive for full detail.
