---
name: opencodex-codex-home
description: "Use when OpenCodex must not share Codex.app home."
---

# OpenCodex beside a live Codex.app

OpenCodex (`ocx` / `opencodex`, npm `@bitkyc08/opencodex`) injects Codex routing into `$CODEX_HOME/config.toml` (default `~/.codex/config.toml`) plus catalog and optional history metadata. Codex.app, CLI, TUI, and SDK share that home. Treat `~/.codex` as the live app home: toml, auth, chats (`thread_history_*.sqlite`), projects, MCP, hooks.

This is not CodexGateway (loopback `:8765`) and not Codex Switcher. For gateway JSON/zstd failures see `codex-desktop-gateway`.

Docs to read together: installation (`ocx` package only) and Codex integration (injector, catalog, restore). Installation without the isolation rules below writes the live toml.

## Always-on gates

- Never export `CODEX_HOME` in `~/.zshrc` / launchd — Codex.app and `codex` inherit it and the live home disappears.
- Never run `ocx init`, `ocx start`, `ocx sync`, `ocx restore`, `ocx ensure`, or shim/service install against the live app home.
- Never install the Codex autostart shim — it wraps the `codex` binary the app launches.
- Do not kill or restart Codex.app unless the user asked; open threads are in that process.
- A live `model_provider` other than `openai`/`opencodex` is not enough protection. Integration skips some toml writes in that case, but catalog, `models_cache.json`, and history still resolve via `CODEX_HOME`.
- Never rename the live `model_provider` string or its `[model_providers.*]` table. Codex tags threads with that id; a new id hides old chats in the history view while sqlite still holds them.
- After any Codex/OpenCodex mutation, if the user asks what happened, answer in three short German lists only: gemacht / nicht gemacht / gefragt — no architecture recap.

## Install (package only)

1. Confirm Codex.app state (`pgrep` the app) and that `CODEX_HOME` / `OPENCODEX_HOME` are unset in the current shell and launchd.
2. Snapshot outside `~/.codex` (hashes + copy of `config.toml`), then install with isolated env even if postinstall later appears:

```bash
export OPENCODEX_HOME="$HOME/.opencodex"
export CODEX_HOME="$HOME/.opencodex/codex-home"
mkdir -p "$OPENCODEX_HOME" "$CODEX_HOME"
npm install -g @bitkyc08/opencodex
```

3. Replace npm's `~/.local/bin/ocx` and `opencodex` symlinks with the isolated launcher (`scripts/ocx-isolated.sh` → `~/.opencodex/ocx-isolated`). The launcher must remap `CODEX_HOME` when it is unset **or** equal to `~/.codex`.
4. Verify: `ocx --version`; `ocx status --json` shows `codexHome.effectiveCodexHome` under `~/.opencodex/codex-home`, `appCodexHome` = `~/.codex`, `startup.routingInjected` false, shim not installed.
5. Re-hash live `~/.codex/config.toml`, `auth.json`, `.codex-global-state.json`, `models_cache.json`. Confirm no `opencodex.config.toml` / `opencodex-catalog.json` under `~/.codex` and no `openai_base_url` / `10100` injection in the live toml.
6. Stop after the package + wrapper. Do not run `ocx init` until the user names a provider. Decline shim and any inject that targets `~/.codex`.

## After `npm update -g @bitkyc08/opencodex`

Npm restores bins to `.../node_modules/@bitkyc08/opencodex/bin/ocx.mjs`. Relink:

```bash
ln -sf "$HOME/.opencodex/ocx-isolated" "$HOME/.local/bin/ocx"
ln -sf "$HOME/.opencodex/ocx-isolated" "$HOME/.local/bin/opencodex"
```

## Connect Desktop without sharing the live toml

Desktop reads `~/.codex/config.toml`. Isolated `CODEX_HOME` keeps `ocx` off that file; it does **not** route the app. Do not `ocx init`/`sync`/`restore` against the app home to "connect" them.

1. Write `$OPENCODEX_HOME/config.json` **before** `ocx start`. A missing file defaults integration ON and `syncResumeHistory` ON. Required flags:
   - `clientIntegrations.codex: false` (no catalog/toml/history writes)
   - `syncResumeHistory: false`
   - `codexAutoStart: false` and `codexShimAutoRestore: false`
   - default `openai` forward provider is enough for passthrough
2. Start the proxy only through the wrapper (`ocx start`). Confirm `/healthz` on `127.0.0.1:10100`, `startup.routingInjected` false, no `opencodex*` files under `~/.codex`.
3. Snapshot live `config.toml` **outside** `~/.codex`. Patch **one** line: the existing provider table's `base_url` → `http://127.0.0.1:10100/v1`. Keep `model_provider`, table name, `wire_api = "responses"`, and `requires_openai_auth`. Do not add root `openai_base_url`, `[model_providers.opencodex]`, or `model_catalog_json`.
4. Diff must be that single line. Re-hash `auth.json` and `.codex-global-state.json`; confirm `.chatgpt-projects` and no opencodex artifacts in the app home.
5. Tell the user to open a **new** thread. Do not restart Codex.app unless they ask. Undo: restore the old `base_url`, then `ocx stop`.

`ocx stop` / `ocx restore` act on the isolated home, not the app home — still never point them at `~/.codex`.

## Other providers in Codex.app

Add providers, logins, and keys only at http://localhost:10100/ (OpenCodex dashboard), never by renaming the live `model_provider`. Codex.app keeps sending to `127.0.0.1:10100`; OpenCodex routes `provider/model`.

- Codex-Auth / Multi-Auth is ChatGPT/Codex login pool only. Cursor, Kimi, xAI, Ollama are not configured there.
- Models page controls which ids OpenCodex advertises. It does not delete app chats. Leave the page-level controls at defaults: neue Modelle deaktivieren off, Shadow-Call off, Aliase off, Standardfenster 350k off, Sub-Agent `base`, do not click Reihenfolge anwenden.
- Routed models do not need ChatGPT aliases. A native-alias combo that captures a `gpt-*` slug steals that id from OpenAI routing — skip unless the user explicitly wants the Desktop allowlist workaround.
- Desktop may hide routed picker rows. Tell the user to select or set `provider/model` (example `xai/grok-4`). Do not inject `model_catalog_json` or change provider id to make the picker prettier.

When the user asks what a dashboard control does, explain in simple German: what it is, on vs off, whether they need it now. Full control map: `references/dashboard.md`.

## Pitfalls

- Snapshot hashes before the first `ocx` mutating command — `ocx start`/`sync` rewrite catalog and toml under whatever `CODEX_HOME` resolved to, including a running app's chats.
- Call `ocx` via `~/.local/bin/ocx` after the wrapper is in place, not `node .../ocx.mjs` directly — the raw bin defaults to `~/.codex`.
- Do not copy live `auth.json` or sqlite history into the isolated home unless the user asked — isolation is the point.
- Do not treat `ocx start` against the isolated home as Desktop wiring — the app still uses `~/.codex` until that table's `base_url` changes.
- Write `clientIntegrations.codex: false` before the first start — absent config means Codex integration ON.
