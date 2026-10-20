# LiveKit: Ergebnis an eine URL

## Agent Builder (Call ending)

Feld: Summary and data collection endpoint URL. HTTP POST JSON:

`job_id`, `room_id`, `room`, `started_at`, `ended_at`, optional `summary`, optional `results` (nur Data Collection).

Optional Headers + Secrets. Data Collection kann den Call automatisch beenden, sobald Pflichtfelder voll sind.

## Cloud Webhooks

Events: `room_started`, `room_finished`, `participant_joined`, `participant_left`, tracks, egress/ingress.

Payload: Room/Participant. Kein Ja/Nein/Termin.

## Python Agents

`ctx.make_session_report()` im Prozess. Kein Cloud-URL-Feld. Für n8n selbst HTTP POST (wie `save_result`).

## Für Energy WarmUP

- Draht 2 (Bericht): Builder-URL oder gleicher POST-Body.
- G4 Disposition: `save_result` / `/webhook/call-result`.
- N36 Slot frei: `/webhook/lk-events` (`room_finished` / `participant_left`).
- Nicht eine URL für Tools und LiveKit-Events.
- Data Collection: Builder verlangt oft eine Call-ending-URL zum Speichern. Leer = Save blockiert. Kein Platzhalter. Dump auf `energy-call-result` + `X-Energy-Key`. Ideal-Summary-Webhook fehlt.
