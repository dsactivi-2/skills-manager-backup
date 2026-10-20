---
name: hermes-mcp-http
description: "Configure and debug Hermes MCP servers using HTTP transport with custom authentication headers (x-api-key, Authorization, etc.). Covers 401 troubleshooting, config reload requirements, and API-key based providers like Plane.so."
version: 1.0.0
author: Agent
license: MIT
---

# Hermes MCP HTTP Authentication

Use when adding or fixing HTTP-based MCP servers that require API keys or custom headers instead of OAuth.

## When to Use
- `hermes mcp test <name>` returns 401 Unauthorized
- `Auth: none` is shown even after editing config.yaml
- Provider docs specify `/http/api-key/mcp` or similar endpoints
- Need to pass `x-api-key`, `Authorization: Bearer`, or workspace slugs
- Adding a **public docs MCP** over HTTP (no auth) non-interactively

## Public docs MCP (no auth) — non-interactive add

`hermes mcp add NAME --url …` prompts for auth + tool enable. From agent/terminal without TTY, pipe answers:

```bash
hermes mcp add soniox-docs --url "https://soniox.com/docs/api/mcp/mcp" <<'EOF'
n
Y
EOF
# n = no auth, Y = enable all discovered tools
hermes mcp test soniox-docs
# Tools live only after /reload-mcp or a new session
```

Same pattern for other public Streamable-HTTP docs MCPs. Do **not** type a dummy API key when the server is public — first prompt is Y/n for auth; answer `n`.

Config after save:

```yaml
mcp_servers:
  soniox-docs:
    url: https://soniox.com/docs/api/mcp/mcp
    enabled: true
```

Soniox tools: `soniox_search_docs`, `soniox_read_page`, `soniox_read_section`, `soniox_docs_toc`, `soniox_docs_summary`, `soniox_full_docs` (last resort). Detail: `references/soniox-docs-mcp.md`. Product: skill `soniox-voice-platform`.

### xAI Docs MCP (public, Streamable HTTP)

```bash
printf 'n\nY\n' | hermes mcp add xai-docs --url "https://docs.x.ai/api/mcp"
hermes mcp test xai-docs
# also: grok mcp add --transport http xai-docs https://docs.x.ai/api/mcp
# Codex SoT: [mcp_servers.xai-docs] url = "https://docs.x.ai/api/mcp"
```

Endpoint: `https://docs.x.ai/api/mcp` · Auth: none · Tools (4):
- `list_doc_pages`
- `get_doc_page` (slug e.g. `developers/quickstart`)
- `search_docs` (query, max_results 1–20)
- `get_llms_txt` (large — last resort)

Hermes tool names after load: `mcp__xai_docs__*` / deferred catalog. Live only after `/reload-mcp` or new session.

### n8n Docs MCP (public GitBook, Streamable HTTP) — verified 2026-09-01

This is **n8n product docs**, not the n8n-lk instance (`n8n-livekit` stays the workflow MCP).

```bash
printf 'n\nY\n' | hermes mcp add n8n-docs --url "https://docs.n8n.io/~gitbook/mcp"
hermes mcp test n8n-docs
```

Endpoint: `https://docs.n8n.io/~gitbook/mcp` · Auth: none · Tools (3):
- `searchDocumentation`
- `getPage`
- `sendFeedback` (do not spam)

GET/browser extract on that URL returns JSON-RPC `Method not allowed` — expected; use MCP `tools/call`. Tools live only after `/reload-mcp` or a new session. Detail: `references/n8n-docs-mcp.md`.

### Lovable MCP (`https://mcp.lovable.dev`) — verified 2026-08

DCR is **blocked** (`invalid_client_metadata`: "Dynamic client registration is restricted to approved partners"). Do **not** `hermes mcp add lovable --auth oauth` and hope DCR works.

Use Lovable's **public** OAuth client ID (same as Cursor/VS Code) and skip DCR:

