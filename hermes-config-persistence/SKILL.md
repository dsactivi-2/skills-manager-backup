---
name: hermes-config-persistence
description: Persist Hermes session settings to config.yaml and interpret "session only — add --global to persist" prompts. Covers hermes config get/set/unset, dotted-key traps, model-switch base_url trap, Ollama Cloud 429/wrong-account (key vs base_url; auth reset needs a credential target), IANA timezone, HERMES_TOOL_PROGRESS_MODE, Bedrock doctor vs IAM, recognized keys, prompt-caching, Claude subscription OAuth vs API key. Use when persisting settings, Ollama Cloud quota/account mismatches, hermes doctor config issues, or Claude abo vs API-key questions.
---

# Hermes Config Persistence

How to make session-scoped Hermes settings permanent, and how to read the
"(session only — add --global to persist)" prompts correctly.

## When this applies
- User ran a slash command (`/model`, `/reasoning`, `/fast`, personality, busy
  mode) and saw a "session only — add --global to persist" / "session only"
  message, and wants it permanent.
- User asks "what does this setting/message mean" for a Hermes config value.
- Any request to change durable Hermes behaviour → belongs in `config.yaml`,
  NOT in `.env`. `.env` is for secrets only (API keys, tokens).

## Core CLI (all live-verifiable)
- `hermes config path`        → prints config file path (~/.hermes/config.yaml)
- `hermes config show`        → full resolved config
- `hermes config get <key>`   → one resolved value (dotted key, e.g. `model.default`)
- `hermes config set <key> <val>` → persist a value
- `hermes config unset <key>` → remove a value
- Keys are dotted paths into the YAML tree: `model.default`, `model.provider`,
  `model.base_url`, `prompt_caching.cache_ttl`, `openrouter.response_cache`.

## The "session only — add --global to persist" message
This message comes from the `/model` switch handler (cli.py ~L8490), NOT from a
separate cache toggle. It means: **the model you just switched to is active only
for this session; config.yaml still holds the OLD model.** To persist a
`/model` switch you either re-run it with `--global` in the TUI, or set the keys
directly via CLI (below). The nearby "Prompt caching: enabled" line is
informational — caching auto-enables for Claude models on OpenRouter /
Anthropic; it is NOT a toggle and has no `--global` of its own.

## Hugging Face: router vs dedicated endpoint

`provider: huggingface` (`hf`) + `HF_TOKEN` is **Inference Providers** (`router.huggingface.co/v1`), not a dedicated Inference Endpoint. Dedicated endpoints are OpenAI-compatible **custom** URLs. Do not set `provider: huggingface` for a `*.endpoints.huggingface.cloud` host — that still hits the router.

Per-profile dedicated endpoint (profile home `~/.hermes/profiles/<name>/`):

```yaml
model:
  provider: custom
  base_url: https://<endpoint-id>.endpoints.huggingface.cloud/v1
  default: <id from GET /v1/models only>
  key_env: HF_TOKEN
```

Put `HF_TOKEN=` in that profile's `.env` (mode 600), not in `config.yaml`. Custom runtime reads `model.key_env` / `model.api_key` for a trusted config `base_url`; it does **not** auto-pick `HF_TOKEN` the way the huggingface provider does. Copy the assignment line with Python; never `source` a Hermes `.env` — unquoted values and comments execute as shell.

Live order before writing `model.default`:
1. Parse `HF_TOKEN=` from the profile `.env` (presence + length only in output).
2. `GET /health` — 200 means the replica is up; 503 is scaled-to-zero / cold, not a bad URL.
3. `GET /v1/models` — use `data[0].id` **verbatim** (vLLM repo path, often `org/Name-…`). Dashboard nicknames and shortened slugs 404 (`The model does not exist`).
4. `POST /v1/chat/completions` with that id. Reasoning/vLLM builds can return `choices[0].message.content: null` and only `reasoning` when `max_tokens` is tiny — that is still a 200, not a failed bind.
5. New CLI session for the profile (`<wrapper>` or `hermes -p <name>`). Wrappers live in `~/.local/bin/<name>` → `hermes -p <name>`.

