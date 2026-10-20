# Session file decision matrix

Use this matrix after reading the effective global and project instructions. The file path—not its name alone—determines its practical scope.

| Option | Use it when | Depends on | Scope and retention | Do not use it when |
| --- | --- | --- | --- | --- |
| `docs/plans/<task>.md` | A task has multiple steps, risks, decisions, or a handoff. | Existing project plan convention, if any. | Task documentation; retain only while useful. | A one-step change is clear without it. |
| `docs/evals/<case>.md` | Agent, prompt, skill, instruction, or tool behavior needs a repeatable manual regression case. | `docs/evals/README.md` and the changed behavior. | Durable project quality record; manual unless a configured runner exists. | The change has no behavior that needs regression coverage. |
| `<subtree>/AGENTS.md` | A service or subtree needs stable local rules, commands, or safety constraints. | Effective parent `AGENTS.md` files and actual local tooling. | Directory subtree; durable until removed. | The guidance is only for one task or repeats parent rules. |
| `<subtree>/AGENTS.override.md` | A narrow local exception is necessary and allowed by higher-priority rules. | Parent and same-directory `AGENTS.md`; an explicit expiry or cleanup plan. | Directory subtree; temporary only by deliberate removal. | It weakens security, approvals, or other higher-priority instructions. |
| `docs/runbooks/<topic>.md` | A repeatable incident, deployment, recovery, or operational task needs safe steps. | `docs/runbooks/README.md`, system facts, and rollback procedure. | Durable project documentation. | The procedure is one-off or not operational. |
| `.agents/skills/<name>/SKILL.md` | A workflow is reusable and has clear triggers, boundaries, and validation. | Current Codex skill documentation; any required references or scripts. | Durable repository skill, discovered by Codex. | It is only a one-time task checklist. |

## Recommended dependency order

1. Read global and project instructions and relevant existing templates.
2. Decide whether the request is temporary (`docs/plans/`) or durable (eval, local instruction, runbook, or skill).
3. For durable files, establish the real project behavior and target location first.
4. Draft the task plan or manual eval after the behavior and constraints are known.
5. Create a local override only after confirming a normal local `AGENTS.md` cannot express the need.

If the request conflicts with this order, explain the risk and let the user choose. Do not silently create a premature or redundant file.
