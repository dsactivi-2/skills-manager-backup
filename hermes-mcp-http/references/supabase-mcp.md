# Supabase MCP + CLI (verified 2026-08)

## Remote MCP (Hermes)

Catalog manifest: `optional-mcps/supabase/manifest.yaml` → `https://mcp.supabase.com/mcp`, `auth: oauth`.

```bash
hermes mcp install supabase
hermes mcp login supabase          # use a PTY; browser OAuth
hermes mcp test supabase           # expect OAuth 2.1 PKCE, 29 tools
```

`install` probe fails until tokens exist. Config after install:

```yaml
mcp_servers:
  supabase:
    url: https://mcp.supabase.com/mcp
    auth: oauth
    enabled: true
```

Tokens: `~/.hermes/mcp-tokens/supabase.{json,client.json,meta.json}`.

Tools live in a session only after `/reload-mcp` or a new session.

Do not add the URL as `auth: none`. Project-scoped query (`project_ref`, `features`) is optional; catalog is unscoped.

If the user pastes `https://mcp.supabase.com/mcp?project_ref=…&features=…`:
1. Check `hermes mcp list` — if `supabase` is already `auth: oauth` + enabled, leave the global URL unscoped. Probe with `get_project` using that `project_ref`; do not `config set` the query string onto `mcp_servers.supabase.url` (that pins every Hermes session to one project).
2. Write the scoped URL into the **repo** `.mcp.json` for Claude/Cursor/Codex/etc. Hermes does not load `.mcp.json`.
3. Skip a second Hermes server with the same host unless they explicitly want a separately named, permanently scoped entry.

Local stack MCP (`http://127.0.0.1:54321/mcp`) is separate and only exists after `supabase start`.

## Official agent skills vs Open Plugin

Hermes skills (vendor-owned — do not curator-patch):

```bash
npx skills add supabase/agent-skills -g -y --agent hermes-agent
```

Installs `supabase` and `supabase-postgres-best-practices` under `~/.hermes/skills/`.

`npx plugins add supabase-community/supabase-plugin` is the Open Plugin pack for Claude Code / Cursor / Codex / Grok / Copilot / VS Code. Hermes is not a plugins target. That command does not add MCP tools to this session. If they asked for it anyway, run it from the project with `--scope project -y`, then still verify Hermes via `hermes mcp test supabase` + one read-only tool call.

## CLI (local stack)

```bash
brew install supabase/tap/supabase   # live: 2.115.0 at /opt/homebrew/bin/supabase
supabase init                        # files only: supabase/ + config.toml
supabase start                       # Docker/OrbStack containers
supabase stop                        # keep local DB
supabase telemetry disable           # optional; also SUPABASE_TELEMETRY_DISABLED=1
```

`start` needs a Docker-compatible runtime (OrbStack is enough). `init`/`login`/`link` do not.
