# Gateway autostart, SIGTERM, wrappers (VPS)

## Sticky vs wrapper vs gateway (simple)

| Concept | What it does | Does NOT do |
|---------|--------------|-------------|
| Sticky (`~/.hermes/active_profile`) | Chooses profile for bare `hermes` | Start/restart gateway |
| Wrapper (`~/.local/bin/<name>`) | CLI shortcut → `hermes -p <name>` | Autostart gateway |
| Gateway unit | Keeps Telegram/API adapter alive | Change bare `hermes` profile |

**Blankes hermes** = only the word `hermes` (no `-p`, no alias). Uses sticky/default.

**SIGTERM** = polite stop signal (15). Process should clean up. Opposite of SIGKILL (9). Hermes logs: `Received SIGTERM — initiating shutdown` + often `.clean_shutdown`. Exit 1 asks systemd `Restart=on-failure` / `Restart=always` to revive — **only works if a unit exists**.

## Failure mode seen on myhermi / s-ella (2026-08-12)

1. Profile gateway run ad-hoc for hours (worker scopes / manual `hermes -p s-ella gateway run`).
2. ~19:35 UTC: planned restart of **default** + **secret** gateways (exit 75 TEMPFAIL / self-improvement cycle).
3. s-ella also got SIGTERM (`under_systemd=yes parent_pid=1`).
4. s-ella exited cleanly expecting restart — **no** `hermes-gateway-s-ella.service` → stayed **stopped**.
5. Not OOM (no dmesg/journal OOM). Stale `gateway_state.json` may still say `running`.

Detect:

```bash
hermes -p <name> gateway status
ls ~/.hermes/profiles/<name>/.clean_shutdown gateway.pid gateway_state.json
systemctl list-unit-files | rg "hermes-gateway"
journalctl -u hermes-gateway -u hermes-gateway-<name> --since "2 hours ago" | rg -i SIGTERM|restart|TEMPFAIL
```

## Install recipe (named profile, boot-safe)

```bash
hermes -p s-ella gateway install --system --force --start-now --start-on-login --run-as-user root
# Unit: /etc/systemd/system/hermes-gateway-s-ella.service
# ExecStart: python -m hermes_cli.main --profile s-ella gateway run
# Environment: HERMES_HOME=…/profiles/s-ella
# Restart=always, KillSignal=SIGTERM
systemctl is-enabled hermes-gateway-s-ella.service   # enabled
systemctl is-active hermes-gateway-s-ella.service    # active
# Telegram: gateway_state.json platforms.telegram.state == connected
```

Pitfall: `--system` without `--run-as-user root` raises:
`ValueError: Refusing to install the gateway system service as root; pass --run-as-user root to override`.

User-level alternative (like secret): omit `--system` → `~/.config/systemd/user/hermes-gateway-<name>.service` (may need linger).

## Ensure every profile has a name wrapper

```bash
for p in $(ls ~/.hermes/profiles); do
  [ -x "$HOME/.local/bin/$p" ] || hermes profile alias "$p"
done
```

Verified thin form:

```sh
#!/bin/sh
exec /usr/local/bin/hermes -p s-ella "$@"
```

## macOS launchd (named profile, live 2026-09-01)

Default unit is **only** `~/Library/LaunchAgents/ai.hermes.gateway.plist` (`ai.hermes.gateway`). Wrappers (`~/.local/bin/marge` → `exec hermes -p marge "$@"`) do **not** start a gateway.

`hermes -p <name> gateway start` without a plist leaves the profile stopped. Install:

```bash
hermes --accept-hooks -p marge gateway install --start-now
# → ~/Library/LaunchAgents/ai.hermes.gateway-marge.plist
# Exec: python -m hermes_cli.main --profile marge gateway run --external-supervisor
# HERMES_HOME=~/.hermes/profiles/marge
# logs: ~/.hermes/profiles/marge/logs/gateway.log
```

`--accept-hooks` is a **global** flag. `hermes -p marge gateway install --accept-hooks` → `unrecognized arguments: --accept-hooks`.

Verify:

```bash
hermes gateway list          # ✓ marge — PID …
launchctl list | grep hermes # ai.hermes.gateway + ai.hermes.gateway-marge
marge gateway status
```

Ops via alias: `marge` / `marge chat` / `marge gateway start|stop|status` / `marge model`.

## Resource claims — live only

- k3s: `ps -p $(pgrep -f '/usr/local/bin/k3s server') -o pid,pcpu,pmem,rss,args` + `systemctl status k3s`
- Docker n8n stack: `docker stats --no-stream` + `docker inspect` for `DB_TYPE=postgresdb`
- Do not say "postgres/coredns small" as if n8n had no DB — n8n app RAM dominates; postgres process can be ~26MB while DB disk is small (e.g. 14MB).
