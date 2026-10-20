---
name: research-backed-sales-agents
description: Use when designing, auditing, or optimizing sales, telesales, voice, or tool-using role-play agents where multi-turn persuasion, factual faithfulness, tool-call reliability, evaluation rubrics, or SLM/LLM routing decisions matter.
---

# Research-Backed Sales Agents

## Overview

Build sales agents as governed systems, not as one clever prompt. A reliable sales agent needs dynamic strategy, strict action contracts, factual grounding, measurable evaluation, and model routing.

This skill is based on three papers: AI-Salesman, Talk Less, Call Right, and Small Language Models are the Future of Agentic AI. Open `references/paper-principles.md` when you need the paper-specific rationale, source links, or the full evaluation rubric.

## When To Use

- The user asks to build, audit, or improve a sales, telesales, voice-call, appointment-booking, objection-handling, or sales role-play agent.
- A prompt or agent over-speaks, under-acts, misses required tool calls, calls nonexistent tools, invents product facts, loses strategy across turns, or sounds like a static script.
- The task needs a sales-call state machine, script library, dynamic prompt assembly, factual claims ledger, or evaluation rubric.
- The user asks whether to use one LLM, multiple models, or smaller models for repeated agent subtasks.
- Use alongside `telesales-voice-agent-builder` when STT, TTS, VAD, telephony, or provider configuration is also part of the work.

Do not use this for generic ad copy, landing pages, or one-off sales emails unless the user is explicitly designing an agent or reusable sales conversation system.

## Intake

Proceed immediately when the user provides the offer, audience, and desired outcome. Ask at most three questions only when missing details materially change the agent design.

Required facts:

- offer or product
- target audience
- call type and goal
- allowed and forbidden claims
- available tools and their schemas
- escalation, opt-out, privacy, and compliance boundaries
- success metric

If product facts are missing, create an `Unknown / Needs Source` list. Never invent prices, guarantees, availability, legal permissions, integrations, customer references, or performance claims.

## Operating Modes

- Build Mode: create a new sales-agent design from sparse requirements.
- Audit Mode: review an existing prompt, workflow, transcript, or config and return findings first.
- Optimization Mode: revise an existing agent while preserving working behavior.
- Routing Mode: decide which subtasks should use SLMs, specialist models, or stronger LLMs.

## Workflow

1. Capture the scenario and hard facts.
   Identify offer, audience, call type, sales goal, allowed claims, forbidden claims, tools, escalation rules, privacy limits, and success metric. Mark missing product facts as unknown; do not fill them with plausible claims.

2. Classify the failure mode before rewriting.
   Look for strategic brittleness, factual hallucination, over-speaking, under-acting, chat-before-tool behavior, schema drift, unnecessary tool calls, missing disambiguation, weak evaluation, or an expensive model doing a narrow repeated task.

3. Design the dynamic outline.
   Define sales intents or states, valid transitions, required facts, personalization fields, exit criteria, and one-turn guidance for each state. Include at least these states when relevant: role alignment, business or needs analysis, offer introduction, idle-chat redirect, objection handling, operational guidance, and close or handoff.

4. Build the script library.
   For each state, write concise templates with placeholders, key points, forbidden claims, and examples of when the template applies. Keep templates reusable and grounded in verified facts. Avoid one long static monologue.

5. Separate voice from action.
   Use a character-card or scene-contract for speaking style, and a separate action contract for tools. Tool rules must be explicit: action-first when the user requests an actionable operation, at most one tool call per turn unless the workflow explicitly requires more, exact schema keys only, no undefined tools, defer natural-language answers until tool results return, and ask for disambiguation instead of guessing.

6. Add a factual claims ledger.
   List approved facts, facts requiring lookup, facts requiring human escalation, and facts the agent must never claim. Tie every persuasive point to context, tool output, or the ledger.

