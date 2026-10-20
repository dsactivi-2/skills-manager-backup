# Project File Decision Matrix

Verify current official Codex documentation before relying on this matrix.

| Need | Recommended file | Ask first | Dependency or warning |
| --- | --- | --- | --- |
| Project-wide work rules | `AGENTS.md` | What differs from global guidance? | Do not repeat global rules. |
| Temporary stronger local exception | `AGENTS.override.md` | Why is normal local guidance insufficient? | It takes precedence in its directory. |
| Shared runbook convention | `docs/runbooks/README.md` | Are there recurring operational tasks? | Create before multiple runbooks when practical. |
| Deployment, incident, restore procedure | `docs/runbooks/<topic>.md` | What is the safe diagnosis, rollback, and stop rule? | Follow the runbook convention if it exists. |
| Durable architectural decision | `docs/decisions/<topic>.md` | Will this matter beyond the current task? | Do not create for temporary notes. |
| Manual regression-test convention | `docs/evals/README.md` | Which agent behavior needs guarding? | It is not an automatic evaluator. |
| One manual agent regression case | `docs/evals/<case>.md` | What input, success criterion, and forbidden result apply? | Follow the eval convention if it exists. |
| Reusable repository workflow | `.agents/skills/<name>/SKILL.md` | Does the workflow repeat and have a clear boundary? | Required tools need separate setup/approval. |
| Rules unique to one service | `services/<service>/AGENTS.md` | Does the service differ from root commands or constraints? | Root `AGENTS.md` remains effective. |

## Conflict rules

1. Read effective global guidance before drafting project instructions.
2. Prefer the narrowest file that can express the needed rule.
3. Flag incompatible instructions instead of silently overriding them.
4. Do not create an override file merely to bypass a higher-level rule.
