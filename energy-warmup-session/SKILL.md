---
name: energy-warmup-session
description: "Use when Energy WarmUP or n8n-lk. F1–F5 live; never F2 Execute; G9 extra Ja."
---

# Energy WarmUP — Session-Skill (dynamisch)

Kein Stand von „heute“. Keine feste Versionsnummer. Immer Dateien + Live-Tools lesen.

Projektroot (fest): `/Users/activi/WizGrok/workflow-livekit-n8n/`

## Wann

User arbeitet an Energy Lead WarmUP, n8n-lk, Eraser-Karte dieses Plans, Routen N/R, Inbound/Outbound LiveKit für **dieses** Repo.

## Session-Start (Pflicht, in dieser Reihenfolge)

1. `skill_view` dieses Skills.
2. Lesen: `PROJECT-MEMORY.md` im Projektroot.
3. Lesen: `HANDOVER.md` (letzter Zeiger — kann falsch/alt sein).
4. Lesen: `VERSIONING.md` → aktuelles Label. Nicht aus dem Chat raten.
5. Lesen: `INHALTSVERZEICHNIS.md` falls vorhanden, sonst `README.md`.
6. Skills laut Memory-Liste laden (n8n / Eraser / LiveKit-Docs), nicht raten welche fehlen.
7. **Live prüfen**, bevor du HANDOVER als Wahrheit nimmst:
   - n8n: MCP `n8n-livekit`, `search_workflows` Query `Energy F` und `MONOLITH`.
   - Arbeitsoffen: `phases/TODO-BUCHUNG-v016.md` + `phases/TODO-v015.md`. Spec: `phases/BUCHUNG-v016.md` + `phases/CHECKLISTE-N8N-LIVEKIT-v016.md`. Erledigt: `phases/ERLEDIGT-v015.md`.
   - Karte nur anfassen nach Snapshot `versions/vNNN/` (N = nächste freie aus VERSIONING).
8. Secrets nicht aus Memory zitieren. Nur Credential-Orte aus `PROJECT-MEMORY.md`.
9. Publish von F1–F4 nie ohne User-Freigabe wenn noch Entwurf. **Ist 2026-09-01: F1–F5 already published** — live MCP, nicht diese Zeile. F2 nie Execute.

Wenn MCP n8n-livekit tot: URL in Memory. Contabo-Hostname nicht verwenden. Token-Refresh über `https://n8n-lk.activi.io/mcp-oauth/token`. Nicht den API-Key von `N8N_API_URL` (oft andere Instanz).

## Dynamische Zeiger (nie hardcoden)

| Brauchst du | Lies live |
|---|---|
| Versionsname | `VERSIONING.md` letzte Arbeitszeile |
| Was der letzte Agent tat | `HANDOVER.md` Abschnitt „Letzter Stand“ |
| Nächste Bauarbeit | `HANDOVER.md` plus `phases/TODO-BUCHUNG-v016.md` + `phases/TODO-v015.md` |
| n8n-Ist | MCP live + `phases/IST-GRAPH-v015.md` (kann hinterherhinken) |
| Buchung SoT | `phases/BUCHUNG-v016.md` + `phases/CHECKLISTE-N8N-LIVEKIT-v016.md` |
| Auth | `phases/AUTH-REZEPT.md` — nicht Contabo, nicht Header-Auth für LiveKit |
| LiveKit-Kurzguides | Download-TXT nicht SoT (`ANLEITUNG-AUDIT`). Energy-Anleitungen: `phases/verbindungsoptionen/` |
| Knoten/Routen | `phases/KNOTEN.md` `phases/ROUTEN.md` |
| n8n Workflow-ID | MCP search, nicht eine ID aus einer alten Session |
| Slot-Zahlen, Sheet-Takt, TZ | `phases/N8N-VON-DIR.md` und G2/G12 |
| Was User liefern muss | `phases/N8N-VON-DIR.md` |

## Doku führen

- Logik/Karte: Phasen + ROUTEN + KNOTEN + VERSIONING + `versions/CHANGELOG.md`.
- n8n: nach struktureller Änderung Gap-Datei aktualisieren oder neu datieren.
- Final: nur neuen Ordner `final_last_<label>/` wenn User Final will. Alte Finals nicht löschen.
- Eraser: nur `mcp__eraser__*`. `manually_update_diagram` bei festen N/R-IDs.

## Session-Ende (Pflicht)

`HANDOVER.md` **überschreiben** in den zwei Blöcken „Letzter Stand“ und „Als Nächstes“:

- Datum
- Versions-Label aus VERSIONING (jetzt)
- n8n: Instanz-URL, Workflow-Name+ID nur wenn diese Session per Tool gesehen
- Was gebaut / geprüft / blockiert
- Nächster konkreter Block (nicht „weitermachen“)
- Offene User-Lieferungen
- Checkbox-Zeilen am Ende

Nicht: Secrets, Chat-Protokoll, Dateizählung als Wahrheit.

Stehende Regeln nur in `PROJECT-MEMORY.md` ändern, nicht ins Handover kopieren.

## Ist-Fallen (live prüfen, nicht aus Chat)

- F1–F5 können published sein; Monolith/G13 aus. HANDOVER-Checkbox „unpublish“ war tot.
- F1 Sheet kann verdrahtet sein und trotzdem 0 Leads: Google Sheets OAuth tot (Exec ~18 ms). F5 kann trotzdem starten und an Gmail sterben → keine Error-Mail.
- Reconnect privates Gmail: `phases/RECONNECT-GOOGLE-OAUTH.md`. Nur F1 Execute = Import. F2 Execute = Anruf.
- Privates Gmail + Testing-OAuth ist nicht dauerhaft. Workspace-Umstellung = User, dann drei Google-Credentials neu Sign-in.
- `energy_leads` leer ⇒ F2-Cron startet und bricht bei N07 ab. Kein Call.
- `interessiert` → Status `ai_termin`. F2 filtert `queued`. G9 Wecker **nicht gebaut** (extra Ja). N27/N19.2 disabled; Kalender nur `book_termin`.
- Langfuse: nein. `N8N_API_KEY` oft n8n-mm, nicht n8n-lk.
- Arbeitsoffen Production: `phases/TODO-PRODUCTION.md` (A vor 09:00, B nach Beweis).

## Verbote

- Zweite n8n-Kopie anlegen ohne User-Auftrag.
- Eine Versionsnummer oder Workflow-ID als ewig annehmen.
- G3 in n8n nachbauen.
- Vertrag durch den Agent.
- Keys in Nodes/Chat/Handover.
- n8n publish für echte Calls ohne User-Freigabe.

## Sprache

Deutsch, direkt, IDs N/R.
