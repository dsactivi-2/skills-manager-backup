---
name: hermes-profile-soul-agents
description: "Use when authoring Hermes SOUL.md and AGENTS.md files."
version: 1.2.3
metadata:
  hermes:
    tags: [hermes, profiles, soul, agents-md, persona, handoff]
---

# Hermes Profile SOUL + AGENTS Authoring

Create or revise **SOUL.md** (profile identity) and **AGENTS.md** (repo/ops behavior) for a Hermes profile or its active project. User expects high-quality specialized SOULs and never wants blind overwrite of a live profile.

## When to use
- "schreib SOUL / AGENTS für Profil X"
- "erstelle ein Hermes-Profil namens X" (CLI create + SOUL, not draft-only)
- "passe Soul auf das Projekt an"
- New specialized profile or agent role (e.g. Dograh builder, DevOps worker)
- Handoff shows weak generic SOUL (default Hermes one-liner) while project has rich rules
- Review/upgrade of an existing specialized SOUL (Output-Contract, Anti-Patterns, …)

## Non-negotiable user preferences
1. **Draft first, apply never without explicit Freigabe.** Write drafts outside the live profile path; show paths; wait for OK. Only after "ja"/Freigabe: copy to live targets + backups.
   - **Counts as Freigabe** (still backup + draft audit copy): „richte ein“, „setze um“, „installiere für Profil X“, „erstelle und richte SOUL/Skills/MCP ein“, „erstelle ein Profil namens X“ / „erstelle eine hermes profil namens X“.
   - **Not Freigabe alone:** „was schlägst du vor“, „erkläre“, pure design talk.
   - **Scoped Ja:** „Ja, mach das“ applies only to the last concrete offer. If you gated `hermes profile create` as a later step, drafts/tar-copy are not create. Wait for an explicit create/apply phrase.
2. **German, direct, knapp** in both files and in your reply. Multi-concept: short tables + simple metaphors first (MCP = Fernbedienung); no YAML walls until asked.
   First package for a **new specialized profile** is not two stubs: SOUL (all required sections, load-trigger table, Model if the user named one) + AGENTS ops + `PROFILE_SPEC` + handoff quartet (`SESSION_RESUME`, `HANDOFF`, `NEXT_ACTIONS`, `INDEX`). Depth lives in those disclosed files so AGENTS stays ≤120 lines. Copy the review set to `~/Downloads/<project>-md-*` when the user will read before Freigabe.
3. **SOUL structure (required):** Identity · Expertise · Skills (sharp) · Style · Output-Contract · Mission · Behavior Rules · Anti-Patterns · Out of Scope · Changelog (optional but preferred).
4. **Tool-first / live-verify** must be explicit in Behavior Rules when the profile does real systems work.
5. **AGENTS.md is behavioral ops**, not README/changelog. Prefer ≤100–120 lines (Sentry agents-md guidance).
6. **No numeric workflow/run IDs in SOUL** — ever. Builders rotate many IDs/day; IDs live in Handoff + Live-MCP resolve rules.

## Placement (after approval only)
| File | Target |
|------|--------|
| SOUL.md | `~/.hermes/profiles/<profile>/SOUL.md` |
| AGENTS.md | **Project root** `…/AGENTS.md` (injected when workdir = project). Sync `handoff_*/AGENTS.md`. |

Draft dir pattern:
`<project>/handoff_<date>/drafts-<profile>-profile/{SOUL.draft.md,AGENTS.draft.md,README.md}`

Do **not** write draft files named `SOUL.md` or `AGENTS.md` under the project: the instruction-file guard blocks those basenames outside the live profile (timeout ≠ consent). Use `SOUL.draft.md` / `AGENTS.draft.md`. Project-root `AGENTS.md` is a separate write (session bootstrap may already have created it).

Apply with backup:
```bash
TS=$(date +%Y%m%d_%H%M%S)
cp -p ~/.hermes/profiles/<profile>/SOUL.md ~/.hermes/profiles/<profile>/SOUL.md.bak.$TS
cp <draft>/SOUL.draft.md ~/.hermes/profiles/<profile>/SOUL.md
cp <draft>/AGENTS.draft.md <project-root>/AGENTS.md
cp <draft>/AGENTS.draft.md <project>/handoff_*/AGENTS.md   # optional sync
```
Takes effect **next session** (frozen system prompt).

