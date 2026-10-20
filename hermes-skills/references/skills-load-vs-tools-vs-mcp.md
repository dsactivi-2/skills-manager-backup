# Skills vs Toolsets vs MCP (Hermes)

For Denis: German, three short drawers. Do not mix the words.

| Schublade | Was es ist | Wann nutzbar |
|---|---|---|
| Skill | Markdown-Anleitung (`SKILL.md`) | Sofort nach `skill_view` / `/skill` **in derselben Session** |
| Toolset | Hermes-eigene Tools (`hermes tools enable`) | Oft erst nach `/reset` |
| MCP | Fremde Tools (`hermes mcp add`) | Nach `/reload-mcp` oder neuer Session |

## n8n-io/skills on Hermes

- Install: `npx skills add n8n-io/skills -g -y --skill '*' --agent hermes-agent --copy` (see `n8n-npx-install.md`).
- 14 skills, already local under `~/.hermes/skills/<name>/`.
- Router `using-n8n-skills-official` does **not** auto-load the other 13.
- No plugin SessionStart here. `~/AGENTS.md` already has the n8n snippet.
- Load on demand: router first, then the one capability skill the task needs. Not all 14.

## User phrasing that means "load now"

"aktiviere den skill", "lade X", `/skill X` → `skill_view` immediately, then follow the skill. Do not answer "it's installed" and stop.

## Skill install ≠ MCP connected

After `npx skills add` the user often asks "hast du jetzt Zugang zum MCP?" / "bist du verbunden?".
That is a **different drawer**. Live-check `hermes mcp list` + `tool_search` for `mcp__<name>__*`.
If the skill is on disk but the server is missing: say so in German, simple words. Do not claim the skill opened the database.
Connector = YAML/`hermes mcp add` + `hermes mcp test` + `/reload-mcp` (or new session) + one real tool call. See skill `hermes-mcp-http`.

A skill can lag or lead the MCP. After connect, report what **`hermes mcp test` / `tool_search` this session** can do, not the skill catalog as if it were live. `hermes mcp test` tool count can be newer than this chat until `/reload-mcp` (verified: recruiting-crm 9 tools on Worker vs 7 in session).

## After a live probe — do not report tool-speak

Denis will not parse "list_occupations (query auto, Limit 3) kam zurück. count_candidates ohne Filter: 122004."
Re-pitch: what you asked, what came back, what that proves (Leitung geht / zählen geht). Fachbegriff first, then Alltag. No command names as the headline.
