# Jev: Limits, Fallstricke, Mocking, direkte API

Alle Angaben distilliert aus `docs/recherche-jev.md` (Stand 2026-09-18).

## Hard Limits

- **Text only**: state = String, JSON-Objekt oder Array von Text. Keine Bilder/Audio/Video. Voice-Calls: erst transkribieren (z. B. Whisper via Gateway), dann Jev aufs Transkript.
- **Kontext**: 64k Tokens pro Request gesamt; state + längste einzelne Frage ≤ 32k Tokens (~150k Zeichen englischer Text). Kein stillses Splitting/Truncating — SDK/CLI lehnen ab.
- **Ein Fehler killt den ganzen Call**: ein ungültiger/unterstützter Fragentyp → kein partielles Ergebnis. Große Batches in kleinere Calls aufteilen.
- Kein partielles Ergebnis, kein Batch unabhängiger States, kein Streaming, kein Multilabel.
- ai-cli: 30s-Timeout pro Evaluation inkl. Retries (Default), überschreibbar via `--timeout`.

## Jaggedness-Liste (jev-1.13, übersetzt aus TypeSafe via flaviocopes.com/jev)

1. **Kein Taschenrechner**: Zählen, exakte Arithmetik, Abstand von Hex-Farben unzuverlässig. Workaround: ein noul pro Item, Summe im Code.
2. **Daten/Zeiten werden als Text gelesen**: Reihenfolge, Abstände, Fenster-Vergleiche unzuverlässig. Extraktion als Choice (Monat/Tag/Jahr + "not stated"), Datum in Code bauen und vergleichen.
3. **Indirektion** (doppelte Verneinung, Property-of-Property) kostet Genauigkeit — direkt fragen.
4. **Context rot**: große states mit irrelevantem Inhalt senken die Genauigkeit — vorfiltern; ggf. erst noul "ist dieser Chunk relevant?".
5. **Literal statt intendiert lesen**: Anweisungen und criteria deckungsgleich formulieren.
6. **State = Daten, kein Code**: adversarialer/steuernder Text im state kann Antworten verschieben. Vor Produktivsetzung mit feindlichen Inputs testen; Thresholds konservativ; Review-Pfad Pflicht.
7. **Kann nicht frei schreiben/extrahieren**: "pick a card from the deck, don't ask it to name a card" — Kandidaten per Regex/LLM finden, Jev wählen lassen.
8. **Mehrsprachigkeit**: Englisch am besten; andere Sprachen mit geringerer Genauigkeit. Für kritische numerische Fragen Englisch bevorzugen; deutsche Voice-Transkripte → Thresholds an deutschen Beispielen kalibrieren.

## Sprach-Caveats & Kalibrierung

- SDK verspricht **keine** Kalibrierung über Provider hinweg; Wahrscheinlichkeiten an eigenen gelabelten Daten kalibrieren (Vercel-Changelog explizit: "Calibrate probabilities and confidence against labeled examples from your workflow").
- Hohe Wahrscheinlichkeit garantiert keine korrekte Antwort. Falsches Routing bleibt trotz typisiertem Output möglich.
- Modell-Version, Fragen, Criteria und Thresholds **gemeinsam** versionieren (Response meldet immer die versionierte ID, z. B. `jev-1.13.0`); Regressionsset mit gelabelten Beispielen pflegen.
- Rollout-Empfehlung (Copes/TypeSafe): mit einer "langweiligen" Entscheidung anfangen, Confidence eine Woche neben bestehender Logik loggen, dann erst handeln lassen.

## Mocking für Tests

```ts
import { Experimental_EvaluationMockModelV4 } from 'ai/test';
```

Liefert typisierte Mock-Antworten für `experimental_evaluate` — kein Live-Call, kein Quota-Verbrauch. Alternativ: direkte API-Responses als Fixtures (Assertions auf Entscheidungen wie `noul > 0.9` bzw. `probability >= 0.9`, `choice === 'billing'`).

## Direkte TypeSafe-API (Alternative ohne Vercel; für n8n/HTTP)

Kein Vercel nötig; Bearer-Key von console.typesafe.ai.

```
POST https://api.typesafe.ai/v1/systemone
Authorization: Bearer <key>
Content-Type: application/json

{ "model": "jev-latest" | "jev-1.13.0" | "jev-preview",
  "state": ..., "questions": { ... } }
```

- Typnamen: `noul` statt `boolean` (Antwortfeld `noul` 0–1); `choice`/`score` analog.
- Response: `{ model, answers, usage: { input_tokens, output_tokens } }` (snake_case).
- `GET /v1/models` listet Aliases. (GET auf den Endpunkt selbst → 405, nur POST.)
- Offizielle Python-/JS-SDKs existieren (`client.systemOne({ state, questions })`, zweites Argument für timeout/retry/signal), aber Quickstart-URL 404 — Paketname/Install vor direkter Nutzung in TypeSafe-Docs/Console verifizieren. Waitlist für direkten Zugang.
- **n8n**: einfacher HTTP-Request-Node (POST) gegen diesen Endpunkt; kein offizieller n8n-Node auffindbar. Fehlerbehandlung: 401 Key, 422 Validierung, 429 Rate-Limit, 529 überlastet → Backoff/Retry-Node.

## Quellen

Vollständige Quellenliste in `docs/recherche-jev.md` (§ Quellenliste, 10 Einträge). Bekannte Quellen-Lücken: Fragen-Anzahl pro Request ohne explizites Maximum (implizit über 64k/32k-Budget); Choice max 255 / Score 2–10 aus Sekundärquelle (Apidog/TypeSafe models page); Rate-Limits sind Early-Access-Werte und dynamisch; Latenz-/Speed-Zahlen sind Herstellerangaben ohne unabhängige Reproduktion.
