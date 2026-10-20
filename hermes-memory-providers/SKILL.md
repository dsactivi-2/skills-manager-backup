---
name: hermes-memory-providers
description: "Use when choosing or setting up a Hermes memory provider."
version: 1.1.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [hermes, memory, mem0, honcho, supermemory, provider]
---

# Hermes Memory Providers

Only **one** external provider can be active per Hermes home. Built-in `MEMORY.md` / `USER.md` always stay on.

## When to use

- `hermes memory status` / `hermes memory setup`
- User asks which provider is best, or auto save/recall
- Mem0 wizard: API key, user identifier, rerank
- Honcho vs Mem0 vs Supermemory comparison
- `hermes memory setup supermemory` / `SUPERMEMORY_API_KEY`

## Pick by job

| Job | Provider |
|-----|----------|
| Auto fact extract + search (IDs, CRUD) | **Mem0** |
| User model / dialectic / per-profile AI peers | **Honcho** |
| Entity graph + reflect | Hindsight |
| Local SQLite, no cloud | Holographic (`auto_extract` default off) |
| Already on RetainDB | RetainDB |
| Semantic recall + session ingest + multi-container tags | **Supermemory** |

Cannot run two externals in the same home (Mem0 + Honcho, Honcho + Supermemory, …). Split: Mac Honcho, VPS Mem0 is two homes, not dual-active. `hermes config set memory.provider supermemory` **deactivates** Honcho on that home.

## Mem0 setup (Platform)

```bash
hermes memory setup
hermes config set memory.provider mem0
hermes memory status
```

Key: `MEM0_API_KEY` in `$HERMES_HOME/.env`. Config: `$HERMES_HOME/mem0.json`. Gateway: `hermes gateway restart`.

### User identifier

Not a Mem0 dashboard login. Scope string under the API key. First write creates the bucket. Same string later = same facts.

- First setup: stable label (`denis`). Do **not** leave `hermes-user`.
- Hermes treats literal `hermes-user` as unset so gateway chats get platform IDs and split memory.
- Only reuse an existing id if memories already live under that exact `user_id`.

### Rerank

Default `false`. Extra cost/latency. Leave off on first setup; later `"rerank": true` in `mem0.json`.

## Honcho auto save/recall

Messages flush (`saveMessages`, `writeFrequency: async`). Hybrid injects user card every turn + dialectic every `dialecticCadence` (default 2). Does **not** store discrete infra facts with IDs.

## Supermemory

Plugin ships with Hermes (`plugins/memory/supermemory`). `is_available` = key present, not SDK import. Official: https://supermemory.ai/docs/integrations/hermes and `hermes memory setup supermemory`.

```bash
# SDK MUST be in the Hermes runtime python, not system python — the plugin does `import supermemory` and fails if absent (verified absent by default).
# Linux host: /root/.hermes/tools/python-3.14.*/bin/python3 -m pip install supermemory
# Mac:        /Users/activi/.hermes/hermes-agent/venv/bin/pip install supermemory
hermes memory setup supermemory   # paste key; writes .env + memory.provider
# or:
hermes config set memory.provider supermemory
# SUPERMEMORY_API_KEY=sm_...  in $HERMES_HOME/.env only — never in chat
hermes memory status
```

Connect URL (user browser): `https://app.supermemory.ai/integrations?connect=hermes` or console keys. Config: `$HERMES_HOME/supermemory.json`. Default `container_tag`: `hermes`. Named profiles: `hermes-{identity}`.

**Learn-from-existing-data trap:** the agent only reads/searches its configured `container_tag` — `search_memories` and `get_profile` both filter by it. To make an agent learn from conversations that already live in Supermemory (e.g. a messenger history), set `container_tag` in `supermemory.json` to THAT data's container; the default `hermes` tag sees nothing else. `enable_custom_container_tags` is **False** by default, so the agent cannot query arbitrary tags — the tag must be set to match the source or the agent retrieves nothing and "learns" nothing. This is retrieval-augmented context (it mimics recalled style/examples), not model training — weights never change.

Mac default is often **Honcho**. Do not flip provider unless the user asked for Supermemory on that home.

## Pitfalls

- `hermes doctor --fix` does not set memory and does not clear npm workspace advisories.
- Do not dump Mem0/npm session trivia into SOUL/USER.md.
- MEMORY.md is 2200 chars — not the long-term store; Mem0/Supermemory are additive.
- Plugin listed as “requires API key” while Honcho is still `provider:` — SDK install alone does not switch providers.

## Related

- `hermes-profile-soul-agents` — SOUL/USER/MEMORY/AGENTS placement
- Official: docs `user-guide/features/memory-providers.md`
