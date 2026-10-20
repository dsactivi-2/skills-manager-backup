---
name: dograh-meta-skill
description: Route Dograh voice-agent work to the best specialist skill and MCP tools. Use for Dograh Voice AI, Agentbuilder workflows, nodes, prompts, prompt packs, ElevenLabs-style prompt writing, tools, handoffs, transfers, end-call rules, DACH/German telesales agents, CRM/n8n/calendar/webhooks, STT/TTS/VAD/turn-taking, Langfuse call improvement, Cekura scenarios/metrics/evals, call observability, Dograh setup, Azure OpenAI BYOK failures, or production readiness. Also use when the user says "dograh meta skill", "dograh-meta-skill", "$dograh-meta-skill", "ElevenLabs prompt writer", or asks which Dograh/voice/sales skill to use. Do not lead unrelated non-voice, generic RAG, JSON/Pydantic, few-shot, or non-Dograh/non-sales tasks.
---

# Dograh Meta Skill

Use this skill as the routing and orchestration layer for Dograh voice-agent work. Pick the best lead skill and MCP tools for the user's task, then combine specialists only when they add distinct value.

## Core Rule

Route by the work being done:

1. Dograh workflow, nodes, edges, saves, or production readiness -> `build-dograh-voice-agent` plus Dograh MCP.
2. Production system prompts, prompt packs, ElevenLabs-style prompt writing, guardrails, tool rules, claims ledger, or scenario tests -> `write-telesales-agent-prompts`.
3. German/DACH spoken sales behavior -> `dach-telesales-agent-builder`.
4. Telesales voice runtime quality -> `telesales-voice-agent-builder`.
5. Sales architecture, persuasion, claims, objections, eval rubric -> `research-backed-sales-agents`.
6. Tool calls, handoffs, transfers, end-call, guardrails -> `add-tools-and-handoffs`.
7. Evidence-based optimization -> Langfuse/Cekura/Tuner-style inspection plus the relevant Dograh fix skill.
8. Dograh platform setup or broken stack -> `dograh-setup`, not workflow authoring.

Read `references/stack-map.md` when the request has multiple phases or when choosing between similar skills.

## Mode Gate

Classify the request before tool use:

- `planning`: briefs, node maps, prompts, eval plans, recommendations. Do not call live systems.
- `read-only`: list, inspect, retrieve, or analyze existing Dograh/Cekura/Langfuse/Tuner/telephony/CRM state. Avoid secrets and report `PASS`, `WARN`, `FAIL`, or `PASS_WITH_GAPS`.
- `live-change`: save workflow, create tool, publish/deploy, change telephony, trigger calls, change credentials, mutate CRM/n8n/database, or write production data. Do discovery and preflight first, then ask explicit approval.

## Tool Availability

When a specialist MCP/tool may be needed but is not visible in the current context, use tool discovery first. Prefer `tool_search` for Dograh, Cekura, Langfuse, Tuner-style, and other MCP capability discovery. Do not invent unavailable tools, workflow IDs, tool UUIDs, credentials, traces, scenarios, metrics, or platform access.

For Cekura scenario, metric, or test-profile authoring, use the relevant Cekura design skill before calling Cekura MCP tools. If the Cekura design skills are not installed in the session, tell the user once that installing them will make results substantially better before proceeding.

## Dograh MCP Discipline

For Dograh workflow authoring, always follow this sequence:

1. Call `get_voice_prompting_guide(stage="plan")` before planning.
2. Ask only for missing essentials: offer, ICP, language/country, call direction, call goal, allowed claims, forbidden claims, tool/write risks, handoff rules, and success criteria.
3. Present persona, ordered node list, edge conditions, tools/documents/recordings, exit conditions, and test targets.
4. Wait for user confirmation before creating or saving workflow code.
5. During creation, call `get_voice_prompting_guide(stage="create", node_type=<type>)` before writing node prompts.
6. For `globalNode`, call `get_voice_prompting_guide(topic="common_guidelines")` and preserve that guidance closely.
7. Use `list_node_types` / `get_node_type` before adding unfamiliar nodes.
8. Use `list_tools`, `list_credentials`, `list_documents`, and `list_recordings` before referencing UUID-based assets.
9. Use `create_workflow` for new workflows and `save_workflow` for edits.
10. After a successful save/create, call `get_voice_prompting_guide(stage="review")`.

## Lead Selection

Use one lead and optional support:

