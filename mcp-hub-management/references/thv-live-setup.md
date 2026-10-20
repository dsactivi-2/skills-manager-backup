# ToolHive live setup (macOS OrbStack + Desktop, verified 2026-07-28)

## Control plane: Desktop only (this user)

ToolHive Studio and Homebrew `thv` are **mutually exclusive**.

```bash
# If Studio shows "External ToolHive CLI Detected":
brew uninstall thv
pgrep -lf '/opt/homebrew/bin/thv' && kill -9 $(pgrep -f '/opt/homebrew/bin/thv') || true
# In app: Check Again
```

CLI while Desktop is SoT — do not rely on PATH after brew uninstall:

```bash
THV="/Applications/ToolHive.app/Contents/Resources/bin/darwin-arm64/thv"
"$THV" version
orb start   # if docker info has no Server
```

Optional CLI-only (not default): `brew tap stacklok/tap && brew trust stacklok/tap && brew install thv` — then do **not** open Studio.

## Clients

```bash
"$THV" client status
for c in claude-code codex cursor vscode opencode gemini-cli copilot-cli \
  continue windsurf windsurf-jetbrains amp-cli factory lm-studio zed; do
  "$THV" client register "$c" 2>/dev/null || true
done
"$THV" client list-registered
```

**Hermes is never in this matrix.** Wire manually after each server has a stable URL.

Studio UI: Clients / Manage Clients toggles should match.

## Smoke server (no secrets)

App Registry → ToolHive Docs (Remote), or:

```bash
"$THV" run toolhive-doc-mcp-remote
"$THV" list
"$THV" mcp list --server toolhive-doc-mcp-remote
# tools: query_docs, get_chunk
```

Auto-written into registered clients (`~/.claude.json`, `~/.codex/config.toml`, `~/.cursor/mcp.json`, VS Code `mcp.json`). New agent session required.

## Hermes (manual)

```bash
hermes mcp remove toolhive-doc-mcp-remote 2>/dev/null || true   # clean dead port
printf 'n\nY\n' | hermes mcp add toolhive-doc-mcp-remote --url "http://127.0.0.1:PORT/mcp"
hermes mcp list
hermes mcp test toolhive-doc-mcp-remote
```

- auth? → `n` for local unauth proxy
- enable all tools? → `Y`
- No agent edit of config.yaml
- After ToolHive stop/rm: remove stale Hermes row

## Skills (Studio)

Tab Skills → Registry → Install → client skill dirs (Claude/Cursor/Codex).  
Not auto into `~/.hermes/skills`. No built-in coding agent — catalog skills are optional playbooks.

## Next real servers

1. Secrets in app / `"$THV" secret setup`
2. Registry: github, context7, playwright, …
3. Hermes `mcp add` per URL if needed
4. New sessions in each agent

## Logs / data

`~/Library/Application Support/toolhive/`

## Plain-DE user brief

1. Registry → MCP install/run  
2. Clients toggles on  
3. Agent neu starten  
4. Skills optional  
5. Hermes = URL → hermes mcp add  
