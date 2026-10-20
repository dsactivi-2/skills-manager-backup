# Grok Build — Headless & ACP notes

Source: xAI Build docs (Headless & Scripting / ACP). Keep lean; prefer live `grok --help` for flag drift.

## Headless output formats

- `plain` — human-readable text (default)
- `json` — one JSON object at end
- `streaming-json` — newline-delimited events as they arrive

```bash
grok -p "List TODO comments" --output-format json
grok -p "Explain the architecture" --output-format streaming-json
```

## Scripting flags of interest

| Flag | Notes |
|------|--------|
| `--no-auto-update` | Skip background update checks in CI/scripts |
| `--always-approve` | Auto-approve tool executions |
| `--no-alt-screen` | Inline run (no alternate screen / fullscreen TUI) |
| `-s / -r / -c` | Session create/resume/continue; store under `~/.grok/sessions` |

Persistent disable updates in `~/.grok/config.toml`:

```toml
[cli]
auto_update = false
```

## ACP (`grok agent stdio`)

- Transport: JSON-RPC over stdin/stdout
- Auth: local `grok login` cache **or** `XAI_API_KEY`
- Flow sketch:
  1. `initialize` (protocolVersion, clientCapabilities: fs/terminal)
  2. `authenticate` with `methodId` = `xai.api_key` if env key + method available, else `cached_token`
  3. `session/new` with `cwd`, `mcpServers: []`
  4. `session/prompt` with content blocks
- Text path: assistant tokens arrive as `session/update` with `sessionUpdate == "agent_message_chunk"` and `content.text`
- `session/prompt` result carries completion metadata (`stopReason`), not necessarily full text

Minimal Node pattern: spawn `grok agent stdio`, line-parse stdout JSON, map pending request ids, accumulate `agent_message_chunk` text, kill process on exit.

Auth failure message (typical):

```
Not signed in. To authenticate without a browser, run:
  grok login --device-code
Alternatively, set the XAI_API_KEY environment variable or run `grok login` …
```

## Auth failure forensics

`~/.grok/logs/unified.jsonl` markers:

- `oidc try_refresh_pure terminal error` + `invalid_grant`
- `auth.refresh.permanent_failure` / `RefreshTokenRejected`
- `auth: cleared credentials after permanent refresh failure` → **file deleted**

Do not restore expired `auth.json` backups; re-login.

## Related agent subcommands

```
grok agent stdio      # ACP
grok agent headless   # headless over Grok WebSocket relay
grok agent serve      # WebSocket server
grok agent leader     # shared leader process for clients
```
