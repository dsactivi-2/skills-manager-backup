# Sales-strong Dograh agent (voiceeu) — stack checklist

## Live inventory first (MCP dograh-voiceeu)
1. `list_workflows` — pick working ID (**handoff Cloud IDs may not exist** — see `handoff-id-mismatch.md`)
2. `list_tools` — often **empty** on fresh self-host orgs
3. `list_documents` — often **empty** (KB not uploaded yet)
4. `get_voice_prompting_guide(stage=plan)` then drill topics before drafting

Empty tools/KB is normal — not a blocker for prompt P0, but a lever after dialogue quality.

## P0 if user says “machine conversation”
Voice TTS can be fine while dialogue is robotic (no emotion, “want to buy / any questions?”).
Load **before** hard-sell polish:
- `dograh-human-conversation` (emotion mirror, ban list, turn shape)
- `dograh-voice-opening-greeting` (startCall)
- `bosnian-voice-prompts` if BS (Barbarez default scope)
- `langfuse-voice-call-quality-optimization` (warmth/naturalness)
Do **not** swap TTS first.

## What makes the script sell (order)
1. **globalNode** — goal, guardrails, emotion micro-rules, 2× clear No → end, ban machine phrases; BS numbers: price=words, phone=digits
2. **Opening** — identity greeting + why + tiny permission (not product catalog)
3. **Discovery** — one question per turn; mirror what they said
4. **Offer** — 1–2 benefits **mapped** to discovery + COD if relevant
5. **Objections** — `objection-handling`; one rebuttal + question back
6. **Closing** — `closing`; readback → explicit yes → then tool/end
7. **Hardship/abuse** — end cleanly; do not keep pitching

One content change per sim round when iterating metrics. Skills also: `marketing-psychology`, optimizer-v2, guide topics `tool_calls` / `call_flow_design` / `success_criteria` / `turn_taking` / `guardrails`.

## KB (documents)
Stable facts only: product 3 lines, price logic, delivery, COD, warranty, hard FAQ.
Not long pitch monologues. Wire `document_uuids` on discovery/offer/objection — not every node.

## Tools
One tool one job; explicit trigger; never mix speech + tool in same turn.
Examples: PLZ check, create_order (after yes+readback), callback, end_success.
`create_tool` + `dograh-stepwise-tool-wiring`. Edge labels ≠ fake “call tool X” if graph is edges-only.

## “Memory” on the phone agent
| Kind | Use |
|------|-----|
| Workflow variables | name, PLZ, objection — readback |
| globalNode state rules | already said no? don't re-pitch |
| Hermes MEMORY.md | builder only |
| Langfuse DograhEU | learn from real calls |

## Sim loop
`simulate_dialogues*.py` (BS or DE path matching WF) → optimizer → one draft on **voiceeu** → user publish.
Include rushed/angry/skeptical/short-backchannel/hard-no dialogues when fixing humanness.
