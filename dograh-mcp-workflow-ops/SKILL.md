---
name: dograh-mcp-workflow-ops
description: "Read, localize, deploy, and locally dry-run large Dograh voice workflows over the MCP API. Use when a Dograh workflow is too large for the MCP tool to return whole (>50k chars, tool output truncates ~110k), when localizing a workflow to another language (covers the hidden routing/extraction layers most passes miss), when deploying an edited workflow as a new version, or when running local dialogue simulations against a live workflow before placing real test calls. Complements dograh-stepwise-tool-wiring (step discipline) and voice-low-latency-patterns (runtime tuning)."
trigger: "Use for Dograh workflow operations over MCP: pulling/deploying large workflow code, full-language localization, or local pre-call dialogue simulation."
metadata:
  version: 1.0.0
  parity: dograh
---

# Dograh MCP workflow operations (read, localize, deploy, simulate)

## When to use
Operating on Dograh voice workflows through the MCP API when: the code is too large
for the MCP tool to return whole; you are localizing a workflow to another language;
you are deploying an edited workflow; or you want to dry-run it locally before real
calls. For the stepwise localization/publish DISCIPLINE see `dograh-stepwise-tool-wiring`;
for runtime latency/voice tuning see `voice-low-latency-patterns`. This skill is the
concrete MCP-ops + simulation mechanics.

## 0. Instance + inventory (Activi)
- Default builder: **voiceeu** MCP `dograh-voiceeu`, key `MCP_DOGRAH_VOICEEU_API_KEY`, header **X-API-Key** (not Bearer).
- Cloud: `dograh` / `MCP_DOGRAH_API_KEY` Bearer — only if user wants Cloud; barbares often disables Cloud MCP.
- Dual routing: skill `dograh-dual-instance`. Sales/KB/tools empty checklist: `dograh-dual-instance/references/sales-stack-voiceeu.md`.
- Before big edits: `list_workflows`, `list_tools`, `list_documents`. Fresh voiceeu often has **empty tools and KB** — plan create_tool/upload; no invented uuids.
- Handoff may list Cloud-era IDs — live list on active MCP wins.

## 1. Bypass MCP tool truncation for large workflow code (>50k chars)
`get_workflow` / `get_workflow_code` MCP-tool output is truncated (~110k chars) and the
sandbox may fail to persist it — a >50k-char workflow never fully enters context. Call
the MCP HTTP endpoint directly and write to disk (full recipe in
`references/mcp-large-workflow-and-simulation.md`).

Keys/endpoints by instance:
- Cloud: `MCP_DOGRAH_API_KEY`, `https://api.dograh.com/api/v1/mcp/`, Authorization Bearer
- voiceeu: `MCP_DOGRAH_VOICEEU_API_KEY`, `https://voiceeu.activi.io/api/v1/mcp/`, **X-API-Key**

Handle SSE `data:` framing; `initialize` then `tools/call`. Same pattern deploys via `create_workflow`
(`{"code": <full ts>}`). Prefer Draft/new version per user rules; never silently overwrite protected source. Verify live (re-read id, residue-grep, node/edge counts).


## 2. Localization: three hidden functional layers
Node `prompt` + `qa_system_prompt` are obvious. THREE more steer routing/extraction and
are easily missed — leaving them in the source language makes the agent branch on
foreign conditions:
1. edge `label` + `condition`
2. node `extraction_prompt`
3. `extraction_variables[].prompt` (nested per variable)
Keep English enum tokens / variable names verbatim inside those prompts (won, follow_up,
high/medium/low, True/False, order_confirmed, final_outcome). Preserve verbatim: QA-node
JSON output keys/enums/tags (n8n/CRM contract — a renamed key breaks the pipeline),
webhook payload_template {{variables}}, tool_uuids. Swap the timezone
(e.g. Europe/Sarajevo -> Europe/Berlin) and rewrite the source-language block into a
target-language block. Apply translations as deterministic mapping JSONs via
exact-quoted-string replace; assert 0 unmatched keys and grep the assembled file for
source-language residue before deploy. Internal `const` identifiers are cosmetic (never
spoken/rendered) — rename for clean code, they don't affect routing.