## Workflow
1. **Load this skill first** for Hermes SOUL/AGENTS work. Optionally load `find-skills` for hub structure — **do not substitute hub soul skills for this skill**.
2. **Resolve profile name** — list `~/.hermes/profiles/`; fix typos (`barbarez` → `barbares`). Display name in SOUL header may differ from folder (`# SOUL: Barbarez` / Profil: `barbares`). See `hermes-profile-capability-audit`.
   - **New profile from a display name:** CLI folder is lowercase + hyphens (`Hermes WWT` → `hermes-wwt`). `hermes profile create <folder> --description "…"` — **no `--clone` / `--clone-from`** unless the user asked to copy. Do not clone the old 13 named profiles.
   - After create: stock SOUL is the Hermes one-liner — backup then replace wholesale. Folder wrapper lands at `~/.local/bin/<folder>`. If the user starts the agent by **display name** (different case/spelling than the folder), add a second wrapper `~/.local/bin/<Display>` → `hermes -p <folder>`; do not `profile use` the worker. Parallel with default = multiplexed default gateway, not a second LaunchAgent. See `hermes-profile-capability-audit`.
   - Fresh `.env` is often empty (comments only). Report it. Do **not** silently copy `~/.hermes/.env`.
   - No project repo yet: thin `AGENTS.md` in `~/.hermes/profiles/<folder>/AGENTS.md` is OK; project-root AGENTS waits until a workdir exists.
   - Do not invent the domain from Safari tab titles. Only facts live-verified for that org.
3. **Find active project** — do not guess from chat alone:
   - `profiles/<name>/memories/MEMORY.md`
   - `profiles/<name>/logs/agent.log` → last meaningful `cwd=` under a real repo (ignore bare `$HOME` / profile dir noise)
   - Project `handoff_*/` full set + any library copies (e.g. "Barabres Dogarh Builder")
   - `session_search(profile=<name>)`
4. **Deep-read the project before drafting** — user correction: shallow skim is failure.
   - Inventory all non-git files; read **every** markdown/txt handoff/doc/prompt
   - Aggregate sims/scripts; note multi-track layouts (e.g. root locale A + `de/` locale B)
   - Do not freeze one language/workflow track into the SOUL
5. **Read current SOUL** — stock Hermes one-liner → replace wholesale (as draft).
6. **Ecosystem search (structure only)** — `find-skills` / `npx skills find`; verify domain fit via skills.sh page. See `references/creator-skills.md`. Prefer install **domain** skills (e.g. dograh-hq) into the target profile; rarely install hub "soul-*" creators.
7. **Author SOUL** — role/outcome mission; Skills section with **load triggers**, not "if relevant"; Output-Contract; MCP/Handoff failure rule; Anti-Patterns; no IDs.
8. **Author AGENTS** — SoT as **patterns**; IDs only via "read handoff + live MCP"; dual-track tables if needed; approval matrix; change loop; sim command with placeholder ID not hardcode-as-identity.
9. **Ship draft only** + README (sources, skill installs, apply cmds). **Prove non-apply** (hash/size vs live). For a new role: include PROFILE_SPEC + handoff quartet; do not stop at thin SOUL/AGENTS.
10. **On Freigabe** — backup + apply + verify no IDs leaked into SOUL (`rg` scan). Confirm the Ja scoped create, not only drafts.

## SOUL quality bar (review target ~9.5+)
- Header: display name (`# SOUL: Barbarez`) + `Profil: <folder>` + Version/Changelog
- Identity/role specific (not stock Hermes)
- Expertise = reusable craft, not one session's diary
- **Skills section sharp:** "Lade aktiv wenn User Thema X berührt" + concrete skill names
- **Output-Contract** for analysis/change proposals (see `references/output-contract.md`)
- Mission = role/outcome; **zero** numeric workflow IDs
- Behavior: tool-first, live-resolve workflow, MCP-first, non-destructive, Freigabe, sim-before-call, verify-before-claim, latency + spoken-language guards, session-start handoff chain
- **MCP/Handoff failure:** say what is missing, wait — never invent stand
- **Anti-Patterns** block (never invent IDs/prompts; multi-change rounds; fake live claims; secrets; hot-path extras without warning)
- Out of Scope + handoff to sibling agents when scoped

