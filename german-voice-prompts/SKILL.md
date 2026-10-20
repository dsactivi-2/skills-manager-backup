---
name: german-voice-prompts
description: "Write natural, production-grade GERMAN-language voice-agent prompts for Dograh/Patter telesales and support agents. Use when authoring or reviewing German (DE) agent prompts, greetings, closings, objection lines, or when a non-German prompt must be localized to natural spoken German. Covers Sie/Du choice, number/date/price/currency speech normalization, natural backchannels, disfluency control, and STT/TTS pitfalls specific to German."
trigger: "Use when writing, localizing, or reviewing German-language voice-agent prompts (greeting, node prompts, objections, closing) for Dograh or Patter telesales/support agents."
metadata:
  version: 1.1.0
  parity: prompt-authoring
---

# German voice prompts (natural spoken DE for voice agents)

## When to use
Authoring or reviewing any German-language voice-agent prompt: greeting, agentNode prompts, objection lines, closing, globalNode persona. Also when a Bosnian/English prompt must be localized to natural spoken German — do NOT machine-translate word-for-word; rewrite for spoken idiom.

## CRITICAL rule: written German != spoken German
TTS reads what you write. Write how a real caller SPEAKS, not how a form is filled out.
- Contractions/particles are natural: "Passt das für Sie?", "Ich schau kurz nach.", "Alles klar." Use "mal", "kurz", "eben", "genau", "gerne" as real speech markers.
- Avoid nominal bureaucrat-German ("Zwecks Terminvereinbarung bezüglich...") — it sounds robotic and inflates latency.
- Short sentences. Voice LLMs over-explain: cap most turns at 1-2 sentences unless reading a list back.

## Sie vs. Du (decide once, in the globalNode)
- Cold outbound B2C/B2B in DE/AT/CH: default to **Sie**. Being duzed unsolicited reads as pushy or scammy.
- Only use **Du** if the brand explicitly targets a young/casual segment AND the builder confirms it.
- NEVER mix within a call. State the rule explicitly in the globalNode: "Sieze den Gesprächspartner durchgehend. Wechsle nie zu Du."
- Regional: "Grüß Gott" (AT/Bayern), "Grüezi" (CH), "Guten Tag / Hallo" (DE default). Match the target market; if unknown, "Guten Tag".

## Number, date, price, currency — write them SPOKEN
TTS mishandles digits and symbols. The core rule has two tiers — do NOT apply word-spelling uniformly to all numbers:

### Tier 1 — Semantic numbers → spell as words
Prices, quantities, years, percentages: the *value* matters, so use natural spoken number words.
- Money: "49 Euro" → "neunundvierzig Euro". Instruct: "Sprich Preise als Zahlwort, nicht Ziffer für Ziffer."
- Cents: "19,90 €" → "neunzehn Euro neunzig" (NOT "neunzehn Komma neun null Euro").
- Percent: "20 %" → "zwanzig Prozent".
- Dates: "am 3. Oktober" → "am dritten Oktober". "15.03." → "fünfzehnter März". Instruct: "Datumsangaben ausgeschrieben, nicht als Ziffern."
- Times: "14:30 Uhr" → "halb drei" or "vierzehn Uhr dreißig". 24h for formal, 12h+Tageszeit for casual.
- Ordinals: spell them or write with period: "1." → "erster/erste/ersten" (case-declined).

### Tier 2 — Identifier numbers → read as DIGIT GROUPS (never as one big number)
PLZ, phone numbers, house numbers: the *sequence* matters, not the arithmetic value. Reading these as words is wrong and confusing.
- PLZ: "04335" → "null vier drei drei fünf" — NOT "viertausenddreihundertfünfunddreißig". Instruct: "Postleitzahlen Ziffer für Ziffer vorlesen."
- Phone: "0151/23 45 67" → "null eins fünf eins, dreiundzwanzig, fünfundvierzig, siebenundsechzig" (pair-grouping). Instruct: "Telefonnummern in Zweiergruppen vorlesen."
- House number: "14a" → "vierzehn a". Short enough that single digits are fine.

**Lesson learned (R2 Aquaphor DE simulation):** Applying "nie Ziffer für Ziffer" globally caused naturalness −1.0: PLZ was read as a five-digit integer. The tier distinction is critical.

