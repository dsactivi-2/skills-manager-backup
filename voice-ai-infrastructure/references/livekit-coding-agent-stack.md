# LiveKit coding-agent stack (Hermes)

Verified 2026-08-23. Official docs: https://docs.livekit.io/intro/coding-agents.md

## What exists (official)

| Layer | Official count | What |
|---|---|---|
| Skills | 2 | `livekit-agents` (architecture/tests) + `livekit-simulations` (scenario YAML / `lk agent simulate`) from https://github.com/livekit/agent-skills |
| Docs MCP | 1 | `https://docs.livekit.io/mcp` — name `livekit-docs` |
| CLI | same as MCP | `lk docs` (search / get-page / code-search / overview). Not a second MCP. |

There is no second LiveKit Docs MCP.

## Install that actually works

`hermes skills install skills-sh/livekit/agent-skills/livekit-agents` → Could not fetch.

```bash
npx skills add livekit/agent-skills -g -y
# then ensure Hermes sees both
ln -sfn ~/.agents/skills/livekit-agents ~/.hermes/skills/livekit-agents
ln -sfn ~/.agents/skills/livekit-simulations ~/.hermes/skills/livekit-simulations
printf 'n\nY\n' | hermes mcp add livekit-docs --url "https://docs.livekit.io/mcp"
hermes mcp test livekit-docs
```

Installing only `--skill livekit-agents` can leave `livekit-simulations` on disk under `~/.agents/skills/` without a Hermes symlink.

## Docs lookup order

1. Skill `livekit-agents` / `livekit-simulations` (how to think)
2. MCP `get_docs_overview` or `lk docs overview` (map)
3. `get_pages` / `lk docs get-page` (one page)
4. search, then `code_search` last

Do not check `llms.txt` / `llms-full.txt` into a repo. `get_docs_overview` ≈ live `llms.txt` (~94 KB). `llms-full.txt` is ~3.8 MB / ~960k tokens.

## Project trigger

Phrase „projekt LiveKit“ → `/Users/activi/Code/Projects/LiveKit` (Hermes project slug `livekit`). `cd` there; load that `AGENTS.md`. Do not use other LiveKit folders unless asked.