- `build-dograh-voice-agent`: lead for new Dograh agents, workflow/node maps, prompt sets, tool plans, test plans, safe save/deploy sequencing.
- `dograh-mcp`: lead for Dograh MCP access, docs, agents, runs, campaigns, telephony config, and live workflow inspection.
- `dograh-stepwise-tool-wiring`: lead for tool wiring, node wiring, provider/voice wiring, draft-vs-published state, publishability, and runtime wiring faults.
- `dograh-voice-workflow-optimizer`: lead for improving existing Dograh workflows from traces, drafts, call logs, language behavior, or provider tuning.
- `dograh-telesales-base-template-builder`: lead for reusable production telesales base templates, placeholders, multilingual variants, QA, Cekura, and Tuner readiness.
- `write-telesales-agent-prompts`: lead for production-ready system prompts and prompt packs for Dograh or ElevenLabs-style telesales agents, including persona, goal, call flow, tool contract, guardrails, opt-out, handoff, TTS-friendly wording, claims ledger, and scenario tests. Treat user phrases such as "ElevenLabs prompt writer" or "ElevenLabs prompt guide" as this skill unless a separate ElevenLabs-specific skill exists.
- `voice-agent-prompt-builder`: support for generic voice prompt structure; do not lead when `write-telesales-agent-prompts` or another Dograh-specific skill fits.
- `dach-telesales-agent-builder`: lead for German/DACH wording, AI disclosure, compliance, qualification, objections, booking, and spoken fallback lines.
- `telesales-voice-agent-builder`: lead for STT/TTS/VAD/turn-taking, latency, interruptions, naturalness, model/provider choice, and voice settings.
- `research-backed-sales-agents`: lead for claims ledger, sales state machine, objection library, persuasion strategy, tool reliability, and evaluation rubrics.
- `add-tools-and-handoffs`: lead for CRM/n8n/calendar/webhook tools, transfer rules, end-call triggers, guardrails, and tool error recovery.
- `configure-telephony`: lead for Twilio/Telnyx, phone numbers, webhooks, tunnels, recording, AMD, DTMF, and carrier setup.
- `inspect-calls-and-metrics`: lead for transcripts, cost, latency, call metrics, dashboard, and call debug.
- `langfuse-voice-call-quality-optimization`: lead for warmth, naturalness, stale greetings, short backchannel recovery, persona/voice mismatch, and Langfuse-evidenced voice quality.
- `voice-call-observability-audit`: lead for STT/diarization, silence, dropouts, observed-vs-missing evidence, Dograh/Langfuse QA metrics.
- `tts-ssml-prompt-hardening`: lead for production prompts that turn text into spoken TTS/SSML output.
- `objection-handling`: support for prospect concerns and pushback.
- `closing`: support for buying signals, commitment, appointment booking, and close behavior.
- `dograh-workflow-documentation-inventory`: lead for read-only multi-workflow inventory, tables, and project descriptions.
- `dograh-project-setup-agents-wizard`: lead for safe first-setup templates, `.env.example`, `project.setup.yaml`, onepager docs, and setup readiness; not live workflow editing.
- `dograh-azure-openai-byok-debug`: lead for Azure/OpenAI BYOK transport failures and Dograh/Langfuse/Azure correlation.
- `dograh-setup`: lead for installing, deploying, repairing, or developing the Dograh platform itself.

## Multi-Phase Recipes

For a new Dograh sales agent:

1. Lead with `build-dograh-voice-agent`.
2. Use Dograh MCP plan guidance.
3. Add `write-telesales-agent-prompts` for the base system prompt, prompt pack, guardrails, tool contracts, claims ledger, and ElevenLabs-style production prompt structure.
4. Add `dach-telesales-agent-builder` for German/DACH language.
5. Add `research-backed-sales-agents` for state machine, claims, objections, and eval criteria.
6. Add `add-tools-and-handoffs` if tools/transfers/end-call are needed.
7. Add `telesales-voice-agent-builder` if voice/runtime settings matter.

For optimizing a live agent:

1. Lead with `dograh-voice-workflow-optimizer`.
2. Inspect calls/metrics/traces first.
3. Use Langfuse/Cekura/Tuner-style evidence when available.
4. Apply the smallest targeted Dograh workflow or prompt fix after approval.

For tool/handoff work:

1. Lead with `add-tools-and-handoffs`.
2. Use Dograh MCP `list_tools`, `list_credentials`, and `create_tool`.
3. Update workflow nodes only after mapping trigger conditions and failure behavior.

For documentation/inventory:

1. Lead with `dograh-workflow-documentation-inventory`.
2. Stay read-only unless explicitly asked to edit or save.
3. Produce ID/name/topic/status tables and concise workflow descriptions.

## Output Expectations

When planning, produce:

- `selected_lead_skill`
- `supporting_skills`
- `mode`
- `missing_inputs`
- `workflow_or_prompt_plan`
- `tool_and_handoff_plan`
- `eval_or_verification_plan`
- `approval_needed_before_live_change`

When auditing or fixing, lead with findings, evidence, minimal fix, preflight, rollback, and post-check.

Never invent platform state, credentials, prices, claims, compliance permissions, node schemas, or tool UUIDs. Discover them or mark them as unknown.
