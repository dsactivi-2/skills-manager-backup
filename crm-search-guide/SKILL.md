---
name: crm-search-guide
description: >-
  Regelwerk für korrekte Kandidaten-Queries gegen den CRM-MCP-Server "crm-mysql"
  (Cloudflare Worker → Hyperdrive → Aiven MySQL, read-only). IMMER zuerst laden,
  bevor Kandidaten gesucht oder gezählt werden — bei jeder Frage nach Kandidaten,
  Bewerbern, Lebensläufen, Berufsfiltern, Sprachniveaus, Alter, EU-Bürgern oder
  Archiv-Status. Erzwingt: Archiv raus (Default), resolve_beruf vor der Suche,
  EXISTS/DISTINCT bei Multi-Joins, Sprach-Mapping (Deutsch = Njemački).
  NICHT für Schema-Erkundung (crm-mcp-explorer) oder Firmen/Nalozi/freie SQL
  (crm-mcp-queries).
---

# CRM Search Guide — Pflicht-Regeln für Kandidaten-Queries

Backend: MCP-Server `crm-mysql` auf
`https://crm-pipedrive-worker.6f484zn9bd.workers.dev/mcp`
(Cloudflare Worker → Hyperdrive → Aiven MySQL, Schema `defaultdb`, read-only).
Auth: Bearer `WORKER_API_KEY` (Header) oder `?token=` (URL).

## Ablauf bei JEDER Kandidatenfrage

1. **Diesen Guide anwenden** (bzw. Tool `crm_search_guide` aufrufen, wenn Unsicherheit über Details besteht).
2. **Zählen/Report für einen Beruf?** → **`crm_beruf_report`** mit allen Begriffen als Array in EINEM Call (liefert eindeutige Zahl + Gruppen + Top-Positionen + Deutsch-Hören). Nicht 10× resolve_beruf + 5× crm_query nacheinander schicken.
3. **Beruf auflösen (nur bei unbekannten Schreibweisen):** `crm_resolve_beruf(<begriff>)` → häufigste tatsächliche Schreibweisen von `kri_pozicija` (meist bosnisch, z.B. "Električar"). NIEMALS den deutschen Begriff direkt als `position_text` raten.
4. **Trefferlisten:** `crm_search_kandidaten(...)` mit den aufgelösten Filtern (Cap 200 — nicht für Vollzählungen).
5. **Profile:** `crm_kandidat_profile(kandidat_id)` für interessante Treffer.
6. **Scope in der Antwort nennen:** Archiv ein-/ausgeschlossen? Sprachniveau = Minimum? Altersbasis = heute?

## Die 6 Pflicht-Regeln

1. **Archiv raus (Default).** `kandidat_status = 3` heißt archiviert und wird standardmäßig ausgeschlossen. Nur mit explizitem `archived: true` einbeziehen — und das in der Antwort sagen.
2. **resolve_beruf vor Count/Search.** Berufsfreiexte zuerst über `crm_resolve_beruf` prüfen; der tatsächliche Datenbestand entscheidet, nicht die deutsche Übersetzung. Ausnahme: bekannte Begriffsmengen gehen direkt als Array in `crm_beruf_report`.
3. **Sprach-Mapping.** "Deutsch" heißt in den Daten `Njemački` — der Server mappt deutsch/german automatisch, bei freiem SQL (`crm_query`) selbst mappen. `sprachniveau_min` prüft NUR das Hören (`kj_slusanje`), wie der CRM-Filter. "B1" = B1, B2, C1 oder C2 (Minimum, nicht exakt).
4. **EXISTS statt JOIN-Vervielfachung.** Bei Filtern über Berufserfahrung/Sprachen `EXISTS`-Subqueries verwenden, damit Kandidaten nicht mehrfach gezählt werden.
5. **DISTINCT beim Zählen.** Counts immer über `COUNT(DISTINCT kandidat_id)` bzw. deduplizierte Treffer — nie Zeilen der Join-Tabelle zählen.
6. **Alter exakt.** Vollendete Jahre per `TIMESTAMPDIFF(YEAR, kandidat_datumrodjenja, CURRENT_DATE)` — kein gerundetes Alter.

## Weitere Filter-Fakten

- **Keine Mapping-Tabelle:** Es gibt KEINE `beruf_mapping`-Tabelle auf dieser DB. `position_text` / `berufsgruppe_id` sind LIKE-Filter auf den Freitext `kri_pozicija` in `idk_kandidat_radno_iskustvo`.
- **EU-Bürger:** `eu_buerger: true` filtert auf Staatsbürgerschaft-Typ `EU%`.
- **Limit:** Default 50, Cap 200. Bei großen Treffermengen Filter schärfen statt Limit erhöhen.

## Typische Nutzerfragen → Calls

- "Elektriker mit Deutsch B2, 30–50 Jahre" → `crm_resolve_beruf("Elektriker")` → `crm_search_kandidaten(position_text: "Elektri", sprache: "Deutsch", sprachniveau_min: "B2", alter_von: 30, alter_bis: 50)`
- "Wie viele Bauarbeiter haben wir, wie ist deren Deutsch?" → `crm_beruf_report(begriffe: ["građev","gradev","gradjev"])` — ein Call liefert Zahl + Gruppen + Top-Positionen + Deutsch-Hören
- "Profil von Kandidat 4711" → `crm_kandidat_profile(kandidat_id: 4711)`
- "Alle Schweißer, auch archivierte" → `crm_search_kandidaten(position_text: "Schweiß", archived: true)`
- "Wie viele Kandidaten gibt es?" → `crm_stats`

## Transport-Regel (wichtig!)

Fehlen die `crm_*`-Tools in der Session → **Session/Client neu starten** (MCP-Configs werden nur beim Start gelesen), statt den Worker per rohem HTTP nachzubauen. Der Verbindungsaufbau per Hand (User-Agent-Falle, SSE-Parsing, Session-ID) hat in der Praxis 12+ Minuten gekostet; der geladene MCP-Client macht denselben Report in Sekunden.

## Häufige Fehler (vermeiden)

- Deutschen Berufsbegriff direkt als `position_text` schicken → leere Ergebnisse wegen bosnischer Schreibweisen. Erst `crm_resolve_beruf`.
- `sprachniveau_min: "B2"` als "exakt B2" lesen — falsch, es ist ein Minimum (B2 und besser).
- "0 Treffer" als "gibt es nicht" verkaufen, ohne Filter zu lockern oder `crm_resolve_beruf` zu prüfen.
- Counts über Join-Zeilen statt über deduplizierte Kandidaten → aufgeblähte Zahlen.

## Verwandte Skills

- `crm-mcp-suche` — kompletter Such-Workflow inkl. Profil-Abruf.
- `crm-mcp-queries` — Firmen, Nalozi, freie gehärtete SELECTs (`crm_query`).
- `crm-mcp-explorer` — Schema-Erkundung, 0-Treffer-Debugging, Health-Checks.
