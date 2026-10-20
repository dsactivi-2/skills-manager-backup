---
name: jev-eval-cli
description: Dokumente multi-dimensional bewerten und Agenten-Arbeit gegen Anforderungen prüfen mit dem jev_eval.py CLI (~/jev-project/tools/jev-eval). Nutze für Dokumenten-Scoring (Recruiting, Voice-Transkripte), Code-/Liefer-Reviews mit Anforderungs-Gates (--requirements), und als Baustein für Agent→Review→Retry-Loops. Ergänzt den generischen typesafe-ai Skill um das fertige, verifizierte CLI-Tooling aus dem jev-project.
---

**Stand: 2026-09-24** (Repo: `~/jev-project/skills/jev-eval-cli/SKILL.md`)

# jev-eval CLI — Bewerten und Prüfen mit Jev

Fertiges, verifiziertes CLI auf Basis der TypeSafe-Python-SDK. Liegt in
`~/jev-project/tools/jev-eval/`, Architektur-Entscheidungen in
`~/jev-project/docs/adr/0002-jev-eval-cli.md`.

**Vor jedem Aufruf:** Keys laden — `set -a && source ~/.env.local && set +a`
(nicht-interaktive Shells lesen `~/.zshrc` nicht).

## Was das Tool kann

Zwei Betriebsmodi:

### Modus 1: Dokumenten-Bewertung (Standard)

```bash
cd ~/jev-project/tools/jev-eval
uv run jev_eval.py --config dimensions.recruiting.yaml dokument1.txt dokument2.md
```

- Bewertet jedes Dokument auf alle Dimensionen der YAML-Config in **einem einzigen
  API-Call pro Dokument** (Fan-out; 12x billiger, 10x schneller als Einzelcalls).
- Composite-Score aus gewichteten Scores wird **in Code** gerechnet (Jev rechnet nicht).
- Dokumente >100k Zeichen werden automatisch gekürzt (Markierung `⚠️trunc`).
- Fehler bei einem Dokument brechen den Gesamtlauf nicht ab.
- Ausgabe: Tabelle im Terminal + JSONL-Datei (`<config-name>.ergebnis.jsonl`) —
  JSONL ist die Maschinen-Schnittstelle für weiterverarbeitende Skripte.

### Modus 2: Review / Anforderungs-Gates (`--requirements`)

```bash
uv run jev_eval.py --config dimensions.code-review.yaml \
  --requirements anforderungen.txt src/zu-pruefender-code/
```

- Die Anforderungsdatei enthält **eine Anforderung pro Zeile in normaler Sprache**
  (z. B. `Der Worker sendet keine Personendaten an externe APIs.`).
- Jede Zeile wird automatisch zu einem Noul-Gate `req_1..N` — kein Formulieren
  von Prüffragen nötig.
- Verdicts: ✅ ≥ 0.8 · 👤 0.5–0.8 (Mensch prüft nach) · ❌ < 0.5
  (Konstante `REVIEW_PASS_THRESHOLD = 0.8` in jev_eval.py).
- Gesamtverdict: `ALLE GATES BESTANDEN` oder `ZURÜCK AN DEN AGENTEN` — direkt als
  Abnahme-/Retry-Entscheidung nutzbar.
- Die Config-Dimensionen (z. B. Secrets-Check, Lesbarkeit) laufen als
  Zusatzprüfung mit.

## Configs (Fragen/Schwellen leben NUR hier, nicht im Code)

| Config | Zweck |
|---|---|
| `dimensions.recruiting.yaml` | Kandidaten-/Profil-Bewertung |
| `dimensions.voice.yaml` | Voice-Call-Transkripte (Disposition, Qualität) |
| `dimensions.code-review.yaml` | Code-Reviews, Zusatzprüfung im Review-Modus |
| `dimensions.voice-skript.yaml` | Skript-TEXTE vor dem Livegang (Brille: Verständlichkeit, Struktur, Ton, Unterbrechungs-Flow, invertiertes Compliance-Risiko) |

Dimensionstypen: `noul` (Ja/Nein + `threshold`), `choice` (Optionen-Map mit
Beschreibungen), `score` (Stufenliste mit Situationsbeschreibungen + `weight`).
Score-Stufen beschreiben **Situationen**, nicht Noten.

**Invertierte Fragen (`invert: true`):** Fragen, bei denen ein HOHER Rohwert ein
Problem ist (z. B. `enthaelt_secrets`), tragen `invert: true` in der Config.
Das Tool zeigt dann die **Gutheit** (1 − Rohwert) mit Klartext: `0.99 ✅ (sauber)`
bzw. `0.01 ❌ (PROBLEM)`. `threshold` bezieht sich dabei auf die Gutheit
(`goodness >= threshold → pass`). In der JSONL stehen beide Werte: `noul`
(Rohwert von Jev, unverändert!) und `goodness` (Gutheit). Wer maschinell
weiterrechnet, liest `goodness` und `pass` — niemals `noul` bei invertierten
Dimensionen allein interpretieren. Ohne `invert` verhält sich alles wie bisher
(hoch = gut).

## Verifikationsstand (2026-09-24)

- Recruiting: Elektriker `teilweise` 0.96 / comp 0.688; Lagerist `passt_nicht` 1.00 / comp 0.107
- Voice: `rueckruf` 1.00 / comp 0.807; `abgelehnt` 1.00 / comp 0.264
- Review-Selbsttest: 6/6 Gates ✅; Negativtest (2 falsche Anforderungen): 0/2 ❌
  — prüft in beide Richtungen korrekt.

## Wann welches Werkzeug

- **Neue Jev-Integration schreiben** (anderes Projekt, andere Sprache) → Skill `typesafe-ai`
  (generisch, Docs-first) bzw. `jev-evaluation` (Gateway/AI-SDK-Wissen).
- **Dokumente bewerten / Arbeit reviewen, Tooling existiert schon** → dieses CLI.
- **Schleifen bauen** (Agent liefert → reviewen → zurück): das fertige Werkzeug
  `skript_optimierer.py` (Stufe B) nutzen — es ruft `jev_eval`-Logik intern auf,
  schickt Jevs Gate-Details als Feedback an den Generator (LLM via AI Gateway),
  macht Best-of-Tracking und bricht am Runden-Limit ab. Auftrag als YAML
  (Vorlage `optimierer.beispiel.yaml`). Nur manuell loopen, wenn der Optimierer
  nicht passt.

## Grenzen (aus den Jev-Limits, verifiziert)

- Kein Rechnen/Zählen/Datumsvergleiche — in Code lösen.
- Kein Text-Output — Jev bewertet nur, generiert nichts.
- Deutsch funktioniert, aber Schwellen mit deutschen Beispielen kalibrieren.
- Schwellen 0.8/0.5 sind Startwerte, noch nicht mit echten Daten geeicht —
  vor Produktivbetrieb Kalibrier-Schleife fahren (50–100 gelabelte Beispiele,
  Abweichungen zählen, Schwelle/Fragen justieren).
- Keine Personendaten in `state` schicken, nur das minimal Nötige.
