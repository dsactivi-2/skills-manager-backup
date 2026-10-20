---
name: truthful-application-briefs
description: "Use when compiling bios or Sprachproben from memory."
version: 1.1.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [bewerbung, memory, sprachprobe]
    related_skills: [hermes-memory-providers]
---

# Truthful application briefs

## When to Use

Bewerbung, Lebenslauf-Zusammenfassung, deutsche Sprachprobe, or a brief for another agent to speak. Not for writing skills or AGENTS.md.

Output is labeled evidence, not a polished CV, until the user asks for the spoken text.

## Procedure

1. State the retrieval scope in one line (this profile, Honcho, files). Do not claim chats, Mem0, or other homes you did not query.
2. Run `hermes memory status`. Only the **active** provider holds facts on this home. An installed Mem0/Honcho plugin is not a second store.
3. Gather: `honcho_profile` / `honcho_search`, `session_search` (user messages first), `MEMORY.md` injection, then optional file search. Honcho cards are agent-derived unless the user said the same words.
4. Bucket every claim:
   - User-stated or live-verified (screenshot, their own sentence).
   - Agent inference / KI-generated CV or Bewerbungstext.
   - Missing.
5. If they asked for a brief or raw dump only: stop after buckets. No intro, no advice, no Ich-form CV, no questions. Skip the session project-picker when they forbade questions.
6. Joint work (Hermes/agent sessions): one short line per project — what it was, user vs agent vs staff, planned/started/shipped/tested/prod or unknown, plus a checkable source. Do not expand into a process replay.
7. Attach a source to every claim: Hermes `@session:…` link, repo URL, or absolute path. Do not invent WhatsApp, mail, or chat sources you did not query. If a channel was not searched, say so once under missing.
8. Spoken German sample: 60–120 seconds of speakable prose, only after they ask to produce it (including a short go-ahead after a brief). Omit any bucket that is not user-stated or live-verified. Leave Einwandbehandlung / Kaltakquise out rather than inventing a line. A go-ahead to write the sample does not confirm career claims inside that sample.
9. If they ask for a downloadable document: write the same buckets to `~/Downloads/` as both `.md` and `.txt`. No extra wrapping text.

## Always-on rules

- Role titles (Geschäftsführer, Recruiter) do not imply personal Kaltakquise, Terminierung, or Einwandbehandlung.
- Designing or operating a voice/telesales agent is system work, not the user's own call history.
- Staff/agent names in workflows are not the user's duties.
- Assistant blocks that say they extracted a CV are unverified until the user confirms each line.
- Honcho cards, Honcho conclusions, and MEMORY.md lines about role/employer/market are agent-derived unless the user said the same words.
- A sourcing occupation list is interest in candidates, not trades the user practised.
- Skip private credentials and unrelated PII.
- Label contradictions instead of merging them.

## Pitfalls

- Confirm the active memory provider before citing Mem0 — this Mac home is often Honcho-only; another machine is another home.
- Prefer a short honest sample plus open questions over filling employer-required sections with plausible sales talk.
- Do not load n8n binary/file skills for a local Downloads write — use write_file to `~/Downloads/`.
