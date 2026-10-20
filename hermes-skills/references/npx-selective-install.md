# npx skills add — Hermes flags + stub wrappers

When the user names a GitHub pack and one skill, run non-interactively:

```bash
npx skills add https://github.com/<owner>/<repo> --skill <name> --agent hermes-agent --copy -g -y
```

The user's paste often omits `--agent hermes-agent --copy`. Without those, the CLI prompts or writes outside `~/.hermes/skills`. Keep `-g` unless LiveKit (PromptScript rejects global-only — see `references/livekit-npx-install.md`).

Before `--skill <name>`, confirm `<name>` appears in `npx skills add <url> --list -y`. A skills.sh skill URL with Installs is not enough. If the CLI prints `No matching skills found for: <name>`: the current pack does not ship it — stop, say not in pack, do not invent a SKILL.md from the catalog blurb unless the user asks for a local copy.

`--list` is the installable set, not the git tree. `npx skills add` skips a `SKILL.md` whose YAML frontmatter fails to parse (compact nested mapping in `description:`) and still prints `Found N skills` without that name. Surface the skip warning in the install report; do not `--skill` the omitted name; do not hand-write a replacement unless the user asks. Install the listed names after the never-overwrite check, then confirm each `~/.hermes/skills/<name>/SKILL.md` has a real body (not a pointer).

Lands as a **copy** under `~/.hermes/skills/<name>/`. That skill is user-owned (npx/URL install): curator agents must not patch it.

## `npx skills use` (Hermes session)

Verified 2026-09-03: user paste `npx skills use "https://github.com/anthropics/skills" --skill "frontend-design"` plus „follow the generated skill instructions“ / supporting-files dir.

1. Run `use` **as pasted**. Do not graft `--copy -g -y` (unknown on `use`). Do not add `--agent hermes-agent` (`Running Hermes Agent is not supported yet`. Supported: claude-code, codex).
2. Redirect stdout to a temp log. Supporting files, when present, land at `$TMPDIR/skills-use-*/<name>/` (this run: SKILL.md + LICENSE.txt). Resolve relative paths from that directory.
3. `use` is ephemeral. Persist with `npx skills add … --agent hermes-agent --copy -g -y` only after `test -e ~/.hermes/skills/<name>` is FREE.
4. CONFLICT includes a symlink `~/.hermes/skills/<name> → ~/.agents/skills/<name>`. Stop; list path; single skill vs category; do not `-y`. Re-run is a no-op, not a refresh.
5. A skills.sh page `https://www.skills.sh/<owner>/skills/<name>` (with or without „installiere“) = named `--skill <name>` from that pack.

## Codex global vs `skills use`

User: „für Codex global“ / named agent is Codex → do **not** add `--agent hermes-agent`.

```bash
npx skills add https://github.com/<owner>/<repo> --skill <name> --agent codex -g -y --copy
```

- `npx skills use <url> --skill <name>` is **not** install. It prints a SKILL.md prompt (redirect to a temp file). There may be **no** supporting-files directory — then skip relative-path resolution.
- The CLI still prints `hermes-agent  Agent detected — installing non-interactively` when Hermes is the running agent. That banner is not the install target. `--agent codex` is.
- Canonical Codex dest (`npx skills ls -g -a Codex --json`): `~/.agents/skills/<name>`.
- Summary text `copy → Codex` / `overwrites: Codex` does **not** mean `~/.codex/skills/<name>` was written. Verified 2026-09-03 `vercel-labs/skills` `find-skills`: `.agents` mtime updated; leftover `~/.codex/skills/find-skills` stayed Jul 13.
- After add: check mtime of **both** paths. Report leftover `.codex` copies; do not delete unless asked.
- Hermes never-overwrite still applies to `~/.hermes/skills/<name>`. Same-name refresh under `.agents` for an explicit Codex install is not a Hermes class-folder clobber.

## Stub front doors

Some packs split user-invoked wrappers from model-invoked primitives. Verified: `mattpocock/skills` `grill-me` SKILL.md is one line (`Call the Skill tool with grilling`) plus `disable-model-invocation: true`. The interview loop lives in skill `grilling`. `--skill grill-me` does not install `grilling`. Upstream docs: "I installed grill-me on its own and nothing happens."

After any selective install:

1. Read the on-disk SKILL.md (not the pack README / skills.sh blurb).
2. If the body only names another skill, install that primitive too, or say the capability is inert.
3. Hermes has no Claude-style `/skill-name` slash commands. `disable-model-invocation` means the agent will not auto-load the wrapper.

Do not claim advertised pack behavior until the primitive is on disk.