If `hermes -p <name> config set` prints `completing source-update dependencies` and starts a Desktop rebuild, stop waiting on the CLI: patch that profile's `config.yaml` directly. A source-update is not a failed profile start; the next `hermes` after a finished update should chat.

A token pasted in chat is leaked. Write it to the profile `.env` if asked, never echo it, tell the user to revoke/rotate on huggingface.co/settings/tokens.

## Persisting a model switch by hand — the base_url TRAP
When you persist a model switch via CLI, you MUST sync FOUR keys, not two.
Setting only `model.default` + `model.provider` leaves `model.base_url` pointing
at the OLD provider's endpoint, which silently breaks the new provider.

Guard in code (hermes_cli/models.py ~L4349): if `provider == openrouter` but
`base_url` does NOT contain `openrouter.ai`, the provider is silently reinterpreted
as `custom` → wrong endpoint, auth fails or wrong model served.

Correct sequence (example: switch to Claude on OpenRouter):
```
hermes config set model.default "anthropic/claude-opus-4.8"
hermes config set model.provider "openrouter"
hermes config set model.base_url "https://openrouter.ai/api/v1"   # MUST match provider
hermes config set model.api_mode <value-or-unset>                  # None clears it
```
Always `hermes config get model.base_url` AFTER setting provider and confirm the
host matches the provider. This is the #1 silent breakage.

## Ollama Cloud — 429 / wrong account is the KEY, not base_url
Cloud base URL is `https://ollama.com/v1` (`provider: ollama-cloud`, env
`OLLAMA_BASE_URL` + `OLLAMA_API_KEY`). A correct URL with the wrong key still
hits a different Ollama user's quota.

- A 429 `you (<name>) have reached your monthly usage limit` names the account
  bound to the key. Do not change base_url to "fix" it.
- Identify without printing the secret: `POST https://ollama.com/api/me` with
  `Authorization: Bearer <key>` (GET returns 405). Report `Name` / `Email` plus
  key prefix/len only. GitHub org / GitHub username is not the Ollama `Name` —
  trust `/api/me`, not the org slug.
- After replacing `OLLAMA_API_KEY`, clear the pool cooldown with a TARGET:
  `hermes auth reset ollama-cloud 1` (or the credential id/label from
  `hermes auth list ollama-cloud`). Bare `hermes auth reset ollama-cloud`
  reports "Reset status on 0 credentials" and leaves the 429 timer even when
  the new key already 200s on chat.
- `/model … --provider ollama-cloud` is session-only until the four model keys
  are persisted; `hermes config get model.provider` may still be openai-codex.

## IANA timezone (not UTC offsets)
`timezone:` must be an IANA name (`Europe/Berlin`). Values like `UTC +2` fail
`hermes doctor` and silently fall back to server-local for the agent clock and
cron. Set with `hermes config set timezone Europe/Berlin`.

## Bedrock doctor vs IAM
`UnrecognizedClientException` / `InvalidClientTokenId` on
`ListFoundationModels` is a broken AWS credentials chain
(`~/.aws/credentials`), not missing IAM `bedrock:ListFoundationModels`.
`bedrock.discovery.enabled false` does not skip the doctor connectivity probe
while AWS creds exist. Do not delete AWS credentials unless the user asks.

## `.env` comments are not keys
A commented `# GOOGLE_API_KEY=…` is not a configured key. Check assignment
lines (`KEY=value`), not substring presence in the file. Re-run `hermes doctor`
live — a pasted issue list from session start can already be stale.

## Profile secrets: `.env`, never shell rc
Durable keys for a named profile belong in `~/.hermes/profiles/<name>/.env`
(mode 600). Hermes wrappers (`~/.local/bin/<name>` → `hermes -p <name>`) do
not source `~/.bash_profile` or `~/.zshrc`. `echo 'export KEY=…' >> ~/.bash_profile`
looks successful and still never reaches that profile; macOS Terminal is zsh so
`.bash_profile` often never loads; each rerun appends duplicates.

