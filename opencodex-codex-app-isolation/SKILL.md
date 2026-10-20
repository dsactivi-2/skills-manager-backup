---
name: opencodex-codex-app-isolation
description: "Use when OpenCodex meets Codex.app. Keep ~/.codex chats."
---

# OpenCodex vs Codex.app

Codex.app live home is `~/.codex` (chats, projects, `config.toml`, auth). OpenCodex must not use that toml as its CODEX_HOME.

## Homes

- OpenCodex: `OPENCODEX_HOME=~/.opencodex`, config `~/.opencodex/config.json`
- ocx Codex home: `~/.opencodex/codex-home`
- Wrappers: `~/.local/bin/ocx` and `opencodex` → `~/.opencodex/ocx-isolated` (forces isolated CODEX_HOME if unset or `~/.codex`)
- Do not export `CODEX_HOME` in zshrc (would also move the app)

After `npm update -g @bitkyc08/opencodex`, restore the two symlinks to `ocx-isolated`.

## Connect Desktop without losing chats

Keep `model_provider = "OpenAI"` in `~/.codex/config.toml`. Changing the provider id hides existing threads.

Safe Desktop hook: only `[model_providers.OpenAI] base_url = "http://127.0.0.1:10100/v1"` (`wire_api = "responses"`). Do not inject `openai_base_url`, `model_catalog_json`, or `[model_providers.opencodex]`.

In `~/.opencodex/config.json` keep:

- `clientIntegrations.codex: false`
- `syncResumeHistory: false`
- `codexAutoStart: false`
- `codexShimAutoRestore: false`

Dashboard toggles leave OFF: shim/autostart, authless Desktop, client compaction. Those rewrite provider identity or wrap the `codex` binary.

Do not run `ocx init`/`sync`/`restore`/`recover-history` against `~/.codex`. Do not kill Codex.app to apply config; tell the user to open a new thread.

## Other providers

Add providers and keys in http://localhost:10100/ (not in `~/.codex`). Models do not need ChatGPT aliases. In the app use `provider/model`. Desktop picker may hide routed rows; requests still work if the model id is explicit.

Undo Desktop hook: restore `base_url` to the previous gateway, then `ocx stop`.
