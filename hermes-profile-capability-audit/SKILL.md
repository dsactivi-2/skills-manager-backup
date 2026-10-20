---
name: hermes-profile-capability-audit
description: "Use when verifying Hermes profile capabilities, remote VPS instance maps, bare-hermes profile selection, wrappers-by-name, per-profile gateway systemd/launchd autostart/SIGTERM recovery, cross-profile sync, or open-plugin packs into profiles."
version: 1.4.1
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [hermes, profiles, mcp, skills, tools, audit, verification, sync, remote, sticky]
---

# Hermes Profile Capability Audit

Verify what a specific Hermes **profile** actually has — installed skills, configured MCP servers, enabled toolsets — instead of trusting a claim ("I only have 1 MCP and 7 skills") or the global skill list. Covers inventory reports, **remote VPS instance maps**, **why bare hermes lands in different profiles**, and **cross-profile selective sync** (there is no official global shared store).

## When to Use

- A user/agent claims a capability count and you must verify it.
- User asks "was habe ich und wo liegt es" for a profile.
- Building a profile-inventory report (local or remote VPS via SSH).
- "Welche Hermes-Instanzen/Profile liegen auf dem VPS?"
- "Warum öffnet hermes mal Profil A, mal Profil B?"
- Diagnosing why a profile "sees" fewer skills than are on disk.
- User wants one global place for skills/tools/MCP for all profiles — answer from **No global shared store**, then offer selective sync.
- User asks to install `npx plugins add owner/repo` (e.g. vercel/vercel-plugin) **for all Hermes profiles**.
- User asks to install **Lark / lark-cli skills globally** („alle Hermes-Instanzen“) — see `references/lark-cli-skills-to-profiles.md`.

## User preference (this class)

- DE, direct, Kurz+Tabellen — no lecture.
- Live-verify on the target host (SSH + CLI), never answer from memory alone.
- Report absolute paths, gateway running/stopped, model, size.

## Core pitfalls

1. **`skills_list` tool = global catalog** (hundreds). Never answer "what does profile X have?" from it.
2. **Folder count ≠ skill count** — category dirs (`creative/`, `productivity/`) bundle many `SKILL.md` files.
3. **`.bundled_manifest` = bundled subset only** — never report as total installed skills. Full count = `hermes -p <name> skills list` summary and/or SKILL.md count (excl. `.hub`/`.archive`/quarantine).
4. **Name typos**: "batbares" / "barbarez" → real dir `barbares`. Confirm under `~/.hermes/profiles/` first.
5. **macOS awk + unicode** (`✓ enabled` in `hermes tools list`) silently fails — parse with Python/regex (see inventory script).
6. **Bare `hermes` ≠ random profile** — selection is deterministic (see **Why different profiles open**). Multi-tab SSH with wrappers/`-p` looks random if you only watch the UI.
7. **Host-key / pubkey failures** on old VPS IPs are environment state — report live status; do not encode as permanent "VPS dead".
8. **Named GW on Mac:** `gateway start` is not enough if no LaunchAgent exists. Default is `ai.hermes.gateway.plist`; named needs `hermes -p <name> gateway install --start-now` → `~/Library/LaunchAgents/ai.hermes.gateway-<name>.plist`.
9. **`--accept-hooks` is global** — must precede the subcommand (`hermes --accept-hooks -p <name> gateway install --start-now`). After `gateway install` it is `unrecognized arguments`.
10. **Provider/model for a named profile:** `<alias> model` or `hermes -p <name> config set …`. Bare `hermes model` writes **default**.

## No global shared store (Docs verdict)

Profiles are isolated by design (`HERMES_HOME` per profile). **No** first-class shared skills/tools/MCP mount for all profiles.

| Shared automatically? | What |
|----------------------|------|
| Yes | Hermes binary/code; `hermes update` seeds **new bundled** skills to every profile |
| No | Hub/local/agent skills, `mcp_servers`, toolsets, `.env` keys, SOUL, memory, sessions |

Do **not** invent one global skills tree for every profile (bloat, prompt size, role mixing; Kanban needs per-assignee skills).