```bash
hermes config set mcp_servers.lovable.url "https://mcp.lovable.dev"
hermes config set mcp_servers.lovable.auth oauth
hermes config set mcp_servers.lovable.oauth.client_id 6d465f583e1e4ce5801b1616f735670c
hermes config set mcp_servers.lovable.enabled false
hermes mcp login lovable          # browser OAuth; 39 tools on success
hermes config set mcp_servers.lovable.enabled true
hermes mcp test lovable           # Auth: OAuth 2.1 PKCE, 39 tools
```

Docs still list only ChatGPT/Claude/Cursor/VS Code — Hermes works anyway with that public `client_id`. No API-key path exists. Tokens: `~/.hermes/mcp-tokens/lovable.{json,client.json,meta.json}` (refresh_token present). Tools in-session only after `/reload-mcp` or a new session. Skill: `lovable-mcp` (`https://mcp.lovable.dev/skill.md`). Credits: `create_project` + `send_message`.

## OAuth-based MCP servers (browser login — user must do it)

Some HTTP MCP servers authenticate by **browser OAuth, not a header/API key**
(e.g. Fish Audio at `https://api.fish.audio/mcp` — official docs: "OAuth
sign-in, no API key"). These have a registration + login flow that differs from
the header pattern, and a hard limit for agents. Verified 2026-08.

**Do NOT just add a bare URL for an OAuth server.** A bare-URL entry registers
as `auth: none`. Then:
- `hermes mcp test <name>` → **`401 Unauthorized` / `Auth: none`** (expected, no creds).
- `hermes mcp login <name>` → **refuses**: `Server '<name>' is not configured
  for OAuth (auth=None)`. Login only works if the server was added `--auth oauth`.

Correct registration (must declare OAuth up front):

```bash
hermes mcp add <name> --url https://api.fish.audio/mcp --auth oauth
```

**PITFALL — `add --auth oauth` silently DROPS the `auth` key (verified Fish, 2026-08).**
When `add` can't complete OAuth non-interactively it still offers "Save config
anyway?" — but the saved entry contains only `url:` + `enabled: false`, **NOT
`auth: oauth`**. So the very next `hermes mcp login <name>` refuses with
`Server '<name>' is not configured for OAuth (auth=None)` — a chicken-and-egg:
`login` needs `auth: oauth` to exist, `add` never wrote it. Break the loop by
setting the key explicitly, THEN login:

```bash
hermes config set mcp_servers.<name>.auth oauth        # add drops this — set it back
hermes config get mcp_servers.<name>                   # confirm: url + enabled + auth: oauth
hermes mcp login <name>                                # NOW login works
```

`hermes mcp login` keys off `auth`, not `enabled`, so you can login while the
entry is still `disabled`, then flip `enabled` after.

**The initial browser OAuth MUST be run by the USER in an interactive TTY.**
An agent/background terminal is non-interactive, so `add --auth oauth` and
`login` both fail there with:
`OAuth error: non-interactive environment and no cached tokens found. Run
'hermes mcp login <name>' interactively first.` The agent can register the
server (it saves **disabled**), but only the user can complete the browser
sign-in. Hand these commands to the user:

```bash
hermes config set mcp_servers.<name>.auth oauth      # if add dropped it (see pitfall above)
hermes mcp login <name>                              # opens browser OAuth
hermes config set mcp_servers.<name>.enabled true    # then enable
hermes mcp test <name>                               # expect ✓ Connected
```

After login, tokens land in `~/.hermes/mcp-tokens/<name>.{json,client.json,meta.json}`
(`fish-audio.json` carries access_token **+ refresh_token**, so the 1h expiry
auto-renews — no re-login). The agent CAN use these before any reload — see
`references/mcp-oauth-direct-token-client.md`.

After a successful login, tokens are cached; later sessions reconnect without
re-login. Tools go live only after `/reload-mcp` or a new session — and a green
`test` still needs one real tool call to confirm.

Config write note: the agent **cannot** patch `~/.hermes/config.yaml`
(refused as security-sensitive, `hermes_config_mod`). Use `hermes config set
mcp_servers.<name>.<key> <value>` or `hermes mcp add`, or hand the YAML to the
user. `hermes config set ... enabled true` writes valid YAML `true` (not Python
`True`) — verify with a read afterward.

## User pasted YAML (`url` + `headers.Authorization` Bearer)

Denis often pastes a ready `mcp_servers.<name>:` block. That **is** Freigabe to add — do not ask again. Do **not** echo the token in the reply. Do **not** write it to memory.

This Mac’s live HTTP MCPs (dograh-voiceeu `X-API-Key`, recruiting-crm `Authorization`) use Hermes field **`headers:`**, not `http_headers`. `hermes config get mcp_servers.dograh-voiceeu` is the local shape.

Do not `patch` `~/.hermes/config.yaml`. Set keys:

```bash
hermes config set mcp_servers.<name>.url "https://…/mcp"
hermes config set mcp_servers.<name>.enabled true
hermes config set mcp_servers.<name>.timeout 120
hermes config set mcp_servers.<name>.connect_timeout 30
hermes config set mcp_servers.<name>.headers.Authorization "Bearer $TOKEN"
# or .headers.X-API-Key for Dograh OSS
hermes config get mcp_servers.<name>   # redact before showing the user
hermes mcp test <name>                 # Connected + tool list ≠ tools in this chat
```

**PITFALL** — user pastes bare token value for Authorization (no 'Bearer ' prefix) → always prepend the scheme before `config set` — the Worker returns 401 on the bare value.

Then: if `tool_search` already returns `mcp__<name>__*`, probe now. Else tell the user tools appear only after `/reload-mcp` or a new session. After tools exist in-chat: one **read-only** tool call, then explain in German what the probe proved — not `tool(args) = N`.

Skill on disk is not this step. If they only installed a skill, the MCP is still missing until the YAML is in config. Conversely: MCP already `✓ enabled` + test green is **not** a reason to reinstall skills.

Verified 2026-09-01: recruiting-crm Workers URL + Bearer via `config set` → `hermes mcp test` (7 → 9 after Worker 1.2.0 remap/unmap → **13** later same day: transitions/history/`set_application_status`). If catalog already has `mcp__recruiting_crm__*`, skip `/reload-mcp` and probe. `hermes mcp test` green + `tools/call` `replace` of undefined = Worker `SUPABASE_URL` missing, not a bad Bearer. Detail: `references/recruiting-crm-http-mcp.md`.

## Core Pattern (Plane.so example)

1. Update `~/.hermes/config.yaml`:

```yaml
mcp_servers:
  plane:
    url: https://mcp.plane.so/http/api-key/mcp
    http_headers:
      x-api-key: plane_api_...
      x-workspace-slug: activi
```

2. **Full restart required** — `hermes mcp test` and running sessions do **not** hot-reload `http_headers`.

3. Verify:

```bash
hermes mcp test plane
```

## Common Pitfalls
- Editing config without restarting Hermes → still shows "Auth: none"
- Using the OAuth URL (`/http/mcp`) when API-key endpoint is required
- Forgetting `x-workspace-slug` for multi-workspace providers
- sed/edit leaving placeholders instead of real values
- **Dograh OSS self-host:** `Authorization: Bearer dgr_…` can make `hermes mcp test` look OK while tools return **401** — use **`X-API-Key`**. See `references/dograh-mcp-setup.md` + skill `dograh-dual-instance`.
- **Expired OAuth MCP hijacks unrelated tools.** If `voice-ops-console` (or any `auth: oauth` server) has a dead refresh token, a CRM/`hermes mcp test` turn can still open that server's authorize URL. Live: `project-foundation-light.lovable.app/mcp` is **not** in Activi's Lovable Pro workspace (that workspace only lists Step2Job Relaunch + Phase One Complete). Disable the stale entry (`hermes config set mcp_servers.voice-ops-console.enabled false`) instead of completing the wrong login. Re-enable only after a workspace-owned `/mcp` URL + interactive `hermes mcp login`.
- **test green ≠ tools live:** after reload, one real tool call (e.g. list_workflows).
- **Skill ≠ MCP:** `npx skills add` and `npx plugins add` do not register `mcp_servers`. Hermes is not an Open Plugin target. User "verbunden?" → `hermes mcp list` / `hermes mcp test <name>`, not the skill or plugin path. Repo `.mcp.json` is for other clients; Hermes only reads `~/.hermes/config.yaml`.
- **taskfuel is CLI, not a second MCP.** Official setup picks one path. With a working `taskfuel` binary, do **not** also add `https://app.taskfuel.ai/mcp` — same prepaid balance, duplicate tools, two connections to keep signed in. Paid calls: `taskfuel whoami` then `discover` / `call --quote`. Vendor skill is user-owned (`hermes curator adopt taskfuel` if it should take Hermes-specific notes).
- **GitHub stdio Python MCP is not HTTP.** Clone + venv + `hermes mcp add --command` (PromptQL, bhtelecom). `--args` must be last or extra flags land in `args`. FastMCP servers: pin `mcp<2` in the **server** venv. PromptQL v1 vs prompt.ql.app v2 vs GraphiQL: `references/promptql-mcp-stdio.md`. Broader stdio client docs: skill `native-mcp` (user-owned — `hermes curator adopt native-mcp` if it should take this file).
- **QMD is local HTTP MCP + CLI.** Daemon `qmd mcp --http --daemon`; Hermes URL `http://localhost:8181/mcp` (health on `localhost`, not `127.0.0.1` if the process listens on `[::1]`). Same search via `qmd search`/`query`. Detail: `references/qmd-http-mcp.md`.
- **User YAML uses `headers:`** on this Mac; Plane docs say `http_headers`. Match the live sibling (dograh-voiceeu), not the Plane snippet.
- **Profile env split:** `hermes -p barbares` reads profile `.env` — also set `MCP_DOGRAH_VOICEEU_API_KEY` there.
- **Codex name/URL mismatch:** server named voiceeu still on cloud URL — check URL when dual-wiring.

## Verification Commands
```bash
grep -A 8 "plane:" ~/.hermes/config.yaml
hermes mcp test plane
hermes mcp test dograh-voiceeu   # expect X-API-Key in auth line
```

## Codex as Source of Truth
In this environment `~/.codex/config.toml` is often the canonical source for MCP servers (including Plane). Prefer TOML headers, then Codex→Hermes sync and restart. **Exception:** fixing a live Hermes session — edit `~/.hermes/config.yaml` + `.env`, reload MCP, verify test + tool call.

```toml
[mcp_servers.plane]
url = "https://mcp.plane.so/http/api-key/mcp"
http_headers = { "x-api-key" = "plane_api_...", "x-workspace-slug" = "activi" }
```

## References
- references/recruiting-crm-http-mcp.md (Workers URL + Bearer via `hermes config set`, no token in skill)
- references/dograh-mcp-setup.md (Cloud + voiceeu dual MCP, X-API-Key)
- references/langfuse-mcp-basic.md (dual LF MCP Basic auth + pairing)
- references/plane-mcp-401.md (error transcripts and exact config that worked)
- references/plane-mcp-codex-sync.md (Codex TOML pattern and sync workflow)
- references/profile-env-split.md (default vs profile .env)
- references/soniox-docs-mcp.md (public Soniox docs MCP + non-interactive install)
- references/n8n-docs-mcp.md (GitBook MCP docs.n8n.io, not n8n-lk)
- references/drive-oauth-mcp-via-ondisk-token.md (agent drives an OAuth MCP directly via the cached token — no session reload needed; Fish Audio verified)
- references/promptql-mcp-stdio.md (hasura/promptql-mcp v1 stdio: FastMCP pin, --args last, three secrets, three UIs)
- references/qmd-http-mcp.md (local QMD daemon :8181, collection ai-bibliothek, skill qmd)
- references/supabase-mcp.md (hosted OAuth MCP, project-scoped URL vs global catalog, plugins vs skills vs MCP)
