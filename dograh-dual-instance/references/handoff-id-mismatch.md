# Handoff ID mismatch (Cloud vs voiceeu)

## Symptom
Builder reads handoff SoT #8783 / #8184 / #8829; `list_workflows` on voiceeu shows only low IDs (3–10) with different names. No DE Amina on voiceeu.

## Cause
Per-instance autoincrement IDs. Migration/copy creates new IDs. Handoff written against Cloud.

## Correct response
1. State discrepancy clearly; do not invent mapping.
2. Ask user: A migrate DE to voiceeu / B stay Cloud / C BS-only on voiceeu.
3. Until decided: no prompt patches on wrong world.
4. Update SESSION_RESUME with live IDs after decision.

## Activi snapshot (2026-07-28, illustrative)
| Cloud (api.dograh.com) | voiceeu |
|------------------------|---------|
| #8783 DE Amina | missing as such |
| #8184 BiH | name-similar copies ≠ same ID |
| #8829 Marge | #5/#9/#10 BS marge variants |
| — | #7 DE template only (not Amina prod) |
