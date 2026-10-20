# German voice number nuance (Amina / Aquaphor lesson)

Captured for agents authoring DE voice SOUL/AGENTS or reviewing prompt rules. Canonical craft skill is `german-voice-prompts` (may be manually locked — apply there when editable).

## Rule
Do **not** instruct "alle Zahlen als Wörter".

| Type | How to speak | Example |
|------|----------------|---------|
| Preise, Mengen, Jahre, % | Zahlwort | 49 € → neunundvierzig Euro |
| PLZ, Telefon, Hausnr., IDs | Zifferngruppen | 04335 → null vier drei drei fünf |

## Why
Sim R2 on #8783: absolute Zahlwort-Fix dropped naturalness ~1.0 (PLZ read as one huge number-word).

## globalNode snippet
```
Zahlen-Nuance:
- Preise, Mengen, Jahre, Prozent → Zahlwort.
- PLZ, Telefon, Hausnummer, IDs → Zifferngruppen, nie eine große Zahl.
```
