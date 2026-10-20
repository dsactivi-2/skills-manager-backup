---
name: dograh-telesales-base-template-builder
description: "Build or refactor a cloned Dograh workflow into a reusable production-ready telesales base template with QA, Cekura, Tuner, placeholder strategy, documentation, and multilingual variants. Use this skill when the user asks to turn a cloned Dograh workflow into a reusable production-ready telesales template with QA, Cekura, Tuner, placeholders, documentation, and multilingual variants."
trigger: "Use this skill when the user asks to turn a cloned Dograh workflow into a reusable production-ready telesales template with QA, Cekura, Tuner, placeholders, documentation, and multilingual variants."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019f5884-c492-7ac2-a7b1-ae00bf07874f
contributors:
  - activi
version: 2
created_by_agent: codex
created_at: 2026-07-13T16:26:14.268Z
updated_at: 2026-07-13T16:29:21.461Z
---

# Dograh telesales base template builder

## When to use

Use when the user asks to rebuild a duplicated Dograh Cloud workflow, such as `https://app.dograh.com/workflow/8111`, into a reusable production-ready telesales base template rather than a one-off campaign.

This covers node architecture, prompt distribution, placeholder strategy, QA, Cekura, Tuner, result sync, clone checklists, documentation, and separated language variants.

## Workflow

1. Follow the project rule order: read-only discovery, draft plan, change plan, explicit approval, save/create, post-check. Use Dograh MCP read-only first: `list_workflows`, `get_workflow`, `get_workflow_code`, `list_node_types`, `list_tools`, `list_credentials`, `list_documents`, and `list_recordings` as needed. Do not print secrets.
2. Verify native node types before designing. In the observed Dograh setup, native types were `globalNode`, `startCall`, `agentNode`, `endCall`, `qa`, `tuner`, `webhook`, and `trigger`. Treat Cekura as an external eval/observability integration via webhook, not as a native Dograh node.
3. For a reusable telesales baseline, prefer this structure: Global Telesales Guardrails, Opening + Permission Check, Discovery, Qualification, Pitch, Objection Handling, Close + Action Gate, Summary + Next Steps, Handoff + Escalation, End Won, End Follow-up, End Lost/Do Not Contact, End Human Handoff, QA Review, Cekura Observability Export, Tuner Export, Result Sync. The observed strong template had 17 nodes and 36 edges; the active conversation flow was smaller because End, QA, Tuner, Cekura, and Sync are support layers.
4. Remove campaign-specific remnants: product names, prices, claims, documents, tool assumptions, CRM URLs, old greetings, and stale AI-disclosure policy. Keep prompts neutral but operational: permission-based opening, short answers, one question at a time, safe recovery from silence/noise, no false promises, no write action without confirmation.
5. Use variables for business context, not secrets. Safe placeholders include `{{agent_name}}`, `{{business_name}}`, `{{offer_name}}`, `{{target_audience}}`, `{{call_goal}}`, `{{target_language}}`, `{{handoff_target}}`, `{{privacy_note}}`, `{{campaign_id}}`, `{{workflow_id}}`, `{{workflow_name}}`, `{{workflow_run_id}}`, `{{recording_url}}`, and `{{transcript_url}}`.
6. Keep API keys, bearer tokens, secret headers, credential values, tool UUIDs, document UUIDs, and recording IDs out of prompts and docs. Use Dograh Credentials for secrets. Prefer router/gateway URLs instead of hardcoded customer endpoints, for example `/result-sync`, `/pre-call-config`, or `/cekura-export`, routed by `workflow_id`, `workflow_name`, `workflow_run_id`, `project_key`, or `client_key`.
7. Treat tool and document binding as prepared until real systems are connected. Document what still needs clone-time setup: CRM/n8n/backend URLs, credential references, product/price/FAQ documents, pre-call fetch, result sync, callback/order/write tools, handoff target, and do-not-contact handling.
8. Keep Cekura, Tuner, and Result Sync disabled or clearly marked `Configure After Clone` until real endpoints, credentials, scenarios, metrics, pass thresholds, run evidence, and remediation loops exist. Cekura is not proof by itself; it becomes evidence only after scenarios and evaluators have run against calls or simulations.
9. Verify model, voice, language, timing, silence handling, turn-taking, interruption handling, and answer length through real or simulated calls. Do not call the template production-ready merely because the graph validates.
10. For multilingual variants, translate every spoken/user-visible prompt: greeting, global prompt, node prompts, QA/extraction prompts, and summaries. Keep technical identifiers, placeholder names, edge keys, and tool names stable unless creating a clean new workflow. Remember that Dograh `create_workflow` may publish version 1, so get approval before creating separate BS/DE/EN workflow IDs.
11. After saving or creating, read back and verify workflow name, target language, greeting language, node count, edge count, disabled integrations, no secret leaks, no product-specific leftovers, no unwanted AI-disclosure remnants, and status `PASS`, `WARN`, `FAIL`, or `PASS_WITH_GAPS`.

## Documentation

When asked for a handbook or template description, create a project-local, secret-safe artifact such as `/Users/activi/Documents/Dograh Base Nodes Template/output/pdf/dograh-base-node-template-guide.pdf`.

Include node map, variable/placeholder contract, where each Dograh value is configured, Cekura/Tuner/QA explanation, model/voice/timing verification needs, production test matrix, clone checklist, and items that must not be changed without approval.

## Anti-patterns

- Treating Cekura as a native Dograh node when MCP only confirms QA, Tuner, Webhook, Trigger, and other Dograh node primitives.
- Putting API keys, bearer tokens, base secret headers, decoded credentials, or live customer data into prompts, docs, payload examples, or chat.
- Hardcoding one customer's product, price, CRM URL, phone number, document, or offer claim into the reusable template.
- Creating BS/DE/EN duplicates before the user approves new published workflow creation.
- Calling Cekura, model, voice, or timing verified without run evidence, pass thresholds, and documented failures/remediation.
- Calling the template production-ready based only on structure, without QA/Cekura test evidence and model, voice, timing, and language verification.
- Mixing post-call evaluation/export responsibilities into live sales dialog nodes instead of keeping QA, Tuner, Cekura, and Sync separate.
