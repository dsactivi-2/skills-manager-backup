# typesafe-skill-router runbook (Jeff skill routing)

Plugin dir: `~/.hermes/plugins/typesafe-skill-router/`. Routes every user request through the TypeSafe API (model `jev-latest`) before the LLM call and injects a single `<skill_relevance>` line naming the one skill worth loading. When a name wins, the same hook also injects that skill's `SKILL.md` in `<skill_loaded>` (cap `autoload_chars`, default 12000; `0` = name only) so the turn does not depend on the agent calling `skill_view`. Silent when nothing fits; every failure path returns None — a routing failure can never break a turn.

## Commands

    hermes typesafe-skill-router status          # switches, thresholds, roster size, key, cache, log
    hermes typesafe-skill-router on | off        # the routing switch (separate from plugins enable)
    hermes typesafe-skill-router check --live    # self-check + one tiny paid probe (~1e-5 USD)
    hermes typesafe-skill-router suggest "text"  # route one request now; shows gate/fits values

## Wiring checklist (all four, in order)

1. `hermes plugins install typesafe-skill-router` + `hermes plugins enable typesafe-skill-router`
2. `TYPESAFE_API_KEY=...` in `~/.hermes/.env` (create at console.typesafe.ai/settings/keys)
3. `hermes typesafe-skill-router on` — the internal switch
4. `hermes gateway restart` — hooks load at process start; settings changes alone do not wire them

## Config surface

`hermes config set plugins.entries.typesafe-skill-router.<key> <value>` — keys: `enabled`, `gate`, `fits`, `shortlist`, `chunk`, `excerpt`, `timeout`, `suggest_chars`, `model`, `base_url`, `roster_dir`, `cache_path`, `log_path`. `allow_tool_override` is granted via `hermes plugins enable <name> --allow-tool-override` (no-op for this hook-only plugin).

## Thresholds

- `gate` (default 0.30): mean of three request-level nouls (acts on the user's system / follows a documented procedure / prose alone suffices — the third inverted). Below it, no suggestion at all. Raising it creates misses.
- `fits` (default 0.40): the winning candidate's own "does this skill do the specific thing" noul. Raising it cuts needless suggestions; at 0.50+ legitimate suggestions start dropping (author's measurement on a 292-skill roster: 88.5% top-1 at 0.30/0.40, needless 8.3%).
- Tune only from logged real turns — the log (`~/.hermes/logs/typesafe-skill-router.log`, one line per decision: suggestion + gate value) plus the session store form the scorecard. Vendor numbers came from a different roster; do not copy them as targets.

## Facts

- Endpoint `https://api.typesafe.ai/v1/systemone`, Bearer auth, ~$0.001 per routed turn, 10 s per-turn budget, skips messages over 4000 chars.
- Roster = `~/.hermes/skills/**/SKILL.md` (same source as the agent's skill index); the router chunks at 240 skills per Choice because the API caps choices at 255.
- The plugin ships a reusable stdlib-only library (`typesafe_router`) — see roster-audit-jeff.md for batch use without Hermes running.

## Coexist with hermes-jev (model routing)

Jeff = skill suggestion only. hermes-jev = model pools, memory/compaction/computer-use tools, optional second skill picker. Leave Jeff `on`. Leave hermes-jev `skills` off. First model mode is `shadow` (log, do not swap). Enable hermes-jev only in the default profile unless asked. Voice/barbares stay off; list them in `routing.json` `private_profiles` so a later enable still sends features-only, not chat text.

Write switches to `~/.hermes/jev/state.json` as strings (`routing: shadow`, `skills: off`, `notice: on`). `hermes config set` boolean `true`/`false` does not satisfy the plugin's `== "on"` check. `jev models suggest --write` is a draft: if `jev doctor` reports dead specialty cells, put a *different* first model in that cell, copied from `jev models list --search`, never invented.
