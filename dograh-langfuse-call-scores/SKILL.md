---
name: dograh-langfuse-call-scores
description: "Use when Dograh QA must land Langfuse call scores."
version: 1.2.0
---

# Dograh → Langfuse call scores (quality path)

## When to use
Voiceeu/DograhEU post-call quality scoring, empty LF scores despite traces, A vs B vs C choice, WF PAS QA node, score relay deploy/fix.

Companion: `dograh-mcp-workflow-ops` (TS save/MCP), `dograh-dual-instance` (MCP routing), `langfuse` (CLI).

## Decision lock

| Option | Meaning | Do |
|--------|---------|-----|
| **A** Post-Call QA + Score Relay | 12 scores SoT | **Yes** |
| **B** Async LF Judge | sampled `eval_*` after ingest | Later only; not live gens; **other names** than A |
| **C** Judge replaces QA | drop Dograh QA | **No** while Cekura needs `{{annotations}}` |

**Empathy:** transcript **content** (acknowledge customer situation/feelings before pitch) — **not** TTS warmth/prosody. A already has `tag_ASSISTANT_LACKS_EMPATHY`. Optional later B: `eval_empathy` 1–5.

**Zero call-impact stack:** OTel + A + join keys in score metadata + annotation sample + offline dataset. No live judges on generations.

## OTel ≠ scores

- **OTel:** automatic `conversation` + `stt`/`tts`/`llm-*` latency/cost (Dograh/Pipecat → Langfuse).
- **Scores:** only if relay POSTs after QA (never automatic from OTel alone).
- Live `scores: []` + working stt/tts ⇒ **publish and/or relay gap**, not missing OTel.

## Production chain (Activi voiceeu)

1. Dograh WF has Post-Call QA (strict 12-field JSON) + webhook to **score relay**.
2. `save_workflow` = **draft** only. Publish: `POST https://voiceeu.activi.io/api/v1/workflow/{id}/publish` with `X-API-Key` (body `{}`). MCP has no publish tool. `"No draft to publish"` ⇒ already published or no draft row.
3. After hangup: QA → webhook → relay resolves trace → 12 scores on existing conversation trace.
4. Verify: Langfuse DograhEU → Trace `conversation` → 12 score names.

### Live relay (preferred over broken n8n scores path)

| Item | Value |
|------|--------|
| Webhook URL | `https://dsactivi-2--dograh-lf-scores.modal.run` |
| Health | `https://dsactivi-2--dograh-lf-scores-health.modal.run` |
| Schema | `aquaphor-langfuse-relay-v2-qa-tags` |
| Code | `dograh-aquaphor-telesales/scripts/langfuse_score_relay_v2.py` |
| Modal app | `dograh-aquaphor-telesales/scripts/modal_langfuse_relay.py` |
| Modal secret | `langfuse-dograheu` (pk/sk/base/queue id) |
| Deploy | `cd …/scripts && modal deploy modal_langfuse_relay.py` |

Old n8n URL `…/webhook/aquaphor-langfuse-scores` may return `Workflow was started` but **not** write scores — do not treat HTTP 200 as success. Prefer Modal relay.

### Trace linkage

- Lookup: `metadata.attributes.conversation.id` == `workflow_run_id` (or `conversation_id`/`session_id` in payload).
- **Never** create a new Langfuse trace for scores.
- OTel traces often have `sessionId=null` / `userId=null` — that is normal.

### Langfuse score API pitfalls (verified)

1. **Exactly one** of `traceId` | `sessionId` | `datasetRunId`. Sending `traceId` **and** `sessionId` → 400.
2. Join keys: put `workflow_run_id` / zoho in score **`metadata`**, not as sibling sessionId with traceId.
3. **BOOLEAN** value must be number **0 or 1** — not `true`/`false` (400).
4. CATEGORICAL `overall_sentiment`: string `positive|neutral|negative`.
5. NUMERIC `call_quality_score`: float 1–10, not string.
6. Idempotency: `id = "{traceId}-{name}"`.
7. Prefer `"environment": "production"` on score body to match voice traces.
8. Annotation queue **create** requires `scoreConfigIds: string[]` (400 if omitted).

### Payload fields (Dograh webhook)

- `session_id` / `conversation_id` / `workflow_run_id`
- `user_id` = zoho_lead_id (optional)
- `qa_annotations` = `{{annotations}}` (JSON string or object)
- `annotation_queue_id`, `dataset_name` (ops)
- `schema_version`: `aquaphor-langfuse-relay-v2-qa-tags`

### Score set (12)

| name | dataType | value |
|------|----------|--------|
| call_quality_score | NUMERIC | 1–10 float |
| overall_sentiment | CATEGORICAL | positive\|neutral\|negative |
| tag_UNCLEAR_CONVERSATION … tag_USER_DETECTS_AI (10) | BOOLEAN | **always emit all** as 0 or 1 |

