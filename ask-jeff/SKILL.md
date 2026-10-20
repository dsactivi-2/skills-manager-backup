---
name: ask-jeff
description: "Use when Jeff/TypeSafe should judge ratings or audits."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [typesafe, jev, routing, skills, audit, evaluation]
---

# Ask Jeff (TypeSafe System One)

Jeff = the `jev` model behind the TypeSafe System One API (`https://api.typesafe.ai/v1/systemone`). Two uses: (a) automatic skill routing via the `typesafe-skill-router` Hermes plugin (`pre_llm_call` hook, names the one fitting skill on the user message), and (b) ad-hoc batch judgments — ratings, duplicate detection, keep/drop decisions over the skill roster or any option set.

## Setup check (live-verify before use)

1. Plugin enabled: `hermes plugins list --plain --no-bundled | grep typesafe` → `enabled`.
2. Key present: `TYPESAFE_API_KEY=apikey_...` in `~/.hermes/.env` (create at https://console.typesafe.ai/settings/keys).
3. Probe — proves key, endpoint, and model in one cheap call (the API has no GET endpoint):
   POST `/v1/systemone`, `Authorization: Bearer <key>`, body `{"state":{"request":"test"},"model":"jev-latest","questions":{"probe":{"type":"noul","instructions":"Is this a probe request?"}}}` → expect `{"model":"jev-x.y.z","answers":...}`.

## Import pattern (any Python session)

The plugin ships a stdlib-only reusable package — import it instead of hand-rolling HTTP:

```python
import sys
sys.path.insert(0, str(Path.home() / ".hermes/plugins/typesafe-skill-router"))
import typesafe_router as tsr
from typesafe_router.primitives import noul, choice, score

client = tsr.SystemOneClient()  # loads ~/.hermes/.env itself; empty .api_key = key missing
```

## Primitives and answer parsing

| Question | Builder | Answer field | Meaning |
|---|---|---|---|
| Yes/No | `noul(instructions)` | `a.noul` | P(yes), float 0..1 |
| Pick one | `choice(instructions, {name: desc})` | `a.choice` | chosen option name |
| Ordered levels | `score(instructions, [levels])` | `a.score` + `a.legend` | float 0..1 across levels |

Pitfalls:
- score answers have NO `.choice`. Map levels yourself: `idx = min(len(levels)-1, round(a.score * (len(levels)-1)))`, then `a.legend[str(idx)]`. Reading `.choice` on a score answer raises.
- A Choice question accepts at most 255 options (API rejects more). Chunk rosters at 240 and add a `none_of_these` option per chunk.
- Batch many questions into ONE `client.ask(state, questions)` call (~20 questions per call) — one API call per chunk, never one call per item. A full 228-skill audit ≈ 30 calls, a few seconds each.
- `state` is free-form JSON both request and context go into: `{"request": ..., "recent_context": ...}`.
- A malformed payload returns `{"detail":{"error_type":"api_usage_error","message":"Invalid request."}}` — check the state/questions shape, not the key.
- Jeff has no browser and no portal access. Put every fact in `state` (full ad, alias list, live search URLs, hit counts, phone). Do not ask whether a company is listed on a site if that evidence is missing — he will guess.
- After evidence is in state: `noul` for yes/no, `score` for buy-likelihood. Never send Jeff out to "check Indeed/StepStone".

## Skill-portfolio audit

Working code for the full recipe: `references/skill-portfolio-audit.md`. Shape:

1. Load the live roster with `tsr.load_roster()` (reads `~/.hermes/skills/**/SKILL.md`, dedupes by name, sorts by category+name) and merge telemetry from `~/.hermes/skills/.usage.json` (use_count, last_used_at) into the question text — judgments get much better with real usage data attached.
2. Pass 1 — duplicates: per category (≥3 skills), one Choice "which skill is redundant?" + `none_of_these`.
3. Pass 2 — overlap %: per duplicate candidate, one Noul per category peer ("does X cover Y's job?"); report top overlaps as percentages.
4. Pass 3 — need rating: one Score (rarely/sometimes/often/critical) per skill, chunks of ~20.
5. Pass 4 — keep/drop: one Noul per rarely-rated skill, telemetry in context.

## Lead-Scoring (Stellenanzeigen / Zweitportal)

Hermes-only. Jeff does not run as a plugin in Kimi/Codex/Alter; those harnesses get judgments only if this session calls System One with a full `state`.

Required `state` before any noul/score:
- full job ad text, source portal, URL, posted_at
- company legal name + alias list
- phone (hard fail if missing — do not ask Jeff to invent one)
- email if present
- per target portal: search URLs, aliases used, hit count, matched URLs, status DA | NICHT_DA | UNKLAR

Questions:
- noul: `ready_for_voice` — phone present AND target portal NICHT_DA with evidence (not UNKLAR)
- noul: `same_employer` — only if hit URLs and aliases are in state
- score: `buy_second_portal` levels drop / weak / call / strong — only after ready_for_voice

If evidence fields are empty, skip Jeff. Do not ask “is this company on StepStone/Indeed”.

Portal ranking: do not send Jeff a blog top-10 and ask which board is biggest. Cheap path: reuse public lists, then a small overlap sample (same ads on the top 3–4 boards). Jeff scores only those sample rows.

## Reporting and action rules

- Report in German; overlap results as a table sorted by %; state P-values so the user can re-sort.
- Never delete skills. Recommend archiving (`hermes curator archive` / curator run) and ask the user before executing any archive.

## Related lookups

- A name missing from `hermes plugins search` may be a hub SKILL, not a plugin — check `hermes skills search <term>` and `hermes skills inspect "<full name>"` before concluding it does not exist. Bundled plugins (e.g. `web-keenable`) need no install, only `hermes plugins enable <name>`.
