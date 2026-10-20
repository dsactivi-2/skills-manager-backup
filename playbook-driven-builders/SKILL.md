---
name: playbook-driven-builders
description: "Use when building Hermes wizards/MCP/skills with a brain."
version: 1.0.0
metadata:
  hermes:
    tags: [hermes, playbooks, builders, constraints, skills, profiles, mcp, wizards]
---

# Playbook-Driven Builders

Build skills, profiles, meta-agents, MCP wrappers, and review passes as **one engine with several doors** — never as four separate dumb form tools.

## When to use

- User wants a wizard / MCP / skill that builds a Hermes artifact step by step
- "Meta-Agent", Skill-Builder, Agent-Builder, Reviewer, Session-Beobachter
- Options must be asked, contradictions must be caught, nothing goes live without Freigabe
- User says tools must have a brain (not Option 1 yes → Option 2 yes → write file)

## Non-negotiable

1. **One source of truth.** Playbook + answers + signed plan + drafts + review log. MCP, wizard, and chat are only doors.
2. **Brain is the agent, not the MCP.** MCP holds steps, options, `requires` / `conflicts_with` / `implies`. The running Hermes agent thinks and asks via `clarify`.
3. **No one-way trees.** After every answer, run the constraint graph. Conflict → stop, explain, offer an alternative. Never write.
4. **Draft first, live never.** SOUL / AGENTS / SKILL / cron / MCP-config land as drafts. Apply only after Freigabe.
5. **Reviewer vs original brief.** After the first pass, check the draft against the same playbook + user answers, not against the builder's last mood.
6. **Scripts execute, they do not think.** Script 1 = Apply from a signed plan. Script 2 = Diff/Update (patch existing, add new, split when the change would break the old unit).

## Do not start with a meta-agent

A meta-agent with no playbook and no reviewer is an empty boss. Build in this order:

1. Constraint language + **one** playbook
2. Conductor skill (ask, conflict-check, write plan JSON)
3. Reviewer skill (plan + draft vs brief)
4. Script 1 Apply
5. Script 2 Update
6. Thin builder profile that **uses** 2–5
7. Optional MCP shell around the same functions
8. Session cron last (propose only, never auto-apply)
9. Extra videos / docs **feed the catalog** — they do not rebuild the engine

## Knowledge ingest

Do **not** transcribe a whole series before the engine exists. Start with the 1–2 modules that define the first playbook. Remaining transcripts fill `playbooks/`, they do not delay the conductor.

## Session observer (if asked)

Cron with a wake-gate: only analyze a session after it is saved/changed. Deliver proposals into the same queue. Never silent live writes. Full-LLM every session is too expensive.

## Pitfalls

- Four products (MCP + wizard + cron + builder) without a shared plan file → drift and contradictions
- MCP sampling as the brain → hard to debug, still no constraint graph
- Meta-agent first → guesses
- Apply scripts that accept unsigned / unreviewed plans
- Overwriting a live profile (use `hermes-profile-soul-agents` draft/Freigabe rules)
- Treating YouTube/masterclass episode counts as gospel — verify the playlist (this series: announced 11, shipped 10 modules + a Quickstart as the 11th playlist video)

## Support

- `references/engine-and-apply-update.md` — engine surfaces, Script 1/2 contract, Tonbi Masterclass index
- Related: `hermes-profile-soul-agents` (SOUL/AGENTS draft+Freigabe), `native-mcp` (MCP is catalog), `plan` (write plan, do not implement yet)
