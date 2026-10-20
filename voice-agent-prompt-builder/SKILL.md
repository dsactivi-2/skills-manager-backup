---
name: voice-agent-prompt-builder
description: Build or audit structured prompts for realtime voice agents. Use when Codex needs to turn a voice-agent use case into a reusable prompt, refine an existing prompt after testing, or review whether a prompt has the right sections, constraints, stages, tool guidance, and example interactions for inbound or outbound voice workflows.
---

# Voice Agent Prompt Builder

Build voice-agent prompts with a consistent structure instead of writing them ad hoc. Start from the use case, gather the constraints that make the agent production-safe, then produce or revise a prompt that is short, structured, and easy to iterate on after testing.

## Workflow

1. Define the use case before writing prompt text.
2. Collect operational constraints before choosing wording.
3. Draft or audit the prompt with the standard section structure from [references/prompt-framework.md](references/prompt-framework.md).
4. Keep the first version compact and specific.
5. Improve the prompt through manual transcript review and targeted edits, not broad rewrites.

## Start With Discovery

Before drafting, gather the minimum facts needed to avoid a generic prompt:

- Agent type: inbound, outbound, intake, support, booking, qualification, routing, follow-up
- Goal: what successful completion looks like
- User type: caller, lead, customer, patient, applicant, internal user
- Business context: company, offer, process, compliance, hours, regions, escalation paths
- Tools: transfer, scheduling, SMS, CRM, forms, lookups, authentication
- Failure cases: unavailable humans, off-topic requests, unsupported requests, after-hours handling

If the user gives only a broad idea, ask strategic questions first. Prefer questions that expose edge cases and constraints over questions about wording.

## Build New Prompts

When creating a prompt from scratch:

1. Map the conversation flow first.
2. Convert the flow into the standard prompt sections.
3. Encode business rules as explicit instructions.
4. Describe tool use in plain operational language.
5. Turn the flow into numbered stages.
6. Add example interactions only for tricky or high-risk situations.

Use the framework in [references/prompt-framework.md](references/prompt-framework.md) for the exact section order and what to place in each section.

## Audit Existing Prompts

When reviewing an existing prompt:

1. Check whether the objective is concrete and testable.
2. Check whether the personality supports the use case instead of sounding generic.
3. Check whether the context contains the facts the agent actually needs.
4. Check whether instructions cover speaking behavior, formatting, tool use, and guardrails.
5. Check whether stages match the real conversation flow.
6. Check whether examples cover edge cases that caused failures in testing.

Prioritize behavioral gaps over style edits. If a prompt fails in production-like testing, fix the missing rule, stage transition, or tool instruction before polishing wording.

## Writing Rules

- Prefer short, explicit sections over long prose.
- State what the agent must do, must not do, and when it must escalate.
- Encode special handling for edge cases directly in the instructions or stages.
- Do not rely on the model to invent qualifying questions, policy, or transfer logic.
- Keep prompts compact enough to remain understandable and iterable.
- Treat prompt design as iterative engineering, not one-shot generation.

## Output Shape

When the user asks for a prompt, return:

1. A short assumptions block when important inputs were inferred.
2. The finished prompt in a clear sectioned format.
3. A short list of open risks or missing constraints, if any.
4. Optional next-step testing advice when useful.

When the user asks for an audit, return:

1. The most important weaknesses first.
2. Concrete suggested edits by section.
3. A revised version only when it materially helps.

## Reference

Read [references/prompt-framework.md](references/prompt-framework.md) when you need:

- the standard section template
- discovery questions
- an audit checklist
- common production constraints for voice agents