## 3. Local dialogue simulation before real test calls
Simulate target-language dialogues locally against the live globalNode prompt (pulled
read-only via #1) with a production-class LLM, score against a TARGET-LANGUAGE rubric,
fix the worst scenarios, THEN place real Dograh calls only on those.
- Default engine OpenAI/GPT-4.1. On HTTP 429 `insufficient_quota`, switch to OpenRouter:
  key `OPENROUTER_API_KEY`, endpoint `https://openrouter.ai/api/v1/chat/completions`,
  model `anthropic/claude-sonnet-4` (`anthropic/claude-3.5-sonnet` 404s on OpenRouter —
  probe one isolated call to confirm the slug first). Add HTTP-Referer + X-Title headers;
  OpenAI-compatible shape.
- Rubric in the target language's terms. German: natural spoken Hochdeutsch + explicit
  booleans sie_form_ok (durchgehend Sie, no Du at the customer) and numbers_spoken_ok
  with NUANCE: prices/mengen/dates as number WORDS; PLZ/phone/house numbers as DIGIT
  GROUPS (not one giant number-word). See `references/german-number-nuance-sim-rubric.md`.
  Penalize pressure-after-a-clear-no. A rubric scoring "natural Bosnian" is useless for a German agent.
- 20 local sims cost cents vs dollars for real calls.

## 4. Edit + save workflow code safely (parse traps)
`save_workflow` / `create_workflow` use a restricted TS parser:
- Top level only: imports, `const X = …`, `wf.edge(...)`.
- Data positions = **literals only** (string/number/bool/array/object). No binary
  expressions. Prefer no `//` comments inside payload objects.
- QA and webhook nodes have **0 edges** (post-call; not in the live conversation graph).

### Assemble multi-line `qa_system_prompt` without breaking the string
Build the TS string with `json.dumps(prompt)`, then replace via **lambda** — never a
plain `re.sub` replacement string (Python `re` turns `\n` in the repl into real newlines
and splits the quoted prompt → `parse_error` BinaryExpression/DoStatement):

```python
# WRONG
src = re.sub(pattern, new_block, src)
# RIGHT
src = re.sub(pattern, lambda _m: new_block, src, count=1)
```

### save_workflow semantics
- Saves **draft** only (`status: draft`). Published stays live until UI publish.
- Always re-read `get_workflow_code` after save; grep contract keys + node/edge counts.
- Backup under project `voiceeu/wf<id>_…_draft.ts` (e.g. PAS Langfuse QA draft).

## 5. Post-call QA → Langfuse score relay (voiceeu)
When scores must land on the **correct** Langfuse trace (not CRM order-gate JSON):

### QA node — Langfuse-oriented default shape
Pure JSON, no markdown. Required fields:
- `call_quality_score` integer 1–10
- `overall_sentiment` one of `positive|neutral|negative`
- `tags` list of `{ "tag": "<TAG_NAME>", "reason": "…" }`
- `summary` 1–2 sentences
- optional `metrics_passthrough` = copy of `{{metrics}}` only — never invent
  latency/tokens/cost in the QA LLM

Exact TAG_NAMEs: `UNCLEAR_CONVERSATION`, `ASSISTANT_IN_LOOP`,
`ASSISTANT_REPLY_IMPROPER`, `USER_FRUSTRATED`, `USER_NOT_UNDERSTANDING`,
`HEARING_ISSUES`, `DEAD_AIR`, `USER_REQUESTING_FEATURE`, `ASSISTANT_LACKS_EMPATHY`,
`USER_DETECTS_AI`.

Do **not** mix with the heavy Aquaphor CRM QA schema (`order_gate`, `PASS_WITH_GAPS`,
`langfuse_score_candidates`, …) from older Cloud 8184/8783 exports unless n8n still
expects that path.

### Langfuse Score Relay webhook (Modal — preferred)
Endpoint (Activi live): `https://dsactivi-2--dograh-lf-scores.modal.run`  
Health: `https://dsactivi-2--dograh-lf-scores-health.modal.run`  
Code: `dograh-aquaphor-telesales/scripts/langfuse_score_relay_v2.py` + `modal_langfuse_relay.py`.

Old n8n `…/webhook/aquaphor-langfuse-scores` may HTTP 200 ("Workflow was started") **without**
writing scores — never treat that as success.

Publish after draft (MCP cannot publish):
`POST https://voiceeu.activi.io/api/v1/workflow/{id}/publish` + `X-API-Key`, body `{}`.
Versions: `GET /api/v1/workflow/{id}/versions`.

Trace linkage:
- Real `trace_id` from Dograh/Pipecat **OTel** — workflow cannot mint it.
- Send `session_id` / `conversation_id` = `{{workflow_run_id}}`, optional `user_id` = zoho.
- Lookup `metadata.attributes.conversation.id` == run id; **attach** scores; never new trace.

### Langfuse score API (verified)
- Exactly **one** of `traceId` | `sessionId` | `datasetRunId` — not both traceId+sessionId (400).
- Join keys → score **metadata**, not dual sessionId.
- BOOLEAN value = number **0|1** only (not true/false).
- Idempotency `id = {traceId}-{name}`; prefer `environment: production`.

Scores to write:
| name | dataType | value |
|------|----------|--------|
| `call_quality_score` | NUMERIC | float 1–10 |
| `overall_sentiment` | CATEGORICAL | positive/neutral/negative |
| `tag_<TAG_NAME>` ×10 | BOOLEAN | **0 or 1**; emit all 10 every call |

Schema: `aquaphor-langfuse-relay-v2-qa-tags`. Latency/tokens = OTel only.
Decision: A=SoT; B async `eval_*` later; C no while Cekura needs annotations.

Details: `references/langfuse-qa-score-relay-v2.md`. WF22 PAS + metrics doc under
`dograh-aquaphor-telesales/voiceeu/`.

## 6. Org TTS/STT/LLM (not workflow code)

Voice/locale/`speed` live in org config, not TS. voiceeu REST uses **X-API-Key**:

```text
GET/PUT https://voiceeu.activi.io/api/v1/user/configurations/user
GET     .../user/configurations/user/validate
GET     .../organizations/context         # organization_id (voiceeu BS = 2)
GET     .../workflow/{id}/runs/{run_id} # runtime_configuration + ghost STT
```

BS Stufe 1 TTS: `azure_speech` + `germanywestcentral` + `bs-BA-VesnaNeural` + `bs-BA` + `speed` ~0.95.  
Recipe: `references/org-tts-stt-llm-config.md`. Do **not** open a workflow draft only to set Vesna.
Change-accounting: Org vs WF-TS vs docs separately — never call docs/speed-only a workflow save.
Pipecat Azure escapes LLM SSML; Gabrijela≠BS.

Ghost user text / Open stuck: inspect STT (`rtf-user-transcription`), not TTS first. Speechmatics often `hr` (no `bs` in schema). Deepgram EU needs factory `base_url` — UI has no endpoint (`balkan-voice-agent-stack` → `references/deepgram-eu-endpoint.md`).

## References
- `references/mcp-large-workflow-and-simulation.md` — copy-paste direct-MCP recipe, the
  full localization-layer checklist, and the simulation engine/rubric details.
- `references/german-number-nuance-sim-rubric.md` — DE numbers_spoken_ok nuance (Amina R2).
- `references/langfuse-qa-score-relay-v2.md` — QA JSON + n8n score_mapping + OTel
  trace_lookup contract (voiceeu / Langfuse DograhEU).
- Org TTS/STT: `references/org-tts-stt-llm-config.md`
- Ghost STT / PAS Open stuck: `references/ghost-stt-pas-open.md` (WF22 evidence + debug)

## Anti-patterns
- Trusting the MCP tool to return a >50k-char workflow whole (it truncates).
- Using Cloud MCP URL/key while the user is on voiceeu (or vice versa).
- Bearer auth on OSS voiceeu (tools/REST 401; test may still look green).
- Assuming handoff workflow IDs match the current instance without `list_workflows`.
- Assuming tools/KB exist — check `list_tools` / `list_documents` (often empty).
- Localizing only node prompts and leaving edge conditions / extraction prompts in the
  source language (agent routes on foreign conditions).
- Renaming QA JSON keys or webhook variables during localization (breaks n8n/CRM).
- Overwriting the source workflow instead of deploying a new one / Draft path.
- Running a "natural Bosnian" rubric against a German agent.
- Blindly trusting a model slug — probe one call before a full batch.
- Placing expensive real test calls before local simulation narrows to the worst cases.
- Treating Hermes MEMORY.md as the phone agent's call memory (use workflow vars + globalNode).
- Using `re.sub(pat, block_with_backslash_n, src)` — breaks multi-line TS strings; use lambda.
- Claiming workflow code can invent Langfuse OTel `trace_id` — use conversation.id lookup.
- Emitting BOOLEAN scores as true/false or omitting absent tags (aggregation breaks).
- Treating draft `save_workflow` as production without UI publish + fresh test call.
- Mixing CRM `order_gate` QA schema with Langfuse tag-score contract without dual n8n paths.
- Editing workflow TS to change Azure voice/locale/speed (org config API only).
- Using Bearer on voiceeu for `/user/configurations/*` (401) — use X-API-Key.
- Blaming Vesna/`speed` for ghost transcripts — check STT/echo first (`rtf-user-transcription`).
- Claiming Deepgram UI save routes to EU — factory omits `base_url` → US until patched.
- Treating EU Deepgram `/v1/projects` 404 as no access — probe `/v1/listen` instead.

