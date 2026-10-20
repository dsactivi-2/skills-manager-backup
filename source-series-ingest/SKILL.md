---
name: source-series-ingest
description: "Use when ingesting a numbered video/course series."
version: 1.0.0
---

# Source series ingest

Use when the user wants a multi-episode course, playlist, or numbered doc series turned into project knowledge (playbooks, WISSEN sheets, a builder). Not for a one-off single-video summary unless they then ask to ingest it.

## User preferences (this workspace)

- German, tables, simple words. If they say they did not understand: explain again simpler. No jargon stack.
- Clarify pickers for choices. If the form times out mid-fill: **re-offer the same form**. Do not switch to a chat list while they were answering.
- Separate **learned** (what the source said) from **built** (what exists in the repo / on disk).
- Long work: SPEC / STATE / HANDOFF / DECISIONS are source of truth, not the chat.
- **No skipping episodes.** Finish the current module before starting the next.

## Sequential rule

1. Transcribe (or confirm transcript exists).
2. Write `sources/<series>/mXX/WISSEN.md` covering every section of that episode.
3. Mark facts that are **stale** (old version numbers, “11 episodes”, OS claims later contradicted).
4. Add a playbook only for what this module is allowed to drive.
5. Set catalog `status: ingested`.
6. Only then start module N+1.

Jumping to “the episodes that match the end goal” (e.g. 4/9/10 while 1 is unfinished) is a correction: do not do that unless the user explicitly asks to skip.

## Catalog, do not copy blobs

Keep a `catalog.yaml` in the project with youtube URL, local transcript path, topics, status (`missing` | `transcribed` | `ingested`).

Leave full transcripts in the user’s existing folder. Do not duplicate them into the repo.

If a module is `missing`: say so. Do not invent from chat memory.

## Builder wiring

A researcher/writer must cite `catalog.yaml` (module number + path) or write `missing`. Review checklists include that cite.

## Pitfalls

- Treating a transcript folder as “ingested.” Filing ≠ wired into the builder.
- Baking episode-1 snapshots into a chef SOUL as eternal truth.
- Waiting for an unpublished later episode before ingesting what exists.

## Verify

- Catalog status matches files on disk.
- WISSEN covers the episode’s section list.
- Next module in STATE is N+1, not a jump.
