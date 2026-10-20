---
name: mcp-hub-management
description: "Use when installing a multi-client MCP hub/gateway with GUI."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [macos, linux, windows]
metadata:
  hermes:
    tags: [MCP, gateway, ToolHive, Toolport, multi-client, GUI, skills]
    related_skills: [native-mcp, hermes-mcp-http, hermes-skills]
---

# MCP hub / gateway management (multi-client)

Use when the user wants **one place** to set up MCP servers so **several agents** (Claude Code, Codex, Cursor, Hermes, …) share them — ideally with a **GUI**. Not for wiring a single server into Hermes only (`native-mcp` / `hermes-mcp-http`).

## Mental model (plain DE for user)

Three layers — ToolHive is **not** a coding agent:

| Layer | What | Analogy |
|-------|------|---------|
| **Client** | Claude Code, Codex, Cursor, Hermes … | Arbeiter |
| **MCP server** | GitHub, Playwright, Context7 … | Werkzeug |
| **Skill** (agentskills.io) | SKILL.md workflow | Bauanleitung |

ToolHive = Verteilerkasten (run MCP, install Skills, write client configs). Studio Skills catalog cards ≠ built-in Hermes replacement.

## Decision (this user)

| Goal | Pick | Why |
|------|------|-----|
| Primary multi-client MCP + Skills + Desktop GUI | **ToolHive Desktop** | User default: rejected Toolport as too small/untrusted |
| Claude + Codex + **Hermes** first-class single gateway (alt) | **Toolport** | Auto Hermes + lazy discovery — only if user re-asks Hermes-first gateway |
| Team control plane / RBAC | Obot, MCPX, Docker MCP GW, … | Heavier; separate eval |

**Default: ToolHive Desktop only.** Hermes stays manual via `hermes mcp add` + URL. Hybrid only if user accepts two layers.

mahseema/awesome-ai-tools lists **ToolHive only** among real MCP managers — not Toolport. List is incomplete for hubs.

## Toolport (local gateway + GUI)

- Site: https://toolport.app · Repo: https://github.com/tsouth89/toolport
- Install: GitHub releases (macOS/Windows/Linux Desktop)
- Flow: add server once → Clients → Connect (Claude Code, Codex, **Hermes**, Cursor, …)
- Hermes path: `~/.hermes/config.yaml` under `mcp_servers` (gateway entry)
- Verify: new Hermes/Codex session; `hermes mcp list` / tool call

## ToolHive (runtime + skills + GUI/CLI)

### CLI install (Homebrew, macOS)

Modern Homebrew requires **tap trust** before install:

```bash
brew tap stacklok/tap
brew trust stacklok/tap          # or: brew trust --formula stacklok/tap/thv
brew install thv
thv version
```

Without `brew trust`, install fails: `Refusing to load formula stacklok/tap/thv from untrusted tap`.

### Runtime prerequisite

`thv` needs a Docker-compatible runtime (Docker / Podman / **OrbStack** / Colima / K8s).  
If OrbStack is stopped: `orb start`, then confirm `docker info` shows Server Version.

```bash
thv version   # should not log "no container runtime available"
```

### Desktop GUI XOR external CLI (critical)

Studio manages its **own** bundled `thv`. Homebrew `thv` on PATH blocks the app:

> External ToolHive CLI Detected — Found: /opt/homebrew/bin/thv  
> Fix: `brew uninstall thv` → Check Again

Rules:

1. **Never run brew `thv` and ToolHive.app together.**
2. Prefer **Desktop only** for this user. After brew uninstall, kill leftovers: `pgrep -lf '/opt/homebrew/bin/thv'`.
3. CLI while Desktop is SoT — app-bundled binary, not PATH:

```bash
THV="/Applications/ToolHive.app/Contents/Resources/bin/darwin-arm64/thv"
"$THV" version
"$THV" client status
"$THV" list
```

4. Studio version may lag bundled thv (e.g. app 0.39.x / thv 0.40.x) — normal.

Desktop: https://stacklok.com/download/ or `stacklok/toolhive-studio` releases (arm64 DMG).

### Common CLI surface (verified thv 0.40.1 / app-bundled)

