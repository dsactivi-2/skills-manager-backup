---
name: n8n-livekit-campaign-orchestration
description: Use when n8n drives LiveKit outbound/inbound calls.
---

# n8n + LiveKit campaign orchestration

n8n is the traffic cop. LiveKit owns the conversation. Correlation is IDs, not "the current lead".

Overlaps `energy-warmup-session` (Energy WarmUP Akte). This skill is the class; that one is the project pointer. Prefer adopting/updating `energy-warmup-session` for Akte-specific IDs.

## Execution model (explain this first if the user asks "why several workflows")

n8n can run **many executions in parallel** and can put **several triggers on one canvas**.

What one **run** cannot do: start a call, wait minutes for LiveKit, then book the outcome in the same chain. Feedback arrives later via webhook. Wiring dispatch → outcome in one run invents the result or never sees it.

Split by **when something happens**, not by node count:

1. Import (sheet → queue table)
2. Dispatcher (JWT + CreateDispatch + CreateSIP, then **stop**)
3. Agent tools / result webhooks (`get-kunde`, `call-result`)
4. LiveKit events (`room_finished` → free slot → **new** dispatcher run; inbound joined)
5. Error workflow (almost always its own published workflow)

Five **starts**. One canvas with islands is valid. Five workflow files is the cleaner default. Never a cable from call-start to call-end.

If the user prefers one file after this explanation, build one canvas with disconnected islands. Do not re-argue five files.

Dispatcher **cron** is a wake, not the call clock and not sheet import. Hangup (`room_finished` → new dispatcher run) is the chain. Cron exists so the **first** call of the window starts when nobody has hung up yet, and as backup if an event is lost. Hourly cron ≠ one call per hour. Import sheet → queue is a **different** workflow. Spell this out when the user opens the Schedule node. See `references/dispatcher-wake-vs-hangup.md`.

## Correlation (4 parallel calls)

Every call has `kundenId` + `callId`/`roomName` (+ `phoneE164` for inbound). Store them on the lead row at dispatch. Every webhook must carry at least one of those IDs. Lookup that row only. Never "last lead in queue".

Room name should contain `kundenId` (plus unique suffix). Reject `call-result` if IDs do not match the row.

## LiveKit REST from n8n

No native LiveKit node. Use HTTP Request.

- Convert `wss://…livekit.cloud` → `https://…livekit.cloud` for REST. Websocket URL is not a credential.
- LiveKit wants `Authorization: Bearer <JWT>`, not the raw API key.
- JWT: HS256, `iss` = API key, HMAC with API secret, short TTL, grants `roomAdmin`/`roomCreate` + SIP admin. Prefer n8n **JWT node** + Set (`token` → `livekitJwt`); Room string **once**. Code-Node `require('crypto')` is **disallowed** on n8n-lk (Energy F2 Exec 117).
- Store key+secret in **Custom Auth** (`httpCustomAuth`), JSON shape `{"json":{"apiKey":"…","apiSecret":"…"}}`. **Code v2 cannot bind that type** — MCP `setNodeCredential` rejects it; `this.getCredentials('httpCustomAuth')` throws „fehlt oder nicht lesbar“ even when the credential exists. Sign with the **JWT node** + `jwtAuth`. `iss` (API key) belongs in JWT **claims** in the UI, never in chat or a Code node. Do not put keys in Header Auth as a static Bearer or in node text. See `references/claim-rollback-and-code-auth.md`.
- n8n **Variables** (`$vars`) are often Community/upgrade-locked. Put the https URL in a Config Set node or the HTTP URL field.
- Mandatory LiveKit paths: (1) webhooks in, (3) Dispatch+SIP out, (4) agent HTTP tools. Skip MCP-in-call, RPC, Egress unless asked.
- SIP twirp is `/twirp/livekit.SIP/CreateSIPParticipant` (docs: SIP APIs). Not `livekit.SIPService`. Keep the n8n **expression** that prefixes Config `livekitHttpUrl`; do not replace it with a hardcoded `https://…` in the node.
- Verify the path without placing a call: POST `{}` with no JWT. Twirp `access key is not found` means host+path exist. Browser GET is empty and is not a test. Do not Execute the dispatcher node.
- SIP fail branch: Wait 5s/15s → **second** CreateSIPParticipant HTTP node → success N10 / fail Lücke. Do not cable Wait straight to Lücke. Do not loop Wait→first SIP (infinite). See `references/sip-retry-and-twirp.md`.