7. Route models by task.
   Prefer small or specialized models for repetitive, scoped subtasks such as intent classification, extraction, scoring, template retrieval, eligibility checks, and transcript labeling. Use a stronger LLM for root conversation, novel objections, ambiguous high-stakes reasoning, and synthesis. Instrument non-human-facing model calls so future logs can support SLM replacement.

8. Evaluate before calling it ready.
   Use scenario tests that include objections, idle chat, ambiguity, tool calls, missing facts, opt-out or handoff requests, and noisy caller turns. Score with the seven metrics from the reference: guideline adherence, factual correctness, logical coherence, user-need fulfillment, response richness, safety, and completeness. Report `PASS`, `WARN`, `FAIL`, or `PASS_WITH_GAPS`.

## Output Contracts

For a full build, produce these sections unless the user asks for a narrower artifact:

1. Scenario Assumptions
2. Dynamic Outline / State Machine
3. Script Library
4. Tool And Action Contract
5. Factual Claims Ledger
6. Prompt Pack
7. Model Routing Plan
8. Evaluation Plan
9. Open Gaps

For an audit, lead with findings:

1. Findings
2. Failure Map
3. Dynamic Outline / State Machine
4. Script Library
5. Tool And Action Contract
6. Factual Claims Ledger
7. Evaluation Plan
8. Revised Prompt Pack
9. Residual Risks

For routing-only work, produce:

1. Current Model Use
2. Repeated Subtasks
3. SLM Candidates
4. Stronger-LLM Keep List
5. Router And Fallback Rules
6. Logging And Redaction Plan
7. Evaluation Gates

Keep prompts operational. Avoid burying the important rules inside a long persona essay.

## Prompt Pack Contract

A production prompt pack should include:

- base system prompt: persona, boundaries, call purpose, tone, and refusal rules
- dynamic state prompts: one short instruction block per state
- tool contract: action-first rules, exact schemas, ambiguity handling, and tool-error recovery
- claims ledger: approved facts, lookup-required facts, escalation facts, and forbidden claims
- evaluator prompt or checklist: expected scoring rubric and pass thresholds

Template: use `assets/prompt-pack-template.md` when the user wants a fillable prompt-pack skeleton.

## Test Scenarios

Always include at least five scenario tests for production-facing agents:

- straightforward qualified prospect
- price, guarantee, or compliance question with missing facts
- objection about cost, timing, or trust
- idle chat or off-topic turn that should redirect politely
- ambiguous tool request requiring clarification
- opt-out, angry caller, or human-handoff request

Template: use `assets/sales-agent-audit-sheet.md` when the user wants a repeatable audit sheet.

## Resources

- `references/paper-principles.md`: paper-derived principles, source links, evaluation rubric, and conversion checklist.
- `scripts/validate_research_backed_sales_agents.py`: structural check for this skill after edits.
- `assets/prompt-pack-template.md`: fillable prompt-pack skeleton.
- `assets/sales-agent-audit-sheet.md`: repeatable audit and test sheet.

## Common Mistakes

- Treating a static mega-prompt as sales strategy. Correct it with a state machine and dynamic script library.
- Letting persona speak before action. Correct it with action-first rules and a separate tool contract.
- Inventing product benefits, prices, compliance claims, or availability. Correct it with a factual claims ledger and lookup/handoff rules.
- Using broad automatic prompt optimization when simple rules would fix the failure. Prefer compact, explicit rules for observable tool and dialogue errors.
- Sending every subtask to a large model. Route narrow, repeated subtasks to smaller or specialized models when quality, latency, and cost allow it.
- Producing a polished prompt but no tests. Add scenario tests and pass thresholds before calling the agent production-ready.

## Red Flags - Stop And Restart

- The prompt says "stay in character" but does not define allowed actions.
- The agent can call tools, but the prompt does not list when to call, when not to call, and how to handle ambiguity.
- The sales pitch contains claims that are not traceable to provided context or tool output.
- There is no evaluation plan beyond "try a few calls".
- A large model is used for every classifier, extractor, or scorer without a reason.
