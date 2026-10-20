---
name: voice-low-latency-patterns
description: "Reduce end-to-end latency and eliminate dead air in Dograh (and Patter) voice-agent workflows. Use when a voice agent feels slow, has awkward pauses after the caller stops speaking, sounds robotic from over-long turns, or when tuning STT/LLM/TTS and node/prompt structure for responsiveness. Covers transition_speech to mask LLM think-time, prompt-length budgeting, node granularity, STT endpointing, TTS streaming, model selection order, and how to measure latency from traces."
trigger: "Use when a Dograh/Patter voice agent feels slow, has dead air after the caller speaks, or needs latency tuning across prompt/node/STT/LLM/TTS."
metadata:
  version: 1.0.0
  parity: dograh-patter
---

# Voice agent low-latency patterns (Dograh / Patter)

## When to use
The agent feels slow, there is dead air after the caller stops talking, turns are too long, or you are choosing/tuning STT-LLM-TTS. Perceived latency = STT endpointing + LLM first-token + TTS first-audio + network. Attack them in that order; do NOT reach for a bigger/smaller model first.

## The latency budget (target for natural conversation)
Aim for < ~1.0-1.2 s from caller-stops-speaking to agent-starts-speaking.
Breakdown to instrument:
- STT endpointing (silence-to-final): often the biggest, tunable win.
- LLM time-to-first-token (TTFT): prompt length + model.
- TTS time-to-first-audio: voice/provider + streaming.
- Network/carrier: mostly fixed.
Measure each from Langfuse/Dograh traces before tuning. Never guess which stage is slow.

## Pattern 1 — transition_speech to mask LLM think-time (Dograh)
Dograh edges support `transition_speech`: a short line spoken IMMEDIATELY on edge transition, while the next node's LLM call is still starting. This hides TTFT behind human-plausible filler.
- Use it on edges that lead into a node doing a tool call or a longer reasoning step.
- Keep it short and generic-but-warm: "Einen Moment, ich schau kurz nach." / "Alles klar, dann machen wir das so."
- Do NOT put content the model must decide in transition_speech — it fires unconditionally on that edge.
- Code (SDK): `wf.edge(a, b, { label: "...", condition: "...", transition_speech: "Einen Moment, ich schaue kurz." });`
- Verified live: workflow 8614 uses transition_speech on the start->mid edge.

## Pattern 2 — prompt-length budgeting (biggest LLM-side win)
Long prompts inflate TTFT on every turn and cost more.
- Keep the globalNode persona tight. Move rarely-needed detail out.
- Per-node prompts: one job per node. A node that "qualifies AND handles objections AND closes" has a bloated prompt and slow, unfocused turns.
- Cap agent turn length in the prompt: "Halte jede Antwort auf ein bis zwei Sätze." Short outputs finish TTS faster and let barge-in work.
- Few-shot examples help quality but cost latency — keep the whole few-shot block ~1000 chars, 3 compact dialogues max (per optimizer skill).
- Prune redundant instructions and instruction collisions (they also cause re-reasoning).

## Pattern 3 — node granularity
- Split multi-step tasks into focused nodes; each node's prompt stays small -> faster TTFT.
- But do NOT over-split: every edge transition is a new LLM turn. Balance. A node per single collected variable (name, then phone, then consent) is the sweet spot for data capture.
- Consolidate end-call scenarios into 2-3 endCall nodes, not ten (also a review-stage rule).

## Pattern 4 — STT endpointing (often the #1 dead-air cause)
- Dead air after the caller stops usually = endpoint silence threshold too high. Lower it so the STT finalizes sooner.
- But too low = the agent interrupts / cuts the caller off. Tune against real calls.
- Pin STT to the single call language (de-DE, bs, etc.). Multilingual STT is slower and less accurate for a single-language flow.
- Treat short backchannels/questions/ASR noise as non-rejection, not a full turn (per optimizer skill).

## Pattern 5 — TTS streaming and voice choice
- Use a streaming TTS voice so first audio starts before the full sentence is synthesized.
- Prefer a "turbo"/low-latency voice tier for high-volume outbound if quality is acceptable.
- Match voice locale to language (de-* for German) — wrong-locale voices are both slower and mangle pronunciation.
- If the agent sounds robotic/depressed, fix voice/TTS tuning before enlarging the LLM.

## Pattern 6 — model selection ORDER (do this last, not first)
1. Fix prompt length + flow + instruction collisions.
2. Fix STT endpointing + language pinning.
3. Fix TTS streaming + voice.
4. ONLY THEN consider the LLM. Pin a lightweight, fast model once behavior is good and latency matters. Do not jump to a bigger model to fix behavior that is actually a prompt/flow problem.

## Barge-in (Patter specifics)
- Barge-in on by default (VAD activation ~0.8, deactivation ~0.65). Short agent turns make barge-in feel responsive; long turns make the caller wait to interrupt.
- If callers interrupt at wrong moments, read VAD events from the call log before retuning thresholds.

## Measure-before-tune loop
1. Pull last 3 traces (Langfuse/Dograh). Record STT-final, LLM-TTFT, TTS-first-audio per turn.
2. Identify the dominant stage.
3. Apply the matching pattern above — ONE change.
4. Save as draft via MCP (`mcp__dograh__save_workflow`), verify version increment.
5. Re-run a test call, re-pull traces, confirm the stage improved. Repeat.

## Anti-patterns
- Swapping the LLM first to fix slowness that is actually STT endpointing or a bloated prompt.
- Cramming multiple jobs into one node -> long prompt, slow unfocused turns.
- transition_speech carrying decision-dependent content (it fires unconditionally).
- Multilingual STT for a single-language flow.
- Long multi-sentence agent turns that block barge-in and delay first audio.
- Tuning without reading traces (guessing which stage is slow).
- Over-splitting nodes so every micro-step is a separate LLM round-trip.
