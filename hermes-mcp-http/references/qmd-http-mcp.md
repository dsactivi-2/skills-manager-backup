# QMD HTTP MCP — Activi default profile

Package: `@tobilu/qmd` (CLI `qmd`). Skill: `qmd` from `npx skills add tobi/qmd --skill qmd --agent hermes-agent --copy -g -y`. Do not install the pack's `release` skill.

## Wire-up

1. `qmd collection add <folder> --name <name>` then BM25 works. `qmd embed` is separate (vectors).
2. Shared server: `qmd mcp --http --daemon` (default port 8181). Prefer HTTP over stdio so models stay loaded.
3. Bind may be IPv6-only (`[::1]:8181`). Probe `http://localhost:8181/health`, not `127.0.0.1`.
4. Hermes:

```bash
printf 'n\nY\n' | hermes mcp add qmd --url "http://localhost:8181/mcp" --connect-timeout 30
hermes mcp test qmd
```

Tools: `query`, `get`, `multi_get`, `status`. Live in-chat only after `/reload-mcp` or a new session. Auth: none.

## Activi index

- Collection `ai-bibliothek` → `/Users/activi/AI Bibliothek` (`**/*.md`)
- Do not add home-wide or CRM trees unless asked.
- Keyword search works with zero vectors; say so if embed is still running.
