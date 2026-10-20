---
name: dach-telesales-agent-builder
description: Write and refine compliant DACH B2B telesales voice-agent prompts, call flows, objection handling, qualification logic, and booking behavior. Use when Codex must turn an offer, ICP, and call goal into a German-speaking voice-agent system prompt, structured conversation states, handoff rules, fallback lines, or coaching artifacts that teach the agent how to sell without inventing facts or hiding its AI identity.
---

# DACH Telesales Agent Builder

## Overview

Build practical sales behavior for German-speaking voice agents. Turn the user's offer, target customer, and call goal into a short, usable system prompt plus a clear state flow, objection responses, booking rules, and guardrails.

## Working Style

1. Gather only the missing essentials: offer, ICP, call goal, booking target, allowed claims, forbidden claims, tools, and hosting or compliance constraints.
2. Produce the sales skeleton before polishing wording: role, goal, states, transitions, objections, booking, fallback.
3. Write for spoken German, not for chat. Prefer short sentences, one thought per turn, and explicit repair behavior.
4. Keep the agent inside scope. If facts, pricing, or promises are missing, make the agent defer instead of improvise.

## Default Output Set

When the user wants a full working package, produce these parts in this order:

1. `agent_brief`
2. `system_prompt_de`
3. `state_flow`
4. `objection_library`
5. `qualification_rules`
6. `booking_rules`
7. `tool_behavior`
8. `failure_and_escalation_rules`

If the user asks for only one part, produce only that part.

## Prompt Construction Order

Write prompts in this order:

1. Identity: who the agent is, whom it calls, and what it may help with
2. Objective: qualify, book, hand off, or end politely
3. Success criteria: what counts as a good call outcome
4. Hard guardrails: no invented facts, no fake urgency, no hidden AI identity, no legal claims
5. Conversation states: opener, reason, discovery, qualify, objection, booking, close
6. Tools: when to check CRM, calendar, DNC, transfer, or consent logs
7. Repair behavior: repeat, clarify, spell, confirm, or hand off
8. Exit behavior: book, follow-up, human transfer, or polite stop

Use `references/prompt-patterns.md` when writing the actual prompt body.

## Voice-Specific Rules

- Write lines that sound natural when spoken aloud.
- Keep turns short enough that interruption is easy.
- Avoid stacked clauses, bullet-like recitation, and long legal monologues.
- Tell the agent how to react when ASR is wrong, the company name is misheard, or the prospect answers indirectly.
- Normalize emails, numbers, dates, times, and prices into speakable German.
- Separate prompt behavior from voice settings. Put tone, cadence, and fillers in a short style section, not everywhere.

## Sales Rules

- Optimize for realistic call outcomes: qualification, next step, meeting, or handoff.
- Do not optimize for closing a full sale on a cold call unless the user explicitly has that process and it is credible.
- Ask only the minimum questions needed to reach the call goal.
- Use objection handling to uncover cause, not to pressure the prospect.
- Stop pushing when the prospect is clearly not a fit, not interested, or asks not to be contacted.

Use `references/flow-and-objections.md` for state design and common objection patterns.

## Compliance Rules

- In DACH outbound contexts, keep AI identity disclosure visible whenever the user's rules require it.
- Never let the agent pretend to be a human.
- Never let the agent invent references, customers, price approvals, legal guarantees, or product capabilities.
- If compliance instructions are unclear, write the prompt to escalate or defer rather than guess.
- If the user asks for deceptive tactics, refuse that part and continue with a compliant version.

## Response Shapes

Use these shapes unless the user asks for another format:

- For prompts: fenced markdown code block
- For state flows: compact numbered list or Mermaid state diagram
- For objections: table with `objection | likely cause | response | when to stop`
- For qualification: checklist with pass or fail thresholds
- For booking logic: clear `if/then` rules

## Resource Routing

- Read `references/prompt-patterns.md` when you need prompt sections, templates, or wording rules.
- Read `references/flow-and-objections.md` when you need conversation structure, qualification, booking, or objection handling.

## Hard Stops

- Stop and ask when the offer, ICP, or call goal is too vague to write a usable sales flow.
- Stop and ask when the user wants the agent to hide that it is AI or make unsupported claims.
- Stop and ask when booking rules or qualification thresholds conflict with the user's stated business process.