Upsert KEY= lines in Python (replace existing same-name lines, chmod 600).
Report only key names, presence, and mode — never values. A token pasted in
chat is leaked: write if asked, do not echo, tell the user to rotate. New
profile session required after `.env` changes.

## Fresh named profile (stock / naked, not a clone)

When the user wants a new profile that is the **Grundbasis** (bundled skills only,
no extra MCPs, no user plugins such as Jeff/hermes-jev): create it **without**
`--clone` / `--clone-from` / `--clone-all`. Clone copies skills, plugins, MCP
config, and identity files from the source and is the wrong shape for “nackt”.

```bash
hermes profile create <name> --description "…"
```

Profile ids are lowercase alphanumeric (hyphens allowed). Create already writes
`~/.local/bin/<name>` unless `--no-alias`. Custom wrapper name:
`hermes profile alias <name> --name <alias>` — the alias is a **filename**, so
it cannot contain spaces.

`hermes <name>` as two words is not a Hermes subcommand. To make `hermes <name>`
start that profile in interactive zsh, add a function that special-cases the
first argument and then `exec`/`command hermes -p <name> "$@"`. Do not wrap the
binary for all callers unless asked; scripts should use the wrapper or
`hermes -p <name>`.

Fresh create **seeds `model` (+ the matching `providers:` / `custom_providers:`
entry) from the active profile**. xAI OAuth lives in the **root** credential
pool (`hermes auth list xai-oauth`); a named profile does not need a copied
`.env` key to reuse it. Verify with `hermes -p <name> auth list xai-oauth` and
`hermes -p <name> config get model` — report labels/ids/presence, never tokens.
Create may print “no API keys yet”; that refers to the profile `.env`, not the
OAuth pool.

User plugins are opt-in via that profile’s `plugins.enabled`. A non-clone has
no Jeff/hermes-jev unless you enable it. Bundled backends (browser, image,
gateway adapters) listing as enabled is stock, not a cloned plugin set.
`hermes -p <name> mcp list` is empty on a stock create — do not copy default’s
MCP servers unless asked.

`--no-skills` is emptier than “basic”: it opts the profile out of bundled-skill
sync. Use it only when the user wants zero bundled skills.

On a multiplexed install, create notifies the running gateway; confirm with
`hermes gateway list` that the new name shares the same PID. Do not start a
second per-profile gateway. Do not `gateway restart` unless list shows it
unserved.

## HERMES_TOOL_PROGRESS_MODE (deprecated)
Behavioural, not a secret. Doctor warns: use `display.tool_progress` in
`config.yaml` (warn-only, not auto-migrated). Valid: `off` | `new` | `all` |
`verbose` (gateway extra: `log`). Unknown values such as `structured` coerce
to `all`. Set `hermes config set display.tool_progress all`, then delete the
`.env` line. Cycle in-session with `/verbose`.

When the user asks what a doctor/config warning *means*: first sentence = what they see and that nothing is broken; then the one switch. Options are volume, not repair. No markdown tables in CLI.

## Doctor tool availability "system dependency not met"
That phrase is the generic fallback when the toolset has no `requires_env` to print — not a missing OS package. Read the toolset `check_fn`.

- **a2a** (default-off): `hermes tools enable a2a` and `hermes config set platforms.a2a.enabled true`. Without a bearer token the inbound bind stays localhost-only. Takes effect on a new session.
- **browser-cdp**: not a `hermes tools enable` name (`Unknown toolset`). Gate is a non-empty `browser.cdp_url` or `BROWSER_CDP_URL`. Local agent-browser hides its CDP port. Do not invent a URL or start Chrome with a debug port unless the user asks.
- **connections**: the toolset can already be enabled; `check_fn` needs Nous Portal login (`hermes portal`) and the portal `managed_tools` claim. `connectors.enabled` is not a recognized key — `unset` it if you set it.