TAG_NAMEs: UNCLEAR_CONVERSATION, ASSISTANT_IN_LOOP, ASSISTANT_REPLY_IMPROPER, USER_FRUSTRATED, USER_NOT_UNDERSTANDING, HEARING_ISSUES, DEAD_AIR, USER_REQUESTING_FEATURE, ASSISTANT_LACKS_EMPATHY, USER_DETECTS_AI.

### QA node JSON (strict)

```json
{
  "call_quality_score": 8,
  "overall_sentiment": "neutral",
  "tags": [{"tag": "DEAD_AIR", "reason": "…"}],
  "summary": "1-2 sentences.",
  "metrics_passthrough": {}
}
```

No invented latency/tokens/cost (OTel only). Prefer this shape over heavy CRM `order_gate` / PASS_WITH_GAPS unless Cekura still needs it on another webhook.

## TS / MCP pitfalls

- `save_workflow` = draft; publish REST above.
- Assemble QA prompts with `json.dumps(prompt)` + `re.sub(pat, lambda m: block, src)` — **plain string repl** turns `\n` into real newlines → Dograh `parse_error`.
- `hermes config set providers…models.grok-4.5…` splits on `.` → nested `grok-4`/`5` — write YAML key `'grok-4.5'` manually.
- Literals only in Dograh SDK data positions.

## CLI smoke

```bash
# demo write onto existing conversation.id
set -a; source <(grep -E '^LANGFUSE_(PUBLIC|SECRET|BASE)' ~/.hermes/.env); set +a
python3 scripts/langfuse_score_relay_v2.py --demo-conversation-id <id>

# or HTTP
curl -sS -X POST https://dsactivi-2--dograh-lf-scores.modal.run \
  -H 'Content-Type: application/json' \
  -d '{"conversation_id":"<id>","workflow_run_id":"<id>","qa_annotations":"{\"call_quality_score\":8,\"overall_sentiment\":\"neutral\",\"tags\":[],\"summary\":\"test\"}"}'
```

## Cross-instance WF copy audit (mandatory after clone)

Workflows copied from Cloud/other org often keep **foreign webhooks** while tools/creds on voiceeu are empty.

Probe every `endpoint_url` with a realistic POST. Classify:

| Probe result | Action |
|--------------|--------|
| Relay returns `ok` + scores_written | keep |
| n8n `200 Workflow was started` | async only — verify **Executions** + side effect (Zoho/Cekura), not success |
| n8n `500 Error in workflow` | **remove or disable node** until n8n fixed (do not leave on published WF) |
| empty `tool_uuids` / `list_tools=[]` | prompts must not assume address/KB tools; or create tools on instance |

### n8n / Zoho (voiceeu)

- Zoho is **not** a Dograh node credential — only via n8n (`zoho_lead_id` from `{{initial_context.zoho_lead_id}}`). Empty campaign context ⇒ empty CRM updates even when webhook 200.
- Cekura path `aquaphor-cekura-postcall-v2` was **500** on live probe; removed from WF22 PAS published. Do not re-add without n8n Execution proof.
- Remaining n8n on PAS: `aquaphor-handoff-ticket`, `aquaphor-postcall` — verify in n8n UI after test call.
- `N8N_API_KEY` may 401 (stale). Without a working key, agent cannot list/edit n8n workflows — need fresh key in `~/.hermes/.env` or human UI.
- Debug notes: `dograh-aquaphor-telesales/voiceeu/N8N_ZOHO_DEBUG.md`

### dograh_org_id

Live DograhEU OTel uses `dograh.org_id=2` for voiceeu org — keep payload marker consistent; do not copy Cloud org ids blindly.

## Skip

LF Prompt Mgmt in-call; live judges on generations; B reusing A score names; C; treating n8n 200 as scores landed; leaving 500 webhooks on published agents.

## Artifacts

- `dograh-aquaphor-telesales/voiceeu/wf22_pas_langfuse_qa_draft.ts`
- `dograh-aquaphor-telesales/voiceeu/WF22_LANGFUSE_METRICS.md`
- `dograh-aquaphor-telesales/voiceeu/N8N_ZOHO_DEBUG.md`
- `dograh-aquaphor-telesales/scripts/langfuse_score_relay_v2.py`
- `dograh-aquaphor-telesales/scripts/modal_langfuse_relay.py`
- Reference detail: `dograh-mcp-workflow-ops/references/langfuse-qa-score-relay-v2.md`
- This skill: `references/cross-instance-webhook-audit.md`

## Older skill note

`voice-call-observability-audit` (user-owned) documents older **4-score** Cekura set. Prefer **v2 12-score** here for PAS. Recommend `hermes curator adopt voice-call-observability-audit` before patching that skill.