Official share/port patterns:
1. `hermes profile create X --clone` / `--clone-from Y`
2. `hermes skills snapshot export/import`
3. Profile Distributions (git: SOUL + skills + MCP defs; creds stay local)
4. **Selective sync** via `scripts/hermes-profile-sync.sh` (preferred for "copy these skills/MCP to barbares")

Practical model: fat install on **default** (`~/.hermes`); role profiles stay lean; copy only what the role needs. **Dry-run first** on every write path.

## Authoritative sources (per profile)

Default home = `~/.hermes`. Named = `~/.hermes/profiles/<name>/`.

| Dimension | Authoritative source | CLI |
|-----------|---------------------|-----|
| MCP servers | `mcp_servers` in `config.yaml` (`enabled`) | `hermes -p <name> mcp list` |
| MCP keys | per-profile `.env` | redact values |
| Skills (full) | `skills list` summary + SKILL.md count | `hermes -p <name> skills list` |
| Skills (bundled only) | `skills/.bundled_manifest` | subset only |
| Disabled skills | `skills.disabled` | `hermes skills config` |
| Toolsets | config + CLI | `hermes -p <name> tools list` |
| Usage | `skills/.usage.json` | `hermes curator status` |
| Overview | profile dir | `hermes profile show <name>` |

Field example: barbares ~69 manifest lines vs **85** full skills after local copies — both correct for different questions.

## Fast path (scripts)

```bash
# Live inventory
scripts/hermes-profile-inventory.sh barbares
scripts/hermes-profile-inventory.sh --md /tmp/inv.md

# Ops copies on this machine also live at:
# ~/Code/Tools/shared/bin/hermes-profile-inventory.sh
# ~/Code/Tools/shared/bin/hermes-profile-sync.sh

# Selective sync — DRY-RUN default; --apply to write
scripts/hermes-profile-sync.sh skills list-diff --from default --to barbares
scripts/hermes-profile-sync.sh skills copy --from default --to barbares --name hermes-profile-capability-audit
scripts/hermes-profile-sync.sh skills copy-many --from default --to barbares --names a,b --apply
scripts/hermes-profile-sync.sh mcp list-diff --from default --to barbares
scripts/hermes-profile-sync.sh mcp copy --from default --to barbares --name dograh --apply

# Open-plugin (e.g. vercel) → Hermes: npx does NOT target Hermes
scripts/hermes-open-plugin-to-profiles.sh vercel/vercel-plugin
scripts/hermes-open-plugin-to-profiles.sh vercel/vercel-plugin --category vercel --skip-npx
scripts/hermes-open-plugin-to-profiles.sh vercel/vercel-plugin --dry-run
```

After MCP copy: ensure target `.env` has keys; `/reload-mcp` or new session / gateway restart.

## Open-plugin → Hermes (all profiles)

`npx plugins add owner/repo` installs into Claude Code / Codex / Copilot / Grok / Cursor / Kimi — **not Hermes**.

When the user wants open-plugin skills on Hermes profiles:

1. Optional: `npx plugins add <id> -y --scope user` for other agents (Grok may fail if CLI has no `plugin` — non-blocking).
2. Do **not** rely on `hermes plugins install` alone — clones without `plugin.yaml`/`__init__.py` are not enableable.
3. Do **not** use `hermes skills install /local/path/SKILL.md` — local paths are not fetchable.
4. Working pattern: one shared git clone under `~/.hermes/plugins/<repo>/` + per-profile **symlinks** of each `skills/*` dir into `skills/<category>/` (default + `~/.hermes/profiles/*/skills/`). Hermes follows skill symlinks.
5. Check frontmatter `name:` collisions before mass-link. Prefer lean role profiles — full packs (30+ Vercel skills) bloat the index; only all-profiles when explicitly requested.
6. Verify with `hermes skills list` / `HERMES_HOME=.../profiles/<p> hermes skills list`; `/reload-skills` or new session.

Details + pitfalls: `references/open-plugin-to-hermes-profiles.md`.

## Vendor CLI skill packs (Lark)

`npx @larksuite/cli@latest install` is **not** `hermes skills install` and **not** `npx plugins add`. It installs `lark-cli` plus 28 `lark-*` skills into `~/.agents/skills` and retargets **default** `~/.hermes/skills/lark-*` only.

