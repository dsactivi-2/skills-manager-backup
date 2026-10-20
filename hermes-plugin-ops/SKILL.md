---
name: hermes-plugin-ops
description: "Use when installing, enabling, or fixing Hermes plugins."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [hermes, plugins, typesafe, gateway, skill-routing]
---

# Hermes Plugin Ops

Manage Hermes Agent plugins end-to-end: install, enable, wire secrets, restart the gateway, and verify live. Covers catalog, git, and pip plugins; the typesafe-skill-router (Jeff) has its own runbook (see References).

## Plugin lifecycle (procedure)

1. **Find:** `hermes plugins search <term>` (curated catalog). Bundled plugins need no install — they appear in `hermes plugins list` with source `bundled` and only need enabling.
2. **Install:** `hermes plugins install <name>` (catalog name or git URL). Installs land in `~/.hermes/plugins/<name>/`.
3. **Enable:** `hermes plugins enable <name>`. When prompted about tool-override (replacing built-ins like write_file/shell_exec), grant ONLY if the plugin's plugin.yaml has a non-empty `provides_tools` — a hook-only plugin never needs `--allow-tool-override`; granting it there is a no-op permission.
4. **Check the plugin's own switch.** `hermes plugins enable` only loads the plugin; many plugins keep a separate internal on/off setting. Run the plugin's CLI subcommand (`hermes <plugin-name> status`) and switch it on if needed (e.g. `hermes typesafe-skill-router on`).
5. **Secrets:** put required env vars (from `requires_env` in plugin.yaml) into `~/.hermes/.env` — a shell export alone does not survive.
6. **Restart:** `hermes gateway restart`. If `hermes gateway status` then reports a stale launchd service definition, follow with `hermes gateway start` to refresh it.
7. **Verify live:** run the plugin's own check (e.g. `hermes typesafe-skill-router check --live`) or one real call. Plugin changes take effect next session, never mid-conversation.

## pip-based plugins

pip plugins (e.g. `hermes-keenable-web`) install into Hermes's own venv, not system Python:

    ~/.hermes/hermes-agent/venv/bin/pip install <package>

- System pip refuses via PEP 668; `--break-system-packages` is the wrong fix.
- Importing such a package outside Hermes fails on `from agent.web_search_provider import ...` — the package needs the Hermes source root on sys.path. Verify via `hermes plugins list --plain --no-bundled` (entrypoint plugins show there) instead of a bare import test.
- Backend-type plugins also need their routing key set, e.g. `hermes config set web.backend <name>`, and a gateway restart.

## Pitfalls

