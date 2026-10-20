---
name: livekit-bih-outbound
description: "Use when LiveKit BiH outbound GSM sales or SIP fails."
version: 1.0.0
author: Activi
license: MIT
metadata:
  hermes:
    tags: [livekit, bosnian, outbound, sip, telesales]
    related_skills:
      - livekit-voice-build
      - bosnian-livekit-template-v1
---

# LiveKit BiH outbound (GSM)

## When to Use

Amina / Firmira / Aquaphor Smile on LiveKit Cloud + FreePBX + Yeastar.
Not Dograh graphs.

## Sales (user-corrected 2026-08)

- Sentence 1: who + **bokal/water**. Do not hide the product.
- Soft *ne / nemam vremena / razmislim* = stay, LAER. Not goodbye.
- Hang up only: DNC, *ne zovi*, third hard no.
- Answer the **callee’s last utterance**, not the next checklist item.
- `pouzeće` is not the first CTA.

## Outbound timing

Do **not** `asyncio.sleep` in `on_enter` (job starts while ringing).
`wait_until_answered` + `wait_for_participant`, then greet.

Turns: `adaptive` interrupt, `min_duration=0.5`. `TurnDetector` has no `bs` — keep, raise `min_delay`.
Soniox `[pause]` ≠ LiveKit endpointing.

## SIP

300 = TG400. 330 = LiveKit auth. 310 = Guarddograh.
Yeastar password = ext Kennwort. 401 = Identify LiveKit IPs on 330.

## Product

One markdown fact card, not RAG. Do not invent NSF.

## Overlap

`livekit-voice-build` is the general brief skill. This one owns outbound GSM + Amina sales rules.