## hermes doctor npm (root vs web workspace)
Root / agent-browser: `cd ~/.hermes/hermes-agent && npm audit fix --workspaces=false`.
Do not `npm audit fix --force` on the web workspace. Doctor treats moderate-only
web vulns as a check, not an issue to address.

## Subscription (Pro/Max) vs API key — how to run Claude on the abo
Recurring user question: "can I use my Claude Pro/Max subscription instead of
paying OpenRouter/API per token?" Answer, verified from OpenRouter docs +
Hermes auth internals:

- A Claude **subscription** (claude.ai Pro/Max, incl. Claude Code) is an
  **OAuth** login bound to a monthly usage quota. It is a DIFFERENT product from
  the Anthropic **API** (console API key, per-token billing). Anthropic does NOT
  expose API access for the subscription — the two are not interchangeable.
- **OpenRouter BYOK = "Bring Your Own API **Key**"** — it accepts ONLY an
  Anthropic API key, never a subscription OAuth token. So you **cannot** wire a
  Claude subscription into OpenRouter's BYOK setting. OpenRouter always bills the
  API path (its own credits, or your BYOK API key).
- The ONLY way to use the subscription in Hermes is the **direct Anthropic
  provider with OAuth**, NOT via OpenRouter:
  ```
  hermes config set model.provider anthropic
  hermes config set model.default claude-opus-4.5   # bare name, no vendor prefix
  # (base_url can stay empty for native anthropic — no openrouter.ai host)
  ```
  Live-switch in a session: `/model claude-sonnet-4-5 --provider anthropic`.
- Hermes stores Anthropic OAuth logins in the credential pool. `hermes auth list`
  shows them by label; the subscription/Claude-Code login typically carries a
  `claude_code` label (others: `dashboard PKCE`, `hermes_pkce`). Add/refresh a
  login with `hermes auth add anthropic --type oauth` (opens a browser; you SEE
  which account you're signing in with — this is also the only reliable way to
  identify which account a stored credential belongs to).
- Identifying the account behind an existing stored OAuth credential is NOT
  possible from `~/.hermes/auth.json`: it stores only `label`, `id`,
  `expires_at_ms`, and a `secret_fingerprint` — no email/name/org, and the token
  secret is not in cleartext at that path. Don't try to decode it; re-run the
  OAuth login to see the account.
- When Anthropic returns HTTP 400 "You're out of extra usage / subscription
  usage is exhausted", that is the ABO QUOTA, not a config error. Options: wait
  for the billing-cycle reset, or add extra usage at claude.ai/settings/usage.
  It's a state signal — do NOT record "anthropic provider broken" anywhere.

### OAuth-subscription proxies (CLIProxyAPI etc.) — and why NOT via OpenRouter
Users often ask for "a proxy where I log in with my Claude OAuth and get an
OpenAI-compatible API I can plug into OpenRouter BYOK." Two facts to deliver:
- **That exact chain is impossible.** OpenRouter BYOK takes only a provider
  API key and has NO custom-base-URL field; and OpenRouter is cloud-hosted, so
  it can never reach a `localhost` proxy anyway. You cannot put a subscription
  proxy behind OpenRouter.
- **Proxies DO exist** and convert an OAuth subscription login into a local
  OpenAI-compatible endpoint (`/v1/chat/completions`). They work by spawning
  the vendor CLI (e.g. `claude --print`) as a subprocess — the only path
  Anthropic tolerates as "programmatic use." Still a ToS grey area; account-ban
  risk. Options seen live: **CLIProxyAPI** (github.com/router-for-me/CLIProxyAPI,
  Go, most maintained, GUI = router-for-me/EasyCLI, explicitly lists Hermes
  Agent as an auto-configurable client), claude-code-proxy (Rust), meridian,
  auth2api, claude-max-api-proxy.
- **Correct wiring for Hermes:** point Hermes' `model.base_url` at the local
  proxy (`http://127.0.0.1:<port>/v1`) as a custom OpenAI-compatible provider —
  NO OpenRouter in between. But note: Hermes already speaks the abo directly via
  the native `anthropic` OAuth provider (above), so the proxy adds nothing for
  Hermes itself; it's only useful for OTHER OpenAI-only clients.
