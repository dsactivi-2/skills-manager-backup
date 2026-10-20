# Mac default → VPS via official profile export

## What the default export actually packs

Allow-list at `~/.hermes` root (`_DEFAULT_EXPORT_INCLUDE_ROOT`):

| In | Out |
|---|---|
| `config.yaml`, `SOUL.md`, `AGENTS.md` if present | `.env`, `auth.json`, `honcho.json` |
| `skills/`, `sessions/`, `memories/`, `cron/`, `plugins/` | `state.db*`, `profiles/`, `hooks/`, `logs/` |
| `desktop.json` | `hermes-agent/`, `bin/`, caches |

Text files are force-redacted. Import name **cannot** be `default`. Suggested: `mac`. Then `hermes profile use mac` and `hermes auth` on the VPS.

`session_search` on the VPS starts empty. After import, write a Memory line that the instance was ported from Mac Desktop to this Linux VPS (no CUA, no Mac paths).

## Console paste (Contabo / no SSH yet)

1. `nano /root/vps-preflight.sh` — wait until nano is open.
2. Paste the **full** script, not a git diff, not a truncated chat reply.
3. `Ctrl+O` Enter `Ctrl+X`
4. `bash /root/vps-preflight.sh`

Never paste `#!/usr/bin/env bash` into interactive bash (`!` history expansion).

Preflight: `scripts/vps-preflight.sh` — read-only, `set +e`, YES/NO inventory, `*.err.log`.

## SSH first key

Dedicated `~/.ssh/<host>_ed25519`. Show fingerprint + **public** line only. `ssh -i … -o BatchMode=yes -o IdentitiesOnly=yes`. `Permission denied (publickey,password)` = panel does not have the pubkey yet.
