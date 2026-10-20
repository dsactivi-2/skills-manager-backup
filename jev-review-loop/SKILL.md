---
name: jev-review-loop
description: Agent→Jev→Retry-Loops bauen und kalibrieren — automatische Qualitäts-Gates für generierte Artefakte (Code, Voice-Skripte, E-Mails, Prompts) mit dem TypeSafe-CLI aus dem jev-project. Nutze, wenn ein Agent iterativ liefern soll, bis Jev-Gates bestehen bzw. ein Ziel-Score erreicht ist (Stufe B), oder wenn Jev-Schwellen mit gelabelten Beispielen geeicht werden sollen. Setzt den Skill jev-eval-cli voraus.
---

**Stand: 2026-09-24** (Repo: `~/jev-project/skills/jev-review-loop/SKILL.md`)

# Jev Review-Loops — Automatik-Gates und Kalibrierung

Musterwissen aus dem jev-project für zwei wiederkehrende Aufgaben:
(A) einen Generator-Loop orchestrieren, (B) Jev-Schwellen kalibrieren.
Beides nutzt `jev_eval.py` (Skill `jev-eval-cli`) als Bewertungsbaustein.

## A. Agent→Jev→Retry-Loop (Stufe B)

Grundmuster für jedes Artefakt (Code, Voice-Skript, E-Mail-Template, Prompt):

```
1. Generator-LLM erzeugt Artefakt v1
2. jev_eval.py bewertet:
   - Anforderungs-Gates:  --requirements anforderungen.txt  (harte Gates, ✅/❌)
   - Score-Dimensionen:   --config dimensions.<domain>.yaml (Güte, 0..n)
3. ORCHESTRATOR-CODE (nicht Jev!) entscheidet:
   - alle Gates ✅ UND Zielscore erreicht → FERTIG, Artefakt + Report an Mensch
   - sonst → Feedback an Generator → v2 (nächste Runde)
```

### Die fünf Regeln (aus Fehleranalyse abgeleitet)

1. **Feedback zurückgeben, nicht nur den Score.** „Zurück, 0.84" lässt den
   Generator raten. Die Gate-Details und schwachen Dimensionen mitschicken:
   *„Begrüßung ✅ 0.95, aber 'klare Abschlussfrage' ❌ 0.61 und
   'Sätze < 15 Wörter' ❌ 0.58 — genau das fixen."* Umgekehrt gilt: Punkte,
   die die Prüfung als erfüllt meldet, explizit als „erfüllt — nicht ändern"
   kennzeichnen, sonst zerstört der Generator beim Rewrite gute Passagen.
2. **Best-of-Tracking, nicht letzte Version.** Jev-Scores rauschen ±0.03–0.05
   bei identischem Text. Immer die beste bisherige Version speichern;
   „besser" erst ab Mindestverbesserung zählen (Live-Praxis: **+0.02** bei
   hohen Latten ≥ 0.85, weil die letzten Schritte klein sind).
3. **Runden-Limit + Eskalation.** max. 5–8 Runden; zusätzlich Stopp nach
   3 Runden ohne echte Verbesserung → beste Version + Score-Verlauf an den
   Menschen. Sonst dreht sich der Loop ewig.
4. **Jev generiert nichts.** Das Schreiben macht immer ein normales LLM
   (z. B. über die Vercel AI Gateway). Jev ist nur der Prüfer.
5. **Anforderungen und Dimensionen in Dateien**, nicht in Prompts verstreut —
   sie sind das Review-Interface für Menschen.

### Umsetzungs-Reihenfolge

Erst lokales Python-Skript (~100 Zeilen: Generator-Call → jev_eval-Aufruf →
JSONL lesen → Retry-Logik), live beweisen, dann bei Dauerbetrieb nach n8n
heben (HTTP-Wrapper ums CLI). Hexabot ist dafür der falsche Platz.

### Fertige Umsetzung: `skript_optimierer.py` (Stand 2026-09-24)

Das Werkzeug existiert und ist **live getestet** (`~/jev-project/tools/jev-eval/`)
— mit **gezielter Politur** (nur schwächste Dimension) + **Anker-Rückfall**.
Live-Befund: Aufwärtstrend (Composite 0.736→0.877), Gate-Durchbruch 5/5; nach
Politur-Präzisierung + Anker-Logik erreichte der Live-Lauf 4/5 Gates + 0.834,
Regressions-Schutz griff 2×, kein Gates-Zerstören mehr — Ziel (Gates + Composite
gleichzeitig ≥ Latte) hängt am Generator-Modell, nicht am Werkzeug (CHANGELOG).

```bash
uv run --python ~/.local/share/uv/python/cpython-3.12-macos-aarch64-none/bin/python3.12 \
  skript_optimierer.py optimierer.beispiel.yaml [--out optimierungen]
```

