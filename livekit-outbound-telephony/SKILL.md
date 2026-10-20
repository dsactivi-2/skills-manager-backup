---
name: livekit-outbound-telephony
description: "Use when LiveKit outbound SIP/GSM voice work."
---

# LiveKit outbound telephony

Bosnian/EU telesales on LiveKit Cloud + FreePBX/Yeastar. APIs from MCP/`lk`, never memory.

## Orchestrator

**Hermes main (`default`) is Orchestrator + Planner — not the user.**  
User only: Freigabe, keys, deploy-yes, Identify. Do not rebuild `default`.

## Team (keep names; one list)

Architekt · Planner · Research/Verify · Code (= Prompt+Test+Implement) · Karte/Docs · Review · dev-op.  
MCP/Skill/Plugin = second lane, not wave 1.  
Do not spawn a 10-agent cluster for one sequential repo. Sweet spot: main + 1–2 hot workers.

## Outbound answer (hard)

- SIP participant can exist **while ringing**. `wait_for_participant` ≠ answered.
- Script: `lk sip participant create --wait` **then** `lk dispatch create`.
- Docs: `sip.callStatus=active`; outbound let callee speak first; ~2.5s silence → one opener.
- **Never** `asyncio.sleep` in `on_enter` as “wait for pickup”.

## TurnDetector

Works without `bs` in the 14-language list (unmapped = default). Not “broken”.  
Override: **one scalar** `unlikely_threshold` (e.g. 0.55) + Env. Not `{"bs": …}` on a bs-only agent. Not a new model. Higher = more patient.

## Sales (user SoT)

Sentence 1: who + product (Bokal/Wasser). Soft no ≠ hangup. Listen to last utterance. NSF/price only if on the fact card.

## Paper vs live

Langfuse OTLP code + local keys ≠ Cloud `--secrets-file` verified.  
Agent `CA_J8AZ7K6yJ5o3` **is** eu-central; document that so the next create is not us-east.

## Plan SoT

`/Users/activi/Code/Projects/LiveKit/.hermes/plans/2026-08-24_101325-amina-v2-komplett.md`  
`BOTLISTE.md` · `docs/SESSION-PROMPT-ARBEITSTEAM.md`

## References

- `references/turn-threshold-and-sip-wait.md`
