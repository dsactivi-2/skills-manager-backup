# Guard `create_workflow` SDK (verified 2026-08)

MCP: `dograh-guarddograh` → `create_workflow({ code })`. Success publishes **version 1** immediately (`created: true`, `workflow_id`, `node_count`, `edge_count`). Failures: `created: false` + `error_code` (`parse_error` | `validation_error` | …). Resubmit **full** source.

## Parser (live errors)

| Symptom | Cause | Fix |
|---|---|---|
| Only `wf.edge` allowed as a bare statement | `wf.addTyped(qa/trigger/webhook(...))` not assigned | `const qaNode = wf.addTyped(qa({...}))` |
| Same, later line numbers | QA/trigger/webhook **after** first `wf.edge` | All `addTyped` first, then edges |
| Unknown field `allow_interrupt` on globalNode/endCall | Field not in those specs | Drop it; keep on startCall/agentNode |

## Guard catalogs

`list_tools` / `list_documents` / `list_credentials` can return `[]`. Do not invent UUIDs. Put product facts in `globalNode` (Aquaphor prices only from a live WF, never invent Strom/Gas kWh).

## Call Memory (repo `dsactivi-2/activi-call-memory`)

Guard cannot send `x-webhook-token`. Use n8n-mm relays (no token):

- Pre-call: `POST https://n8n-mm.activi-apps.io/webhook/call-memory-pre-call` on `startCall` (`pre_call_fetch_mode: always`)
- Report: webhook `POST https://n8n-mm.activi-apps.io/webhook/call-memory-report`

Do not point Guard nodes at `*.supabase.co/functions/v1/*`. Repo Guard scope: WF1 Telesales BA + WF2 PAS — do not silently patch those or WF3/WF4/pre-main.

## Skeleton order

```
imports
new Workflow({ name })
const global = wf.addTyped(globalNode({...}))
const open = wf.addTyped(startCall({...}))
const … = wf.addTyped(agentNode/endCall/qa/trigger/webhook)
wf.edge(open, …)
```
