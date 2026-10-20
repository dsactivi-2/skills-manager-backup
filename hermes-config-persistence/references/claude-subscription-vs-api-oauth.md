# Claude subscription (Pro/Max) vs API key, and OAuth in Hermes

Session-verified detail behind the "Subscription vs API key" section of SKILL.md.

## The user's question pattern
"Can I connect Claude with my plan/subscription in OpenRouter's BYOK setting so
I use the abo instead of paying per token?" — Answer: **No.**

## Why not (verified from OpenRouter docs + provider model)
- OpenRouter **BYOK = Bring Your Own API *Key***. It accepts only an Anthropic
  **API key** (console, per-token billing). It has no field for a subscription
  OAuth token.
- A **Claude Pro/Max subscription** (claude.ai / Claude Code) is an **OAuth**
  grant tied to a monthly quota. Anthropic deliberately does NOT expose API
  access for the subscription — subscription and API are separate products.
- Therefore a subscription cannot be routed through OpenRouter at all. The only
  subscription path in Hermes is the **direct anthropic provider over OAuth**.

## Live commands used this session (all succeeded)
```
hermes auth add --help          # shows --type {oauth,api-key}, provider positional
hermes auth list                # lists credential pool by provider + label
# anthropic showed 3 oauth creds: "dashboard PKCE" (active ←), "hermes_pkce", "claude_code"
```
`hermes chat --provider anthropic -m claude-sonnet-4-5 -Q -q "..."` connected
over OAuth WITHOUT an API key — proving the OAuth abo path works. It then
returned the quota error below (a state, not a config fault):
```
HTTP 400: You're out of extra usage. Add more at claude.ai/settings/usage ...
Claude subscription usage is exhausted for claude-sonnet-4-5
```

## Switching Hermes to the abo (direct anthropic OAuth)
```
hermes config set model.provider anthropic
hermes config set model.default claude-opus-4.5   # bare name, NO "anthropic/" prefix
```
Or live: `/model claude-sonnet-4-5 --provider anthropic`.
Note the base_url trap from the main SKILL: for native anthropic the base_url
must NOT point at openrouter.ai — leave it empty/native.

## Identifying which account a stored OAuth credential belongs to
NOT possible from `~/.hermes/auth.json`. Its per-credential fields are only:
`id, label, auth_type, priority, source, last_status, expires_at_ms,
request_count, secret_fingerprint` — no email/name/org, and the token secret is
not in cleartext at that path. Attempts to decode as a JWT or hit
`api.anthropic.com/api/oauth/profile` fail (opaque token / not accessible).
The reliable way to see the account is to re-run the browser login:
```
hermes auth add anthropic --type oauth
```
You see the account in the browser during the PKCE flow. Offer this to the user
rather than guessing an account identity.

## OAuth-subscription → OpenAI-compatible-API proxies (asked for this session)
User wanted a proxy to log in with the Claude OAuth subscription and expose an
OpenAI-compatible API to register in **OpenRouter BYOK**. Verified conclusions:

- **The OpenRouter-BYOK leg is impossible.** OpenRouter's BYOK doc
  (openrouter.ai/docs/guides/overview/auth/byok) only accepts provider API keys
  (Anthropic API key, Azure, Bedrock, Vertex). There is NO custom base-URL /
  self-hosted-endpoint field — this is a known, requested-but-unshipped feature.
  Plus OpenRouter runs in the cloud and cannot reach a local `localhost` proxy.
  So "abo-OAuth → local proxy → OpenRouter BYOK" cannot be built.

- **The proxies themselves exist** and turn an OAuth CLI login (Claude
  Code / Pro / Max, also Codex/Gemini/Grok/Kimi) into a local OpenAI-compatible
  endpoint. Mechanism: they spawn the vendor CLI as a subprocess
  (`claude --print` / `claude -p`) — the only usage Anthropic tolerates as
  programmatic; Anthropic blocks OAuth tokens on direct third-party API calls.
  ToS grey area, account-ban risk — always tell the user this.

  | Proxy | Lang | Notes |
  |-------|------|-------|
  | CLIProxyAPI — github.com/router-for-me/CLIProxyAPI | Go | Most maintained (~44k★, MIT, active). GUI: router-for-me/EasyCLI (Tauri). Web mgmt UI: router-for-me/Cli-Proxy-API-Management-Center. Endpoints `/v1/chat/completions`, `/v1/responses`, `/v1/models`. Multi-account pools + cooldown/refresh. EasyCLI lists **Hermes Agent** as an auto-configurable client. Tokens in `~/.cli-proxy-api/`. Docker supported. |
  | claude-code-proxy (lib.rs) | Rust | Spawns `claude --print --output-format stream-json`. `PROXY_API_KEY=... claude-code-proxy` → `http://localhost:8080/v1`. |
  | claude-max-api-proxy (wende fork of joesobo/sethschnrt) | Node/npm | Wraps Claude Code CLI subprocess, localhost:3456. |
  | meridian (github.com/rynfar/meridian) | — | Built on the Claude Agent SDK; localhost:3456; OpenCode plugin. |
  | auth2api (github.com/AmazingAng/auth2api) | — | Claude + Codex + experimental Cursor OAuth → OpenAI API, per-provider pools. |

- **Correct wiring for Hermes** (if the user still wants a proxy): run the proxy
  locally, then set Hermes as a custom OpenAI-compatible provider:
  ```
  hermes config set model.base_url http://127.0.0.1:<port>/v1
  hermes config set model.api_key <proxy-key-or-placeholder>
  # model.provider stays a generic openai-compatible custom endpoint
  ```
  But this adds nothing over Hermes' native `anthropic` OAuth provider, which
  already speaks the abo directly. The proxy only earns its keep for
  OpenAI-ONLY clients that can't do native Anthropic OAuth.
