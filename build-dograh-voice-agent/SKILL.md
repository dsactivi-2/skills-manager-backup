---
name: build-dograh-voice-agent
description: Build, plan, review, or improve Dograh Voice AI agents and Agentbuilder workflows from a concrete use case. Use when the user asks for a Dograh voice agent, voice AI workflow, conversation builder design, prompt set, node plan, tool-calling plan, n8n/Telnyx/CRM integration plan, test/eval checklist, production readiness review, or safe deployment workflow for Dograh Cloud or self-hosted Dograh.
---

# Build Dograh Voice Agent

## Overview

Use this skill to turn a voice-agent use case into a safe Dograh-ready plan: discovery, workflow nodes, prompts, tool wiring, tests, and production guardrails. Treat Dograh Cloud, n8n, Telnyx, CRMs, databases, and real calling as production-impacting systems.

## Operating Rules

- Work in German when the user writes in German; keep generated prompt artifacts in the target call language.
- Do discovery before drafting a workflow unless the user already supplied enough detail.
- Never ask for secrets in chat. Reference existing credentials or ask the user to enter them locally/in the provider UI.
- For any live Dograh Cloud, n8n, Telnyx, CRM, database, phone number, calling, or deployment change: first produce discovery, draft, preflight/dry-run plan, then ask for explicit approval before applying.
- Prefer read-only checks and timestamped PASS/WARN/FAIL/PASS_WITH_GAPS reports before changes.
- If the task is only planning or prompt drafting, do not touch external systems.

## Mode Boundary

Classify the request before acting:

- **Planning mode**: produce briefs, prompts, node maps, tool matrices, test plans, or local reports only. Do not call Dograh Cloud, n8n, Telnyx, CRMs, databases, phone APIs, or deployment tools.
- **Read-only inspection mode**: use available tools only to list, read, or inspect existing configuration. Write timestamped PASS/WARN/FAIL/PASS_WITH_GAPS findings and avoid exposing secrets.
- **Live change mode**: any save, deploy, credential update, workflow edit, tool wiring, phone-number change, test call, outbound call, or production data write. Require explicit approval after discovery, draft, and preflight/dry-run.

## Workflow

1. Discover the use case

Collect only what is missing:

- Business goal and expected outcome
- Inbound, outbound, or both
- Caller/user type and source of truth
- Top 3 capabilities the agent needs
- Actions the agent may take and actions it must not take
- Required integrations: Dograh, n8n, Telnyx, CRM, calendar, email, database, webhooks
- Target language, voice, accent, tone, and response length
- Human handoff, escalation, cancellation, and failure behavior
- Data retention, recording, transcript, and compliance constraints
- Success criteria and production readiness target

2. Draft the workflow

Use a multi-node Dograh shape by default:

- Global Node: role, goal, company context, language, speech handling, tone, constraints
- Start Call: greeting, identity/context, consent or reason for call where needed
- Main Task Node(s): gather facts, qualify, answer, or guide the caller
- Tool/Action Node(s): call CRM/API/n8n/calendar/email/database
- Summary/Next Steps Node: confirm outcome and next actions
- Escalation/Handoff Node: route uncertainty, angry callers, or restricted decisions
- End Call: concise goodbye and final confirmation

3. Write prompts like operating instructions

For the Global Node include:

- Who the agent is and why it is calling or answering
- Exact goal of the call
- Company/domain context
- Target language/accent and wording constraints
- Short, natural speech rule, usually 1-3 sentences
- Do-not-repeat rule
- Interruption, silence, unclear audio, noise, and off-topic handling
- Domain terms, spelling, pronunciation, and forbidden claims

For each node include:

- Main task at this stage
- Step-by-step call flow
- What to ask, what to wait for, and what to confirm
- Success criteria for moving to the next node
- Failure criteria for retry, handoff, or ending the call
- Tool/transition names in clear `snake_case`

4. Plan tools before wiring them

Create a tool matrix with:

- Tool name in `snake_case`
- Purpose and owner system
- Read/write risk level
- Inputs: fixed values vs LLM-generated values
- Validation rules
- Success and error behavior
- Dry-run/mock strategy
- Required credential reference, never the secret value

5. Test before production

Build tests around realistic calls:

- Happy path
- Caller interrupts or changes topic
- Caller gives partial or noisy information
- Caller asks for unsupported action
- Tool succeeds, fails, times out, or returns ambiguous data
- Human handoff path
- End-of-call summary accuracy

Review Dograh traces, transcript, recording, STT/TTS latency, LLM calls, tool calls, node transitions, and final state. Mark the result PASS, WARN, FAIL, or PASS_WITH_GAPS.

6. Apply only after approval

Before live changes, present:

- Planned changes
- Systems affected
- Dry-run/preflight result
- Rollback or recovery plan
- Post-change checks

Ask explicitly for approval. After applying, run post-checks and report outcomes.

## Resources

- Read `references/dograh_voice_agent_blueprint.md` when drafting a full workflow, prompt set, tool matrix, or production-readiness review.
- Use the blueprint's German wizard questions when the user wants a guided Agentbuilder discovery flow.
- Use the blueprint's forward-test protocol when revising this skill or checking whether it works on a fresh use case.
- Use `scripts/render_voice_agent_plan.py` when the user has a structured JSON brief and wants a repeatable Markdown plan generated locally.

## Script Usage

Create a JSON brief, then run:

```bash
python3 scripts/render_voice_agent_plan.py brief.json --out voice_agent_plan.md
```

The script is local-only. It does not call Dograh or external systems.
