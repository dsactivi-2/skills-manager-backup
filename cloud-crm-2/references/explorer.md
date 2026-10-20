---
name: crm-mcp-explorer
description: Schema und Inhalte der CRM-Datenbank über MCP crm-remote (Worker-Name crm-mysql) erkunden. Nutzen, wenn der Nutzer wissen will, welche Tabellen/Spalten es gibt, wie Tabellen zusammenhängen, was ein Feld bedeutet, oder wenn eine Suche unerwartet 0 Treffer liefert und man die tatsächlichen Schreibweisen der Daten prüfen muss. Auch für Gesundheitschecks ("läuft der Worker?", "sind Daten da?"). Für Kandidaten-Suche → crm-mcp-suche; für fertige Auswertungen → crm-mcp-queries.
---

# CRM-Explorer über MCP crm-remote

## Server & Gesundheitscheck

MCP-Server `crm-remote` (Worker-Name crm-mysql), URL `https://crm-pipedrive-worker.6f484zn9bd.workers.dev/mcp`.
- Offener Health-Endpoint (ohne Auth): `GET https://crm-pipedrive-worker.6f484zn9bd.workers.dev/health` → `{ok: true}`.
- Bei 401/403: Auth-Problem (Bearer-Key bzw. ab Umstellung Cloudflare Access), NICHT Datenbank-Problem.
- Bei Timeouts/5xx: Worker-Logs mit `npx wrangler tail` im Ordner `crm-pipedrive-worker` prüfen (im Projektordner `MacSetup & konfig`).

## Tools

| Tool | Zweck |
|---|---|
| `mcp__crm_remote__crm_list_tables` | Alle `idk_*`-Tabellen mit ungefährer Zeilenzahl; `search`-Filter, z.B. `search: "kandidat"` |
| `mcp__crm_remote__crm_describe_table` | Spalten einer Tabelle (Name, Typ, Nullable, Key) |
| `mcp__crm_remote__crm_stats` | Schnelle Füllstandsanzeige (Kandidaten, Firmen, Nalozi) |
| `mcp__crm_remote__crm_query` | Freie SELECTs für Inhalts-Stichproben (gehärtet, nur idk_*/information_schema, LIMIT-Cap 200) |

## Erkundungs-Workflow

1. Überblick: `mcp__crm_remote__crm_list_tables` — ggf. mit `search` eingrenzen.
2. Tabelle verstehen: `crm_describe_table(table: "...")`.
3. Inhalt prüfen: `mcp__crm_remote__crm_query` mit kleiner Stichprobe, z.B. `SELECT DISTINCT spalte FROM tabelle LIMIT 50`.
4. Beziehungen: FK-Namensmuster — `kj_kandidatid`, `kri_kandidat_id`, `ke_kandidat_id` zeigen auf `idk_kandidati.kandidat_id`.

## Kernschema (bekannt, nicht neu erkunden)

- `idk_kandidati` — Kandidaten-Stammdaten. Wichtig: `kandidat_status = 3` = archiviert, `kandidat_datumrodjenja` (Geburtsdatum), `kandidat_drzavljanstvo_vrsta` (Staatsbürgerschaft-Typ, "EU%"), `kandidat_group` → `idk_kandidati_grupe`.
- `idk_kandidat_jezici` — Sprachen 1:n: `kj_naziv` (Sprache; "Deutsch" = `Njemački`), `kj_slusanje`/`kj_citanje`/`kj_pisanje` (Niveaus A1–C2, auch "Bez znanja").
- `idk_kandidat_radno_iskustvo` — Berufserfahrung: `kri_pozicija` (Freitext-Position, oft bosnisch), `kri_darum_od`/`kri_datum_do`.
- `idk_kandidat_edukacija` — Ausbildung.
- `idk_companies` — Firmen; `idk_nalozi` — Aufträge/Stellen.
- KEINE Tabelle `beruf_mapping` auf dieser DB (existierte nur auf der alten/getrennten Instanz).

## Unerwartete 0-Treffer debuggen

1. `mcp__crm_remote__crm_stats` — sind überhaupt Daten da?
2. Schreibweise prüfen: `mcp__crm_remote__crm_query` mit `SELECT DISTINCT kj_naziv FROM idk_kandidat_jezici LIMIT 100` bzw. `SELECT kri_pozicija, COUNT(*) ... GROUP BY ...` für Berufe.
3. Filter zu eng? Archiv-Status? Niveau-Spalte richtig (`kj_slusanje` = Hören, wie CRM-Filter)?
4. Erst dann dem Nutzer "keine Treffer" melden — mit Angabe, was geprüft wurde.

## Häufige Fehler

- Annahme, Feldnamen lägen auf Deutsch/Englisch vor — sie sind bosnisch/slavisierend (z.B. `prezime` = Nachname).
- `beruf_mapping` referenzieren — gibt es auf dieser DB nicht.
- Bei 5xx dem Nutzer "Datenbank leer" melden — erst `wrangler tail` bzw. `/health` prüfen.

---

In Codex heißt der Server **crm-remote** (Worker-Name crm-mysql). Dieselbe Tool-Liste. Nicht crm-suche-2 / Neon.

Codex-Tools haben den Prefix mcp__crm_remote__. Nie mcp__crm_suche_2__.
