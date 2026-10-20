---
name: zep-memory-platform
description: "Use when installing or operating Zep (zepctl, MCP, Codex)."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [Zep, MCP, Memory, Codex, zepctl]
    related_skills: [hermes-mcp-http, native-mcp, honcho-cli, honcho-integration, codex]
---

# Zep Memory Platform

Use when the user pastes GetZep install snippets or asks for Zep docs, Memory MCP, `zepctl`, or the Codex `building-with-zep` plugin.

Three different surfaces. Do not mix them.

| Surface | URL / install | Auth | Role |
|---|---|---|---|
| Docs MCP | `https://docs-mcp.getzep.com/mcp` | none | Public Zep docs for coding agents |
| Memory MCP | `https://api.getzep.com/mcp` | OAuth / IdP | One end-user's graph; MCP seats |
| CLI | `zepctl` | API key or bearer | Project admin |

`/sse` on the docs server is deprecated. Use Streamable HTTP `/mcp`.

## Codex plugin (Claude/Codex/Cursor path)

Not `hermes skills install`. Not `npx plugins add`.

```bash
codex plugin marketplace add getzep/building-with-zep-plugin
codex plugin add building-with-zep@building-with-zep --json
codex plugin marketplace list
codex plugin list --json
```

Verified: marketplace name `building-with-zep`; plugin `building-with-zep@building-with-zep` **0.4.2**, cache under `~/.codex/plugins/cache/building-with-zep/`.

The plugin bundles the Docs MCP plus a build-on-Zep skill. Hermes is an "other MCP client" — add the Docs MCP yourself (see below) instead of expecting the Codex plugin to register Hermes tools.

## zepctl (Homebrew)

```bash
brew tap getzep/zepctl https://github.com/getzep/zepctl.git
brew trust getzep/zepctl
brew install --formula getzep/zepctl/zepctl
zepctl version
```

Homebrew tap-trust is required. `brew install` after an untrusted tap fails with `Refusing to load formula … from untrusted tap`. Trust the tap, then install. Do not start a second `brew install` while one is compiling (Cellar lock).

Verified: `zepctl 0.2.1` at `/opt/homebrew/bin/zepctl`.

## Docs MCP on Hermes

Public Streamable HTTP, no API key. Same non-interactive pattern as Soniox/xAI docs:

```bash
printf 'n\nY\n' | hermes mcp add zep-docs --url "https://docs-mcp.getzep.com/mcp"
hermes mcp test zep-docs
```

Tools live only after `/reload-mcp` or a new session. Do not invent a dummy API key — first prompt is Y/n for auth; answer `n`.

## Memory MCP

Endpoint: `https://api.getzep.com/mcp` (managed cloud; BYOC uses the same `/mcp` path on the private API host).

This is **not** the Docs MCP. It serves one authenticated user's graph. Login is IdP-brokered (Google Workspace default; custom OIDC is Enterprise/BYOC). The client never registers with the IdP. Uses per-account MCP seats.

User-graph tools take **no** user/graph/project argument — the token binds identity + project. Standalone-graph tools (`*_in`, `list_graphs`) appear only when the project connection allows it.

Do not add this to Hermes as `auth: none`. It needs OAuth (`hermes mcp add zep-memory --url https://api.getzep.com/mcp --auth oauth` then user-run `hermes mcp login`). Use `setup_mcp` in desktop so the user can consent. Do not complete browser login from a non-interactive agent TTY.

## SDK latency (when writing Zep client code)

- Reuse one SDK client (connection pool). No per-request client.
- Conversations: `thread.add_messages`. Large docs/tool output: `graph.add` (chunk; up to 10k chars/call). Bulk: `zep-ingest` or Batch API, not parallel `graph.add`.
- Prefer `thread.add_messages(..., return_context=True)` over a second `get_user_context` round-trip.
- Search queries short and specific (truncated at 8192 tokens).
- `user.warm(user_id)` on login / app-open so retrieval hits the hot cache.

## Pitfalls

- Docs MCP ≠ Memory MCP. Pasted GetZep pages look similar; check the slug (`docs-mcp-server` vs `memory-mcp-server`).
- Codex plugin does not configure Hermes MCP.
- `brew tap` alone is not enough after Homebrew tap-trust; run `brew trust getzep/zepctl` first.
- Concurrent `brew install zepctl` hits `A brew install zepctl process has already locked /opt/homebrew/Cellar/zepctl` — wait, do not kill-and-retry unless the first process is dead.

See also: `hermes-mcp-http` (public docs MCP add), `native-mcp`, `codex` (exec vs plugins).
