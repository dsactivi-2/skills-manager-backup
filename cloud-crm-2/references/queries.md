---
name: crm-mcp-queries
description: Firmen und Aufträge (Nalozi) im CRM über MCP crm-remote (Worker-Name crm-mysql) suchen sowie freie, gehärtete SELECT-Queries stellen. Nutzen bei Fragen nach Firmen/Kunden ("welche Firmen aus Deutschland"), Aufträgen/Stellenangeboten ("offene Nalozi für Pflege"), Statistiken ("wie viele Kandidaten") oder wenn die vorgefertigten Filter nicht reichen und eine eigene SELECT-Query nötig ist. Für reine Kandidaten-Suche → crm-mcp-suche; für Schema-Erkundung → crm-mcp-explorer.
---

# CRM-Queries über MCP crm-remote

## Server

MCP-Server `crm-remote` (Worker-Name crm-mysql) auf `https://crm-pipedrive-worker.6f484zn9bd.workers.dev/mcp`, read-only. Auth: Bearer `WORKER_API_KEY` (Umstellung auf Cloudflare Access geplant).

## Tools

| Tool | Zweck |
|---|---|
| `mcp__crm_remote__crm_stats` | Gesamtzahlen: Kandidaten (gesamt/aktiv/archiviert), Firmen, Nalozi |
| `mcp__crm_remote__crm_search_companies` | Firmen suchen: `q` (Name LIKE), `country` (exakt), `status`, `limit` |
| `mcp__crm_remote__crm_search_nalozi` | Aufträge suchen: `q` (Titel/Beschreibung LIKE), `status`, `limit` |
| `mcp__crm_remote__crm_query` | Freie SELECT-Query, gehärtet (siehe unten) |
| `mcp__crm_remote__crm_search_guide` | Regelwerk — bei komplexen Queries ZUERST lesen |

## Härtung von `mcp__crm_remote__crm_query`

- Nur `SELECT` (kein INSERT/UPDATE/DDL).
- Nur Tabellen `idk_*`, `beruf_mapping`, `information_schema`.
- LIMIT wird auf 200 gecappt bzw. automatisch ergänzt.
- Verbotene Schlüsselwörter werden abgelehnt → bei Fehlermeldung Query vereinfachen statt tricksen.

## MySQL-Syntax-Regeln für diese DB

- Kein `::text`-Cast → `CAST(x AS CHAR)`.
- `LIKE` statt `ILIKE` (LIKE ist hier case-insensitiv genug; sonst `LOWER()`).
- `?`-Platzhalter nur über die vorgefertigten Tools; in `mcp__crm_remote__crm_query` Werte direkt einsetzen, aber Strings quoten.
- Zeiträume: `TIMESTAMPDIFF(YEAR, ...)` für Alter, `CURRENT_DATE` für heute.

## CRM-Fachlogik, die in Queries eingehalten werden muss

- **Archiv:** `idk_kandidati.kandidat_status = 3` = archiviert → in Auswertungen ausschließen, außer explizit gewünscht.
- **Sprachen:** 1:n über `idk_kandidat_jezici` (`kj_kandidatid` → `kandidat_id`), Niveau-Spalte `kj_slusanje` (Hören), Sprache "Deutsch" = `Njemački`. Bei Joins auf 1:n-Tabellen: `EXISTS` oder `COUNT(DISTINCT kandidat_id)` verwenden, sonst Duplikate.
- **Berufserfahrung:** `idk_kandidat_radno_iskustvo` (`kri_kandidat_id` → `kandidat_id`), Freitext-Position in `kri_pozicija`.
- **Firmen/Aufträge:** `idk_companies` (company_id, company_name, company_country, company_status), `idk_nalozi` (nalog_id, nalog_naslov, nalog_opis, nalog_status).

## Typische Nutzerfragen → Calls

- "Wie viele Kandidaten/Firmen/Aufträge haben wir?" → `mcp__crm_remote__crm_stats`
- "Firmen aus Deutschland" → `crm_search_companies(country: "Deutschland")` — bei 0 Treffern `country` mit LIKE-Varianten über `mcp__crm_remote__crm_query` prüfen.
- "Offene Aufträge für Pflege" → `crm_search_nalozi(q: "Pflege")`, Status-Spalte im Ergebnis lesen.
- "Top 10 Berufe nach Anzahl Kandidaten" → `mcp__crm_remote__crm_query`: `SELECT kri_pozicija, COUNT(DISTINCT kri_kandidat_id) AS n FROM idk_kandidat_radno_iskustvo GROUP BY kri_pozicija ORDER BY n DESC LIMIT 10`

## Häufige Fehler

- Duplikate durch 1:n-Joins ohne `DISTINCT`/`EXISTS`.
- Archivierte Kandidaten in Zählungen vergessen auszuschließen.
- Bei "0 Treffer" auf Firmen/Nalozi sofort "gibt es nicht" sagen — erst mit breiterem `q` oder `mcp__crm_remote__crm_query` gegen die Rohdaten gegenprüfen.

---

In Codex heißt der Server **crm-remote** (Worker-Name crm-mysql). Dieselbe Tool-Liste. Nicht crm-suche-2 / Neon.

Codex-Tools haben den Prefix mcp__crm_remote__. Nie mcp__crm_suche_2__.
