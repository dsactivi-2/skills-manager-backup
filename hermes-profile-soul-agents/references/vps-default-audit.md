# VPS default-home knowledge audit (Contabo / root)

Read-only probe: `~/Desktop/hermes-knowledge-audit.sh`.
Copy+run example: `scp … root@HOST:~/hermes-knowledge-audit.sh && ssh root@HOST 'bash ~/hermes-knowledge-audit.sh'`.

## What to expect on a fresh operator default

- One profile: `default`. No `profiles/` dir → do not create named profiles unless asked.
- Stock `SOUL.md` (one-liner, ~500 bytes) → replace with operator SOUL (draft first).
- `USER.md` may exist; `MEMORY.md` often **missing** — create small standing infra facts only.
- `memory.provider: mem0` can be active while `.hub` skills = 0. Unrelated.

## Mem0 setup (docs-verified)

- `user_id` is a **scope label**, not a Mem0 dashboard account. First write creates the bucket.
- Default wizard value `hermes-user` is treated as unset by the plugin (gateway IDs take over). Pick a stable string if you want one merged store.
- Do not change `user_id` after facts exist under it (example seen: `dev n8n lk` with spaces).
- `rerank: true` = better recall, extra cost. Official default is false.
- Only **one** external provider per home. Built-in MEMORY/USER stay on.

## hermes doctor npm lines

`web workspace` / `ui-tui workspace` high advisories = **build-tool** (vite/esbuild), not runtime Hermes.
Do **not** run `npm audit fix` / `npm audit fix --workspace web|ui-tui` (npm arborist crash).
`hermes doctor --fix` does not clear them. Clears only when upstream lockfile bumps (`hermes update`).

## Do not

- Put `AGENTS.md` in `/root` or `$HERMES_HOME`.
- Treat `state.db` or npm deps as knowledge stores.
- Apply SOUL/USER/MEMORY live without backup + Freigabe.
