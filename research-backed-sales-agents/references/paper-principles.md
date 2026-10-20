# Paper Principles For Research-Backed Sales Agents

Use this reference when the user needs source-grounded reasoning, an audit rubric, or model-routing decisions. Keep `SKILL.md` small; put paper detail here.

## Sources

- AI-Salesman: Towards Reliable Large Language Model Driven Telemarketing: https://huggingface.co/papers/2511.12133
- Talk Less, Call Right: Enhancing Role-Play LLM Agents with Automatic Prompt Optimization and Role Prompting: https://huggingface.co/papers/2509.00482
- Small Language Models are the Future of Agentic AI: https://huggingface.co/papers/2506.02153

## Synthesis

The combined pattern is a three-layer sales-agent architecture:

1. Strategy layer: dynamic outline-guided sales control.
2. Action layer: rule-based role prompting with strict tool contracts.
3. Efficiency layer: heterogeneous model routing, with SLMs for repeated scoped subtasks and LLMs only where general conversation or harder reasoning is needed.

## Paper To Artifact Map

- AI-Salesman -> dynamic outline, state machine, script library, factual evaluation.
- Talk Less, Call Right -> voice/action separation, action-first rules, schema-correct tool calls.
- Small Language Models are the Future of Agentic AI -> SLM-first routing for repeated scoped subtasks, logging for later replacement, fallback to stronger models.

Use this map when the user asks why a deliverable exists.

## AI-Salesman Principles

AI-Salesman frames telemarketing as a constrained, goal-driven, multi-turn dialogue problem. The key failure modes are strategic brittleness and factual hallucination.

Operational takeaways:

- Use a dynamic outline rather than one static prompt.
- Keep a structured script library indexed by dialogue intent or state.
- Retrieve and personalize turn-level guidance at runtime.
- Use state transition rules so the agent cannot jump incoherently through the sales flow.
- Ground all persuasion in verified context, user profile data, or explicit product facts.
- Evaluate both sales capability and factual faithfulness.

DOGA-style implementation:

1. Offline: collect high-quality historical or expert sales dialogues.
2. Annotate turns by intent or sales state.
3. Extract concise successful scripts.
4. Cluster similar scripts and summarize them into reusable templates.
5. Index templates by state, intent, and required profile fields.
6. Online: classify current intent/state, constrain it with transition rules, retrieve the matching template, personalize placeholders, then assemble the turn prompt.

Core sales capabilities to evaluate:

- Role alignment
- Business or needs analysis
- Offer or activity introduction
- Idle-chat redirect
- Objection handling
- Operational guidance

Seven response metrics:

- Guideline adherence
- Factual correctness
- Logical coherence
- User-need fulfillment
- Response richness
- Safety
- Completeness

## Talk Less, Call Right Principles

The paper identifies two common role-agent failures:

- Over-speaking: the agent gives long in-character replies when concise action is needed.
- Under-acting: the agent fails to use tools correctly, calls nonexistent tools, or calls tools unnecessarily.

Rule-based role prompting outperformed broader automatic prompt optimization in the reported setting. The useful lesson is not the game domain; it is the separation of voice and legal action.

Adapted sales-agent rules:

- Voice: define persona, tone, relationship, market, and allowed speaking style.
- Scene contract: define the call objective, current context, available facts, and boundaries.
- Action-first: if the caller requests an operation that maps to a tool, call the matching tool before answering.
- Single-shot: use at most one tool call per turn unless the workflow explicitly requires multiple calls.
- Defer text: answer after tool results return, or ask for clarification when arguments are ambiguous.
- Schema-correct: use exact tool names and parameter keys; never invent fields.
- Ambiguity: if multiple candidates fit, ask a short disambiguating question instead of guessing.

Sales examples:

- If the caller asks for available appointment slots, call the calendar lookup before suggesting times.
- If the caller asks about a price or eligibility, call the approved lookup tool or escalate; do not infer.
- If the caller says "book that one", resolve the referenced option from context or ask which option they mean.

## Small Language Model Principles

The SLM paper argues that many agentic calls are repetitive, scoped, and non-conversational. Those calls are natural candidates for smaller or specialized models, while stronger LLMs remain useful for open-ended conversation and harder reasoning.

Use SLMs or specialist models for:

- Intent or state classification
- Entity and field extraction
- Lead scoring
- Template retrieval or ranking
- Transcript labeling
- Rubric scoring
- Simple eligibility checks
- Tool argument drafting after schema validation

Keep a stronger LLM for:

- Root conversation in complex calls
- Novel objections
- Ambiguous or high-stakes reasoning
- Summarizing conflicting evidence
- Final prompt synthesis or audit output

LLM-to-SLM conversion checklist:

1. Instrument non-human-facing model calls.
2. Log prompts, outputs, tool calls, latency, and quality signals without exposing secrets or unneeded personal data.
3. Curate and redact logs; remove PII, PHI, and tenant-sensitive data.
4. Cluster repeated tasks.
5. Select candidate SLMs by capability, context length, license, latency, memory, and deployment footprint.
6. Fine-tune, distill, or prompt-specialize where useful.
7. Add a router and fallback to stronger models when confidence is low.
8. Re-evaluate periodically with fresh production-like data.

## Baseline Failure This Skill Prevents

Without this skill, agents tend to write a generic sales prompt with a friendly persona, a few objection-handling bullets, and no state machine, no factual claims ledger, weak tool-call discipline, no model-routing plan, and no sales-specific evaluation rubric. That output can sound polished while still failing real calls.

## Prompt Pack Guidance

Prompt packs should be split into small contracts rather than one large persona prompt:

- System prompt: identity, purpose, tone, safety, privacy, and escalation.
- State prompts: current state objective, allowed transition, next best action, and short example.
- Tool prompt: when to call, when not to call, exact schema, ambiguity handling, and result handling.
- Claims ledger: facts the model may say, must look up, must escalate, or must never say.
- Evaluator prompt: score against the sales capabilities and response metrics.

If the prompt pack grows too large, move examples into a script library and retrieve only the matching state guidance at runtime.

## Scenario Test Matrix

Scenario test guidance: use these minimum scenario tests before calling an agent ready:

| Scenario | Expected Behavior | Common Failure |
| --- | --- | --- |
| Qualified prospect | Move through needs analysis to next step | Skips discovery and pitches too early |
| Missing price or guarantee fact | Looks up or escalates | Invents a confident answer |
| Cost objection | Acknowledge, clarify, answer with one grounded value point | Argues or monologues |
| Idle chat | Briefly acknowledge and redirect | Follows off-topic thread |
| Ambiguous booking request | Ask a disambiguating question | Books or calls tool with guessed args |
| Tool failure | Apologize once, recover or hand off | Pretends the action succeeded |
| Opt-out or human request | Respect immediately and update disposition if possible | Continues selling |

## Minimal Audit Checklist

Return `PASS`, `WARN`, `FAIL`, or `PASS_WITH_GAPS` for each item:

- Dynamic outline exists and has legal transitions.
- Script templates are tied to states and facts.
- Tool rules separate voice from action.
- Tool schema constraints are explicit.
- Ambiguity handling exists.
- Claims ledger exists.
- Evaluation covers the six sales capabilities.
- Evaluation uses the seven response metrics.
- SLM/LLM routing is justified for repeated subtasks.
- Escalation and opt-out behavior are defined.
