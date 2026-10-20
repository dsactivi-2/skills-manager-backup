---
name: dograh-voice-opening-greeting
description: "Use when Dograh startCall/greeting or first 10s of outbound call is weak, robotic, cut off, or kills permission. BS/DE opening patterns from Dograh guide+docs."
version: 1.0.0
license: MIT
metadata:
  hermes:
    tags: [dograh, voice, greeting, startCall, opening, telesales, bosnian, permission]
    related_skills:
      - barbarez-three-lanes
      - german-voice-prompts
      - marketing-psychology
      - closing
      - objection-handling
      - voice-low-latency-patterns
      - dograh-mcp-workflow-ops
---

# Dograh Voice Opening & Greeting (startCall)

## When
- Greeting klingt steif, zu lang, zu sales-y, wird abgeschnitten
- Caller sagt „ko je?/šta hoćeš?“ und Agent wackelt
- Dead air nach Greeting
- Permission-Frage zu früh oder zu aggressiv
- Outbound BS (BiH) oder DE cold call

## Dograh mechanics (live sources)

### Two layers on startCall
| Layer | Field | Role |
|-------|--------|------|
| **TTS greeting** | `greeting` | First audio **before** LLM turn. Short identity only. |
| **First LLM turn** | `prompt` on startCall | Reason + permission + routes. Runs **after** greeting. |

Never dump product pitch into `greeting`. Never re-introduce full name in prompt if greeting already said it (unless caller asks).

### Config that makes openings fail
| Setting | Opening recommendation | Why |
|---------|------------------------|-----|
| `delayed_start` | **true**, 1.0–2.0s | Let callee say „halo“; avoid talking over pickup |
| `allow_interrupt` on **startCall** | Prefer **false** for greeting delivery | Dograh docs: disable interrupt on greeting so intro finishes ([interruption](docs)) |
| `allow_interrupt` later nodes | **true** | Natural barge-in after open |
| Greeting length | ≤ ~8–12 spoken words | STT/VAD + attention |
| First LLM turn | 1–2 short sentences + **one** question | turn_taking guide |

### Guide atoms (always load when editing open)
```
get_voice_prompting_guide(topic="turn_taking")
get_voice_prompting_guide(topic="call_flow_design")
get_voice_prompting_guide(topic="success_criteria")   # if available
get_voice_prompting_guide(stage="create")             # then node-specific
```
- **turn_taking:** every agent turn ends with question/nudge — no dead air.
- **call_flow_design:** sections (task / flow / success); **one question per turn**; extraction not in spoken prompt.
- Success criteria on startCall = clear edges (continue / later / refuse / wrong number).

## Sales psychology (opening only — ethical)

| Principle | Opening use |
|-----------|-------------|
| Activation energy | First ask is tiny: „imate li 20 sekundi?“ not full pitch |
| Mere exposure / liking | Warm human voice, name once, smile in wording |
| Commitment & consistency | Small yes (time) before product yes |
| Loss aversion | **Not** in second 1 — no fear dump |
| Curiosity gap | Reason in one concrete line, not catalog |
| Reciprocity | Optional later; not gift-spam on open |

**Anti-patterns:** fake urgency, fake prior consent, monologue feature list, double intro, „je li ovo dobar trenutak za prezentaciju našeg…“ essay.

## Pattern: strong cold outbound open (BS default)

### A) `greeting` (spoken first)
Template BS:
```text
Dobar dan, ovdje Amina, {{business_name | Firmira}}.
```
Optional shorter:
```text
Dobar dan, Amina, {{business_name | Firmira}}.
```
- No product name in greeting.
- No „kako ste“ in greeting (burns turn; use in LLM only if natural after halo).

