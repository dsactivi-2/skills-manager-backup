---
name: dograh-telesales-pacing
description: "Use when Dograh outbound sells too fast (COD/order in first 10s). Warm open → discover → pitch → close. Graph+prompt pacing."
version: 1.0.0
license: MIT
metadata:
  hermes:
    tags: [dograh, telesales, sales, pacing, discovery, opening, bosnian, cold-call]
    related_skills:
      - dograh-voice-opening-greeting
      - dograh-human-conversation
      - closing
      - objection-handling
      - marketing-psychology
      - bosnian-voice-prompts
      - barbarez-three-lanes
---

# Dograh telesales pacing (no hard-sell in first 10s)

## Symptom
Agent in first ~10 seconds:
> „Prodajem bokal, hoćeš pouzećem, šaljem ti — imaš li pitanje?“

Feels spam/scam. User wants: **warm up → who I am → what about → then sell**.

## Dograh basis (verified)
| Rule | Source |
|------|--------|
| Graph phases = order of sales | docs Voice Agent graph |
| startCall = greet + start, not full close | docs start-call |
| One thing per turn; multi-step as **sequence of nodes** | guide call_flow_design |
| Success criteria = when to leave node (not “always close”) | guide success_criteria |
| Global = persona/style; node = this phase only | guide common_guidelines |

Dograh does **not** require hard close on open. Closing belongs in **later nodes** with strict success criteria.

## Correct phase map (outbound B2C filter/water BS)

| # | Node | Allowed | Forbidden |
|---|------|---------|-----------|
| 0 | `greeting` TTS | Name + firm only | Product, price, COD, order |
| 1 | startCall prompt | Who + **why in 1 line** + **time permission** | Order, price, “hoćeš kupiti”, “imaš li pitanja” as pitch dump |
| 2 | Discovery | Water habit / pain, 1 Q/turn | Offer package + COD |
| 3 | Pitch | 1–2 benefits tied to discovery + soft next step | Immediate order form |
| 4 | Close / order | COD, address, phone after interest signal | Jump here from open |
| 5 | Confirm | Readback | New pitch |

**Rule:** Order/COD language **only** from node ≥3 and only if discovery/pitch edge fired.

## Why it hard-sells (root causes)
1. **startCall success criteria** jump straight to order edge  
2. **globalNode** says “goal = narudžba” without “not in first turns”  
3. **Too few nodes** — one mega-node does open+sell+close  
4. **Ponuda** reachable too early / default edge too loose  
5. Prompt examples contain COD line → model copies early  
6. Weak “permission” → model fills silence with pitch  

## Fix pattern (graph + prompt)

### A) Graph (preferred)
```
Pozdrav (startCall)
  → only: da/minute/interes → Kvalifikacija
  → nije zgodno → Kasnije
  → ne/ne zovi → Odbijanje
  → NO edge to Narudžba/Potvrda

Kvalifikacija
  → interes/bol → Ponuda
  → ne → Odbijanje

Ponuda
  → hoće naručiti → Narudžba
  → razmisli → Kasnije
  → ne → Odbijanje

Narudžba → Potvrda → Uspjeh
```
Remove any edge **Pozdrav → Narudžba** or **Pozdrav → Potvrda**.

### B) globalNode add
```text
## Sales pacing (obavezno)
Ne nudi narudžbu, cijenu kao close, niti plaćanje pouzećem kao prvi poziv na akciju u prvim zamjenama.
Prvo: ko si, zašto zoveš, dozvola za kratko vrijeme, pa potreba, pa ponuda, pa narudžba.
Zabranjene rane fraze (prvih ~30–45s / dok nisi u Ponuda/Narudžba nodu):
- "hoćeš da naručiš / šaljem ti / pouzećem odmah"
- "imaš li pitanja?" kao zamjena za discovery
Ako pita "koliko košta" ranije — odgovori kratko i vrati se na pitanje o vodi/dozvoli, ne na formu narudžbe.
```

### C) startCall prompt (only this job)
```text
# Cilj ovog koraka SAMO
1) Ko si (ako greeting nije rekao sve)
2) Zašto zoveš — jedna konkretna rečenica (tema, NE katalog, NE close)
3) Jedno pitanje: ima li 20 sekundi / smije li kratko

# Zabranjeno u ovom koraku
Narudžba, adresa, telefon, količina, "plaćanje pouzećem hoćeš li", "šaljem ti", "imaš li još pitanja" kao close.

# Success
- da/može/slušam → edge Kvalifikacija
- nema vremena → Kasnije
- ne/ne zovi → Odbijanje
```

### D) Discovery node
Only water/need questions. Success → Ponuda when **signal**, not after one hello.

### E) Pitch node
Tie benefit to what they said. Soft ask: “ima li smisla da objasnim kako radi?” or “želite li čuti kako ide dostava?” — **not** full COD dump until they lean in.

### F) Close node
Only here: pouzeće, adresa, telefon, readback.

## Sales craft (warm then sell)
| Step | Intent |
|------|--------|
| Rapport micro | Human, calm, not rushed pitch |
| Identity | Amina + Firmira once |
| Reason | Curiosity: filter/bokal theme |
| Permission | Small yes |
| Discover | Their situation |
| Value | Mapped benefit |
| Commit | Order after signal |
| Handle no | Respect; no triple close in open |

Skills: marketing-psychology (small yes, curiosity), closing (only late), dograh-human-conversation (emotion).

## Builder checklist
- [ ] No order words in greeting/startCall  
- [ ] No edge open → order  
- [ ] global pacing ban list  
- [ ] Discovery before Ponuda  
- [ ] success_criteria match edges  
- [ ] Test first 30s: must NOT hear pouzeće/order  

## Barbarez procedure
1. get_workflow BS ID (#9/#10)  
2. Map edges from startCall — flag illegal early close paths  
3. Patch startCall + global pacing (+ edges if needed) **one freigabe round**  
4. save draft → test first 30 seconds only  

## Related
- `dograh-voice-opening-greeting` — mechanics of open  
- `dograh-human-conversation` — emotion, anti-robot  
- Guide: call_flow_design, success_criteria, turn_taking  
