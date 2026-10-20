# Prompt Framework

Use this framework to create or audit structured prompts for realtime voice agents.

## Standard Section Order

1. `Role and Objective`
Describe the agent's identity and primary job in one tight block. State the outcome the agent is trying to achieve.

2. `Personality`
Define how the agent should feel in conversation. Make the personality contextual to the use case instead of defaulting to generic friendliness.

3. `Context`
Describe the company, process, caller type, relevant business rules, and any important constraints.

4. `Instructions`
Split this into focused subsections when needed:
- communication guidelines
- pronunciation and formatting rules
- qualifying logic
- tool usage
- escalation and fallback behavior

5. `Stages`
Describe the flow as numbered stages. Start with the opening, then move through qualification, branching, action, and closing.

6. `Example Interactions`
Show desired behavior for unusual, risky, or easy-to-mishandle scenarios. Use examples to teach judgment, not to duplicate the entire prompt.

## Discovery Questions

Ask strategic questions before drafting. Focus on how the system should behave, not only on what it should say.

- What is the agent trying to accomplish on the call?
- Who is the caller and what do they usually want?
- What questions must the agent ask every time?
- What tools can the agent use, and when?
- What should happen if a transfer, booking, lookup, or handoff fails?
- What counts as out of scope?
- What should happen after hours?
- What rules change by region, service line, or caller type?
- What mistakes would be most costly?

## Common Production Constraints

Look for these details even if the user does not volunteer them immediately:

- business hours versus after-hours behavior
- transfer failure behavior
- unsupported request handling
- qualification thresholds
- compliance or privacy limits
- caller frustration or interruption handling
- voicemail or callback fallback
- multilingual handling

## Audit Checklist

Use this checklist when a prompt already exists.

### Objective
- Is the objective specific?
- Is success measurable from a transcript?

### Personality
- Does the tone fit the business and caller emotion?
- Does the personality improve behavior or only add style words?

### Context
- Does the prompt include the facts needed to make decisions?
- Does it avoid irrelevant background?

### Instructions
- Are tool rules explicit?
- Are speaking rules explicit?
- Are escalation rules explicit?
- Are prohibited behaviors explicit?

### Stages
- Do stages mirror the real call flow?
- Are branch conditions clear?
- Are transitions obvious?

### Examples
- Do examples cover edge cases that matter?
- Do examples teach behavior that the main instructions alone do not make obvious?

## Operating Principle

Treat prompt building as an iterative workflow:

1. Understand the use case.
2. Capture constraints and edge cases.
3. Draft a structured prompt.
4. Test with transcripts.
5. Revise the exact section that caused the failure.

Prefer manual reasoning and targeted edits over repeatedly asking another model to regenerate the whole prompt.