- **Auftrag** = eine YAML (`task`, `generator_model` über die AI Gateway,
  `config`, optional `requirements`, Schwellen `min_composite`/`min_gates_ratio`,
  `max_runden`, `min_delta` = die Mindestverbesserung). Vorlage: `optimierer.beispiel.yaml`.
  Getestet: `min_composite 0.85` + `min_gates_ratio 1.0` als harte Latte,
  `max_runden 8`, `min_delta 0.02`, Generator `google/gemini-2.5-flash`
  (Free-Tier-tauglich; gemini-3.1-flash-lite und claude-haiku sind dort 403).
- **Generator**: beliebiges Text-Modell über `POST https://ai-gateway.vercel.sh/v1/chat/completions`
  (OpenAI-kompatibel, `AI_GATEWAY_API_KEY`). KEIN Evaluation-Modell hierfür.
- **Bewertung**: nutzt die jev_eval-Logik intern (Fan-out, Gates, Composite).
- **Ausgabe**: `optimierungen/<lauf>/version_N.md` + `lauf.jsonl` (alle Urteile)
  + `ERGEBNIS-version_N.md` (beste) oder `LETZTE-VERSION-nicht-bestanden.md`
  mit offenen Beanstandungen. Exit 0 = Ziel erreicht, Exit 1 = Limit/Fehler.
- Feedback an den Generator enthält automatisch die Gate-Details und schwachen
  Dimensionen (Regel 1); Best-of mit `min_delta` (Regel 2); Abbruch nach
  `max_runden` mit Eskalation (Regel 3).
- **Politur-Pass (präzisiert 2026-09-24):** Besteht ein Skript alle Gates, liegt
  aber unter `min_composite`, wird es nicht neu geschrieben, sondern **gezielt**
  poliert: Jev beanstandet **nur die eine gewichtete Score-Dimension mit dem
  niedrigsten norm** (statt alle — ein Rundumschlag zerstörte im Live-Lauf gute
  5/5-Gates-Skripte), und `VERBESSER_PROMPT` verbietet ausdrücklich, die
  Fach-Struktur (`(Wenn…)`/`(Sonst…)`-Zeilen, Begrüßung, Abschluss) anzufassen.
  **Übernommen wird die Politur nur, wenn sie KEINE Gates kostet** UND Fortschritt
  bringt (mehr Gates, oder gleiche Gates bei höherem Composite) — sonst verworfen.
- **Anker (Sicherungspunkt, seit 2026-09-24):** Die erste Version, die ALLE Gates
  besteht, wird als Anker festgehalten. Stagniert der Loop danach 2 Runden und
  liegt unter dem Anker (weniger Gates), springt er automatisch auf den Anker
  zurück, statt den fachlichen Fortschritt zu verlieren. Danach greift erst die
  bisherige Regressions-Logik (beste Annäherung).

Achtung: uv respektiert `~/.python-version` (3.10) — das Projekt braucht ≥ 3.12,
deshalb das `--python`-Flag explizit setzen (oder `uv python pin 3.12` im Verzeichnis).

## B. Kalibrierung (Pflicht vor Produktivbetrieb)

Schwellen (0.8/0.5 im CLI) sind Startwerte. Vor echtem Einsatz:

**Phase 1 — Eichen:**
1. 50–100 echte Beispiele vom Fachmenschen labeln (die Wahrheit).
2. Jev drüberlaufen lassen, Abweichungen zählen.
3. Justieren: Frage schärfen (z. B. „Ist der Absender unzufrieden mit einer
   Leistung?" statt „Beschwerde?"), Kriterien ergänzen, Schwelle anpassen.
4. Wiederholen bis Trefferquote stimmt (Ziel ~95 %).

**Phase 2 — Betrieb mit drei Zonen:**

| Jev-Wert | Aktion |
|---|---|
| ≥ obere Schwelle (z. B. 0.85) | automatisch |
| 0.5–0.85 | Mensch-Review — das ist neues Kalibriermaterial |
| < 0.5 | verwerfen / andere Route |

Der Review-Bereich speist Phase 1 nach — der Kreislauf hält die Trefferquote
über die Zeit oben. Bei deutschen Texten: mit deutschen Beispielen eichen
(Hersteller: „handled but not equally well").

## Beispiel: Voice-Skript-Optimierung

Skript-Struktur, die Jev fair bewerten kann: `[KONTEXT]`, `[ERÖFFNUNG]`,
`[HAUPTTEIL]` (max. 1 Frage pro Turn), `[ABSCHLUSS]` (konkrete Zusage),
`[FALLBACKS]`. Typische Dimensionen für `dimensions.voice-skript.yaml`:
Begrüßung nennt Name+Grund (noul), max. 1 Frage/Turn (noul), Satzlänge
TTS-tauglich (score), Abschluss mit konkreter Aktion (noul), Ton
steif/natürlich/übertrieben (choice). Nach Live-Calls dieselbe Config gegen
die echten Transkripte laufen lassen („Skript eingehalten?").
