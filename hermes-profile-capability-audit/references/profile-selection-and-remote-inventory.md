# Profile selection + remote instance inventory

## Selection order (Hermes CLI)

Applied in `hermes_cli/main.py` → `_apply_profile_override()` **before** heavy imports:

1. `-p` / `--profile` / `--profile=<name>` (broad argv scan; invalid profile ids ignored so pytest `-p` does not collide)
2. Existing `HERMES_HOME` whose **parent basename is `profiles`** (already scoped to a named profile)
3. Sticky file: `$HERMES_ROOT/active_profile` (usually `~/.hermes/active_profile`) written by `hermes profile use <name>`
4. Missing/empty sticky → **default** (`~/.hermes` itself)

Then: `os.environ["HERMES_HOME"] = resolve_profile_env(name)`.

Note: s6 supervised default gateway children intentionally skip sticky redirect so a dashboard `profile use` cannot steal the default gateway into a named profile.

## Sticky default

```bash
hermes profile use coder     # write ~/.hermes/active_profile
hermes profile use default   # clear / reset sticky to default
hermes profile               # show active
cat ~/.hermes/active_profile 2>/dev/null || echo "(none → default)"
```

## Wrapper aliases

`hermes profile create` installs `~/.local/bin/<alias>` (must be on PATH).

Typical thin wrapper:

```sh
#!/bin/sh
exec hermes -p dograh "$@"
```

Custom launchers (e.g. `secret`) may map bare invocation → `hermes -p secret chat`.

```bash
ls ~/.local/bin
type -a hermes secret dograh
head -20 ~/.local/bin/secret
```

If the user types the alias name instead of `hermes`, they are not in default.

## Multi-session diagnosis

```bash
ps -eo pid,tty,user,lstart,args | rg '[h]ermes'
# per PID:
tr '\0' ' ' < /proc/$PID/cmdline; echo
tr '\0' '\n' < /proc/$PID/environ | rg -i 'HERMES|HOME'
ls -l /proc/$PID/cwd
```

Expect mix of:

- bare `hermes` → sticky/default
- `hermes -p secret chat` → named
- `hermes gateway run` with `HERMES_HOME=…/profiles/secret` → profile gateway
- systemd `hermes-gateway.service` WorkingDirectory=`~/.hermes` → default gateway

## CLI names (v0.20+)

| Wrong | Right |
|-------|--------|
| `hermes profiles list` | `hermes profile list` |
| `hermes profile show` (no name) | `hermes profile show <name>` |

## Remote VPS inventory checklist

1. Resolve SSH host from `~/.ssh/config` (do not guess IPs from stale memory).
2. Live public IP: `curl -4 ifconfig.me` + `ip -4 -br addr`.
3. Binary: `command -v hermes`; `hermes version`.
4. Sticky + list: `hermes profile`; `hermes profile list`.
5. Trees: `~/.hermes`, `~/.hermes/profiles/*`, stubs under projects.
6. Processes + systemd units (`*hermes*`).
7. Wrappers: `~/.local/bin` aliases.
8. Docker/k8s only if present — often none on single-node VPS.
9. Report DE table: PROFILE | MODEL | GW | SIZE | CONFIG | PATH.

Script: `scripts/hermes-remote-instance-inventory.sh`.

## myhermi field note (2026-08)

- Host: MyHermi `178.105.73.78` / tailscale `100.122.29.48`
- Install: `/usr/local/lib/hermes-agent`, CLI v0.20.x
- Home: `/root/.hermes` (~3.6G)
- Sticky: often **absent** → default; model grok-4.3 xai-oauth
- Concurrent: default gateway + `secret` gateway + several bare `hermes` TTYs + one `hermes -p secret chat`
- Wrappers: agent-builder, agentme, creative, dev-op, dograh, hhhj, hi, ki-voice-agent, mlops, n8n-workflow, orchestrator, prompting-salesteleagent, research, s-ella, s-pornsearch, secret, voice-agent-builder, xai-voice-dograh
- Gateways: default system, secret user, s-ella system `hermes-gateway-s-ella.service` (enabled; Telegram connected after install)
- Host also runs k3s + docker n8n/postgres — prove with live `ps`/`docker stats`, not memory