## Credentials (self-hosted n8n)

MCP cannot create credentials. User creates them in the UI.

Google Sheets/Calendar/Gmail OAuth on self-host: OAuth client type **Web application**. Redirect URI exactly `{n8n-origin}/rest/oauth2-credential/callback`. Authorized JavaScript origins empty. Same Client ID/Secret for Sheets, Calendar, Gmail if those APIs are enabled. Consent **External** + Testing + test user for private Gmail; **Internal** blocks non-org accounts.

Webhook auth: Header Auth credential, then bind on the trigger. Do not leave production webhooks on `authentication: none`.

Header Auth is **Credentials** in the n8n UI, not a workflow node. MCP cannot create it. Tell the user the menu path, never a checklist code alone ("A5").

Mint a **new** secret (`openssl rand -hex 32`). Do not reuse LiveKit API key, Google OAuth, n8n API, SIP password, or Sheet ID. Paste only into the credential Value. Do not post it in chat, nodes, or the lead sheet. Bind on result/event webhooks later (go-live C), not in the same step as creating the credential.

## Draft vs publish

`create_workflow_from_code` = inactive draft. `publish_workflow` is separate. Do not publish campaign flows without explicit Freigabe.

`setWorkflowSettings.errorWorkflow` is rejected unless the target is **published** and has an Error Trigger. Publish the error workflow only (not the campaign) if the user asked to finish error wiring without publishing the rest.

Set campaign timezone on workflow settings (e.g. `Europe/Berlin`).

## Go-live sequence (open work)

When listing what is still open, sort — do not dump HANDOVER order.

A. User fills node values (no real call without these): sheet, LiveKit https URL + agent + SIP trunk, calendars, alert-to, Header Auth credential in the UI (MCP cannot create credentials).
B. Graph on the **draft** (no publish): JWT `sip.call` grant, SIP path `livekit.SIP/CreateSIPParticipant` not a guessed `SIPService`, fail-branch second SIP after wait, outbound slot count, call window, import dedup/cap, `executeWorkflow` mode `once`|`each` (not `all`), inbound busy, Hold/VM as a **new run** not the same chain.
C. Bind Header Auth on result/event webhooks (after A).
D. Unpublish any leftover error workflow with 0 triggers before the real error workflow goes live.
E. Publish error workflow (Freigabe).
F. Publish campaign flows (Freigabe). Leave the old monolith unpublished.
G. After publish: put the webhook URLs on the agent + LiveKit events. Verify with **POST** (no key → 403 if Header-Auth). Browser GET 404 is not unpublished. Prod URLs do not exist before publish.

User asks for a list they can check off: write an `.xlsx` to `~/Downloads/` with Status dropdown `offen`/`erledigt` in that A–G order, and keep the repo TODO file in the same order. Do not invent a second source of truth.

## Parallel cap (outbound slots)

Do **not** add "count calling < N" as another condition on the lead IF. A Data Table `get` of `status=calling` emits one item per row and would fan the dispatcher.

Pattern: `get` filter `calling`, `returnAll: true`, `alwaysOutputData: true` (so 0 rows still continue) → Set `executeOnce` with `callingCount` from `$('Count').all().filter(…status==='calling').length` → IF uses `$json.callingCount` plus the lead fields via `$('N07…')`. One run, one call attempt.

## Values the user must type vs MCP

If MCP can set the node (sheet ID, SIP URL expression, cron rules, calendar name), **set it**. Do not send the user into the field. User-only: credentials MCP cannot create (Header Auth, OAuth sign-in), and Execute/Test which would place a real call — never ask them to press those on an unpublished dispatcher.

When the user asks which node: answer **workflow name + node name** first (e.g. Energy F1 / N01.1 Quelle Sheet). Never a checklist code alone (A5).

When they say finish everything you can without them: do remaining **unpublished** graph (B + bind Header C) in one pass. Do not drip "sag weiter" per B item. Still no publish, no LiveKit tool-save, no Execute.

Google Calendar on some n8n builds: `parameters.calendar` validates as a **string** (name or `={{ art === 'human' ? 'Human cal' : 'AI cal' }}`), not an RLC object. Existing nodes may already be objects and warn pre-existing; new nodes use the string form.

Booking tools (`get-termine` / `book-termin`) are **disconnected islands** on the result workflow. Unpublished Prod-POST = 404 — do not save LiveKit HTTP tools yet. After F3 publish: POST without header = 403 = save tools (secret template, no Content-Type). Builder click-path: `n8n-livekit-outbound` `references/builder-http-tools.md`.