- Relink named **work** profiles to that same SoT (do not leave `hermes-lark` on a second clone).
- „Alle Instanzen“ = Mac work profiles + remote **default**. Skip RP-only VPS profiles (`s-ella`, …).
- Dedicated profile copies at top-level + a new `skills/lark/` category = Ambiguous `name:`.
- Do not run `config init` / `auth login` as part of the skill copy.

Recipe: `references/lark-cli-skills-to-profiles.md`.

## Manual audit steps

1. Resolve real profile name (`ls ~/.hermes/profiles/`).
2. `profile show` + `mcp list` + `skills list` + `tools list` for that `-p`.
3. Confirm MCP keys in profile `.env` (redact).
4. If user counted folders/manifest only, re-explain full vs bundled.
5. Report claim vs reality with absolute paths.

## Verification

- CLI skills summary should track SKILL.md count; large gaps → incomplete copy or stale session (`/reload-skills`).
- Never `grep -r` over `$HOME` — scope to `~/.hermes`.

## Local skill vs hub indexer

Prefer this **local** skill over hub "index/catalog" skills for Hermes inventory. Hub/tap skills are curator-off-limits; generic indexers target code docs, not `$HERMES_HOME`. Native CLI already exposes the data.

## Discover another profile's active project path

Do **not** answer from process cwd alone (often `$HOME`).

1. `profiles/<name>/memories/MEMORY.md`
2. `profiles/<name>/logs/agent.log` — last repo-looking `cwd=`
3. `handoff_*/HANDOFF.md`, `PATHS.md`, `NEXT_ACTIONS.md`
4. `session_search(profile=<name>)`
5. Optional `lsof` cwd — weak

Report **project SoT** and **last tool cwd** when they differ.

For SOUL/AGENTS authoring against that project: load `hermes-profile-soul-agents` (draft-first, Freigabe before apply).

## Why different profiles open (bare hermes / multi-tab)

Profile selection runs **before** argparse via `_apply_profile_override()` in `hermes_cli/main.py`:

1. Explicit `-p` / `--profile` / `--profile=` (invalid ids rejected)
2. Else if `HERMES_HOME` already points at `…/profiles/<name>`, keep it
3. Else sticky `~/.hermes/active_profile` (`hermes profile use <name>`) — missing/empty ⇒ `default`
4. Named profile ⇒ set `HERMES_HOME` to that profile root

Also looks like a different profile when:

| Cause | Detect |
|-------|--------|
| Wrapper alias (`secret`, `dograh`, …) in `~/.local/bin` | `type -a secret`; wrappers `exec hermes -p <name> …` |
| Explicit `hermes -p X` | `ps` cmdline / history |
| Sticky switch | `cat ~/.hermes/active_profile`; `hermes profile` ◆ |
| Other SSH tab in another profile | `ps -eo tty,args \| rg hermes` |
| Separate gateway per profile | systemd unit + `HERMES_HOME=…/profiles/X` |
| Same profile, different model/session | Banner Session + model — not a profile switch |

```bash
hermes profile                 # active now
hermes profile use default     # sticky default
hermes -p secret chat          # one-shot explicit
echo "$HERMES_HOME"            # empty/~/.hermes=default; …/profiles/X=named
```

CLI note (v0.20+): `hermes profile list` — not `hermes profiles list`.

**List local profiles from disk first.** Named dirs = `ls ~/.hermes/profiles/` plus implicit `default` at `~/.hermes`. Do not wait on `hermes profile list` for the inventory: the CLI can run a source-update / desktop rebuild before printing names. Count SKILL.md later with `find … -name SKILL.md` or the inventory script; `hermes -p <name> skills list` is slower and same rebuild risk.

Details: `references/profile-selection-and-remote-inventory.md`.

## Remote VPS: all Hermes instances + profiles

Do **not** inventory the local Mac when the target is an SSH host (e.g. `myhermi`).

```bash
ssh <host> 'bash -s' < scripts/hermes-remote-instance-inventory.sh
```

Minimum live checks on host:

