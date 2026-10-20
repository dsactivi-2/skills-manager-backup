---
name: voice-workflow-maps
description: "Use when mapping n8n/LiveKit sales flows with N/R IDs."
version: 1.0.0
author: activi
license: MIT
metadata:
  hermes:
    tags: [eraser, workflow, n8n, livekit, telesales]
    related_skills: [eraser, eraser-diagrams, livekit-telesales-outbound]
---

# Voice / n8n sales workflow maps

Class: overview maps for outbound voice sales (LiveKit + n8n), not pretty architecture posters.

## When to Use

User wants Überblick, Status, Lücken, Verbindungen — or says zeichnen, Phase Gx erklären, Route, Wiedervorlage, Kalender.

## Pflicht

1. Erst Stichpunkte der zu zeichnenden Phasen. User bestätigt oder ändert. Dann erst Eraser.
2. Jeder Knoten: fortlaufende ID `N01`, `N01.1`, `N18.1`. Tausch-Sprache: „N12 mit N07“.
3. Jede Kante: `R01`… auf der Linie + Tabelle. Beispiel: „R21 geht von G3 N15 nach G4 N16 — Ausgang Ja.“
4. Vor jeder Zeichen-Änderung: neue Version (`versions/vNNN/` + Changelog). Nie still überschreiben.
5. Rendern nur `mcp__eraser__*` (Skill `eraser`). Nie curl `/api/render`.
6. Lokal speichern: PNG, DSL, Phasen-MD, ROUTEN.md. Quer, kurze Labels, `direction right`, outline/clean — lesbar vor hübsch.

## Zwei Kalender (dieses Produkt-Muster)

| Fall | Kalender | Zurück |
|---|---|---|
| Ja (N16) | Human (G7) — Termin für Mensch / Vertragsabschluss. Agent schreibt keinen Vertrag. | Kein Agent-Rückruf |
| Will Termin (N19) | AI-Kalender (G9) | Zur Zeit → **N07** (G2), nie direkt G3 |
| Nicht erreicht (N18) | Kein Human. Queue + `N18.1` max 2 Anrufe/Tag | N07 Slot / nächsten Tag |
| Weiches Nein (N24) | Lead-DB On Hold | Frühestens **2 Monate**, dann automatisch N07 |
| Hartes DNC (N25) | Sperre | Nie Queue |

## Phasen-Reihenfolge

G1 Quellen/Dedup/DNC/Felder → G2 Queue/Regeln/SIP/Call-ID → G3 Gespräch → G4 Ausgang → G5 Ja / G6 Nein / G9 AI-Termin → G7 nur Human → G8 Check.

## Pitfalls

- N18 nicht auf Human-Kalender legen.
- N24 nicht wie N18 behandeln (kein Same-Day-Retry).
- R38/Callback immer über G2 (SIP + Call-ID).
- Skill `eraser` ist pinned — Pairing-Regeln dort nicht autonom patchen.

## References

- `references/energy-warmup-no-contract.md` — aktueller Plan-Pfad und IDs.