### B) startCall `prompt` (first LLM turn)
Structure:
```text
# Uloga
Prvi red NAKON greetinга. Ne predstavljaj se ponovo.

# Cilj
1) Jedna rečenica ZAŠTO zoveš (konkretno, bez kataloga).
2) Jedno kratko pitanje za dozvolu / vrijeme.
3) Slušaj → route po success criteria.

# Tok
1. Ako čuješ "halo/da/slušam" — nastavi odmah razlog + pitanje.
2. Razlog (jedan od):
   - BS Aquaphor: "zovem zbog kratke ponude za bokal koji filtrira vodu iz česme — plaćanje pouzećem."
   NOT: full filter chemistry.
3. Pitanje (jedno):
   - "Imate li dvadesetak sekundi?"
   - ili "Smetam li u glupo vrijeme?"
4. NE pitaj ime+grad+interes odjednom.

# Ton
Toplo, kratko, bez pritiska. Maks 1–2 rečenice + pitanje.

# Uslovi (edge labels — NE "pozovi alat" ako su edges)
- pristanak / interes → edge kvalifikacija
- nije zgodno, ne odbija → edge kasnije
- jasno ne / ne zovi → edge odbijanje
- pogrešan broj / nije ta osoba → edge lost (odmah izvini, kraj)
```

### C) Number-source honesty (BiH cold call)
In **globalNode** (not only open): if asked where number from → public directory / imenik truth; never claim they opted in. Align with firm policy.

## Diagnosis checklist (why open „feels shit“)

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| Cut off mid-name | interrupt ON + short hello | `allow_interrupt: false` on startCall |
| Talks over halo | delayed_start false/0 | delayed_start 1–2s |
| Robot catalog | product essay in greeting or turn1 | shorten; curiosity one line |
| Silence after hello | no question / turn_taking fail | end with permission Q |
| Double name spam | prompt re-intros | "ne predstavljaj se ponovo" |
| "Ko je?" loop | reason missing or too vague | one concrete why |
| Immediate hangup | too salesy / too long | shorter + soft ask |
| Edge never fires | "pozovi alat X" but only edges exist | use edge conditions, not fake tools |
| BS mixed with EN/DE | global language weak | exclusive BS rule |

## Review rubric (score 1–5 each)
1. Greeting ≤12 words, identity only  
2. delayed_start sensible  
3. interrupt policy correct for startCall  
4. First LLM: reason one line + one Q  
5. No double intro  
6. Success criteria → 3–4 clean exits  
7. Spoken BS natural (not translationese)  
8. No fake consent / no pressure  

Ship only if 1–6 ≥4.

## Workflow edit procedure (Barbarez)
1. Confirm **BS voiceeu** WF ID live (`list_workflows`) — default work objects often **#9 / #10** (marge BS). Do not touch DE Cloud IDs.
2. `get_workflow` / `get_workflow_code`
3. Load this skill + `get_voice_prompting_guide(topic=turn_taking)` + `call_flow_design`
4. Propose **only** startCall (+ optional global one-liner) — one change round
5. User freigabe → `save_workflow` draft → verify live → user publish
6. Test: real pickup + "halo", "ko ste vi?", "nemam vremena", hard no

## Example improved BS startCall (draft text — adapt, don't blind paste)

**greeting:**
```text
Dobar dan, ovdje Amina, {{business_name | Firmira}}.
```

**prompt (sketch):**
```text
# Uloga
Ti si Amina. Greeting je VEĆ izgovoren — ne predstavljaj se ponovo.

# Cilj
Kaži zašto zoveš u jednoj kratkoj rečenici i pitaj smiješ li 20 sekundi.

# Tok
1. Nadoveži se prirodno (bez novog "Dobar dan, ja sam…").
2. Razlog: zoveš zbog kratke informacije o bokalu Aquaphor Smile za vodu s česme, plaćanje pouzećem na vratima.
3. Jedno pitanje: "Imate li dvadesetak sekundi?"
4. Čekaj odgovor. Jedno pitanje po redu.

# Uslovi prelaska
- Da / može / slušam / aha → nastavi_na_kvalifikaciju
- Sad ne može, nazovi kasnije → zakazi_kasnije
- Ne zanima / ne zovi / obriši → zavrsi_odbijanje
- Pogrešan broj → zavrsi_odbijanje (kratko izvini)

# Zabranjeno
Dugi pitch, cijena u prvom redu, lista benefita, pritisak, ponovna puna predstava.
```

Also set: `delayed_start: true`, `delayed_start_duration: 1.5`, consider `allow_interrupt: false` on this node only.

## Related
- `voice-low-latency-patterns` — transition_speech / dead air after open  
- `marketing-psychology` — small yes, curiosity  
- `objection-handling` — after open, not inside greeting  
- `german-voice-prompts` — DE twin (Sie, Guten Tag)  
