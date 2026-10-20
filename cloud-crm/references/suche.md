---
name: crm-mcp-suche
description: >-
  Kandidaten im CRM über MCP crm-remote (Worker-Name crm-mysql) (Cloudflare Worker → Aiven MySQL) suchen. Nutzen, wenn der Nutzer nach Kandidaten, Personen oder Lebensläufen fragt, Filter kombiniert (Beruf, Sprache, Niveau, Alter, EU-Bürger, Archiv) oder Profile zu einer Kandidaten-ID braucht — z.B. "such Elektriker mit Deutsch B1, 25-45 Jahre", "zeig Profil von Kandidat 12345". NICHT für Schema-Erkundung (dafür crm-mcp-explorer) oder freie SQL (dafür crm-mcp-queries).
---

# CRM-Kandidatensuche über MCP crm-remote

## Server

MCP-Server `crm-remote` (Worker-Name crm-mysql) auf `https://crm-pipedrive-worker.6f484zn9bd.workers.dev/mcp` (Cloudflare Worker → Hyperdrive → Aiven MySQL, read-only). Auth: aktuell Bearer `WORKER_API_KEY`; Umstellung auf Cloudflare Access geplant — bei 401/403 Auth-Status prüfen.

## Tools

| Tool | Zweck |
|---|---|
| `mcp__crm_remote__crm_search_guide` | Regelwerk — ZUERST lesen, wenn Unsicherheit über Filter-Semantik besteht |
| `mcp__crm_remote__crm_search_kandidaten` | Hauptsuche mit Filtern |
| `mcp__crm_remote__crm_kandidat_profile` | Vollprofil zu einer `kandidat_id` (Stammdaten, Sprachen, Berufserfahrung, Ausbildung) |
| `mcp__crm_remote__crm_resolve_beruf` | Häufigste Positions-Freitexte (`kri_pozicija`) erkunden → liefert gute `position_text`-Werte |

## Standard-Workflow

1. Unsicher, wie ein Filter gemeint ist (Archiv? Sprachniveau? Alter?) → `mcp__crm_remote__crm_search_guide` aufrufen.
2. Berufsbegriff frei übersetzen → `mcp__crm_remote__crm_resolve_beruf` mit dem Begriff, häufigste Schreibweisen wählen.
3. `mcp__crm_remote__crm_search_kandidaten` mit Filtern aufrufen.
4. Interessante Treffer → `mcp__crm_remote__crm_kandidat_profile` pro `kandidat_id`.
5. In der Antwort den Scope nennen: Archiv ausgeschlossen? Welches Sprachniveau? Altersbasis = heute.

## Filter-Semantik (DAS Wichtigste)

- **Archiv:** `kandidat_status = 3` = archiviert, standardmäßig AUSGESCHLOSSEN. Nur mit `archived: true` einbeziehen — und das dann in der Antwort sagen.
- **Beruf:** Es gibt KEINE Mapping-Tabelle auf dieser DB. `position_text` / `berufsgruppe_id` sind LIKE-Filter auf den Freitext `kri_pozicija`. Vorher mit `mcp__crm_remote__crm_resolve_beruf` prüfen, wie der Beruf tatsächlich geschrieben wird (oft bosnisch, z.B. "Električar").
- **Sprache:** "Deutsch" heißt in den Daten `Njemački` — der Server mappt deutsch/german automatisch. `sprachniveau_min` prüft NUR das Hören (`kj_slusanje`), wie der CRM-Filter. "B1" bedeutet B1, B2, C1 oder C2.
- **Alter:** Vollendete Jahre per `TIMESTAMPDIFF(YEAR, datumrodjenja, CURRENT_DATE)` — kein aufgerundetes Alter.
- **EU-Bürger:** `eu_buerger: true` filtert auf Staatsbürgerschaft-Typ `EU%`.
- **Limit:** Default 50, Cap 200. Bei großen Treffermengen Filter schärfen statt Limit erhöhen.

## Typische Nutzerfragen → Calls

- "Elektriker mit Deutsch B2, 30–50 Jahre" → `crm_resolve_beruf("Elektriker")` → `crm_search_kandidaten(position_text: "Elektri", sprache: "Deutsch", sprachniveau_min: "B2", alter_von: 30, alter_bis: 50)`
- "Profil von Kandidat 4711" → `crm_kandidat_profile(kandidat_id: 4711)`
- "Alle Schweißer, auch archivierte" → `crm_search_kandidaten(position_text: "Schweiß", archived: true)`
- "Wie viele Kandidaten gibt es?" → `mcp__crm_remote__crm_stats` (oder Skill crm-mcp-explorer)

## Häufige Fehler

- Beruf direkt als `position_text` raten, statt erst `mcp__crm_remote__crm_resolve_beruf` → leere Ergebnisse wegen bosnischer Schreibweisen.
- `sprachniveau_min: "B2"` erwarten, dass nur exakt B2 kommt — falsch, es ist ein Minimum (B2 und besser).
- Ergebnis "0 Treffer" als "gibt es nicht" verkaufen, ohne Filter zu lockern oder `mcp__crm_remote__crm_resolve_beruf` zu prüfen.

---

In Codex heißt der Server **crm-remote** (Worker-Name crm-mysql). Dieselbe Tool-Liste. Nicht crm-suche-2 / Neon.

Codex-Tools haben den Prefix mcp__crm_remote__. Nie mcp__crm_suche_2__.


## Schnelle Zaehlung (ein Roundtrip)

Nicht 10x crm_resolve_beruf. Fuer Vollzahlen: python3 scripts/beruf_report.py --preset bau

SQL: python3 scripts/beruf_report.py --preset bau --sql-only  dann ein crm_query.

crm_search_kandidaten hat Cap 200 und ist fuer Vollzahlen falsch.
