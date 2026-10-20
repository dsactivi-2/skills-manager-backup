---
name: infisical-env-project-sync
description: "Safely discover local .env files, map them to Infisical projects, and sync secrets to a self-hosted or cloud Infisical instance through API with dry-run and credential guardrails."
trigger: "Use when importing many local .env secrets into Infisical projects via API."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019ec8f0-aba6-7621-a3bf-fbe0245636fe
  - activi_dsactivi's Organization_default_019ec7f8-7ba8-7070-9865-2fc0cbac4eda
  - activi_dsactivi's Organization_default_019ec7f8-39c8-7492-8f28-a60ec6e38f6f
  - activi_dsactivi's Organization_default_019ec7f4-cf83-7373-8dde-79222417d631
  - activi_dsactivi's Organization_default_019ec6d1-fa14-7be2-9a51-8478f5a05f7e
  - activi_dsactivi's Organization_default_019ec6b3-b9ad-7501-84b7-a671a0756d10
  - activi_dsactivi's Organization_default_019ec7e5-6a3c-7092-ad01-eb5293bd0f13
  - activi_dsactivi's Organization_default_019ec7e4-28cd-71f2-a1e6-113b96486206
contributors:
  - activi
version: 1
created_by_agent: codex
created_at: 2026-06-15T02:40:50.757Z
updated_at: 2026-06-15T02:40:50.757Z
---

# Infisical env project sync

## When to use

Use when many local `.env` files must be discovered, grouped into Infisical projects, and synced to Infisical by API. This is for bulk migration or repair work where secrets must not be printed, decoded, or pasted into chat.

## Workflow

1. Read project instructions first:
   - `/Users/activi/Documents/Agent OS Systeme/AGENTS.md`
   - `/Users/activi/.codex/RTK.md`
2. Confirm the exact Infisical base URL before creating anything. Distinguish cloud URLs such as `https://eu.infisical.com` from self-hosted URLs such as `https://infisical-aai-u73280.vm.elestio.app/`.
3. Run discovery only. Find `.env` files, exclude examples/templates, and report counts by project candidate.
4. Write a timestamped report under `reports/`, for example `reports/infisical-env-discovery-YYYYMMDDTHHMMSSZ.md`.
5. Create a dry-run sync plan listing project names, source file paths, estimated key counts, skipped files, conflicts, and risks. Do not call the Infisical API yet.
6. Require Machine Identity credentials stored locally, not in chat.
7. Run API apply only after dry-run passes and the user explicitly approves.
8. After apply, report projects created, secrets synced, conflicts skipped/overwritten, and failures without exposing secret values.

Use scripts for repeatability, for example `scripts/infisical_sync_apply.sh`, with `set -euo pipefail`, timestamped logs, structured `PASS|WARN|FAIL|PASS_WITH_GAPS`, and no secret output.

## Credential handling

For a local macOS setup, store self-hosted Infisical Universal Auth credentials in Keychain:

```bash
read -r -p "Infisical Client ID: " cid
read -rsp "Infisical Client Secret: " cs; echo
security add-generic-password -U -a "$USER" -s codex-infisical-selfhost-client-id -w "$cid"
security add-generic-password -U -a "$USER" -s codex-infisical-selfhost-client-secret -w "$cs"
unset cid cs
```

For cloud or a different instance, use a distinct service name so credentials cannot be mixed, such as `codex-infisical-client-id` versus `codex-infisical-selfhost-client-id`.

Never print API tokens, client secrets, dotenv values, decoded credentials, OAuth tokens, private keys, or complete env files. If credentials are missing, stop with `PASS_WITH_GAPS` or `BLOCKED` and give local storage commands.

## Mapping rules

- Exclude `.env.example`, `.env.template`, samples, generated files, and obvious test fixtures unless explicitly approved.
- Treat very large or ambiguous env files as approval-required.
- Prefer project names derived from repository or service directories, such as `hermes-profiles`, `dograh`, `openclaw`, `mission-control`, `livekit-telesales`, `hivementality-ai`, and `n8n-workflow`.
- Keep local source paths in the report, but never include values.
- Resolve duplicate keys deliberately: document whether project/env/path conflicts are skipped, overwritten, or require approval.

## API apply discipline

Before mutation, validate:

```bash
curl -fsS "$INFISICAL_URL/api/status" || true
```

Then authenticate with Universal Auth, create missing projects, and sync secrets to the correct project/environment/path. If the wrong URL was used, stop immediately, list created resources, state whether any secrets were synced, and wait for user direction. Do not continue on a different instance without a new dry-run against that instance.

## Anti-patterns

- Creating projects before confirming the exact Infisical URL
- Mixing cloud and self-hosted Machine Identity credentials
- Importing example/template env files by default
- Printing `.env` values or API credentials in reports
- Treating a dry-run as a completed sync
- Continuing after resources were created on the wrong Infisical instance
- Bulk overwriting existing secrets without an explicit conflict policy
