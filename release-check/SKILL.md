---
name: release-check
description: Prüft einen geplanten Release vor der Veröffentlichung und dokumentiert offene Risiken.
---

# Release Check

## Ziel

Stelle vor einem Release fest, ob die relevante Validierung erfolgreich war
und ob ein sicherer Rückweg bekannt ist. Diese Skill veröffentlicht nichts.

## Ablauf

1. Lies die Projektregeln und das passende Release- oder Deployment-Runbook.
2. Prüfe den aktuellen Änderungsumfang und nenne fremde oder unklare Änderungen.
3. Führe die kleinsten relevanten Tests, Lint- und Build-Prüfungen aus.
4. Prüfe, ob Versionsstand, Änderungsnotizen und Rücknahmeweg bekannt sind.
5. Berichte: bestanden, fehlende Prüfungen, Risiken und den nächsten sicheren
   Schritt.

## Stop-Regeln

- Keine Veröffentlichung, keine Tags und keine externen Änderungen ausführen.
- Bei fehlendem Rücknahmeweg, fehlgeschlagener Prüfung oder unklarem Umfang
  anhalten und den Grund nennen.
