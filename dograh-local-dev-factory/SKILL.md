---
name: dograh-local-dev-factory
description: "Use when patching Dograh factory STT on dograh-devshift."
version: 1.0.0
author: Hermes Agent
license: MIT
---

# Dograh local factory (devshift)

Mac checkout `/Users/activi/Projects/dograh-devshift`. origin `https://github.com/devshift-stack/dograh.git`. Never push to `dograh-hq/dograh`.

## User comms

Simple DE, tables. Verify scripts against **live file bytes**. Do not invent CLI subcommands.

## Git order (user)

1. Local backup branch only — do not push backup.
2. Local commit (Factory + vocab only).
3. Test on host API/UI.
4. Then GitHub.

Rollback: `git checkout backup/pre-nova-stt-20260822`.

## Host vs OrbStack

OrbStack compose here is postgres/redis/minio. API is host Python `:8000`. UI is Next `:3000`. Compose rebuild does not ship factory.py. Root `http://localhost:8000/` → `{"detail":"Not Found"}`. Health: `/api/v1/health`.

## OSS cookie ≠ DB user

`users` can be empty while `/api/auth/oss` accepts leftover `dograh_auth_token`. UI looks logged in. Clear localhost cookies, then signup.

## Nova factory (live shape)

Shared `settings_kwargs` for US+EU Nova (not Flux):

`language`, `profanity_filter=False`, `endpointing=100` (unpatched), `model`, `keyterm`. EU adds `extra.tag=["dograh","eu"]` + EU host.

Pipecat omit-defaults: `punctuate=True`, `smart_format=False`. Factory omit ≠ off.

Shipped helper `7da0f96` on `feat/deepgram-nova-stt-settings`: endpointing 300, punctuate+smart_format on, empty `bosnian_stt_vocab.py`.

## Patch pitfalls

- Do not match HQ `DeepgramSTTSettings(language=..., endpointing=...)`.
- Insert helpers **before** `@_report_service_factory_failures`+`def create_stt_service`, never between (decorator theft).
- One-shot v3: `python3 patch_deepgram_stt.py` — no `status`/`apply`. If the file has `argparse`, it is not v3.
- Do not overwrite a filled vocab. Do not patch `pipecat/` or registry/UI for these flags.
- Diarize labels speakers; it does not mute a second voice. Pipecat uses `transcript` only.

## Fish emotion (s2.1-pro)

Tags in LLM text `[calm]`, not TTS config. DE is on Fish’s official 13-lang emotion list; BS is not the same (Global Coverage / fork claim only). Companion: `dograh-upstream-platform` `references/fish-s21-emotion-de-vs-bs.md`.