## MCP `update_workflow` gotchas

- `addConnection`: `source` and `target` are **node name strings**, not objects. Error output of a node with `onError: continueErrorOutput` is `main[1]`; pass `sourceIndex`/`outputIndex` `1` so you do not steal `main[0]`. Verify connections after.
- `addTags` wants `names`, not `tags`.
- SDK: no `function` declarations in workflow code. `switchCase` uses `.onCase(0, …)` not `.output('key', …)`. `executeWorkflow` `mode` is `each` | `once` (not `all` on some versions).
- After `addNode`, MCP often parks new nodes at `[0,0]` (stacked). `setNodePosition` per island left-to-right. Do not leave the user to drag. Skill `n8n-workflow-lifecycle-official` saying SDK positions are ignored applies to create-from-code, not to `setNodePosition`.

## Google Sheets nodes

Never invent a spreadsheet ID. Empty `documentId` `{ __rl: true, mode: 'list', value: '', cachedResultName: 'PASTE_SHEET' }` until the user picks the sheet. Tab by `mode: 'name'` if only the tab title is known.

E.164: Sheets turns a leading `+` into a formula (`=+49…`) and strips the plus in the cell. "Plain text" after the fact does not fix it. Visible apostrophe (`'+49…`) is invalid for import (does not start with `+`). Working cell: formula `="+491…"` so the cell *and* the import see `+491…`. Alternative: `0049…` if the importer normalizes to `+49`.

Column mapping: read `kundenId` **and** `kunden_id` / `KundenID` / `id`. Header `kundenId` is what users type in Sheets; snake_case-only mapping drops the ID.

## Do not import

YouTube/n8n "MCP Server Trigger + Google Sheets tools" restaurant gists are not LiveKit telephony.

## Pitfalls

- **Claim lock:** if the dispatcher updates `queued` → `claiming` (or similar) before SIP, the next get-filter on `queued` will skip that row. Rollback on „no lead / rules false” is not enough — every later fallible node (room-build, JWT, Dispatch) needs `onError: continueErrorOutput` and `main[1]` → rollback-to-queued. Import does not reset `claiming`. Report queue as **status counts**, not table row count. Do not treat “table has rows” as “F2 will call”. Wiring: `references/claim-rollback-and-code-auth.md`.
- **Inbound flag ≠ match.** A Set node `direction=inbound` on `participant_joined` does not look up `phoneE164` and does not reserve the inbound slot. Phone-match inbound is a Data Table get, not an event ACK.
- File/PDF reviews of exports are not live. Re-check `get_workflow_details` (sheet tab, Config trunk/agent, disabled calendar nodes), recent executions (ms-success = no SIP), and agent code (HTTP retry vs n8n `retryOnFail`) before accepting DONE/BLOCKED from an external write-up.
- Fan-out on one canvas is sequential (Y-position), not parallel. Four live calls = four dispatcher **runs**.
- Per-node error outputs that swallow errors will **not** fire the error workflow.
- HTTP `retryOnFail` is not a substitute for a wired fail branch to a luecke state.
- Data Tables: do not declare `id` / `createdAt` / `updatedAt`. Primitives only. `projectId` required on create/add column. **Upsert writes only mapped columns** (n8n docs / MCP `n8n-docs`). Import that maps `attemptsToday: 0` zeros live counters — omit counters unless the row is empty/`queued`.
- AI-Rückruf ist **G9** (`termin_start` → dispatcher), extra Ja. Kein zweiter Workflow „F6“, keine `termin_retries_*` ohne Produkt-Ja. `attemptsToday` = max 2/Tag nur `keine_antwort`, nicht Termin-Retries.
- Token refresh for n8n MCP: use the instance's public origin `/mcp-oauth/token`, not an internal/Contabo hostname from `.meta.json`.
- Wake vs hangup vs import: `references/dispatcher-wake-vs-hangup.md`.
- SIP path + retry: `references/sip-retry-and-twirp.md`.
- Session may list the MCP as configured while `search_workflows` is not in the tool catalog. Do not query a different n8n (voice-ops-console, `N8N_API_KEY`/`N8N_API_URL`). Refresh the token, then JSON-RPC `search_workflows` against that instance's `/mcp-server/http`. Recipe: `n8n-plan-route-audit` `references/n8n-lk-oauth-refresh.md`. `/reload-mcp` is optional for read-only discovery.
