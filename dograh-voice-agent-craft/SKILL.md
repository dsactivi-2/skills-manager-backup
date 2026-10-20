---
name: dograh-voice-agent-craft
description: "Use for Dograh voice prompts, pacing, opening, human talk."
version: 1.0.0
license: MIT
metadata:
  hermes:
    tags: [dograh, voice, prompts, telesales, opening, pacing, ulaw, guide]
    related_skills:
      - dograh-dual-instance
      - barbarez-three-lanes
      - dograh-mcp-workflow-ops
      - bosnian-voice-prompts
      - german-voice-prompts
      - langfuse-voice-call-quality-optimization
---

# Dograh voice agent craft

## When
- Building or fixing Dograh workflow prompts/nodes (startCall, globalNode, sales nodes)
- Agent sounds robotic, hard-sells in first 10s, ignores emotion, or opening fails
- Questions about prompt style vs model strength, codecs/ARI media, dual instance routing
- Barbarez / BS voiceeu telesales work

## User preferences (Activi)
- Default product work: **Self-Host voiceeu** unless user says Cloud
- Prefer **live MCP evidence** over handoff IDs (handoff may be Cloud-era)
- German user chat; BS/DE only inside prompt text
- One primary change per freigabe round; no silent publish
- Direct answers, tables OK; avoid LangGraph dual-repo lectures unless asked

## Dograh source of truth (always)
Load via MCP before large prompt edits:
```
get_voice_prompting_guide(stage=plan|create|review)
get_voice_prompting_guide(topic=…)  # one topic at a time — never stage+topic together
```
Core topics: `common_guidelines`, `turn_taking`, `call_flow_design`, `success_criteria`, `instruction_collision`, `tool_calls`, `guardrails`, `end_call_logic`.

### Official craft rules (all models)
1. **Graph owns phases** — nodes/edges; LLM does not invent free “phase” state like LangGraph demos
2. **globalNode** ≈ `common_guidelines` structure (persona, short speech, fillers, objections, honesty)
3. **Node prompts** structured: task → flow (one Q/turn) → success criteria matching edges
4. **turn_taking** — every spoken turn ends with question/nudge
5. **No instruction_collision** global vs node / style vs length
6. Natural phone speech always — structure tight, **language free-natural** (not robot script dump)

### Model strength (verified vs myth)
| Claim | Dograh truth |
|-------|----------------|
| Strong model → freeform one-node agent | **False** as product rule — still use graph |
| Weak model → more nodes + clearer criteria | **Useful practice**, not a second architecture |
| `nodes_strong/` vs `nodes_cheap/` | **Not** Dograh-native; avoid dual prompt repos |
| Spoken `[INTENT:…]` tags | Prefer `extraction_prompt` + edges |

See `references/prompt-model-strength.md`.

## Sales pacing (critical)
**Forbidden in first ~10–30s / startCall:** order, COD/pouzeće push, “want to buy?”, “any questions?” as pitch dump.

Correct order:
```
greeting (identity only)
→ open: who/why + time permission
→ discovery (need)
→ pitch (1–2 benefits mapped)
→ close/order (COD, address, readback)
```
Graph: **no** edge open → order. Details: `references/sales-pacing.md`.

## Human conversation
Mirror emotion in ≤1 clause → one agenda step → one question.  
Ban catalog closes and ignore-emotion scripts.  
Details: `references/human-conversation.md`.

## Opening / startCall mechanics
| Field | Role |
|-------|------|
| `greeting` | Short identity TTS **before** LLM |
| startCall `prompt` | Reason + permission only after greeting |
| `delayed_start` | 1–2s typical |
| `allow_interrupt` on open | Often **false** so intro finishes (docs interruption) |

Details: `references/opening-startcall.md`.

## Dual instance + media
| Instance | MCP | Notes |
|----------|-----|--------|
| Self-host voiceeu | `dograh-voiceeu` | `X-API-Key`; default for Activi builder |
| Cloud | `dograh` | Separate IDs; may be disabled in barbares |

ARI external media codec: **G.711 μ-law (`ulaw`) only** (Dograh docs). PBX trunk must allow ulaw; Opus/G.729/GSM are not Dograh-WS media.  
Full dual/ARI: skill `dograh-dual-instance` + `references/ari-ulaw-codec.md`.

## Workflow (builder)
1. Confirm instance + live `list_workflows` (never trust stale handoff IDs alone)
2. `get_workflow` target ID
3. Load guide topics for the edit
4. Diagnose (quote bad lines / illegal edges)
5. One freigabe-sized fix (open / global pacing / human block / edges)
6. Draft save → verify → user publishes

## Pitfalls
- Mixing Cloud #8783 with voiceeu #3–10 IDs
- “pozovi alat X” when only **edges** exist
- Hard-sell success criteria on startCall
- Instruction collision: deep empathy + max 10 words
- Fixing robotic talk by only changing TTS/codec
- Assuming a-law/Opus replaces ulaw on ARI path
- MCP: pass **either** `stage` **or** `topic` to `get_voice_prompting_guide`, not both

## Narrow skills (prefer this umbrella first)
Session-era siblings still useful for deep dives: `dograh-voice-opening-greeting`, `dograh-human-conversation`, `dograh-telesales-pacing`, `bosnian-voice-prompts`. Prefer loading **this** class skill first; use siblings only if needed.

## References
- `references/prompt-model-strength.md`
- `references/sales-pacing.md`
- `references/human-conversation.md`
- `references/opening-startcall.md`
- `references/ari-ulaw-codec.md`
- `references/mcp-guide-usage.md`
