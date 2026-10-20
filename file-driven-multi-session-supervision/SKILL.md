---
name: file-driven-multi-session-supervision
description: "Coordinate independent agent sessions through shared append-only reports, corrective prompts, and quiet periodic monitoring."
trigger: "Use when multiple agent sessions must work independently while one supervisor tracks progress, approvals, and deviations."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019ec6b3-b9ad-7501-84b7-a671a0756d10
  - activi_dsactivi's Organization_default_019ec6d1-fa14-7be2-9a51-8478f5a05f7e
contributors:
  - activi
version: 1
created_by_agent: codex
created_at: 2026-06-14T21:16:57.777Z
updated_at: 2026-06-14T21:16:57.777Z
---

# File-driven multi-session supervision

## When to use

Use when separate agent sessions cannot directly control each other but must coordinate on a shared project, especially for long-running or security-sensitive work.

## Coordination model

Combine three mechanisms:

- **Files** provide shared state and an audit trail.
- **Prompts** communicate corrections and next actions to worker sessions.
- **Automations** periodically inspect reports and notify only on actionable gaps.

Keep one append-only report per worker or target system, plus optional shared files such as `decisions.md`, `handoff.md`, and `master-report.md`.

## Worker contract

Give each worker an explicit target, report path, phase structure, and approval boundary. Require every meaningful step to append:

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

The worker must distinguish local helper actions from target-system changes, state whether the overall objective or only a phase is complete, and record the exact pending decision whenever waiting.

## Supervisor workflow

1. Create the worker prompt and report template before work begins.
2. Require orientation, documentation review, read-only discovery, and a written plan before mutations.
3. Poll the report periodically.
4. Check chronology, required fields, phase coverage, commands, tests, results, approval gates, and target alignment.
5. Stay quiet when work is on track.
6. When a gap appears, send a concise corrective prompt naming the exact missing evidence or unsafe action.
7. Recheck the report rather than trusting chat claims.

Example corrective prompt:

```text
Before continuing, append the missing Phase 2 and Phase 3 entries using the required template. State completed phases, remaining phases, next action, whether installation occurred, and whether mutation approval is pending. Do not mutate the target until the report contains the read-only preflight and written plan.
```

## Monitoring decisions

Notify when:

- reports stop updating while work allegedly continues
- required phases or fields are skipped
- a worker claims completion but only completed one phase
- target and local environments are confused
- mutations occur without approval
- blockers or plan changes are not documented

Do not notify when the report is current, the worker is correctly waiting for approval, or no actionable deviation exists.

## Anti-patterns

- Assuming sessions can directly control one another
- Treating chat messages as the authoritative audit trail
- Sending repeated prompts before checking the report
- Noisy monitoring that reports healthy progress
- Allowing workers to overwrite history
- Accepting vague statuses such as “finished” without phase and objective status
- Letting monitoring authorize mutations
