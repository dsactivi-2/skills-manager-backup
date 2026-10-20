---
name: codex-desktop-gateway
description: "Use when Codex Desktop/CLI fails via a local gateway."
---

# Codex Desktop local gateway

Operate and debug Codex Desktop/CLI when traffic is routed through a loopback gateway (CodexGateway / CodexBar, custom `model_provider`, `openai_base_url`). Do not mix this up with Codex Switcher (account switching) or the official Codex.app process itself.

A JSON blob in a Codex chat bubble is usually the gateway or upstream HTTP error body, not a model reply.

## Procedure

1. Identify which app is in the screenshot: Codex Desktop chat chrome vs a menu-bar gateway Settings window vs Codex Switcher.
2. Confirm the gateway process and port (default CodexGateway: `127.0.0.1:8765`):
   - `curl -sS -D - --max-time 3 http://127.0.0.1:8765/health`
   - `lsof -nP -iTCP:8765 -sTCP:LISTEN`
3. Read only the managed block and model routing in `~/.codex/config.toml`. Redact keys. Note `model_provider`, `openai_base_url`, `wire_api`, and duplicate top-level `model =` keys (later keys win in TOML).
4. Match the exact error string in the gateway source or live log before guessing. For CodexGateway, grep the process log for `Invalid JSON on /v1/responses` and the `ce=` field (often `/tmp/codexgateway_debug.log`).
5. Build a tight loop against the live gateway, not against Codex UI:
   - Uncompressed POST `/v1/responses` with a tiny JSON body and the catalog slug (`cursor/grok-4.6` style).
   - Same JSON zstd-compressed to a file, then `curl --data-binary @file` with `Content-Encoding: zstd`.
   - Do not pass raw zstd bytes as a Python `subprocess` argv value — embedded NUL bytes abort the spawn; write a file.
6. Apply the smallest fix that turns the loop green, then tell the user Codex Desktop must restart before the feature flag takes effect.

## `{"error":"Invalid JSON body"}`

This exact body is CodexGateway `POST /v1/responses` when `JSONSerialization` runs on an empty or non-JSON body. If the log shows `ce=zstd` and `preview=<binary>`, Codex is sending zstd-compressed request bodies and the gateway is not decompressing them.

Workaround (verified): disable Codex request compression, then restart Desktop:

```bash
/Applications/Codex.app/Contents/Resources/codex features list | rg enable_request_compression
/Applications/Codex.app/Contents/Resources/codex features disable enable_request_compression
```

That writes `[features] enable_request_compression = false`. The running Codex.app does not pick it up until restart. Do not kill Codex without saying so — the user may have an open thread.

Root-cause fix (gateway): decompress `Content-Encoding: zstd` (and gzip) before `parseJSON`. Do not treat uncompressed-JSON success as proof the Desktop path works while compression is still on.

## Pitfalls

- Treat `ce=zstd` + `Invalid JSON body` as a compression mismatch — chasing a malformed Codex payload wastes time because uncompressed JSON to the same endpoint already succeeds.
- Distinguish pass-through `401 Incorrect API key provided: dummy` from Invalid JSON body — native GPT through `openai_base_url` uses the gateway dummy bearer; custom catalog slugs must hit third-party routing, not OpenAI.
- Keep Codex Switcher, CodexGateway, and Codex.app separate — Switcher mutates `~/.codex/auth.json`; Gateway mutates a managed `config.toml` block and `~/.codexgateway/`; Desktop is the client that compresses `/v1/responses`.
- Check `codex features list` for `enable_request_compression` before editing `config.toml` by hand — the CLI is the supported write path and reports effective state.
