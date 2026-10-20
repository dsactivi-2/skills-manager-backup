---
name: n8n-livekit-outbound
description: "Use when wiring n8n to LiveKit outbound SIP."
version: 1.0.0
license: MIT
metadata:
  hermes:
    tags: [n8n, livekit, sip, jwt, telesales]
    related_skills: [livekit-telesales-outbound, voice-workflow-maps, eraser-workflow-maps]
---

# n8n ↔ LiveKit outbound

n8n orchestriert. LiveKit telefoniert. n8n spricht nicht.

Overlaps `voice-workflow-maps` (Karten N/R) and `livekit-telesales-outbound` (Agent-Build). This skill is the Verdrahtung layer.

## When to Use

User maps or builds outbound: Sheet/Queue → SIP → Ergebnis zurück → nächsten Call.

## Walkthrough (User-Korrektur)

- Frage ≠ Entscheidung. Nicht als Wahl speichern.
- Ein G/Punkt. Erst erklären, dann warten.
- Einfache Worte: JWT = Ticket, Webhook = Briefkasten, Data Table = n8n-Tabelle.

## Drei Bausteine (ohne die: kein Call)

1. **JWT** — `Authorization: Bearer <JWT>`, nicht API-Key-Header. Claims: `roomAdmin`/`roomCreate` + `sip.call`. Ohne: 401.
2. **Code-Node** — zwischen Lead und **zwei** HTTP-Nodes (`CreateDispatch`, `CreateSIPParticipant`). n8n Cloud oft ohne Extra-npm → Mini-Dialer `POST /dial`.
3. **Drei URLs, nicht eine** — `/webhook/get-kunde` (Lookup), `/webhook/call-result` (`save_result` = Geschäft), `/webhook/lk-events` (`participant_joined` / `room_finished` = Telefon). `room_finished` allein ist kein Outcome.

Anleitung: `/Users/activi/Downloads/livekit-n8n-call-trigger-ergebnis-anleitung.md`

## Folge-Call

Call-Ende → Slot frei → nächsten Queue-Lead (nicht denselben). Parallel-Limit separat.
Morgens braucht einen Fenster-auf-Trigger, sonst startet niemand.

Sheet-Takt = nur Nachschub neuer Zeilen, nicht der Folge-Call.

## SIP-Reihenfolge

Erst SIP wait-until-answered, dann Agent-Dispatch. `wait_for_participant` ≠ abgehoben.

## Config-Felder (F2 / Dispatcher)

| Feld | Eintragen | Nicht |
|---|---|---|
| LiveKit-URL | `https://<projekt>.livekit.cloud` ohne Slash | `wss://` (Websocket). Node darf wss→https ersetzen, ins Feld trotzdem https. |
| Agent-Name | Anzeigename (z.B. `Michaela`) | `CA_…` (das ist die Agent-ID). Bytegleich zum Builder. |
| SIP-Trunk | LiveKit-**Outbound**-ID `ST_…` | `sip:…sip.livekit.cloud` (URI) · PBX-Nebenstelle · Inbound-Adresse |

Kette vor `ST_…`: PBX-Endpoint (`ari.activi.io`) fertig → LiveKit Outbound-Trunk (Adresse = PBX) → ID nach n8n. PBX-ID nie ins n8n-Feld.

CreateDispatch: `room` setzen; `metadata` = **ein JSON-String** `kunden_id`, `phone`, `kampagne`, `room` (room zweimal). CreateSIP `room_name` = derselbe room. Roomname **vor** Dispatch wählen.

Unpublished n8n-Webhook = Prod-**POST** **404**. Browser-**GET** auf denselben Path ist immer 404 (kein Test). Nach Publish + Header-Auth: POST ohne Key = **403** = live. Builder-Tools erst dann speichern. Click-Felder: `references/builder-http-tools.md`.

## Kalender im Gespräch

Legen ≠ Melden. Data Collection kommt am Call-Ende. Termin während des Gesprächs = HTTP-Tools `get_termine` / `book_termin`. **n8n schreibt** Google; LiveKit fragt nur. Zwei Bücher (Human-Abschluss / AI-Rückruf), nicht mischen. Collector-Felder `required` lassen den Call enden sobald die Liste voll ist — optional halten. Tool-Wann in die **Feld**-Instructions, nicht ins Hauptprompt (sonst gierige Tool-Calls).

`room_finished` setzt kein Termin. `save_result` legt kein Event.

n8n Data Tables: kein timestamptz — ISO als **string**.

## Pitfalls

- N18 (nicht erreicht) ≠ Voicemail ≠ Human-Kalender.
- Ja = Human-Termin, kein Vertrag durch den Agent.
- N19 zurück über Queue/SIP/Call-ID, nicht direkt ins Gespräch.
- Secrets nur n8n Credentials, nicht Chat.
- `sip:…livekit.cloud` ist keine Trunk-ID.
- Agent-ID `CA_` ist kein `agent_name`.

## References

- `references/energy-warmup-v012.md` — Plan-IDs und Defaults dieses Produkts.
- `references/f2-config-ids.md` — URL / Agent-Name / `ST_` vs URI vs PBX.
- `references/builder-http-tools.md` — Agent-Builder HTTP-Tools, Secret-Klammer, GET-404, Call-ending-Pflicht.