```bash
hermes version
hermes profile list
hermes profile
ls -la ~/.hermes/active_profile ~/.local/bin
ps auxww | rg '[h]ermes'
systemctl list-units --all | rg -i hermes
du -sh ~/.hermes ~/.hermes/profiles/* 2>/dev/null
```

Report: PROFILE | MODEL | GW | SIZE | CONFIG | PATH. Separate empty project stubs from real installs.

## Profile wrappers (open by profile name)

User expectation: **every named profile opens via its name** (`marge`, `s-ella`, `dograh`, …), not only bare `hermes`.

Start: `<name>` or `hermes -p <name>` (TUI: `<name> --tui`). Wrapper is `exec ~/.local/bin/hermes -p <folder> "$@"` in `~/.local/bin/<folder>` (same shape as `marge`).

Display name ≠ folder (`MacDev` vs `mac-dev`): `hermes profile alias` only writes the **folder** name. Add a **second** executable `~/.local/bin/<Display>` with the same `exec … -p <folder>` body. Do not `hermes profile use` the worker — sticky `default` stays the orchestrator.

Never invoke `<Display> -p <folder>` — the wrapper already injects `-p`; a second `-p` makes Hermes treat the folder as a subcommand.

```bash
# missing folder wrappers
for p in $(ls ~/.hermes/profiles); do
  [ -x ~/.local/bin/$p ] || hermes profile alias "$p"
done
# display-case extra (example)
# printf '%s\n' '#!/bin/sh' 'exec ~/.local/bin/hermes -p mac-dev "$@"' > ~/.local/bin/MacDev && chmod +x ~/.local/bin/MacDev
type -a s-ella; head -3 ~/.local/bin/s-ella
```

- `default` has no wrapper — bare `hermes` is default.
- Custom wrappers (e.g. `secret`) may auto-`chat` when argv empty; plain aliases pass args through.
- Ensure `~/.local/bin` is on PATH (login shell `.profile` / `.bashrc` often source `~/.local/bin/env`).

## Gateway autostart per profile (systemd)

**Why a profile shows GW=stopped forever:** it was started ad-hoc (`hermes -p X gateway run` / worker scope). On **SIGTERM** (planned restart of *other* gateways, update, systemd stop) it exits code 1 expecting `Restart=on-failure` — **without a unit nobody restarts it**. Marker: profile `.clean_shutdown` + `gateway.pid` missing + stale `gateway_state.json`.

Install + enable + start (Linux system unit; boot without linger):

```bash
hermes -p <name> gateway install --system --force --start-now --start-on-login --run-as-user root
# without --run-as-user root → ValueError: Refusing system service as root
systemctl is-enabled hermes-gateway-<name>.service
systemctl is-active hermes-gateway-<name>.service
journalctl -u hermes-gateway-<name> -n 40 --no-pager
# Telegram proof: profiles/<name>/gateway_state.json → platforms.telegram.state=connected
```

| Kind | Example unit | When |
|------|----------------|------|
| system default | `hermes-gateway.service` | host default profile |
| system named | `hermes-gateway-s-ella.service` | boot-safe named GW |
| user named | `~/.config/systemd/user/hermes-gateway-secret.service` | needs user session/linger |

### macOS launchd (this Mac)

Default GW ≠ named GW **unless multiplex is on**. If `gateway.multiplex_profiles: true` and `hermes gateway list` already shows named profiles as “served by the default multiplexer”, do **not** `gateway install` a second LaunchAgent when the user wants the same gateway as default — create the profile, copy skills, `hermes gateway restart` (default), verify the new name appears on the multiplexer. A second plist is for a dedicated Telegram/token process, not for parallel CLI.

When multiplex is off: `hermes gateway list` can show default running while named profiles are stopped even if wrappers exist.

```bash
hermes profile list
hermes gateway list
# missing LaunchAgent and NOT multiplexed → install, do not only start
hermes --accept-hooks -p <name> gateway install --start-now
# plist: ~/Library/LaunchAgents/ai.hermes.gateway-<name>.plist
# label: ai.hermes.gateway-<name>
# logs:  ~/.hermes/profiles/<name>/logs/gateway.log
launchctl list | grep hermes
<name> gateway status   # alias = hermes -p <name>
```

