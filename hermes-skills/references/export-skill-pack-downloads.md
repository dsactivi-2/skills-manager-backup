# Export skill packs to Downloads

Denis: "alle Informationen … eine Datei je Skill" → `~/Downloads/<skill-name>.md`. Not a zip of folders. Not SKILL.md only.

## What goes in one file

1. Header: export time, live `skill_dir`, usage JSON from `~/.hermes/skills/.usage.json`.
2. Section A: every file under the live skill dir (`SKILL.md`, `references/`, scripts).
3. Section B: related repo docs mapped to that skill (Jobstep: `/Users/activi/Documents/ChatGPT/jobstep-crm-status-mcp`). Include the bundle copy under `skills/bundle/<name>/` if it differs.
4. Redact Bearer, JWT (`eyJ…`), `sbp_`, postgres URLs. Do **not** dump CRM candidate rows.

## Zips for Hermes / Kimi / Codex / Alter

When the user wants Jev+Jeff as install packs, write one zip per named harness under `~/Downloads` (no `.env`, no credentials, no `.git`, no Jeff `cache.json`, no `jev-eval/optimierungen/`, no `*.ergebnis.jsonl`) unless they asked zip-only. Packers: `~/.hermes/cache/scratch/rebuild-jev-packs.py` and `build-jev-zips-3.py`.

Write a **separate** `AGENTS.md` per harness. Do not copy `~/.hermes/AGENTS.md` into Kimi/Alter/Codex. Hermes: Jeff plugin + hermes-jev `skills: off`. Kimi: Skill/Bash, `kimi.plugin.json` skills **array**. Codex: `~/.codex/skills`, never edit `hooks.json`. Alter: pointer `Skills/jev/SKILL.md`, no `pre_llm_call`. Each zip also has `README.md`/`INSTALL.md` and `PROMPT.md`; also write `Jeff <Harness> prompt.md` + `.txt` next to the zip.

Each zip must contain:
- the eval trio from `~/jev-project/skills/` (`jev-evaluation`, `jev-eval-cli`, `jev-review-loop`)
- the ten kerpopule skills from `~/hermes-jev-skills/skills/`
- CLIs: kerpopule `bin/jev` + `jevkit/` under `cli/`, and a trimmed `~/jev-project/tools/jev-eval/` (no run artifacts)
- harness-native loader (not Hermes `plugin.yaml` as the thing that runs on Kimi/Codex/Alter):
  - Hermes zip only: `plugins/typesafe-skill-router` + `plugins/hermes-jev` + skills `ask-jeff` and `typesafe-ai`
  - Kimi: `kimi.plugin.json` `skills` MUST be a JSON array of `"./skills/<name>"` (one per SKILL.md). A string `"./skills/"` is nine characters, not thirteen skills — the loader will not walk the folder. `commands` is `"./commands"`. Dest: `test -f` both `~/.kimi/plugins/jev/kimi.plugin.json` and under `~/.kimi-code/plugins/`; write every live dest, `rm -rf` first or you nest `jev/jev`. Also copy skills into whichever `*/skills` dirs already hold `jev-setup`.
  - Codex: skills into `~/.codex/skills` and `~/.agents/skills` plus Codex `AGENTS.md`. Do not splice `hooks.json`.
  - Alter: `~/Library/Application Support/Alter/Skills` plus pointer skill `jev/SKILL.md`
- `plugins/typesafe-skill-router` in non-Hermes zips only as labeled reference, without `.git` or `cache.json`

Do not `ln -sfn` over `~/.local/bin/jev` when `jev doctor` already reports 0.19.x and reachable. SoT: `~/hermes-jev-skills/bin/jev`. Eval CLI is `uv run jev_eval.py` (missing system-Python `typesafe_sdk` is expected, not a blocker).

Replace the previous zip of the same name. CLI is kerpopule `bin/jev`, not PyPI `jev-cli`.

## Jobstep map (verified 2026-09-01)

| Skill | Live dir |
| --- | --- |
| jobstep-crm | `~/.hermes/skills/supabase/jobstep-crm` |
| jobstep-crm-supabase | `~/.hermes/skills/devops/jobstep-crm-supabase` |
| jobstep-crm-candidate-search | `~/.hermes/skills/supabase/jobstep-crm-candidate-search` |
| jobstep-crm-status | `~/.hermes/skills/supabase/jobstep-crm-status` |
| jobstep-crm-write-gates | `~/.hermes/skills/supabase/jobstep-crm-write-gates` |
| jobstep-crm-autologik | `~/.hermes/skills/supabase/jobstep-crm-autologik` |

Those six are user-owned. Export is a copy; do not curator-patch the sources.