- **Enable ≠ on.** A plugin can show `enabled` in the list while its function is internally off — silent no-op is the failure mode. Always run the plugin's `status` subcommand after enabling.
- **Concurrent `hermes update` mutates ~/.hermes/skills.** If skills vanish mid-session without your action, do not assume your own archive ran: re-scan, then restore from `~/.hermes/backups/pre-update-*.zip` (unzip the specific `skills/<category>/<name>/` paths back). Verify every roster change by reloading the roster.
- **Gateway restart kills running agents** — it is approval-flagged. Batch restarts instead of restarting twice.
- **Jeff and hermes-jev are different plugins.** Jeff (`typesafe-skill-router`) already picks one skill per turn. Default: leave hermes-jev `skills` off so only Jeff routes skills; hermes-jev does model routing (`routing: shadow` until the user asks for `on`). Live switch is `~/.hermes/jev/state.json` strings. If default AGENTS.md says hermes-jev skills on while Jeff is on, treat AGENTS.md as stale and set `skills: "off"` unless the user named `/jev skills on`. Two skill tips per turn is the failure mode. If the user names the Skill-Switch / `/jev skills on`, write `skills: "on"` (not YAML bool), warn that Jeff still runs, and do not disable Jeff unless asked. `install.py` default `--enable all` would turn hermes-jev and hermes-handoff on in every profile including voice lanes — use `--enable default` unless the user names other profiles.
- **One Jev skill tree only.** Same frontmatter `name:` under both `~/.hermes/skills/jev-*` and `~/.hermes/skills/jev/jev-*` inflates Jeff's roster so Choice splits probability. Keep a single copy: on this Mac `~/.hermes/skills/jev-*` matching `~/hermes-jev-skills/skills/`. Before `rm -rf` either tree, confirm the other exists as a real directory (`test -d` + `SKILL.md`), not the same inode — deleting the nested folder first can wipe the only copy if they were linked. Restore from `~/hermes-jev-skills/skills/` if a tree vanishes.
- **kerpopule hermes-jev** is not `hermes plugins install` from the catalog. Install from `~/hermes-jev-skills` with `python3 install.py --check` then `--enable default --hermes-home ~/.hermes`. Verify `hermes plugins list` shows hermes-jev enabled, `jev doctor` has `tiers_configured`, and routing is `shadow`. Then gateway restart once.
- **`hermes config set … notice on` writes YAML boolean `true`.** hermes-jev `_setting` does `str(value).lower()` and compares to `"on"` / `"shadow"`, so `true` never matches. Put the strings in `~/.hermes/jev/state.json` (`routing`, `skills`, `notice`) — that file wins over config.yaml. Do not patch `config.yaml` by hand when `hermes config` is blocked.
- **Jev jargon, Alltag first:** Routing = welches Modell dieser Turn bekommt. off = Sitzungsmodell bleibt. shadow = Jev tippt und loggt, wechselt nicht. on = wechselt wirklich. Skill-Switch = welche Anleitung — bei Jeff schon an, bei hermes-jev aus lassen. Notice = eine sichtbare Zeile an der Antwort, kein Modellwechsel.
- **Nightly handoff:** `nightly-handoff.py --dry-run` before scheduling. Limit `--profile default` so voice lanes are not closed. Cron: wrapper script + `no_agent` + `deliver=local`. Do not run the live closer in the current session.
- **Jev dashboard** (`jev dashboard`, http://127.0.0.1:8791/): file-backed (config, `jev/routing.json`, `logs/jev-decisions.jsonl`). No Redis/DB — do not provision one for this page. Closing a Terminal window does not always kill it; ending the Hermes CLI or reboot does. Not launchd. User double-click after reboot: `~/Desktop/Jev Dashboard.command` (chmod +x, `nohup` + `~/.local/bin/jev`, then `open` the URL). Off/Shadow/On POSTs immediately (`/api/jev/switch`); **Apply changes** is only for main-model/slot dropdowns and stays disabled at 0 pending. Routing pools are read-only on the page. All-profiles switch needs the confirm dialog. The Live table is hidden until the Live button is on — `/api/jev/live` can already have events while the page looks empty. `jev route` on the CLI does not append jsonl; only the hermes-jev plugin does. A `route` row with reason `you pinned this model` means the session model is locked, so routing on still does not switch. There is no HOOKS.md — hooks live in `plugins/hermes-jev/plugin.yaml`.
- **Skills are not the plugin.** npx/`hermes skills` copies SKILL.md; `install.py` copies `hermes-jev` into `~/.hermes/plugins/`. Do not tell the user you turned skills into a plugin. After `--list` skips a YAML-broken SKILL.md, copy that skill from the checkout into `~/.hermes/skills/<name>/` if it only landed under `skills/jev/`.
- **„Plugin für die Jev-Skills“ is hermes-jev.** Verify enabled + `state.json` + `jev doctor`; do not scaffold a second `plugin.yaml`. Motor vs Zettel: plugin runs every turn; skills remain for CLI/pools/mail/browser. Jeff already picks skills — leaving hermes-jev `skills` on means two tips. Default-only `--enable default`. There is no HOOKS.md; fleet ops notes go in `~/.hermes/AGENTS.md` when there is no project root.
- **Do not port Hermes plugin.yaml into Kimi/Codex/Alter as the plugin.** Those harnesses load SKILL.md (Kimi also `kimi.plugin.json`). Copying `hermes-jev` or `typesafe-skill-router` into their plugin dirs does not attach `pre_llm_call`. See hermes-skills `references/export-skill-pack-downloads.md`.
- **Kimi live is the registry, not a leftover home.** Kimi Code 2.x loads `~/.kimi-code/plugins/installed.json` plus `managed/<id>/`. A tree under `~/.kimi/plugins` or `~/.kimi/skills` after migration is leftover. Another agent saying the pack is already installed because those folders match the zip is a false positive until `id` is in that JSON and `enabled`. User skills Kimi actually scans: `~/.kimi-code/skills/` and `~/.agents/skills/`.
- **One `jev` on PATH.** SoT is `~/hermes-jev-skills/bin/jev` via `~/.local/bin/jev`. Do not `ln -sfn` a zip copy over it when `jev doctor` already reports version and reachable. Eval CLI is `uv run jev_eval.py`; missing system-Python `typesafe_sdk` is expected, not a blocker.
- **TypeSafe is not a supervisor of all agents.** Jeff picks one skill in Hermes. Jev with routing on may pick a model in Hermes. Neither watches Kimi/Codex/Alter unless that session runs `jev`. `jev_eval` is an explicit review, not a per-turn checker. Many `jev-*` SKILL.md files share that one CLI — they do not each get a binary.
- **Welcher Befehl:** if Denis asks what you did not change, name the typed command `jev` in one sentence. Do not lead with symlink, umbiegen, or Chef.

## References

- `references/typesafe-router-runbook.md` — operate and tune the typesafe-skill-router (Jeff): switches, config keys, thresholds, live verification.
- `references/roster-audit-jeff.md` — batch-evaluate the skill roster via the TypeSafe API: duplicates, overlap %, need ratings, keep/archive, restore.
