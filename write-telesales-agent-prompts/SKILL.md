---
name: write-telesales-agent-prompts
description: Write production-ready system prompts and prompt packs for telesales, outbound sales, follow-up, reactivation, qualification, appointment-booking, and handoff voice agents. Use when Codex is asked to draft, improve, audit, or adapt prompts for phone-based sales agents on Dograh, ElevenLabs Agents, or similar conversational AI platforms, especially when the prompt must include persona, goal, call flow, tool rules, guardrails, opt-out handling, escalation, TTS-friendly wording, and test criteria.
---

# Write Telesales Agent Prompts

## Overview

Write concise, structured, production-grade prompts for telesales voice agents. Favor reliable call behavior over clever copy: every prompt should make the agent's role, goal, allowed facts, conversation stages, tool use, guardrails, and escalation rules explicit.

Respond in the user's language. For German-speaking users, write natural German output, but keep technical keys, tool names, and platform placeholders exactly as provided.

## Workflow

1. Identify the sales scenario before writing prompt text.
   Capture offer, audience, call type, desired next step, market or language, lead context, tools, handoff path, and compliance constraints.

2. Separate facts from assumptions.
   Use only supplied or verified product facts. Put missing prices, guarantees, legal permissions, availability, integrations, and case studies into an `Unknown / needs source` list.

3. Map the call flow.
   Define greeting, permission check, reason for call, discovery, value bridge, objection handling, close, opt-out, no-fit exit, and human escalation.

4. Draft the prompt with clean sections.
   Use headings such as `# Personality`, `# Environment`, `# Tone`, `# Goal`, `# Call flow`, `# Guardrails`, `# Tools`, `# Tool error handling`, and `# Success criteria`.

5. Make tool behavior operational.
   For every CRM, calendar, lookup, transfer, SMS, or webhook tool, state when to use it, required inputs, expected formats, confirmation rules, and failure recovery.

6. Add guardrails and evaluation.
   Include opt-out, consent, privacy, no-fabrication, forbidden claims, sensitive-topic escalation, and scenario tests with `PASS`, `WARN`, `FAIL`, or `PASS_WITH_GAPS`.

Read [references/telesales-prompt-framework.md](references/telesales-prompt-framework.md) when you need the full prompt section template, tool contract pattern, quality checklist, or example prompt pack.

## Intake

Proceed without questions when the user provides the offer, target audience, and call objective. Ask at most three focused questions only when missing details materially change the prompt.

Minimum useful inputs:

- offer or product
- target audience
- call type: cold call, warm lead, inbound, follow-up, reactivation, qualification, appointment booking, or handoff
- primary success outcome

Important optional inputs:

- language, country, timezone, and call-time restrictions
- lead source and known personalization fields
- allowed claims, forbidden claims, pricing boundaries, and required disclosures
- CRM, calendar, transfer, SMS, or enrichment tools
- human handoff route and unavailable-human fallback
- data capture fields and evaluation criteria

## Prompt Writing Rules

- Keep spoken responses short: usually one to three sentences, then one question.
- Write one action per instruction line where possible.
- Put non-negotiable rules under `# Guardrails`.
- Repeat only the most critical rule once, and mark it with `This step is important.`
- Never make the agent claim facts, prices, outcomes, guarantees, legal permission, or integrations that were not supplied or verified.
- Require the agent to honor opt-out and human-agent requests immediately.
- Require graceful recovery for tool failures: acknowledge, retry once if appropriate, then hand off or schedule follow-up.
- Make prompts TTS-friendly: avoid dense punctuation, unexplained symbols, internal labels, and long lists read aloud.
- Preserve platform placeholders exactly, such as `{{lead_name}}` or Dograh runtime variables, when the user provides them.

## Output Shape

For a new prompt, return:

1. Assumptions and unknowns
2. Final system prompt
3. Tool contract, if tools exist
4. Test scenarios and quality checklist
5. Open risks or missing constraints

For an audit, return:

1. Findings first, ordered by severity
2. Concrete edits by prompt section
3. Revised prompt only when useful
4. Remaining test gaps

For a prompt pack, return:

1. Base system prompt
2. State or stage prompts
3. Tool and action contract
4. Claims ledger
5. Evaluation checklist