See references/claude-subscription-vs-api-oauth.md for the full proxy list.

## Recognized vs unrecognized keys
`hermes config set` on an unknown key succeeds but WARNS:
"'X' is not a recognized config key — saved anyway, but Hermes may not read it."
Treat that warning as a failure signal — the key probably does nothing. Verify
the real key from source (search cli.py / hermes_cli/ for the slash-command
handler) instead of guessing. Example mistake this session:
`prompt_caching.enabled` is NOT read by Hermes → `unset` it and persist the real
intent instead.

## Prompt caching config (what's actually adjustable)
Under `prompt_caching:` — only `cache_ttl` (e.g. `5m` or `1h`) is meaningful;
there is no `enabled` key (caching auto-enables for Claude). Under `openrouter:`
a separate response cache exists: `response_cache: true`, `response_cache_ttl`.
Caching stays intact only while the system prompt + toolsets are byte-stable for
the session; switching models mid-session invalidates it.

### "Is it caching right now?" — answer from the policy, not from config
Whether caching is ON is decided entirely by provider+model at agent init, NOT
by any config flag. The authoritative function is
`anthropic_prompt_cache_policy` in `agent/agent_runtime_helpers.py` (forwarded
from `run_agent.py:_anthropic_prompt_cache_policy`), returning
`(should_cache, use_native_layout)`. Key branches (verify by reading, ~L1857+):
- native Anthropic (`api_mode == anthropic_messages` + anthropic host) → `(True, True)`
- `(is_openrouter or is_nous_portal) and (is_claude or is_kimi)` → `(True, False)`
  — this is the common case: Claude/Kimi via OpenRouter or Nous Portal.
- Nous Portal Qwen → `(True, False)`; MiniMax / Alibaba-Qwen on their Anthropic
  wire → `(True, True)`; everything else → `(False, False)`.
`is_claude = "claude" in model.lower()`; `is_openrouter` = base_url host matches
`openrouter.ai`. So `anthropic/claude-opus-4.8` + `openrouter.ai/api/v1` → caching ON.
The startup line `💾 Prompt caching: ENABLED (...)` (agent_init.py ~L1434) fires
only when `_use_prompt_caching` is True — it's the ground-truth signal.

To VERIFY live: check the cached-token count OpenRouter reports on the NEXT
turn. First turn after a model switch is always low (cache is being written);
the ratio climbs on subsequent turns (observed 1%→67%→84%→97%). A low number on
turn 1 does NOT mean caching is broken.

## Finding the real key when unsure (source-of-truth workflow)
1. `hermes config path` and read the relevant block.
2. Locate the source: the `hermes` launcher in ~/.local/bin is a wrapper →
   real venv at ~/.hermes/hermes-agent/ (editable install; code is in the repo
   root, NOT site-packages).
3. `search_files` the repo for the exact on-screen message wording (e.g.
   "add --global to persist") to find the handler and the exact `save_config_value(...)`
   key it writes.

## Provider / model timeouts (reasoning models, Broken pipe)

Symptom: `API call failed after 3 retries: [Errno 32] Broken pipe` plus Hermes
text about "thinking phase exceeded the upstream proxy's idle timeout". Common
on reasoning models (grok-4.5, o1/o3, deepseek-r1, nemotron, …) when no content
token arrives before the stale detector / upstream idle cap.

Authoritative keys (docs "Provider Timeouts" + `hermes_cli/timeouts.py`):

| Level | Stale (non-stream idle) | Request wall |
|-------|-------------------------|--------------|
| Provider | `providers.<id>.stale_timeout_seconds` | `providers.<id>.request_timeout_seconds` |
| Model | `providers.<id>.models.<model>.stale_timeout_seconds` | `providers.<id>.models.<model>.timeout_seconds` |

