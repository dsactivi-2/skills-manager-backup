# Dedupe + refresh vendor-shipped agent skills

## Problem
Local skill library had both `langfuse/` and `langfuse-official/` with the same
frontmatter `name: langfuse` → Hermes refused `skill_view('langfuse')` as ambiguous.

## Fix pattern (class-level, one skill)
1. `langfuse get-skill` (or vendor equivalent) → latest SKILL.md body.
2. Merge into **one** path (here: real dir `~/.agents/skills/langfuse`, Hermes
   symlink `~/.hermes/skills/langfuse` → that target).
3. Keep/upgrade `references/*` from the larger local set + upstream raw files
   (prompt-engineering, v4-project-migration, trace-evaluator-upgrade, …).
4. Preserve a short **local Activi** appendix (dual projects DograhEU vs LocalM5,
   MCP names, CLI `--env ~/.hermes/.env`) — not in upstream get-skill.
5. `rm -rf` the duplicate (`langfuse-official`) under default skills.
6. Sync active profiles (barbares had its own `langfuse-official` + symlink).
7. Verify: `skill_view(langfuse)` succeeds; `find … -name SKILL.md | rg 'name: langfuse'` = 1 per scope.

## CLI vs MCP vs skill (Langfuse)
| Layer | Role |
|-------|------|
| `langfuse` CLI | Full Public API (OpenAPI wrap). Prefer for scripts + agent shell. |
| MCP `langfuse-voiceeu` / `langfuse-dograh-cloud` | Same project API as tools (~79). Dual project routing. |
| MCP `langfuse-docs` | Documentation only. |
| Skill `langfuse` | How-to + docs workflow + Activi routing — **not** a second API. |

Do not “improve” skills by re-implementing scores/traces CRUD the CLI already has.

## Install note
```bash
npm install -g langfuse-cli
langfuse --env ~/.hermes/.env api projects get-public
```
Keys: never paste into chat on refresh; read from `.env`.
