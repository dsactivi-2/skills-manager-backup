---
name: hermes-vps-profile-port
description: "Use when porting Mac Hermes without memory to a Linux VPS or OrbStack Docker. Overlay allow-list; never profile export; never share HERMES_HOME."
version: 1.0.0
author: Hermes Agent
license: MIT
---

# Hermes VPS profile port (no memory)

Class-level move: take the **default** Mac Hermes (config, skills, SOUL, `.env`) onto a **new** Linux home **without** built-in memory, sessions, or Honcho. Destinations: Ubuntu/Hetzner VPS (installer) or OrbStack Docker (official image + isolated `./data`).

## When to use

- User wants a 1-1 Hermes copy, explicitly **ohne Memory**
- Target is a VPS **or** an OrbStack container on the same Mac
- `hermes profile export` / `/export` is wrong (those pack memory)
- `--clone` is local-only

## Do not

- Rsync `~/.hermes/hermes-agent` or a macOS venv onto Linux
- Paste a private key into chat or onto the VPS
- Invent a one-shot official clone command

## Recipe

1. SSH `BatchMode=yes` must already work (pubkey in VPS `authorized_keys`).
2. Install Linux Hermes on the VPS (official installer).
3. Overlay selected files from the Mac default home.
4. Disable memory on the VPS and run `hermes doctor`.

```bash
HOST=root@<vps>
ssh "$HOST" 'curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash'
rsync -az \
  --exclude 'memories/' --exclude 'MEMORY.md' --exclude 'USER.md' \
  --exclude 'sessions/' --exclude 'state.db*' --exclude 'logs/' \
  --exclude 'honcho.json' --exclude '.hermes_history' \
  ~/.hermes/config.yaml ~/.hermes/.env ~/.hermes/SOUL.md ~/.hermes/AGENTS.md \
  ~/.hermes/skills ~/.hermes/hooks \
  "$HOST":~/.hermes/
ssh "$HOST" 'hermes config set memory.memory_enabled false; hermes memory off; hermes doctor'
```

| Comes | Does not come |
|---|---|
| config, `.env`, SOUL/AGENTS, skills, hooks | Memory, sessions, `state.db`, Honcho, logs |
| fresh Linux install | macOS checkout/venv |

Verify: `hermes memory status` (injection/profile/tool all disabled; no MEMORY.md).

OrbStack Docker (same Mac, isolated volume): `references/orbstack-docker-clone.md`. Pair with `orbstack-compose-port`. Do not mount `~/.hermes`.

Related: `hermes-profile-capability-audit` owns inventory/sync on an already-installed host. This skill owns the first Mac→new-home port without memory.

## Pitfalls

- `hermes profile export` includes memory — do not use it for "ohne Memory".
- Two writers on one `HERMES_HOME` corrupt state; destination gets its own home.
- `.env` is secrets. Copy only to a host the user named.
- Copying `TELEGRAM_BOT_TOKEN` (or Discord/Slack) into a second gateway steals the Mac bot. Strip messaging tokens on the clone.
- Mac-absolute MCP/hooks (`/Users/...`, `/Applications/...`) fail in Linux. Disable or rewrite; empty `hooks:` rather than leave broken node paths.
- `auth.json` is needed for xAI OAuth to work; official export omits it — overlay it only onto the named destination.
