# Jev API-Referenz (AI SDK 7 `experimental_evaluate`)

Alle Angaben distilliert aus `docs/recherche-jev.md` (Stand 2026-09-18). Primärquellen: ai-sdk.dev/docs, vercel.com/docs/ai-gateway, docs.typesafe.ai, flaviocopes.com/jev, apidog.com/blog/what-is-jev.

## Verfügbarkeit

- Nur über den AI SDK (≥ 7.0.105; lokal 7.0.106). **Nicht** über die OpenAI-/Anthropic-/Cohere-kompatiblen Gateway-Endpunkte.
- Experimentell — kann sich in Patch-Releases ändern.
- Model-IDs: `typesafe-ai/jev` (Gateway), Aliase `jev-latest` (stabil, SDK-Default), `jev-preview` (neuester Build). Die Response meldet immer die versionierte ID (z. B. `jev-1.13.0`) — loggen; für kalibrierte Thresholds pinnen statt Alias.

## Parameter

| Parameter | Typ | Beschreibung |
|---|---|---|
| `model` | `Experimental_EvaluationModel` oder String | Pflicht. Strings lösen über Vercel AI Gateway auf (`'typesafe-ai/jev'`); Alternativen: `gateway.evaluationModel('typesafe-ai/jev')`, Provider-Fabriken, Registry (`registry.evaluationModel('provider:model')`), Custom Aliases. |
| `state` | string \| object \| array | Pflicht, JSON-kompatibel. Ein Array = **ein** state, kein Batch. Keine Funktionen, Klassen, Zyklen, `undefined`, nicht-endliche Zahlen. |
| `questions` | `Record<string, Question>` | Pflicht, nicht-leer. |
| `maxRetries` | number | Default 2 (transiente Fehler). |
| `abortSignal` | AbortSignal | Abbruch. |
| `headers` | Record<string,string> | Zusätzliche HTTP-Header. |
| `providerOptions` | ProviderOptions | u. a. `providerOptions: { gateway: { zeroDataRetention: true } }`. |

## Rückgabe (`Experimental_EvaluationResult`)

- `answers`: ein typisierte Antwort pro Frage-ID (Literal-Union bei Choice inferiert).
- `usage`: `inputTokens`, `outputTokens`, `totalTokens` (optional; total nur wenn beide bekannt).
- `warnings`, `rounding` (deklarierte Dezimalrundung), `providerMetadata`, `response` (Timestamp, Modell-ID, ggf. Headers/Body).
- **TypeSafe-spezifisch**: `result.providerMetadata?.typesafe?.confidence` — separater Confidence-Wert für Choice/Score, keyed by question ID. **Nicht** die Wahrscheinlichkeit der gewählten Option, kein portables Maß. Fehlende Werte werden nicht synthetisiert.
- Validierung: Distributions summieren auf 1 (Toleranz 1e-6 + Rundungstoleranz); Score = wahrscheinlichkeitsgewichteter Mittelwert. Ungültige Outputs werden verworfen, native Werte nie still normalisiert.

## Fragentypen & Antwort-Shapes

### boolean (TypeSafe-nativ: `noul`)

- Frage: `{ type: 'boolean', criteria?: { true: '...', false: '...' } }`
- Antwort: `{ type: 'boolean', probability }` — P(true) ∈ [0,1]. 0.98 = starkes Ja, 0.02 = starkes Nein, ~0.5 = unklar (keine "mittlere" Confidence).
- Direkte TypeSafe-API: Typ heißt `noul`, Antwortfeld `noul` (0–1). Semantisch identisch.

### choice

- Frage: `{ type: 'choice', criteria: { option: 'Beschreibung', ... } }` — nicht-leer, **bis 255 Optionen** (Sekundärquelle Apidog/TypeSafe models page).
- Antwort: `{ type: 'choice', choice, probabilities? }` — `choice` = Option mit max. Wahrscheinlichkeit; `probabilities` deckt alle Optionen ab (bei Jev vorhanden). Native TypeSafe-Antwort enthält zusätzlich `confidence`.

### score

- Frage: `{ type: 'score', criteria: ['Stufe 0 (niedrig)', ..., 'Stufe N (hoch)'] }` — **2–10** Stufen, geordnet.
- Antwort: `{ type: 'score', score, probabilities? }` — fraktionaler Score ∈ [0, levels-1], gleich dem wahrscheinlichkeitsgewichteten Mittel; `probabilities` mit String-Keys der Stufenindizes.

### Allgemein

- `instructions`/Beschreibungen: String, JSON-Objekt oder -Array (auch `null`); Core interpretiert Struktur nicht.
- Verschiedene Typen können einen state teilen — ein Round-Trip. Fragen unabhängig; unabhängige Fragen bündeln (13 Fragen in 1 Call = 12,2x billiger als 13 Calls, da state nur einmal gesendet wird).
- Kein Streaming, kein Multilabel, kein Batch unabhängiger States — je state ein Call.

## Fehler

- `Experimental_EvaluationUnsupportedQuestionTypeError` — vor dem Provider-Call; **der gesamte Call schlägt fehl** (kein partieller Erfolg, kein automatischer Modell-Wechsel).
- `InvalidArgumentError` (Eingaben), `InvalidResponseDataError` (fehlende/falsch typisierte Antworten; kein Retry).
- `NoSuchProviderError`, `NoSuchModelError` (`modelType: 'evaluationModel'`), `UnsupportedModelVersionError` bei nicht-v4-Modellen.
- Transiente Provider-Fehler: normale Retry-Policy. Direkte API: 401 ungültiger Key, 422 Validierung, 429 Rate-Limit, 529 überlastet (Backoff/Retry).

## ZDR / No Training

- Pro Request: `providerOptions: { gateway: { zeroDataRetention: true } }` — ohne Zusatzkosten (Pro/Enterprise); team-weites ZDR $0.10/1.000 Requests. Jev unterstützt ZDR generell.

## Preise & Rate Limits

- **$0.042 pro Mio. Input-Tokens, Output-Tokens kostenlos** ($42/Mrd.). Gleicher Preis direkt bei TypeSafe und via AI Gateway (kein Markup).
- Beispiele: Triage-Call ≈ 300 Tokens → ~$0.0000126; 1.018 Paper-Summaries → $0.08 (LLM-Summaries extra $3.99 — Vorbereitungskosten einrechnen).
- Gateway-Free-Tier: $5/Monat Credit, PAYG, Budgets absicherbar; Evaluation-Calls zählen für Budgets.
- Rate Limits (TypeSafe, Early Access, dynamisch): **250.000 Tokens/s, 1.200 Requests/Min.**; Gateway-Free-Tier niedriger, 429 bei Überschreitung.

## Alternative Provider (Evaluation-Adapter, nicht nativ)

OpenAI `gpt-5.6-luna`, Anthropic `claude-haiku-4-5-20251001`, Google `gemini-3.5-flash-lite`: ein Prompt, strukturierte Outputs, `reasoning: 'none'` default; **keine** nativen unabhängigen Fragen, keine echten kalibrierten Wahrscheinlichkeiten. Für Produktion eigenes Modell an gelabelten Daten wählen — Jev ist der einzige native Evaluation-Provider.
