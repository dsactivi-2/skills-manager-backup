---
name: jev-evaluation
description: Typisierte LLM-Entscheidungen mit TypeSafe Jev (typesafe-ai/jev via Vercel AI Gateway) — boolean/choice/score-Fragen mit Wahrscheinlichkeiten. Nutze für Klassifikation, Routing, Triage, Rubric-Assessment, automatisierte Verifikation. Details in reference/api.md und reference/limits-and-pitfalls.md (Quelle aller Angaben: docs/recherche-jev.md, Stand 2026-09-18).
---

# Jev Evaluation Skill

Jev (`typesafe-ai/jev`, aktuell `jev-1.13.0`) ist ein **Evaluations-Modell**, kein Chat-Modell: Es bewertet einen `state` gegen typisierte `questions` und liefert direkt Antworten mit Wahrscheinlichkeiten. "Probabilistic decision model" — ein intelligentes if-Statement.

## Wann Jev einsetzen

- **Klassifikation / Routing**: Choice mit Option→Beschreibung-Map, Auto-Routing ab Wahrscheinlichkeits-Threshold, sonst Review-Pfad.
- **Triage**: boolean (P(true)) + score (Dringlichkeit) + choice (Team) in **einem Call** gegen denselben state — Fragen sind unabhängig und parallel, Mehrfragen kosten nur eigene Tokens.
- **Rubric-Assessment**: score mit 2–10 Stufen, die Situationen beschreiben, nicht Grade.
- **Automatisierte Verifikation / Guardrails**: Ja/Nein-Prüfungen in Agent-Loops ("weitermachen / retry / user fragen / stop").
- **Voice-Call-Disposition**: auf Transkript + Metadaten (Call vorher transkribieren, z. B. Whisper via Gateway — Jev nimmt **kein Audio**).

## Wann NICHT

- Freie Textgenerierung, Chat, Extraktion freier Werte, Streaming.
- Exaktes Zählen, exakte Arithmetik, Hex-/Farbvergleiche, Datums-/Zeitlogik (Fenster, Fristen) → Kandidaten per Regex/LLM/Code finden, Jev nur wählen lassen; Datum in Code bauen.
- Adversariale/ungefilterte User-Inputs ohne Tests (steuernder Text im state kann Antworten verschieben).
- Numerisch kritische Fragen auf Deutsch → Englisch bevorzugen (geringere Genauigkeit außerhalb Englisch).

## Aufruf (AI SDK 7+, ≥ 7.0.105)

```ts
import { experimental_evaluate as evaluate } from 'ai';

const result = await evaluate({
  model: 'typesafe-ai/jev',            // oder 'typesafe-ai/jev-latest' / 'jev-1.13.0' (gepinnt für kalibrierte Thresholds)
  state,                                // string | JSON-Objekt | Array (Array = EIN state, kein Batch)
  questions: {
    refund: { type: 'boolean', criteria: { true: 'Kunde fordert explizit Erstattung', false: 'keine Erstattung gefordert' } },
    department: { type: 'choice', criteria: { billing: 'Rechnung/Zahlung', support: 'Produkt-Hilfe', other: 'sonstiges' } },
    urgency: { type: 'score', criteria: ['Broken feature, workaround exists', 'Feature broken, no workaround', 'System down'] },
  },
  providerOptions: { gateway: { zeroDataRetention: true } },  // pro Request — Vorsicht: nur auf Pro/Enterprise-Plänen verfügbar (nicht Free); Direktzugang: ZDR nur Enterprise
});
// result.answers.refund        → { type: 'boolean', probability: 0.98 }
// result.answers.department    → { type: 'choice', choice, probabilities? }
// result.answers.urgency       → { type: 'score', score, probabilities? }
// result.providerMetadata?.typesafe?.confidence  // separater Confidence-Wert je Frage (nicht = Wahrscheinlichkeit)
```

## Fragen-Design

- **score**: Stufen beschreiben **Situationen**, nicht Grade ("Broken feature, workaround exists" statt "moderately severe"); Beispiele in Stufen erhöhen Confidence deutlich. Score nur zum Thresholden/Ranken, nicht als absolute Magnitude.
- **boolean**: Klare criteria `{ true, false }`. Wert nahe 0.5 = unklar, nicht "mittel".
- **Thresholds** auf `probabilities` setzen (z. B. Auto-Routing nur bei `>= 0.9`), an eigenen gelabelten Daten kalibrieren — hohe Wahrscheinlichkeit garantiert keine korrekte Antwort.
- State-Felder in Backticks/Pfadnotation referenzieren (`` `order.status` ``); state vorfiltern (irrelevante Inhalte = context rot). Kompakte Question-IDs wählen — IDs sind für den Code.
- Alle unabhängigen Fragen in einen Call (speculative fan-out); Follow-up nur wenn Frage vom Ergebnis abhängt.

## Limits & Fehlerbehandlung

- 64k Tokens pro Request gesamt; state + längste Frage ≤ 32k. **Kein Truncation** — zu groß = Fehler, also vorfiltern/splitten.
- **Ein Fehler killt den ganzen Call** (kein partielles Ergebnis): große Batches in kleinere Calls aufteilen.
- `InvalidResponseDataError` wird nicht retried; transiente Fehler: Default `maxRetries: 2`. Direkte API: 401 Key, 422 Validierung, 429 Rate-Limit, 529 überlastet (Backoff).
- Versionierung: Modell-Version, Fragen, Criteria und Thresholds gemeinsam versionieren; Regressionsset mit gelabelten Beispielen pflegen. Response meldet immer die versionierte ID — loggen.

## Kosten

~$0.042 pro Mio. Input-Tokens, **Output gratis** (~$0.0000126 pro typischem Triage-Call). $5/Monat Gateway-Free-Tier. Rate Limits (Early Access, dynamisch): 250k Tokens/s, 1.200 req/min. Details: `reference/api.md`, `reference/limits-and-pitfalls.md`.

## Beispiel: Voice-Call-Disposition (Deutsch)

```ts
// state = deutsches Call-Transkript + Metadaten (Dauer, Agent, IVR-Pfad)
const r = await evaluate({
  model: 'typesafe-ai/jev',
  state: { transcript, durationSec: 312, ivrPath: 'billing' },
  questions: {
    terminVereinbart: { type: 'boolean', criteria: { true: 'Ein Termin wurde konkret vereinbart', false: 'kein Termin vereinbart' } },
    disposition: { type: 'choice', criteria: {
      verkauft: 'Abschluss/Verkauf erzielt', termin: 'Termin vereinbart',
      ruckruf: 'Rückruf vereinbart', kein_interesse: 'Kunde lehnt ab', unerreichbar: 'nicht erreicht' } },
    kundenstimmung: { type: 'score', criteria: ['Kunde verärgert/beschwert sich', 'Kunde neutral/sachlich', 'Kunde interessiert/positiv'] },
  },
  providerOptions: { gateway: { zeroDataRetention: true } },
});
if (r.answers.disposition.probabilities?.[r.answers.disposition.choice] >= 0.9) {
  routeToCRM(r.answers);          // Auto-Routing
} else {
  queueForHumanReview(r.answers); // Review-Pfad
}
// Thresholds an deutschen Beispiel-Transkripten kalibrieren!
```
