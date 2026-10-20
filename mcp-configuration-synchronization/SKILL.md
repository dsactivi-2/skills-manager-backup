---
name: mcp-configuration-synchronization
description: "Use when MCP server definitions must be kept in sync across Hermes, Codex, or other clients, especially when one client should be the source of truth."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [mcp, configuration, sync, codex, hermes, devops]
---

# MCP Configuration Synchronization

Use this skill when MCP server definitions need to be shared, imported, or synchronized across multiple agent clients such as Hermes and Codex.

## When to Use

- A user wants to import MCP servers from one client into another
- A user asks for a symlink or automatic mirroring of MCP server config
- Multiple agent apps must stay consistent without manually duplicating MCP entries
- You need to decide between a one-way sync and a shared source-of-truth workflow

## Core Principle

Do **not** assume MCP configs are interchangeable across clients.
Different apps may use different file formats, field names, auth fields, and reload behavior.
Treat each client as a **target format**, not as a config you can safely symlink.

## Recommended Decision Order

1. **One-way sync from an existing source** when one app already owns the server list.
2. **Shared master source** when multiple apps must stay aligned long-term.
3. **Never raw-symlink app configs** unless the formats are identical and the app explicitly supports it.

## Standard Workflow

1. **Discover the source config format**
   - Hermes typically uses YAML in `~/.hermes/config.yaml`
   - Codex typically uses TOML in `~/.codex/config.toml`
2. **Inventory the MCP server block** from the source.
3. **Map fields explicitly** for the target client.
   - Server names often transfer directly
   - Transport fields may differ (`url`, `command`, `args`, `env`, `headers`, auth-specific keys)
4. **Back up the target config** before writing.
5. **Write only the MCP section** if possible; preserve unrelated settings.
6. **Verify with the target CLI** (for Hermes, `hermes mcp list`).
7. **Restart or start a new session** if the client loads MCPs only at startup.

## Preferred Patterns

### One-way sync

Use when one config is already authoritative.

- Source of truth: one app, one file
- Generator: source → target
- Best for quick wins and low operational overhead

### Shared master source

Use when multiple apps must stay consistent long-term.

- Source of truth: a separate shared file
- Generators: shared → Hermes, shared → Codex, etc.
- Best for durable multi-client setups

## Pitfalls
- **Raw symlink between Codex and Hermes configs**: formats differ and fields do not map cleanly.
- **Assuming hot reload**: many MCP clients read server config only at startup.
- **Overwriting the entire config file**: preserve the rest of the app settings.
- **Dropping auth/header fields during conversion**: map them deliberately.
- **Treating a generated config as editable source**: edits should happen in the source-of-truth file, not the generated target.
- **Using stale /Applications paths**: GUI apps like Open Design often launch via App Translocation. Always copy the current path from Codex (`mcp_servers.<name>`) instead of hardcoding `/Applications/...`.
- **Attempting direct edits to `~/.hermes/config.yaml`**: the agent is blocked from writing this file for security. User must edit manually.
- **Sync script replaces instead of merges**: When Codex has fewer servers than Hermes, a naive "write all" sync will delete servers that only exist in Hermes. Always restore the full target list first, then add/overwrite only the synced servers (or implement a true merge in the generator). This session produced a working Python implementation that includes backup + full restore before sync.

## Verification

Always verify after sync:

- The target config parses cleanly
- The target CLI lists the expected MCP servers
- Any required auth variables or headers still exist
- The agent/client is restarted or a fresh session is started if needed

## Support Files

- `references/codex-hermes-sync.md` — practical field mapping, migration notes, and a verified Codex → Hermes sync recipe.
- `references/vscode-mcp-continue.md` — VS Code native mcp.json + Continue multi-provider + MCP server sync pattern (including env var handling and Context7 example).
- `references/claude-code-mcp-json.md` — Claude Code `.mcp.json` (JSON) format: how to add a server without clobbering siblings, and the verify-the-API-key-via-vendor-CLI-before-trusting-the-MCP pattern (MCP clients only load config at startup, so a bad key silently 401s inside tool calls).
- `scripts/sync-mcp-codex-to-hermes.sh` — one-way sync script (Codex TOML → Hermes YAML).
- `scripts/install-mcp-sync-launchagent.sh` — installs a LaunchAgent that runs the sync hourly and on login.

## Centralized Remote MCP Architecture (Cloudflare Workers)

When the user wants **all agents** (Hermes, Codex, VS Code, cluster, VPS agents) to use the same MCP servers without duplicating local stdio configs:

**Recommended Pattern:**
- Host MCP servers centrally as **Cloudflare Workers** or via Cloudflare AI Gateway.
- Use `url` + `headers` transport in all clients (no `command`/`args`).
- Maintain a single master file (`~/mcp-servers.yaml`) as source of truth.
- All clients consume the same remote endpoints.

**When to choose this:**
- User explicitly requests centralized remote access
- Multiple agents on different machines/VPS need the same tools
- User prefers Cloudflare over VPS or tunnels
- Long-term maintainability is priority over local simplicity

**Key Decision:**
- Cloudflare Workers > VPS + Tunnel (user preference)
- Single `url` config per server across all clients
- Token management via Cloudflare (cfat_ tokens)

## Automated Sync (LaunchAgent)

When the user wants the sync to happen automatically without manual intervention:

1. Place `sync-mcp-codex-to-hermes.sh` in `~/bin/`.
2. Install the LaunchAgent using `install-mcp-sync-launchagent.sh`.
3. The agent will keep Hermes MCP definitions in sync with Codex.

This pattern emerged when the user needed the native Open Design MCP (which uses App Translocation paths) to be reliably available in Hermes after Codex changes.