CLI chat: `<name>` or `<name> chat`. Provider: `<name> model` then `<name> gateway restart`. Persist model/provider/base_url/api_mode via `hermes-config-persistence` (four keys).

Live proof of load claims (never memory): `ps -o pid,pcpu,pmem,rss,args -C k3s` / `systemctl status k3s` / `docker stats --no-stream`. RSS kB/1024 = MB. n8n stack = app RAM + task-runner + postgres (DB process can be small while app is large).

Details: `references/gateway-autostart-and-sigterm.md` (Linux systemd + macOS launchd).

## RP-only / companion profile skill cut (s-ella pattern)

When a profile is **character RP only** (Telegram companion), do **not** leave full creative/github/research/comfyui indexes enabled — soft-conflicts (agent picks ComfyUI instead of Wiro) and prompt bloat.

Live-verified keep set for s-ella:
`ella-behavior`, `ella-roleplay`, `ella-image-gen`, `ella-nsfw-guard`, `agent-rpg`, `humanizer`.

```bash
# 1) Delete hard conflicts / junk on disk
rm -rf ~/.hermes/profiles/<p>/skills/creative/comfyui
rm -rf ~/.hermes/profiles/<p>/skills/{github,research,agent-builder}
# Artemis full dumps if present:
rm -rf ~/.hermes/profiles/<p>/skills/{behavior-engine,harem,violence-nsfw}

# 2) skills.disabled in profile config.yaml (authoritative for remaining builtins)
# skills:
#   disabled: [architecture-diagram, arxiv, github-auth, …]

# 3) Stop bundled re-seed of empty category stubs after gateway restart
hermes -p <p> skills opt-out
# marker: profiles/<p>/.no-bundled-skills
# optional: hermes -p <p> skills opt-out --remove -y  # delete unmodified bundled on disk

# 4) Verify
hermes -p <p> skills list   # expect lean enabled set
ls ~/.hermes/profiles/<p>/skills
systemctl restart hermes-gateway-<p>   # if system unit exists
```

Pitfalls:
- `skills list` may show `0 disabled` after dirs were deleted even if `skills.disabled` still lists names — those names are no longer on disk.
- Without opt-out, restart/update can recreate empty category dirs (`apple/`, `github/`, …).
- Image soft-conflict: **comfyui skill + ella-image-gen** both enabled while Telegram toolset is MCP-only — still confuses the model. Delete/disable comfyui; SOUL/AGENTS: only `mcp__ella_wiro__generate_ella_image` + `MEDIA:`.
- Name-dupes: zero SKILL.md frontmatter `name:` collisions required (`skill_view` fails on Ambiguous).
- Hook inject: one HARD STATE + one BEHAVIOR block; pre_llm timeout ~8s, smoke should be <1s.

Artemis port status (installed on s-ella): see `references/artemis-to-s-ella-import.md`.

## References & scripts

- `references/audit-recipe.md` — short recipe + count pitfalls
- `references/no-global-shared-store.md` — Docs model + share patterns
- `references/open-plugin-to-hermes-profiles.md` — npx plugins vs Hermes; vercel multi-profile recipe
- `references/lark-cli-skills-to-profiles.md` — official `@larksuite/cli` skills → default + work profiles; SoT after npm install
- `references/profile-selection-and-remote-inventory.md` — sticky/active_profile, wrappers, multi-tab, remote inventory
- `references/gateway-autostart-and-sigterm.md` — SIGTERM without unit, system install --run-as-user root, wrappers-by-name
- `references/artemis-to-s-ella-import.md` — what to port from momori777/Artemis into s-ella (and what to skip)
- `references/artemis-s-ella-live-install.md` — paths/hooks actually installed on myhermi s-ella
- `references/rp-only-skill-cut.md` — lean companion skill set + opt-out/disabled recipe
- `scripts/hermes-profile-inventory.sh` — multi-profile inventory
- `scripts/hermes-profile-sync.sh` — dry-run-default skills/MCP sync
- `scripts/hermes-open-plugin-to-profiles.sh` — open-plugin skill tree → default + all profiles (symlinks)
- `scripts/hermes-remote-instance-inventory.sh` — host-wide Hermes instance/profile/process inventory (SSH target)
