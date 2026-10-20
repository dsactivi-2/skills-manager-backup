# Dograh Voice Agent Blueprint

Use this reference when producing a Dograh workflow, prompt pack, integration plan, or production readiness checklist.

## Source Pattern

This blueprint is based on a Dograh webinar about building a Voice AI agent with a live Dograh demo and lessons from production AI calls. The practical pattern is:

1. Define a concrete phone use case.
2. Treat the voice agent like a trained role-based employee.
3. Split the job into focused workflow nodes.
4. Write global and node-specific prompts with success criteria.
5. Add tools only after the conversation flow is clear.
6. Test traces, recordings, transcripts, latency, and tool calls before production.

## Good Use Cases

Prefer use cases where phones are still used and the process is repetitive:

- Appointment booking, rescheduling, reminders, and cancellation
- Missed appointment follow-up
- Reception and intake
- Lead qualification
- Cart/payment follow-up
- Customer support triage
- Insurance or eligibility pre-check
- Post-service care instructions

Avoid or escalate:

- Medical, legal, financial, or safety decisions that require a licensed human
- Irreversible transactions without confirmation
- Ambiguous identity or consent
- Angry, distressed, or abusive callers
- Anything outside the approved scope

## Discovery Template

Ask or infer:

- Use case name:
- Business owner:
- Caller type:
- Inbound/outbound:
- Call trigger:
- Primary goal:
- Secondary goals:
- Not allowed:
- Target language and voice:
- Knowledge sources:
- Tools/actions:
- Human handoff trigger:
- Success definition:
- Failure definition:
- Recording/transcript policy:
- Production target:

## German Agentbuilder Wizard Mini Template

Use these questions for a concise German discovery wizard. Ask only what is missing.

1. Was soll der Voice Agent am Ende des Gespraechs erreicht haben?
2. Ist der Agent fuer eingehende Anrufe, ausgehende Anrufe oder beides gedacht?
3. Wer ist der typische Anrufer oder angerufene Kontakt?
4. Welche drei Aufgaben muss der Agent sicher erledigen koennen?
5. Was darf der Agent ausdruecklich nicht entscheiden oder versprechen?
6. Welche Systeme braucht er: Dograh, n8n, Telnyx, CRM, Kalender, E-Mail, Datenbank oder Webhook?
7. Welche Daten darf er nur lesen, und welche Daten darf er nach Freigabe schreiben?
8. In welcher Sprache, Stimme, Tonalitaet und Antwortlaenge soll er sprechen?
9. Wann muss er an einen Menschen uebergeben oder abbrechen?
10. Welche Testfaelle muessen bestanden sein, bevor echte Telefonie angebunden wird?

Summarize answers as a brief with `use_case_name`, `primary_goal`, `call_type`, `capabilities`, `not_allowed`, `tools`, `test_cases`, and `production_target`.

## Plan vs Live Tooling Boundary

Default to planning artifacts unless the user explicitly asks for inspection or changes.

- Planning-only output: briefs, workflow sketches, prompt packs, tool matrices, local JSON/Markdown plans, test plans, readiness reports.
- Read-only tooling: list/read existing Dograh workflows, tools, credentials by reference, documents, recordings, traces, logs, or provider configuration. Do not decode or display secrets.
- Live Dograh or cloud changes: create/save workflows, wire tools, update credentials, change telephony, start calls, dispatch outbound campaigns, deploy infrastructure, write CRM/database records. Use discovery -> draft -> preflight/dry-run -> explicit approval -> apply -> post-check.

## Workflow Template

Use this shape unless the user provides a better one:

```text
global
start_call
identify_intent
main_task
tool_action
confirm_outcome
handoff_or_fallback
end_call
```

For complex agents, split `main_task` into separate nodes such as `qualify_lead`, `collect_appointment_details`, `answer_faq`, `check_availability`, or `payment_discussion`.

## Global Prompt Template

```text
You are {{agent_name}}, a voice AI agent for {{company_name}}.

Goal:
{{one_sentence_goal}}

Call context:
{{why_the_call_is_happening}}

Language and tone:
- Speak in {{language}} with {{accent_or_locale}} wording.
- Keep answers short and natural, usually 1-3 sentences.
- Ask one question at a time.
- Do not repeat yourself unless the caller asks or audio was unclear.

Speech handling:
- If interrupted, stop and respond to the caller's latest intent.
- If audio is unclear, ask a short clarification.
- If the caller is silent, retry once, then offer to end or hand off.
- If the caller asks for something outside scope, say what you can do and offer handoff.

Safety and scope:
- Do not invent facts, prices, availability, policies, or eligibility.
- Use tools for facts from external systems.
- Escalate when required by policy.
```

## Node Prompt Template

```text
Main task:
{{what_this_node_must_complete}}

Call flow:
1. {{first_action}}
2. Wait for the caller.
3. {{second_action}}
4. Confirm only the details needed for this stage.

Success criteria:
- Move to `{{next_node_or_tool}}` when {{condition}}.

Failure criteria:
- Move to `{{fallback_or_handoff}}` when {{condition}}.
```

## Tool Matrix Template

| Tool | System | Risk | Inputs | LLM-generated fields | Fixed fields | Validation | Dry-run | Failure behavior |
| --- | --- | --- | --- | --- | --- | --- | --- | --- |
| `send_summary_email` | n8n/email | write | recipient, subject, body | subject, body | recipient | no secrets, concise body | mock recipient | summarize locally and warn |
| `lookup_contact` | CRM | read | phone/email/customer_id | lookup key | none | exact match or ambiguity handling | read-only | ask clarification |
| `create_appointment` | calendar/CRM | write | caller_id, date, time, reason | date, time, reason | location | confirmation required | sandbox calendar | handoff or retry |

## Test Plan Template

Minimum cases:

- Happy path completes goal.
- Caller refuses or cancels.
- Caller asks unsupported question.
- Caller changes language or code-switches.
- Caller interrupts.
- Caller provides incomplete date/time/details.
- Tool returns no match.
- Tool returns multiple matches.
- Tool fails or times out.
- Handoff path triggers correctly.

For each test, record:

- Expected node path
- Expected tool calls
- Required confirmations
- Final outcome
- Trace/latency observations
- PASS/WARN/FAIL/PASS_WITH_GAPS

## Forward-Test Protocol

Use this when validating future changes to this skill. Keep the test independent from the implementation notes.

Prompt:

```text
Use $build-dograh-voice-agent to design an outbound dental rescheduling agent for a clinic that calls patients who missed appointments. The agent should reschedule if possible, cancel if the patient refuses, avoid medical advice, send a summary email through an approved tool, and require approval before any live Dograh/n8n/Telnyx action.
```

Expected evidence:

- The answer starts with discovery gaps or states assumptions.
- The workflow includes global, start, main task, tool/action, confirmation, fallback/handoff, and end nodes.
- Prompts include short speech, one-question-at-a-time behavior, interruption handling, and success criteria.
- Tool matrix separates fixed fields from LLM-generated fields and marks write risk.
- The agent refuses medical advice and escalates restricted requests.
- The response does not perform live Dograh, n8n, Telnyx, CRM, phone, or database actions.
- The result includes tests and PASS/WARN/FAIL/PASS_WITH_GAPS style readiness notes.

## Production Readiness Checklist

- Use case and scope approved
- Prompts include goal, speech handling, and success criteria
- Tool matrix reviewed
- Credentials referenced safely
- Dry-run or sandbox test completed
- Eval/test cases recorded
- Human handoff configured
- Recording/transcript policy confirmed
- Latency checked for target region and telephony path
- Rollback or disable path known
- Explicit approval captured before live changes
