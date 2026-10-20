# Claim rollback + LiveKit auth (Code vs JWT)

Verified n8n-lk 2026-09-03. No secrets in this file.

## Claim lock

Dispatcher pattern: get `status=queued` → update that row to `claiming` → window/cap/JWT/Dispatch/SIP.

If the run dies **after** the update and **before** `calling` or rollback-to-`queued`, the lead is invisible to the next cron. F1 upsert that only writes `queued` for “anrufbar” paths will not clear `claiming`.

Rollback on “no lead” / “rules false” does not cover room-build or JWT throws. Wire those nodes:

1. `setNodeSettings` `onError: continueErrorOutput`
2. `addConnection` source = that node, target = rollback update, `sourceIndex: 1` (`main[1]`)

Unhandled crash also fires the workflow-level error workflow; handled error-output usually does not. Stuck rows from **old** runs stay `claiming` until someone sets `queued` in the table — graph fix is not retroactive.

Do not Execute the dispatcher to test this.

## Code node cannot read Custom Auth

LiveKit keys live in `httpCustomAuth` JSON `{ "json": { "apiKey", "apiSecret" } }`.

Code v2 has **no credential slot** for that type. `setNodeCredential` → `node type 'n8n-nodes-base.code' does not accept credential 'httpCustomAuth'`. Unbound `getCredentials('httpCustomAuth')` throws (Energy F2 Exec 150, ~0.2 s, after a successful claim).

Working split:

- **JWT node** + credential type `jwtAuth` = HMAC (API secret)
- **Claims `iss`** = API key, set in the JWT node in the UI (not chat, not Code)
- HTTP Dispatch/SIP: `Authorization: Bearer` from the JWT node output, not raw API key
