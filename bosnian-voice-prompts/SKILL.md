---
name: bosnian-voice-prompts
description: "Use when writing/reviewing Bosnian (bs-BA) Dograh voice prompts: greeting, nodes, numbers, outbound BiH telesales natural speech."
version: 1.0.0
license: MIT
metadata:
  hermes:
    tags: [bosnian, bs-BA, dograh, voice, telesales, bih]
    related_skills:
      - dograh-voice-opening-greeting
      - german-voice-prompts
      - dograh-workflow-localization
      - barbarez-three-lanes
---

# Bosnian voice prompts (spoken bs for Dograh)

## When
Author/review BS prompts on voiceeu BS workflows (Amina / Aquaphor / marge).  
Not for DE Cloud #8783.

## Spoken ≠ written
TTS reads text. Write phone speech:
- Short clauses, 1–2 sentences/turn
- One question per turn
- Light fillers max 1/turn: pa, hm, evo, dobro, razumijem
- No bureaucratic walls, no EN mix

## Language lock
globalNode must say: **isključivo bosanski**, no DE/EN switch unless policy allows.  
Prefer BiH standard forms (bokal, flaša, samo, hiljada, ijekavica).

## Numbers
| Type | How |
|------|-----|
| Prices | words: trideset devet maraka |
| Phone | digit by digit |
| Qty | words |

## Opening
Defer to skill `dograh-voice-opening-greeting`.  
Greeting = identity only; reason + permission in startCall prompt.

## Cold call honesty
If asked where number from: public imenik / directory — never fake prior consent.

## Structure per node
Main task → flow (numbered, one Q) → objections short → success criteria (edges) → tone.

## Do not
- Machine-translate DE→BS literally  
- Re-introduce name every node  
- Feature dump on open  
- "pozovi alat X" if only graph edges exist — use edge conditions  