`disable-model-invocation: true` plus a line `Call the Skill tool with "…"` is **not** enough to call the file a stub. Verified 2026-09-03: mattpocock `improve-codebase-architecture` is 71 lines + `HTML-REPORT.md` (scan → HTML report → grill). Dest already at `~/.hermes/skills/…` → `~/.agents/skills/…` — stop, no `-y`. The body still *calls* `codebase-design` and `grilling`; without those primitives the later steps are incomplete, but the front skill is not inert.

## Plugin-dir stubs vs nested canonical skill (`--full-depth`)

User paste is often a GitHub *tree* URL: `https://github.com/<owner>/<repo>/tree/main/plugins/hermes`.
That folder can be a 5-line SKILL.md (`name: recruiting-crm` + `Canonical skill: ../../skills/recruiting-crm` + `cp -R …`). The real skill lives at `skills/<name>/` with `references/`.

`npx skills add` stops descending when it hits a SKILL.md. Without `--full-depth` it can copy the stub and drop the references.

```bash
npx skills add https://github.com/<owner>/<repo> --list --full-depth
# stub description is one short line; canonical description is the long trigger block
test -e ~/.hermes/skills/<name> && echo CONFLICT   # stop if set
npx skills add https://github.com/<owner>/<repo> --skill <name> --agent hermes-agent --copy -g -y --full-depth
# verify: SKILL.md is not a pointer; references/ is present; skill_view(name) unique
```

Do not `cp` only `plugins/hermes`. Do not `hermes skills install` the stub SKILL.md URL.

Verified: `dsactivi-2/recruiting-crm-mcp` → `~/.hermes/skills/recruiting-crm` (user-owned; do not curator-patch).

## Never overwrite (user rule)

Before `npx skills add`, for every name that would land:

```bash
test -e ~/.hermes/skills/<name> && echo CONFLICT
```

If any dest exists: **stop**. List path, whether it is a category (has child SKILL.md dirs) vs a single skill, and wait. Do not pass `-y` over a conflict. Re-running a pack the user already installed is a no-op, not a refresh.

`--skill '*'` is the high-risk form. Prefer named `--skill a b c` after the conflict check.

## Category vs single-skill name collision

Hermes uses `~/.hermes/skills/research/` as a **class folder** (DESCRIPTION.md + children). A pack skill named `research` occupies that same path. npx `--copy` replaces the directory.

Safe restore (verified 2026-08-28, backup `~/.hermes/backups/pre-update-2026-08-28-151638.zip`):

1. `test ! -e ~/.hermes/skills/pocock-research`
2. `mv ~/.hermes/skills/research ~/.hermes/skills/pocock-research`
3. `unzip -n <backup.zip> 'skills/research/*' -d ~/.hermes` — **only** that prefix, never the whole Hermes home zip
4. Rename Pocock frontmatter `name: research` → `name: pocock-research` (else `skill_view` Ambiguous)

wayfinder’s “Call the Skill tool with research” then misses both until the agent loads `pocock-research` for fact tickets and child names (`arxiv`, …) for the Hermes library.

## vercel/workflow vs class folder `skills/workflow/`

Verified 2026-09-02. User: „installiere“ `https://workflow-sdk.dev/docs/foundations/starting-workflows`.

- Pack: `npx skills add vercel/workflow --list` → `workflow`, `workflow-init`, three `migrating-*`, `internal-dev-workbench`.
- `~/.hermes/skills/workflow/` is a **class folder** (`verify-first-workflow/`). `--skill workflow` (or `--skill '*'`) would replace it. Stop; do not `-y`.
- Canonical WDK skill already: `~/.hermes/skills/vercel/workflow` → vercel-plugin. Do not install a second `workflow`.
- `skill_view(name='workflow')` is Ambiguous: plugin `SKILL.md` **and** `upstream/SKILL.md` both `name: workflow`. Load `vercel/workflow`.
- Free dests that session (install only if asked): `workflow-init`, `migrating-to-workflow-sdk`, `migrating-workflow-v4-to-v5`, `migrating-world-v4-to-v5`, `internal-dev-workbench`.
- Docs-URL ≠ `npm i workflow` in cwd unless the user names a project directory.
- User 2026-09-02 nach `workflow-init`: „npm noch nicht installieren nur den skill für dich.“ Default: Docs-/Skill-URL = Agent-Skill. npm erst nach genanntem App-Ordner mit Framework.
- `workflow-init` liegt unter `~/.hermes/skills/workflow-init` (npx copy, user-owned, nicht curator-patchen). WDK-Doku-Skill bleibt `vercel/workflow` (Plugin).

## Claude-only pack skills on Hermes

`git-guardrails-claude-code` → Hermes `hooks.pre_tool_call` + `matcher: terminal` (exit 2 blocks; merge, do not replace Hivemind hooks). Do not write `.claude/settings.json`.
`claude-handoff` → `terminal(..., background=true)` + `hermes chat -q`, not `claude --bg`, not `delegate_task`.
