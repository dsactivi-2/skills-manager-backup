# Knowledge layers (Hermes official)

Verified against `website/docs/user-guide/features/{memory,context-files,personality}.md` and `memory-providers.md`.

## Per Hermes home (default or named profile)

| File | Path | Job | Cap |
|------|------|-----|-----|
| SOUL.md | `$HERMES_HOME/SOUL.md` | Who the **agent** is (slot #1) | `context_file_max_chars` |
| USER.md | `$HERMES_HOME/memories/USER.md` | Who the **user** is, style | 1375 |
| MEMORY.md | `$HERMES_HOME/memories/MEMORY.md` | Standing env/conventions | 2200 |
| External | `memory.provider` | Auto facts / user model | provider |

Named profile = `$HOME/.hermes/profiles/<name>/` with its own SOUL + memories. Not OS-global.

## Per git project

Only **one** project context type loads (first match): `.hermes.md` → `AGENTS.override.md` → `AGENTS.md` → `CLAUDE.md` → `.cursorrules`. SOUL always loads separately.

AGENTS.md is discovered from cwd up to git root. Outside a git repo, parents are never walked — `~/AGENTS.md` or `$HERMES_HOME/AGENTS.md` is **not** a global AGENTS.

## Do not store knowledge in

- `state.db` — session store; use `session_search` to read, never hand-edit
- npm/pip lockfiles / doctor advisories

## Operator VPS default (Denis)

1. Draft SOUL (Identity…Behavior), apply only after Freigabe
2. USER.md = Denis rules (DE, dry-run, skills→tools/MCP→scripts)
3. MEMORY.md = tiny infra only
4. Mem0 if auto facts; Honcho if user-model (one only)
5. AGENTS.md only in project git roots

Audit (read-only): `hermes-profile-capability-audit` script `scripts/hermes-knowledge-audit.sh`
