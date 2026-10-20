# Stadtplan / Gesetze / Hosenzettel

User metaphor (keep in German replies):

- **Stadtplan** = worum geht das Projekt, was ist verboten, wo liegt was
- **Gesetze** = eine Wahl, die lange gelten soll (X statt Y)
- **Hosenzettel** = kurze Fakten über User/Umgebung; überlebt Sessions, gehört nicht ins Repo

## Live mapping (verified 2026-08-22)

| Metaphor | Actual file | Owner |
|---|---|---|
| Stadtplan | `<project>/AGENTS.md` | repo, injected when workdir = project |
| Schichtbuch | `handoff_*/HANDOFF.md` | repo, session diary |
| Gesetze | `docs/decisions/NNNN-slug.md` | repo + git — **convention only** |
| Hosenzettel | `~/.hermes/memories/MEMORY.md`, Honcho, USER.md | Hermes profile, not git |

There is **no** `project-summary.md` system. Do not create one as a parallel landkarte.

Home rule text lives in `/Users/activi/AGENTS.md` and `/Users/activi/Code/Tools/shared/mcp-routing.md`:
- Architecture decisions → first grep `docs/decisions/*.md` in the project
- Cross-session prefs / solved bugs → Hindsight / local session memory
- New project bootstrap: `~/Code/Tools/shared/bin/init-project.sh` (templates + git/postgres MCP + pre-commit). It does **not** seed `docs/decisions/` or any summary file.

## What actually exists

Filled ADR folder: `/Users/activi/Code/AgentPlatform/docs/decisions/` — 15 short Accepted notes (`0001`–`0015`). Format: Status / Decision / Rationale. Topics are a **planned** LangChain/LangGraph/Deep-Agents platform (LangSmith, provider registry, web MVP). Not the live Hermes/Dograh/CRM stack.

Empty or unused:
- `/Users/activi/Code/AgentPlatform/memory/decisions/` — README only
- `/Users/activi/Code/Knowledge/decisions/` — empty
- AgentPlatform has **no git**, so the “git-versioned ADR” benefit is unused there

Live everyday context is already: Skills (how), `AGENTS.md` (ops), HANDOFF (now), MEMORY/Honcho (user/env).

## When ADRs are worth it

Only long-lived repos where a cold agent re-argues an expensive choice. Keep 3–5 notes, one decision each, no IDs that rotate daily.

Good law (example shape, do not invent new policy here):
- Status: Accepted
- Decision: one sentence that will still be true in 6 months
- Rationale: one sentence why the alternative is forbidden

Bad law: “today we tested workflow 10”, provider-of-the-week, anything MEMORY already holds as a user/env fact.

Suggested homes if the user later asks to install (do not create unasked):
- Dograh / voiceeu
- Jobstep CRM

Not: one-off tools, samples, AgentPlatform-style strategy dumps in every repo.

## Pitfall from AgentPlatform

Those ADRs still “Accepted” LangSmith as the observability center. Live voice/QA uses Langfuse (Guard ≠ DograhEU ≠ LocalM5). A law that is not live-verified becomes a lie agents will cite. Prefer no ADR over a stale one.

## Reply style for this topic

German, short table, metaphors first. Do not propose rolling out a new file pair unless the user asks to install laws in a named repo.
