---
name: terminal-execution
description: Run scripts and Docker commands safely on macOS zsh.
---

## Always-on rules
- Export variables on separate lines before commands.
- Never paste multi-line blocks into zsh.
- Verify containers with ps + logs after start.

## Credential-safe database checks
1. Inspect container environment key names and mounts first; never print credential values.
2. Verify a database credential with a TCP authentication probe that prints only the authenticated role/database.
3. When pgAdmin uses `PassFile`, check file ownership and mode before replacing any password; libpq ignores a passfile readable by group or world.
4. Test the passfile from the same Docker network namespace with `PGPASSFILE` and a disposable PostgreSQL client.

See `references/postgres-auth.md` for safe commands.

## Local HTTP checks
1. Check the listener first: `lsof -nP -iTCP:<port> -sTCP:LISTEN`.
2. Probe the exact loopback endpoint separately: `curl --noproxy '*' -sS -D - --max-time 5 http://127.0.0.1:<port>/ -o /dev/null`.
3. Report listener state and HTTP outcome independently; a bound port does not prove that the HTTP route works.
4. A docs/health 200 is not a model-path proof — still run the stack's smoke that calls an agent (e.g. `./scripts/mcp_check.sh`); quote the agent answer or the provider error, never the key.

## Clone vs existing project dir
- Before `git clone … <folder>`, check both `$PWD/<folder>` and `/Users/activi/Projects/<folder>`. If either exists, do not create a second copy; say both absolute paths and use the one that already has the stack, unless they named a different path.
- After clone, state the absolute repo path once. Later ".env" means that path, never a same-named sibling.
- If they want a `/Users/activi/Projects/<name>` home: copy the live trees into that folder (exclude `.git`, `node_modules`, `.next`, `.venv`), copy `.env` untracked, retarget README/docs to those paths. Do not leave only docs while compose still runs from `$HOME/<name>` without saying so. Do not `up` the copy on the same host ports until the original compose is down.

## Env files the human must fill
- After copying `example.env` → `.env`, open it in TextEdit: `open -a /System/Applications/TextEdit.app /abs/path/.env` (not Cursor). Name the absolute path in the same sentence.
- If they ask to open "the place you described" for the key, reopen that same `.env`. Do not open NVIDIA/OpenAI/Render dashboards unless they named that vendor.
- If they are lost between two `.env` files: open the file the running compose project actually mounts (`docker compose` cwd), and list the other path as "not this stack".
- When they say the keys are saved, re-read that `.env` and report only `set`/`empty` per variable name — never print values. Treat a doubled prefix (`sk-sk-…`) as invalid without echoing the rest.
- Then boot. Do not wait for a second confirmation once the required keys are `set`.

## Compose boot
- Run `docker compose up -d --build` with `background=true` and `notify=true`. Foreground compose is treated as a long-lived server and is refused. Same for `up -d --force-recreate`.
- After it exits 0, poll the HTTP probe separately; then `docker compose ps` and logs if it never goes 200.
- `docker compose restart` does not reload `.env` — recreate: `docker compose up -d --force-recreate --no-build <service>` (background).

## Local UIs talking to AgentOS
- os.agno.com Connect OS: Local, `http://localhost:<api-port>`, JWT off in `RUNTIME_ENV=dev`. Safari often blocks HTTPS→localhost; use Chrome or Edge before tunneling.
- A companion Agent UI (Next) is not AgentOS. Its sidebar AGENTOS field must be the API origin, never the UI's own origin. Dev auth_mode none → AUTH TOKEN empty. A red status with the UI port in that field means it is pointing at itself.
- Before binding Next/docs default ports (3000, 7777), `lsof` the listener and identify the process; occupied ports belong to other stacks on this Mac.

## Docker daemon
- Before compose or container work, `docker info` must succeed.
- If it fails, run `docker context ls` and start the app that owns the starred context — `open -a OrbStack` when the context is `orbstack`, `open -a Docker` when it is `desktop-linux`. Both apps can be installed while only one socket is live; starting the wrong app leaves the CLI on a dead sock.
- Poll `docker info` until it succeeds rather than switching contexts unless the user asked to.

## Pitfalls
- Pasting scripts causes parse errors.
- Missing export leaves empty env vars.
- Set PostgreSQL passfiles to mode `0600`; libpq rejects permissive files and the resulting missing-password error can be mistaken for a wrong credential.