Asymmetric request key: model = `timeout_seconds`, provider =
`request_timeout_seconds`. `request_timeout_seconds` under the model node is
ignored. Built-in floors: `agent/reasoning_timeouts.py` (e.g. `grok-4.5` → 300s);
user config wins. Guidance text may say "600s floor" — check the real slug floor.

Known-good (xAI OAuth + grok-4.5):

```yaml
providers:
  xai-oauth:
    stale_timeout_seconds: 900
    request_timeout_seconds: 1800
    models:
      "grok-4.5":
        stale_timeout_seconds: 900
        timeout_seconds: 1800
```

Needs a **new session**. Secondary: `/reasoning medium|low`, faster model.

### DOTTED MODEL IDs — `hermes config set` trap (critical)

`hermes config set` splits on `.`. A model slug with a dot is destroyed:

```bash
# WRONG → models.grok-4.'5' nested, NOT grok-4.5
hermes config set providers.xai-oauth.models.grok-4.5.stale_timeout_seconds 900
```

Always `hermes config get providers.<id>` after set. If you see
`grok-4: { '5': … }` instead of `grok-4.5: …`, fix via YAML edit with the full
string key `"grok-4.5"`. Provider-level timeouts (no model slug) are safe via CLI.

Live verify with Hermes venv (system python may fail on `|` type unions):

```bash
~/.hermes/hermes-agent/venv/bin/python - <<'PY'
from hermes_cli.timeouts import get_provider_stale_timeout, get_provider_request_timeout
print(get_provider_stale_timeout("xai-oauth", "grok-4.5"))
print(get_provider_request_timeout("xai-oauth", "grok-4.5"))
PY
```

Expect `900.0` / `1800.0`. `None` = wrong nesting or not loaded.

## Shell hooks: persist and verify safely

For an always-on session workflow, configure a `pre_llm_call` shell hook under `hooks:` rather than relying on a gateway-only hook. The script receives JSON on stdin and may return `{"context":"..."}`; inspect `extra.is_first_turn` so the workflow is injected once per new session.

1. Write the script outside a project repository, make it executable, and keep its stdout strictly JSON.
2. Persist the hook declaration with `hermes config set hooks.pre_llm_call '<JSON-list>'`; do not edit `.env` for behaviour.
3. Let Hermes record the per-event script approval. Use `hermes hooks list` to confirm it is allowlisted, then `hermes hooks test pre_llm_call` to exercise the production stdin/stdout protocol.
4. For messaging sessions, run `hermes gateway status`. If it reports that the launchd service definition is stale, run `hermes gateway start` first to refresh it. Then run `hermes gateway restart` and re-run `hermes gateway status`; proceed only when it reports that the service definition matches the current install and the gateway is supervised. Start a fresh CLI session for CLI hooks.

Ask for explicit approval before registering a shell hook, because Hermes executes it with the user's account privileges.

## Gateway migration (`hermes gateway migrate --multiplex`)

Hermes recommends a single multiplexed gateway serving all profiles instead of one
gateway per profile. The migration is blocked if any credential conflict exists across
profiles. Before running migration, always check for shared credentials.

### The token-conflict blocker

`hermes gateway migrate --multiplex` refuses to proceed if two profiles configure
the SAME external credential — most commonly a shared Telegram `bot_token`. The
bot can only belong to one gateway, so one profile must drop it.

Example error:
```
✗ Blockers (fix these first, nothing will be changed):
  • Profiles 'default' and 'hermesvoice' both configure telegram with the same
    credential: the bot can only belong to one profile; remove the token from
    'hermesvoice' or keep it in default and route hermesvoice's chats with
    profile_routes (gateway.profile_routes in default's config.yaml).
```

