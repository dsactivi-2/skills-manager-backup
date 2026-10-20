# Profile Capability Audit — Recipe

Goal: verify what a *specific* Hermes profile actually has (skills / MCP / tools /
where each lives), instead of trusting a claim like "7 skills, 1 MCP".

## Core pitfalls

- `skills_list` (the tool) = **global** catalog. Never answer profile inventory from it.
- Folder count ≠ skill count (category dirs bundle many SKILL.md).
- `.bundled_manifest` = **bundled subset only**, not full installed count.
- Full count: `hermes -p <name> skills list` summary line and/or SKILL.md count under `skills/` excluding `.hub` / `.archive` / quarantine.
- Default profile home is `~/.hermes` (not under `profiles/`).

## Authoritative sources

| What | Source | Notes |
|------|--------|-------|
| MCP | `config.yaml` → `mcp_servers` | Check `enabled`; keys in profile `.env` |
| Skills full | `hermes -p <name> skills list` + SKILL.md count | Prefer CLI summary line |
| Skills bundled | `skills/.bundled_manifest` | Subset only |
| Disabled | `skills.disabled` | Empty = none |
| Toolsets | `platform_toolsets` + `hermes tools list` | Parse tools list with Python; macOS awk breaks on ✓ |
| Usage | `skills/.usage.json` | Curator sidecar |

## Fast commands

```bash
hermes profile show <name>
hermes -p <name> mcp list
hermes -p <name> skills list | tail -5
hermes -p <name> tools list
scripts/hermes-profile-inventory.sh <name>
```

## Gotchas

- Typos: batbares / barbarez → `barbares`
- Never `grep -r` over `$HOME` — scope `~/.hermes`
- After skill/MCP copy: `/reload-skills`, `/reload-mcp`, or new session
- Field example: barbares ~69 manifest lines vs 85 full skills — both valid for different questions
