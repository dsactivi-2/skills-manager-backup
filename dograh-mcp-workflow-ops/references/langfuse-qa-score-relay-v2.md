# Langfuse post-call QA score relay v2 (voiceeu)

Contract when Dograh post-call QA must land scores on the **existing** Langfuse
conversation trace (project **DograhEU**). Umbrella skill: `dograh-langfuse-call-scores`.

## Production endpoint (Activi, live)

| | |
|--|--|
| Webhook | `https://dsactivi-2--dograh-lf-scores.modal.run` |
| Health | `https://dsactivi-2--dograh-lf-scores-health.modal.run` |
| Schema | `aquaphor-langfuse-relay-v2-qa-tags` |
| Logic | `dograh-aquaphor-telesales/scripts/langfuse_score_relay_v2.py` |
| Modal deploy | `…/scripts/modal_langfuse_relay.py` + secret `langfuse-dograheu` |

n8n `https://n8n-mm.activi-apps.io/webhook/aquaphor-langfuse-scores` may return
`{"message":"Workflow was started"}` (HTTP 200) **without** writing Langfuse scores.
Do not treat that as success. Prefer Modal relay.

## Publish Dograh draft

```http
POST https://voiceeu.activi.io/api/v1/workflow/{id}/publish
X-API-Key: <MCP_DOGRAH_VOICEEU_API_KEY>
Content-Type: application/json

{}
```

- MCP `save_workflow` = **draft only** (no publish tool).
- Versions: `GET /api/v1/workflow/{id}/versions`
- `"No draft to publish"` ⇒ already published or no draft row.

## Trace linkage (do not invent OTel IDs)

Dograh/Pipecat creates the Langfuse trace via OpenTelemetry.

Webhook fields:
- `session_id` / `conversation_id` / `workflow_run_id` (same run id)
- `langfuse_trace_id` = `{{initial_context.langfuse_trace_id}}` (often empty)
- `user_id` = zoho_lead_id (optional)
- `qa_annotations` = `{{annotations}}`
- optional `annotation_queue_id`, `dataset_name`
- `schema_version`: `aquaphor-langfuse-relay-v2-qa-tags`
- Lookup: `metadata.attributes.conversation.id` == run id; attach scores; never new trace.
- OTel `sessionId`/`userId` on trace often null — normal.

## Langfuse POST /api/public/scores (verified pitfalls)

1. Exactly **one** of `traceId` | `sessionId` | `datasetRunId`.
   Sending `traceId` **and** `sessionId` → **400**.
2. Join keys → score **`metadata`** (not dual sessionId with traceId).
3. BOOLEAN `value` = number **0 or 1** only (not true/false).
4. CATEGORICAL: string; NUMERIC: number not `"8"`.
5. Idempotency: `id = "{traceId}-{name}"`.
6. Prefer `"environment": "production"` on the score body.
7. Annotation queue **create** requires `scoreConfigIds: string[]`.

## QA JSON + 12 scores

See `dograh-langfuse-call-scores`. Emit all 10 `tag_*` every call (0 if absent).

## Decision lock

A = SoT. B async `eval_*` later with other names. C no while Cekura needs annotations.

## TS assembly

`json.dumps(prompt)` + `re.sub(pat, lambda m: block, src)` — never plain string repl.

## Verify

1. Published WF webhook = Modal URL.
2. CLI/HTTP demo on known conversation.id → 12 scores on trace.
3. Real test call after hangup.

## Artifacts

- `dograh-aquaphor-telesales/voiceeu/wf22_pas_langfuse_qa_draft.ts`
- `dograh-aquaphor-telesales/voiceeu/WF22_LANGFUSE_METRICS.md`
- `dograh-aquaphor-telesales/scripts/langfuse_score_relay_v2.py`
- `dograh-aquaphor-telesales/scripts/modal_langfuse_relay.py`