### Resolution order
1. Identify which profiles share the credential: `grep -rn "telegram\|bot_token"` in both config.yaml and profiles/*/config.yaml.
2. Decide which profile keeps the credential (usually the primary/default one).
3. Fix the secondary profile by either:
   a. Removing the `telegram:` block entirely from its config.yaml, OR
   b. Keeping the token in `default` and adding `gateway.profile_routes` to
      route that profile's Telegram chats through the default profile.
4. Re-run `hermes gateway migrate --multiplex`.

### Verifying the fix
After migration, confirm one gateway serves all profiles:
```
hermes gateway status
```

Should show a single multiplexed gateway process. Then verify each profile
still reaches its intended channels.

## Pitfalls
- Do NOT invent config keys. If `set` warns "not recognized," it likely no-ops (`connectors.enabled` is this class — unset it).
- Do NOT treat doctor "system dependency not met" as a missing binary — a2a needs `platforms.a2a.enabled`, browser-cdp needs a CDP URL (not a toolset toggle), connections need Nous Portal login.
- Do NOT persist provider without fixing base_url — stale endpoint breaks silently.
- Do NOT set dedicated HF endpoints as `provider: huggingface` or invent `model.default` from a dashboard alias — GET `/v1/models` is the id; custom + `key_env: HF_TOKEN` in the profile `.env`.
- Do NOT `source` Hermes `.env` files or wait on `hermes config set` during a source-update Desktop rebuild — parse KEY= lines in Python; patch the profile `config.yaml` instead.
- Do NOT treat an Ollama Cloud 429 `you (<name>)` as a base_url problem — that
  name is the key's account; confirm with POST `/api/me`, then swap
  `OLLAMA_API_KEY` and `hermes auth reset ollama-cloud 1` (bare provider
  resets 0). Do not equate GitHub org slugs with Ollama `Name`.
- Do NOT leave `HERMES_TOOL_PROGRESS_MODE` in `.env` — migrate to
  `display.tool_progress` (`off|new|all|verbose`); unknown values become `all`.
- Do NOT write `timezone: UTC +2` (or any offset string) — IANA only, or cron
  and the agent clock silently use server-local.
- Do NOT diagnose Bedrock doctor failures as missing IAM when the error is
  `InvalidClientTokenId` / `UnrecognizedClientException` — the access key is
  invalid; discovery.enabled does not stop the probe.
- Do NOT treat a commented `# GOOGLE_API_KEY=` as a live key.
- `.env` is secrets only; behavioural settings go in config.yaml.
- Do NOT `--clone` a fat profile when the user asked for a naked/base profile — clone copies skills, user plugins, and MCP servers; `hermes profile create <name>` without clone seeds only the launch model plus bundled skills.
- Do NOT treat “no API keys yet” on create as missing xAI OAuth — the pool is root `auth.json`; verify `hermes -p <name> auth list xai-oauth`.
- Do NOT invent a two-word wrapper filename (`hermes kraken`) — aliases are PATH binaries; two-word start needs a zsh function or `hermes -p <name>` / `~/.local/bin/<name>`.
- The launcher is a bash wrapper; source lives in the editable install repo, not
  site-packages — search there for handlers.
- Never `hermes config set …models.<slug-with-dots>.…` — dots split the path;
  write the model key via YAML edit instead.
- Model request timeout key is `timeout_seconds`, not `request_timeout_seconds`.
- Timeout config needs a fresh session; verify via `get_provider_stale_timeout`.
- Do not treat a successful `hermes gateway restart` as proof that a shell hook is active. Check `hermes gateway status`; a stale launchd definition can restart an older runtime until `hermes gateway start` refreshes the service definition.
- Do NOT run `hermes gateway migrate --multiplex` while two profiles share a Telegram token (or any external credential) — the bot can only belong to one gateway. Resolve by removing the token from the secondary profile or routing via `gateway.profile_routes` first.

## References
- references/model-switch-base-url-trap.md — the full session trace of the
  stale-base_url breakage and its fix.
- references/claude-subscription-vs-api-oauth.md — subscription (Pro/Max) OAuth
  vs API key, why OpenRouter BYOK can't use a subscription, running Claude on the
  abo via the direct anthropic provider, and identifying the account behind a
  stored OAuth credential.
- references/reasoning-stale-timeout-dotted-model.md — Broken pipe / thinking
  idle kill, timeout key map, grok-4.5 floor, dotted-model config-set trap.