## Natural backchannels and turn-taking
- Listening tokens: "mhm", "verstehe", "ja, genau", "okay". Put ONE, not a stack.
- End every agent turn with a question or a clear nudge, e.g. "Wie klingt das für Sie?", "Darf ich Ihnen kurz zeigen, wie das geht?" A turn that ends flat stalls the call.
- Acknowledge before pivoting: "Verstehe, das ist ein fairer Punkt. Darf ich kurz einordnen, warum..." (mirrors LAER: Listen-Acknowledge-Explore-Respond).

## Disfluency and pace control
- One idea per turn. If reading a list (e.g. package contents), chunk it: "Erstens..., zweitens..., und drittens..." with the model instructed to pause between items.
- Forbid filler-stacking: instruct "Keine langen Einleitungen wie 'Ich möchte Ihnen gerne mitteilen, dass...'. Komm direkt zum Punkt."
- Instruct against reading punctuation/markdown: no bullet characters, no asterisks — TTS says them literally.

## STT/TTS pitfalls for German
- Umlauts and ß: ensure the TTS voice is a genuine German voice, not an English voice reading German (it will mangle "ü", "ö", "ä", "ß"). Verify voice locale = de-DE/de-AT/de-CH.
- Compound words: German STT can split or mis-hear long compounds ("Trinkwasserfilteranlage"). Keep spoken product names shorter where possible, or accept minor ASR noise as non-rejection.
- Anglicisms: brand/product names in English inside German speech ("Smile", "Cloud") — instruct the model to keep them as-is, and pick a voice that handles code-switching, else they get germanized.
- Do NOT use multilingual STT for a single-language DE flow — pin STT to German. (Same rule as the optimizer skill.)

## Prompt skeleton (globalNode persona, German)
```
Du bist [Name], [Rolle] bei [Firma]. Du rufst an, um [Ziel in einem Satz].
Sprache: durchgehend Deutsch. Sieze den Gesprächspartner. Wechsle nie zu Du.
Ton: warm, professionell, nie aufdringlich, nie roboterhaft.
Länge: Halte jede Antwort auf ein bis zwei Sätze, außer beim Vorlesen einer Liste.
Zahlen/Preise/Daten — NUANCIERT (zwei Regeln, nicht eine):
  Semantische Zahlen (Preise, Mengen, Prozent, Jahre) → als Zahlwort:
    49 → "neunundvierzig", 19,90 € → "neunzehn Euro neunzig", 3.10. → "am dritten Oktober".
  Identifier (PLZ, Telefonnummer, Hausnummer) → als Zifferngruppen, NIE als Zahlwort:
    PLZ 04335 → "null vier drei drei fünf", Telefon 0151/2345 → "null eins fünf eins, dreiundzwanzig, fünfundvierzig".
Höflichkeit: Bestätige zuerst, was der Kunde sagt, dann führe weiter.
Beende jede Antwort mit einer Frage oder einem klaren nächsten Schritt.
```

## Localization checklist (Bosnian/EN -> DE)
1. Rewrite, don't translate: keep intent, replace idiom with natural DE idiom.
2. Re-decide Sie/Du for the target market (BiH informal norms != DE cold-call norms).
3. Convert all numbers/dates/prices to spoken-DE instructions.
4. Swap greeting/closing to DE-market conventions ("Guten Tag" / "Vielen Dank, einen schönen Tag noch. Auf Wiederhören.").
5. Re-check compound product names for STT/TTS.
6. Verify the workflow's voice = de-* locale, not the source-language voice.

## Anti-patterns
- Reading prices/dates/years digit-by-digit (e.g. "vier neun Euro" instead of "neunundvierzig Euro").
- Reading PLZ/phone numbers as one big word-number — this is the overcorrection trap. Digit-groups are CORRECT for identifiers.
- Mixing Sie and Du in one call.
- Bureaucratic nominal German that no one says out loud.
- Long multi-sentence turns that never hand back to the caller.
- Using an English TTS voice for German text (mangles umlauts/ß).
- Machine-translating a Bosnian prompt into German without rewriting for spoken idiom.
- Leaving markdown/bullets in a prompt the TTS will read aloud.
