# Option B — default profile export (keys stripped)

Live-checked against `hermes_cli/profiles.py` `_DEFAULT_EXPORT_INCLUDE_ROOT`.

## Commands

```bash
hermes profile export default -o /path/hermes-default-mac-port.tar.gz
# import name cannot be default
hermes profile import ./hermes-default-mac-port.tar.gz --name mac
hermes profile use mac
hermes auth
```

## In / not in

In: `config.yaml`, `SOUL.md`, `skills/`, `sessions/`, `memories/`, `cron/`, `plugins/`, `desktop.json`.

Not: `.env`, `auth.json`, `honcho.json`, `state.db*`, `profiles/`, `hooks/`, `logs/`, `hermes-agent/`.

## After import

Rewrite MEMORY so the clone knows: ported from Mac Desktop default to this Linux VPS; no CUA/Desktop; keys were not copied; `/Users/activi` and OrbStack are not this host.

## Sibling profiles

A default export cannot restore named profiles. If the user may want stubs back, `tar czf stubs-backup.tar.gz` from `~/.hermes/profiles/` **before** `hermes profile delete -y`.
