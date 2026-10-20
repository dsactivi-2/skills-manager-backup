---
name: hermes-skills
category: hermes
description: Safe usage of the Hermes skills CLI (browse, search, install, list). Emphasizes explicit confirmation before any installation and clear distinction between read-only exploration and mutating actions.
---

# Hermes Skills Management

## Purpose
Provide safe, explicit workflows when working with `hermes skills` commands.

## Key Rules
- `hermes skills browse` and `hermes skills search` are **read-only**. They do not install or activate anything.
- Installation only happens via explicit `hermes skills install <identifier>`.
- Always confirm with the user before running any install command.
- When user shows caution ("ich hoffe nicht"), explicitly reassure that browse/search commands have no side effects.

## Pitfalls
- Do not assume that running `browse` activates hub skills.
- Hub-installed skills are only added when `install` is deliberately called.
- Some skills are protected (bundled or hub-installed) — do not attempt to edit them.
- `hermes skills install` accepts hub IDs or HTTP(S) SKILL.md URLs only — **local filesystem paths fail** ("Could not fetch"). For local/open-plugin skill trees, symlink into `$HERMES_HOME/skills/<category>/` (see `hermes-profile-capability-audit` + `scripts/hermes-open-plugin-to-profiles.sh`).
- `npx plugins add` is **not** the Hermes installer (targets Claude/Codex/Copilot/… only).
- Installing an agent skill does not automatically install the vendor CLI it invokes. Read the installed `SKILL.md`, consult the vendor's official setup docs, install standalone Python CLIs with `uv tool` or `pipx` where appropriate, then verify both version and authentication status. Do not trigger interactive login without the user's request. Same-name PyPI packages are not the pack CLI — match `jev doctor` / `setup-key` to `kerpopule/hermes-jev-skills` `bin/jev`, not `uv tool install jev-cli`. See `references/agent-skill-cli-prerequisites.md`.
- Pack skills on disk do not force Jev on every turn. Auto-routing needs plugin `hermes-jev` in `plugins.enabled` plus non-empty routing pools; `jev doctor` `tiers_configured: []` means no routing. Do not claim the nine skills are always used. Dashboard is `jev dashboard` on loopback :8791 — start it only when asked. `npx skills add --list` can skip a SKILL.md with a YAML parse error; report the skip, do not install a broken name.
- `npx @larksuite/cli@latest install` is a **vendor CLI installer**, not `hermes skills install`. It writes `lark-cli` plus 28 `lark-*` skills into `~/.agents/skills` and **retargets default** `~/.hermes/skills/lark-*` to those dirs. Named profiles keep old copies/symlinks until you relink them. After it runs, one SoT only — see `hermes-profile-capability-audit` `references/lark-cli-skills-to-profiles.md`. Do not also `npx skills add larksuite/cli --skill '*'` (overwrite risk).
- Two local skills with the same frontmatter `name:` → `skill_view` fails with "Ambiguous skill name". Keep one class-level skill; delete/archive duplicates (e.g. do not leave both `langfuse` and `langfuse-official` with `name: langfuse`). Cloudflare: platform = `cloudflare`; MCP/tokens/Worker-exposure = `cloudflare-mcp`.
- Profile skills can still hold old copies after default is cleaned — sync active builder profiles (e.g. barbares) in the same pass.
- Symlinks: `~/.hermes/skills/X` may point at `~/.agents/skills/X`. Edit the real target once.
- When asked whether a named skill is installed, verify the active Hermes path and the resolved symlink target, then read that target's `SKILL.md` frontmatter. A present folder or symlink alone is not proof of a usable installation. If it is usable, do not reinstall or overwrite it; report the active path. If absent, the request “wenn nein installiere ihn” is explicit approval to run the selective `npx skills add` command with Hermes flags, then re-read `SKILL.md` to verify.
- A GitHub pack URL is not one skill. Answer install-status from `hermes skills list` plus `test -e ~/.hermes/skills/<name>` for names from `npx skills add <url> --list --full-depth -y`. Same-prefix folders under `~/.agents/skills` from another origin (local project, Codex copy) are not that pack — do not report them as installed for Hermes.
- **`tool_search` does NOT index skills.** It only searches deferred MCP *tools*. An empty `tool_search` result ("youtube" → 0 matches) does **not** mean the capability is missing. Before concluding a capability doesn't exist and reinventing it from scratch, check `skills_list` (or `hermes skills browse`) — a matching skill may already be installed. (Session cost: searched `tool_search` for "youtube", got nothing, hand-built a `yt-dlp` transcript pipeline — while a bundled `youtube-content` skill already covered exactly that.)
- User `npx skills add <github-url> --skill <name>` for Hermes: add `--agent hermes-agent --copy -y` (and `-g` except LiveKit). The user's paste usually omits the Hermes flags; without them the CLI prompts or lands outside `~/.hermes/skills`.
- User paste `npx skills use <url> --skill <name>` is **not** `add`. Do not graft `--copy -g -y` onto `use` (`Unknown option`). `--agent hermes-agent` on `use` fails (`Running Hermes Agent is not supported yet`; only claude-code, codex). Bare `use` dumps SKILL.md to stdout and may write `$TMPDIR/skills-use-*/<name>/`. Follow that prompt this turn; persist with `add` + Hermes flags only after never-overwrite. A skills.sh URL without „installiere“ is still named-skill install. A GitHub repo with `pyproject.toml` and no Root-`SKILL.md` is **not** a pack — do not `npx skills add` it. See `references/npx-selective-install.md`.
- User „für Codex global“: `--agent codex -g -y --copy`, **not** hermes-agent. Lands in `~/.agents/skills/<name>`. `skills use` is prompt-only. CLI „overwrites: Codex“ ≠ `~/.codex/skills/` write. See `references/npx-selective-install.md`.
- Selective `--skill` from a pack can install a **stub front door** whose body only names another skill (mattpocock `grill-me` → "Call the Skill tool with grilling", `disable-model-invocation: true`). That primitive is **not** pulled. After install, read the on-disk SKILL.md; if it only redirects, install the named primitive or tell the user the skill is inert. See `references/npx-selective-install.md`.
- GitHub trees like `plugins/hermes/SKILL.md` that only say `Canonical skill: ../../skills/<name>` are the same class of stub. `npx skills add` without `--full-depth` can stop at that thin file and miss `skills/<name>/` plus `references/`. Verified 2026-09-01: `dsactivi-2/recruiting-crm-mcp` — list with `--full-depth`, install `--skill recruiting-crm --full-depth --agent hermes-agent --copy -g -y`, then confirm on-disk SKILL.md is the long RPC skill (not the 5-line pointer) and `references/` exists.
- `--skill '*'` **overwrites same path**. If `~/.hermes/skills/<name>/` is a **category folder** (children: arxiv, …) and the pack ships a **single skill** of that name, npx replaces the whole tree. Verified: `mattpocock/skills` `research` clobbered Hermes `skills/research/` (arxiv, grounded-citations, balkan-phone-directories, …). Same class 2026-09-02: `vercel/workflow` skill `workflow` vs class folder `~/.hermes/skills/workflow/` (`verify-first-workflow`). WDK skill already at `vercel/workflow` (plugin). Default user rule: **never overwrite**; if the dest exists, stop and list conflicts. Restore: `references/npx-selective-install.md` (mv aside + `unzip -n` only that prefix). Docs-URL „installiere“ ≠ zweites `workflow`, ≠ npm in cwd.
- User explanations for this class: German, simple words, Fachbegriff first. Do not dump pack READMEs or SKILL.md bodies. Catalog listings (names + downloads + links): numbered list; each item = name, install count, skills.sh link on its own line, one Alltag sentence. CLI does not render markdown tables — do not use a table there. Missing count → `—`, never invented.
- TUI autocomplete after `/` mixes slash commands (run now) and skills (load on match or `/skill name`). When explaining that list, label which is which; seeing a skill name does not run it.
- `npx skills find` is ranked keyword search (top ~20 by installs), not a pack inventory and not a name lookup. `find --owner X` is that owner's popularity top — a requested skill can be absent while unrelated high-install skills rank. Repeating `find <skill-name> --owner X` still returns the same top list. `find <query>` is noisy: query tokens hit unrelated names; keep only skills whose name or description matches the task. Complete names+blurbs: `npx skills add <owner/repo> --list -y` (clone+list, no install). Topic search with Matt first: `--list` `mattpocock/skills`, then `find` for other creators. skills.sh HTML can show extra template names (`good-skill`, `cli-e2e-…`) that `--list` omits — trust `--list` as the installable set. A **per-skill** catalog page with Installs is still not installable if `--list` omits the name (`npx skills add --skill` → "No matching skills found"; git tree has no path). Do not hand-write a copy unless the user asks. Recipe: `references/npx-pack-inventory.md`.
- Skill install does **not** connect MCP. "hast du Zugang / bist du verbunden" after a skill add → `hermes mcp list` + `tool_search`, then German. Detail: `references/skills-load-vs-tools-vs-mcp.md`.
- CLI-backed skills (Omni, Langfuse CLI) are not MCP. Prove access with the vendor binary plus `hermes skills list` (local, enabled) and `skill_view`. Do not look for them in `tool_search`.
- `skill_manage` `create` rejects YAML `description` over 60 characters because the session skill index truncates at 57+…. That is a description-field gate, not a skill refusal. If the user pasted a vendor SKILL.md, land the skill, then patch the on-disk file to the vendor text and verify with `skill_view` plus a byte compare to the vendor dump (`omni skill`, `langfuse get-skill`). Never report that the skill was rejected when only the long description bounced.
- The conversation's available-skills snippet can still show a short blurb from session start. Report completeness from the file and a fresh `skill_view`, not from that snippet.
- Skills created via `skill_manage` get `created_by: learn`. After a user-requested vendor skill, `hermes curator pin <name>` so idle archive does not drop it.
- After a live MCP probe, do not answer with tool names + raw counts as the proof. Re-pitch what you asked and what it proved.
- If Denis asks "was bedeutet" / "was ist falsch gelaufen" after jargon: first sentence = Alltag (Textsuche kaputt / nur gemappte Berufe gezählt). RPC names and error codes only after that. Same for doctor/config warnings: what you see, nothing broken, then the one switch — no CLI markdown tables.
- Session banner `N tools · M skills` is the enabled catalog (`hermes skills list` footer: hub + builtin + local), not files injected into the prompt. Local includes plugin packs (Lark, Vercel). `.archive/` is already out of M. Disk `SKILL.md` under `~/.hermes/skills` is smaller than M; copies in `~/.agents/skills` are Codex/npx -g, not Hermes dups.
- Skill cleanup/merge/archive: proposal in waves, wait for explicit Freigabe. n8n-*-official and langchain/* are packs, not duplicates. Do not mass-delete profile copies in the same pass as default.
- "Skills in den Download-Ordner, eine Datei je Skill": dump complete packs, not SKILL.md alone. Concatenate live `skill_dir` (SKILL.md + references/) plus mapped repo docs; redact Bearer/JWT; no CRM-PII. Zips: one per harness (Hermes/Kimi/Codex/Alter), each with its own AGENTS.md + README + PROMPT — not a copied Hermes default. Eval trio + ten kerpopule + `jev`/`jev-eval` CLIs. Kimi `kimi.plugin.json` skills **array**. Codex never auto-edit hooks.json. Alter Skills folder + pointer. Hermes zip may include plugins; Hermes `plugin.yaml` does not load on the others. A matching copy under `~/.kimi/plugins` is not a live Kimi Code install — confirm `jev` in `~/.kimi-code/plugins/installed.json` before calling the zip redundant. Never replace a working `~/.local/bin/jev`. Recipe: `references/export-skill-pack-downloads.md`.
- jobstep-crm umbrella + children (`jobstep-crm-supabase`, `-candidate-search`, `-status`, `-write-gates`, `-autologik`) and `recruiting-crm` are **user-owned** — curator must not patch them. MCP tool-list drift goes in `hermes-mcp-http` references, not those SKILL.md files.

## Recommended Workflow
1. Use `browse` or `search` to explore.
2. Use `inspect <name>` to preview.
3. Only after explicit user approval: `install`.

## Vendor skill refresh (CLI-shipped skills)
Some vendors ship agent skills via CLI. SoT is the vendor dump, not a shortened Hermes create:

```bash
npm install -g langfuse-cli
langfuse get-skill > /tmp/vendor-SKILL.md
# Merge into ONE local class skill; keep Activi dual-routing appendix.
# Delete …-official duplicates so frontmatter name is unique.
skill_view(name)   # must not be Ambiguous

# Omni (Mac app helper — one skill, many subcommands):
/Applications/Omni.app/Contents/Helpers/omni skill
# Write that stdout to ~/.hermes/skills/omni-local-search/SKILL.md
```

Do **not** invent a second skill that only wraps the same API. If the vendor CLI covers the full OpenAPI surface, improve one skill’s routing/docs — not another CRUD wrapper. Layers: CLI = full API; project MCP = same API as tools; skill = how-to + local routing. Omni: one SKILL.md, CLI only, add/remove sources only on request.

## References
- `references/safe-browse-behavior.md` — browse is strictly read-only.
- `references/dedupe-vendor-skill-refresh.md` — name collisions, get-skill sync, profile copies (Langfuse case).
- `references/n8n-npx-install.md` — official n8n-io/skills pack via `npx skills add` (not `hermes skills install`).
- `references/npx-selective-install.md` — Hermes/Codex flags for `npx skills add`; `skills use` vs add; Codex dest is `~/.agents/skills`; stub wrappers vs primitives.
- `references/npx-pack-inventory.md` — list every skill in a pack (`--list` vs `find`); install counts; numbered German tables.
- `references/export-skill-pack-downloads.md` — one markdown per skill into `~/Downloads`, live tree + related repo docs, secrets redacted.
- `references/agent-skill-cli-prerequisites.md` — verify and install required vendor CLIs after a third-party agent-skill installation.