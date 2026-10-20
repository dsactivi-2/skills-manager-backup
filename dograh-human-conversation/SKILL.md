---
name: dograh-human-conversation
description: "Use when Dograh voice agent sounds machine-like: no emotion reaction, robotic buy-ask, flat rapport. Human turns, affect mirror, anti-catalog close."
version: 1.0.0
license: MIT
metadata:
  hermes:
    tags: [dograh, voice, naturalness, emotion, warmth, rapport, telesales, bosnian]
    related_skills:
      - dograh-voice-opening-greeting
      - bosnian-voice-prompts
      - langfuse-voice-call-quality-optimization
      - marketing-psychology
      - closing
      - objection-handling
      - voice-low-latency-patterns
      - german-voice-prompts
---

# Dograh human conversation (emotion + natural talk)

## Problem this skill fixes
Voice TTS is fine, but **dialogue is machine**:
- Ignores irritation, sarcasm, sadness, rush, doubt
- Jumps to „hoćeš kupiti / imaš li pitanja?“ catalog
- No mirror, no micro-empathy, no conversational glue
- Same script beat every turn

## Load together
1. `dograh-voice-opening-greeting` (first 10s)
2. This skill (whole call feel)
3. `langfuse-voice-call-quality-optimization` (warmth/naturalness scores)
4. `bosnian-voice-prompts` or `german-voice-prompts`
5. MCP: `get_voice_prompting_guide` topics **turn_taking**, **call_flow_design**, **common_guidelines** if available

## Core rule
**Acknowledge the human state in ≤1 short clause, then one agenda step + one question.**  
Never skip straight to pitch/close after emotional content.

```
hear emotion → name it lightly → one helpful next step → one question
```

## Emotion → micro-responses (BS outbound examples)
Write as **rules in globalNode**, not long scripts. Vary wording (no repeat last 2 turns).

| Caller vibe | Do (BS sketch) | Don't |
|-------------|----------------|-------|
| Rush / nemam vremena | „Razumijem, kratko ću.“ + 15s offer or callback | Full pitch |
| Irritated | „Neću da smetam — samo jedna stvar.“ | Argue |
| Skeptical | „Pošteno — mogu u jednoj rečenici zašto zovem.“ | Overclaim |
| Confused | „Jasno, sporije: …“ + one fact | Three benefits |
| Warm/curious | Match energy slightly; still one Q | Dump catalog |
| Sad/heavy | Soften; offer callback; no hard sell | Cheerful pitch |
| „Ko ste vi?“ | Answer identity + why once; stop repeating | Re-intro loop |
| Short „da/aha/mhm“ | Treat as continue cue; advance one step | Restart opening |
| Clear ne | Honor; soft close | „Ali imate li pitanja?“ push |

## Forbidden machine lines (ban in prompts)
Global ban list (adapt language):
- „Da li želite da kupite?“ as first reaction to anything
- „Imate li još pitanja?“ as default filler every turn
- „Kako Vam mogu pomoći danas?“ on **outbound** cold call
- Feature lists without tie to what they just said
- Ignoring curse/annoyance and continuing script
- Asking 2–3 questions in one turn
- Re-saying full name/company every node

## Human turn shape (every agentNode)
1. **Mirror** (0–1 short phrase) — only if caller gave content/emotion  
2. **Value crumb** — one concrete point tied to *their* last words  
3. **Handoff** — one question OR clear choice (not both long)  

Example bad:
> Aquaphor Smile filtrira hlor i kamenac i stoji X KM. Želite li naručiti ili imate pitanja?

Example better:
> Zvuči kao da vam flaširana dodijava. Bokal radi s česme, plaćanje na vratima.  
> Da li vam je važnije ušteda ili ukus vode?

## Sales still happens — humanely
| Stage | Human version |
|-------|----------------|
| Open | Why + tiny time ask |
| Discover | Their water habit first |
| Pitch | 1–2 benefits **mapped** to discovery |
| Close | Assumptive only after signals; else soft choice |
| After no | Respect; door open once max |

Use `closing` + `objection-handling` for technique; this skill overrides **robotic** delivery of those techniques.

## globalNode patches (checklist)
Add explicit blocks:
- **Emotion / tone tracking** — detect rush, no, irritation, interest; adjust pace
- **Ban list** machine phrases
- **Short backchannels** — da/aha/mhm = continue, don't restart
- **One question rule**
- **No catalog close** without discovery signal
- **After second clear no** → polite end (no more pitch)

## startCall / early nodes
- See `dograh-voice-opening-greeting`
- Opening must not end with buy-ask; ends with permission/time or soft curiosity

## Measurement
Langfuse / QA scores: Warmth, Naturalness, Humanness, Greeting, Emotion-ack (if custom).  
Sim dialogues: angry, rushed, confused, skeptical, short-backchannel — not only happy buyer.

## Edit procedure
1. Live BS WF on voiceeu  
2. Read globalNode + startCall + first sales node  
3. Apply **one** primary change set: global emotion+ban list OR opening OR first sales node — prefer global+opening together only if user allows one round multi-file  
4. Freigabe → draft → test human scenarios  

## Anti-patterns for the builder
- Making prompts longer with more rules only  
- Adding fake empathy paragraphs  
- Changing TTS voice first (dialogue structure first)  
- Mixing DE and BS  