## AGENTS quality bar
- Behavioral ops for the **project**; progressive disclosure → HANDOFF for session diary/open P-items
- SoT as patterns (published live vs local working copy vs protected original)
- Multi-track repos: table root vs locale folders; "don't mix"
- Current IDs: dated pointers or **lookup-only** ("INDEX + get_workflow") — never SOUL
- Approval matrix; reproducible verify/sim with env placeholders
- No secrets; ≤100–120 lines preferred

## Pitfalls
- Drafting SOUL/AGENTS after skimming one HANDOFF page (user: "du hast das Projekt nicht genau analysiert")
- Workflow IDs baked into SOUL (wrong language track; stale after next `create_workflow`)
- Applying before Freigabe
- Naming project drafts `SOUL.md`/`AGENTS.md` — guard blocks the write; use `*.draft.md` then copy on Freigabe
- Encoding a profile model as grok/default when the user named another (e.g. Qwen3-Coder-Next): put a **Model** section in SOUL; live-check `ollama list` / provider config — do not invent the tag is installed
- Local `*.ts` as prod SoT when published workflow is SoT
- Installing domain-mismatched hub "soul" skills — **higgsfield-soul-id = video face identity**, not agent SOUL (link OK to report; do not install for persona work)
- **find-skills hub agents-md / soul-***: structure only; Hermes persona → **this skill**, not Sentry/GitHub create-agentsmd or social Soul packs. `npx skills find` on agents.md/docs is popularity noise (Lark/Azure/browser); do not install those for MD quality — use this skill + `writing-for-agents`.
- Dograh builders: default MCP instance (e.g. voiceeu) + optional 3-lane ops (infra/workflow/prompt) in SOUL Skills/Behavior — companions `barbarez-three-lanes` / `dograh-dual-instance` (user-owned → adopt to patch)
- Upstream monorepo `AGENTS.md` trees (e.g. dograh-hq 8 files) = **coding-agent docs**, not 8 deployable agents
- Long HANDOFF chronology stuffed into AGENTS.md
- Skills only under `default` while worker profile skill_view empty — absolute paths + symlink domain skills into profile
- Profile `.env` missing self-host MCP key while default has it — copy when wiring dual Dograh
- Treating multi-locale monorepo as one frozen language
- Soft "skills laden wenn relevant" without load triggers
- Narrative replies instead of Output-Contract on change proposals
- Header `# SOUL: barbares` (folder) vs identity **Barbarez** — prefer display name in H1, folder as Profil line
- `--clone` on a new named profile because “so it has keys” — empty `.env` is expected; user runs `<alias> setup` or copies keys explicitly
- Leaving the stock one-liner SOUL after `hermes profile create` — „erstelle ein Profil“ includes a real SOUL
- One default AGENTS.md copied to Hermes, Kimi, Codex, and Alter — each harness loads differently (Hermes `~/.hermes/AGENTS.md` + plugins; Codex skills dirs, no `hooks.json` splice; Kimi `kimi.plugin.json` skill array; Alter Skills folder, no `pre_llm_call`). Write three distinct files. „Keine Default-Datei“ means not one text for all, not „skip AGENTS.md“.

## Related skills
- `hermes-profile-capability-audit` — inventory + project-path discovery
- `find-skills` — hub search; always verify domain fit
- `hermes-skills` — hub install needs explicit user OK; domain installs OK when user asked to install sensible skills for the job
- `cluster-orchestrator` — multi-profile cluster
- `direct-instructions` — command-only delivery tone

## Support files
- `references/creator-skills.md` — skills.sh queries + vetted creators + mismatch list
- `references/output-contract.md` — standard 6-block change-proposal format
- `references/german-number-nuance.md` — DE Zahlwort vs Zifferngruppen
- `references/barbares-aquaphor-example.md` — worked Dograh builder example paths
- `references/builder-start-and-freigabe.md` — Freigabe phrases, scoped Ja, review pack before create
- `templates/SOUL.md` — v1.1+ scaffold
- `templates/AGENTS.md` — pattern-based ops scaffold