```bash
thv registry list                 # curated catalog
thv search <q>
thv run <server>                  # registry name, image, uvx/npx/go://, or remote URL
thv run toolhive-doc-mcp-remote   # good smoke: no secrets, remote proxy
thv list                          # NAME STATUS URL PORT GROUP
thv status <name>
thv mcp list --server <name>      # tools/resources/prompts
thv client status                 # installed × registered matrix
thv client register <client>      # claude-code | codex | cursor | vscode | …
thv client list-registered
thv secret setup                  # required before API-key servers (keychain)
thv tui                           # experimental dashboard
```

Auto-clients include Claude Code, OpenAI Codex, Cursor, Copilot, Goose, … — see client-compatibility docs. **Hermes is not auto-registered.**

After `thv run`, ToolHive writes URLs into registered clients (e.g. `~/.claude.json`, `~/.codex/config.toml`, `~/.cursor/mcp.json`, VS Code `mcp.json`). New agent sessions required to pick up MCP.

### Hermes + ToolHive (do not use agent file-patch on config.yaml)

Hermes `config.yaml` is **agent-write-protected** (patch/write_file refused). Use CLI only.

`hermes mcp add` is **interactive** (auth? / enable tools?). Non-interactive for local unauth ToolHive proxies:

```bash
# after thv list → URL e.g. http://127.0.0.1:61303/mcp
printf 'n\nY\n' | hermes mcp add toolhive-doc-mcp-remote --url http://127.0.0.1:61303/mcp
hermes mcp list
hermes mcp test toolhive-doc-mcp-remote
```

- First prompt: auth? → `n` for local thv proxy without OIDC  
- Second: enable all tools? → `Y`  
- New Hermes session needed for tools to load  

Auth headers for remote upstreams: `hermes-mcp-http`.

### Skills (ToolHive)

- Spec: https://agentskills.io/ (`SKILL.md` bundles)
- UI/CLI: browse / install / build / manage; user vs project scope
- Installs into **client** skill dirs (Claude/Cursor/Codex) — not automatically into `~/.hermes/skills`
- Hermes skills remain under Hermes profiles unless you install/copy there on purpose

## Discovery sources

| Source | Use for |
|--------|---------|
| mahseema/awesome-ai-tools | Broad AI tools; thin MCP coverage |
| punkpeye/awesome-mcp-servers | MCP **server** catalog |
| ToolHive registry / Toolport catalog | Installable managed servers |
| native-mcp + hermes-mcp-http | Per-agent config in Hermes |

## Pitfalls

- **Desktop + brew thv together** → Studio blocks (“External ToolHive CLI Detected”); uninstall brew + kill stale processes
- PATH `thv` after brew uninstall while Desktop runs → use app-bundled binary
- Trust brew tap before `brew install thv` only for intentional CLI-only (not Desktop default)
- `thv` without OrbStack/Docker → fix runtime, not “thv broken”
- ToolHive does **not** auto-wire Hermes — `hermes mcp add` with URL from list/app
- Agent **cannot** patch `~/.hermes/config.yaml` — always `hermes mcp add|remove|…`
- `hermes mcp add` without stdin cancels (“Cancelled.”) — `printf 'n\nY\n' | …` for local unauth
- **Stale Hermes rows** after ToolHive stop/rm (dead localhost ports) — `hermes mcp remove` then re-add
- API-key servers need secrets provider (app / `thv secret setup`)
- Local proxy unauth warning OK on laptop; not on shared net
- ToolHive Skills ≠ Hermes `~/.hermes/skills` install targets
- No built-in coding agent in ToolHive — Clients + Skills catalog only; teach 3 layers in plain DE
- Clients registered ≠ MCP running — empty list means nothing usable yet
- New agent **session** required after MCP install/run
- awesome-ai-tools alone is incomplete for hub choice
- Don’t mass-register unused clients every session; once is enough

## Related

- `native-mcp` — Hermes `mcp_servers` config
- `hermes-mcp-http` — HTTP auth headers / 401
- `hermes-skills` — Hermes skill CLI (not ToolHive skills)
- `references/toolport-vs-toolhive.md` — comparison + brew + URLs
- `references/thv-live-setup.md` — end-to-end thv + client register + Hermes smoke (printf pipe)
