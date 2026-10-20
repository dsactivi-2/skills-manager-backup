# Skill-portfolio audit via Jeff (TypeSafe System One)

Full 4-pass recipe. Prerequisites and import pattern: see SKILL.md. All snippets ran as-is against the live API.

## Data sources

```python
import sys, json
from pathlib import Path

sys.path.insert(0, str(Path.home() / ".hermes/plugins/typesafe-skill-router"))
import typesafe_router as tsr
from typesafe_router.primitives import noul, choice, score

roster = tsr.load_roster()                 # live skills dir, respects HERMES_HOME
by_name = {s.name: s for s in roster}
usage = json.loads((Path.home() / ".hermes/skills/.usage.json").read_text())
client = tsr.SystemOneClient()
```

`tsr.stats(roster)` gives counts per category; `tsr.render_index(roster)` the exact index the agent sees.

## Pass 1 — duplicate candidates (per category)

One Choice per category with ≥3 skills; skip smaller ones (nothing to duplicate).

```python
cat = "voice-ai"
skills = [s for s in roster if s.category == cat]
crit = {s.name: s.index_description for s in skills}
crit["none_of_these"] = "Keine dieser Skills überlappen nennenswert."
q = {"dup": choice(
    "Which of these skills, if any, is a near-duplicate or substantial overlap "
    "of another skill in this same list? Pick the one that is REDUNDANT. "
    "Pick none_of_these if all are distinct.", crit)}
state = {"request": f"Duplicate-detection pass over category '{cat}'."}
ans = client.ask(state, q).answers["dup"].choice
```

## Pass 2 — overlap % (per candidate)

For each candidate from pass 1, one Noul per category peer in a single call:

```python
peers = [x for x in roster if x.category == cand.category and x.name != cand.name]
questions = {
    f"ov::{x.name}": noul(
        f"Does the skill '{x.name}' ({x.index_description}) cover substantially "
        f"the same job as '{cand.name}' ({cand.index_description})? Answer yes "
        f"if loading '{x.name}' would make '{cand.name}' mostly unnecessary.")
    for x in peers}
resp = client.ask({"request": f"Overlap analysis for skill '{cand.name}'."}, questions)
scores = {k.split("::")[1]: round(a.noul, 3) for k, a in resp.answers.items()}
top = sorted(scores.items(), key=lambda kv: -kv[1])[:4]   # report as % overlap
```

## Pass 3 — need rating (all skills, chunked)

Chunks of ~20 skills; one Score question per skill, telemetry baked into the question text; describe the agent's actual work domains in `state.request` so ratings are grounded.

```python
LEVELS = ["rarely", "sometimes", "often", "critical"]
CHUNK = 20
ratings = {}
for ci, chunk in enumerate(chunks_of_20):
    questions = {}
    for name in chunk:
        s = by_name[name]
        u = usage.get(name, {})
        ctx = f"use_count={u.get('use_count', 0)}, last_used={u.get('last_used_at') or 'never'}"
        questions[f"need::{name}"] = score(
            f"How likely is this agent to actually need skill '{name}' in the next "
            f"months? {s.index_description} Telemetry says {ctx}. "
            f"Levels: rarely / sometimes / often / critical.", LEVELS)
    state = {"request": "Skill-portfolio audit: rate future need for each skill. "
             "<one sentence on the agent's real work domains>.",
             "recent_context": f"chunk {ci+1}"}
    resp = client.ask(state, questions)
    for k, a in resp.answers.items():
        idx = min(len(LEVELS) - 1, round(a.score * (len(LEVELS) - 1)))
        ratings[k.split("::", 1)[1]] = a.legend[str(idx)]
```

## Pass 4 — keep/drop for rarely-rated skills

Same chunking; one Noul per skill, P(keep) < 0.5 → archive candidate.

```python
questions[f"act::{name}"] = noul(
    f"Should the skill '{name}' ({s.index_description}) be KEPT? Telemetry: {ctx}. "
    "Say no (=delete/archive) if it is redundant, obsolete, or mismatched to this "
    "agent's actual work.")
```

## Output and follow-through

- Write each pass to a JSON file in the workspace (roster_full.json, dup_overlap.json, need_ratings.json, keep_actions.json) so later passes and the final report read from disk, not memory.
- Final report: German, duplicate table sorted by % overlap, need-rating counts, archive candidates with P(keep) values.
- Action is always the user's call: propose `hermes curator archive <name>` (or curator run), never delete, never execute without asking.
