# Skill-roster audit with the TypeSafe API (Jeff)

Class of task: evaluate the live skill roster — duplicates, overlap %, future need, keep/archive — using the `typesafe_router` library shipped with the typesafe-skill-router plugin. Runs without Hermes; ~$0.001 per request.

## Setup

    import sys
    sys.path.insert(0, "~/.hermes/plugins/typesafe-skill-router")  # expand to absolute
    import typesafe_router as tsr
    from typesafe_router.primitives import choice, noul, score
    client = tsr.SystemOneClient()   # reads TYPESAFE_API_KEY from ~/.hermes/.env
    roster = tsr.load_roster()       # Skill: name, category, description, index_description, excerpt, path
    by_name = {s.name: s for s in roster}

Telemetry: `~/.hermes/skills/.usage.json` — per skill `use_count`, `last_used_at`, `state`, `pinned`. Feed it into prompts so ratings reflect real usage.

## Answer parsing (the API's shape — get this right first)

- `choice(...)` → answer `.choice` (picked option) plus the full distribution.
- `noul(...)` → answer `.noul` (probability of yes, 0..1).
- `score(...)` → answer `.score` (float 0..1) and `.legend` ({index: label}). Map to a label via `legend[str(min(n-1, round(score*(n-1))))]` for n levels. Score answers have NO `.choice` attribute.
- Namespace question keys (`"need::<skill>"`) and split on `"::"` to recover the skill name from the response.
- Max 255 options per choice question → chunk rosters at 240; add a `none_of_these` option to duplicate-detection choices.

## Recipe (4 passes)

1. **Duplicate candidates** — per category, one Choice over all its skills (+ none_of_these): "which is redundant given another skill in this same list?"
2. **Overlap %** — per candidate, one Noul per same-category skill: "would loading X make Y mostly unnecessary?" The top probabilities are the overlap percentages.
3. **Need rating** — chunked (~20 skills per request), one Score per skill with telemetry and the agent's real work domains in the prompt; levels rarely/sometimes/often/critical.
4. **Keep/archive** — for the "rarely" set, one Noul per skill: "should this be kept?" Archivable below 0.5.

## Applying results

- Archive = `shutil.move(skill_dir, ~/.hermes/skills/.archive/<dirname>)` — never delete. `skill_dir = Path(skill.path).parent`.
- A roster skill's NAME can differ from its directory name (frontmatter name wins) — resolve paths through the roster; for a name missing from the roster, fall back to `rglob(dirname)` under `~/.hermes/skills`.
- Verify after every batch: reload `tsr.load_roster()` and assert losers are gone and keepers are present.
- The Curator (`hermes curator run`) does time/idle-based maintenance only — it cannot detect semantic duplicates; this audit complements it.
- A concurrent `hermes update` can remove skills mid-session. Before assuming your own move ran, re-scan; restore point is `~/.hermes/backups/pre-update-*.zip` — `unzip <zip> "skills/<category>/<name>/*" -d /tmp/restore`, then copy the directory back and re-verify the roster.
