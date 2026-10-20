# Inbound + SMS (einfach)

## Inbound (Frage „Mobile-to-IP wohin?“)

Nur der **TG400** mit den SIMs. Nicht das private Handy.

- Inbound = jemand ruft die **SIM-Nummer im TG** an.
- Mobile-to-IP = TG schickt den Anruf per SIP zur PBX.
- Wohin = welcher SIP-Trunk (FreePBX), erst nach Trunk.
- Ziel-Agent: Dograh-Workflow (ID nicht raten, bis der WF existiert).
- Call Control / Always Forward **aus**, sonst kommt der Anruf nie bei Dograh an.

Kette: SIM → TG Mobile-to-IP → PBX → Stasis → Dograh-WF.

## SMS

Nicht über FreePBX (SMS-Plus Commercial weg).

| | |
|---|---|
| Senden | E-Mail **und** API |
| Mail an | `sms@activi.io` |
| Mail von | `noreply@activi.io` (SMTP am TG, Werte fehlen) |
| API | n8n Webhook, URL in `~/.hermes/secrets/tg400-sms-n8n.env` |

Jargon in einer Zeile erklären, dann Tabelle. Nicht Register/Peer/ARI ohne Satz „was das für den Kasten heißt“.
