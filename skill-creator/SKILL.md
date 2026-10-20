---
name: skill-creator
description: Use when creating a new skill or updating an existing skill for Codex, especially when the skill needs reliable triggering, reusable resources, or validation against realistic failure modes.
---

# Skill Creator

Create skills the way strong engineers create software: observe failure, write the minimum that fixes it, validate it, and tighten the result until it generalizes.

## Core Principle

Treat skill authoring as test-driven documentation.

If you did not first observe how an agent fails without the skill, you do not yet know what the skill needs to teach.

## When To Use

Use this skill when:

- creating a new Codex skill
- revising an existing skill that triggers poorly, is too vague, or has become bloated
- adding reusable scripts, references, or assets to support recurring work
- tightening a skill after real usage exposed gaps, omissions, or rationalizations

Do not use this skill for:

- one-off project notes
- repository conventions that belong in `AGENTS.md`
- rules that should be enforced by validation, linting, or automation instead of documentation

## What A Good Skill Does

A strong skill should:

- trigger for the right requests
- stay small enough to justify loading
- teach non-obvious behavior instead of restating generic knowledge
- point to scripts or reference files instead of inlining large detail
- hold up under realistic pressure, not just calm read-throughs

## Required Shape

A fully packaged, UI-friendly skill usually has:

```text
skill-name/
├── SKILL.md
├── agents/
│   └── openai.yaml
├── scripts/
├── references/
└── assets/
```

Rules:

- `SKILL.md` is required
- frontmatter must include `name` and `description`
- `name` uses lowercase letters, digits, and hyphens only
- `description` starts with `Use when`
- `description` describes triggering conditions, symptoms, and contexts
- `description` should not summarize the workflow of the skill

Keep `agents/openai.yaml` when the skill should appear cleanly in UI lists or chips.

Create `scripts/`, `references/`, and `assets/` only when they earn their keep.

## Description Rules

The description exists for discovery, not execution.

Write it so another agent can answer: "Should I load this skill right now?"

Good:

```yaml
description: Use when tests are flaky, timing-dependent, or pass and fail inconsistently across runs.
```

Bad:

```yaml
description: Use for fixing flaky tests by writing polling helpers, removing sleeps, and adding teardown cleanup.
```

Why:

- workflow summaries tempt agents to skip the body
- trigger-only descriptions improve discovery and push the reader into the real instructions

## Workflow

Follow this order unless there is a clear reason not to.

### 1. Define Concrete Scenarios

Collect or invent realistic requests that should trigger the skill.

For each scenario, ask:

- what would the user actually say?
- what should the skill help the agent do better?
- what reusable knowledge or tooling would save time next time?

### 2. Run A Baseline First

Before writing or substantially editing the skill, observe failure without the improved version.

For a new skill:

- run the task with no skill at all

For an existing skill:

- run the task with the current skill version

Capture:

- what the agent got wrong
- what it omitted
- what shape problems appeared
- what rationalizations it used under pressure

If no meaningful failure appears, do not add more guidance just to have more guidance.

### 3. Classify The Failure

Match the form of the skill to the failure.

- rule violation under pressure: use explicit prohibitions, red flags, and rationalization counters
- wrong output shape: use a positive recipe or contract that states the required parts and order
- missing required element: use a required slot, checklist item, or template field
- conditional behavior: use an explicit `if X, do Y` rule tied to an observable condition

Do not default to long prohibition lists for output-shaping problems. They often backfire.

### 4. Plan Reusable Resources

Decide what belongs in:

- `scripts/` for deterministic, repeatable operations
- `references/` for large documentation or variant-specific details
- `assets/` for templates, boilerplate, brand files, or other output resources

Keep `SKILL.md` focused on workflow, decisions, and navigation.

### 5. Initialize Or Restructure

When creating a new skill from scratch, use the initializer:

```bash
scripts/init_skill.py my-skill --path "${CODEX_HOME:-$HOME/.codex}/skills"
scripts/init_skill.py my-skill --path "${CODEX_HOME:-$HOME/.codex}/skills" --resources scripts,references
```

Then generate or refresh UI metadata:

```bash
scripts/generate_openai_yaml.py path/to/skill --interface key=value
```

Read [references/openai_yaml.md](references/openai_yaml.md) before overriding UI-facing fields.
When passing `default_prompt` through a shell, quote or escape `$skill-name` so the shell does not expand it as an environment variable.

### 6. Write The Minimum Effective Skill

Write only what the baseline showed was needed.

Prefer:

- short, direct instructions
- concrete trigger language
- one strong example over many weak ones
- cross-references to bundled files instead of dumping reference material inline
- explicit navigation for when to open a reference file

Avoid:

- narrative postmortems
- duplicated documentation
- filler explanations of things the model already knows
- many language variants of the same example
- extra docs like `README.md`, `QUICK_REFERENCE.md`, or `CHANGELOG.md`

## Default Body Shape

Use this structure by default:

```markdown
# Skill Name

## Overview
One or two sentences with the core principle.

## When To Use
Symptoms, contexts, and edge cases.

## Workflow
Ordered operating steps.

## Resources
When to use scripts, references, and assets.

## Common Mistakes
Typical failure modes and corrections.
```

Add a small flowchart only when a decision is genuinely non-obvious.

## Resources

Use bundled resources deliberately.

### `scripts/`

Put repeatable code here when reliability matters more than improvisation.

Scripts should:

- perform deterministic, recurring work
- be easier to run than to rewrite
- be tested after creation or revision

### `references/`

Move large detail here when it is useful, but not on every trigger.

Good fits:

- API docs
- schemas
- policy details
- provider-specific variants
- large examples that would bloat `SKILL.md`

Keep references one level away from `SKILL.md` and link them directly.

### `assets/`

Store files meant for outputs, not for context loading.

Good fits:

- templates
- boilerplate project folders
- images, icons, logos
- fonts
- sample files that get copied or modified

## Validation

Always run structural validation after edits:

```bash
scripts/quick_validate.py path/to/skill
```

Also validate behavior.

Minimum validation standard:

- the skill validates structurally
- a realistic task succeeds with the skill
- the skill does not depend on hidden context
- bundled scripts run if they were added or changed
- `agents/openai.yaml` still matches the skill if present

### Forward-Testing

Use fresh-context subagents when practical.

Rules:

- give the subagent the task, not your conclusion
- pass raw artifacts rather than your diagnosis
- do not leak the expected answer
- use realistic prompts that resemble actual user requests
- review outputs and artifacts, not just confidence

Forward-testing is especially valuable for:

- fragile workflows
- discipline-enforcing skills
- skills with multiple decision points
- skills whose description might over-trigger or under-trigger

## Discipline Skills

For skills that prevent bad behavior under pressure, strengthen them explicitly.

Add:

- a short non-negotiable rule
- a table of common rationalizations and rebuttals
- a red-flags section that tells the agent when to stop and restart

Example:

```markdown
## Red Flags - Stop And Restart

- You already wrote implementation before the test
- You are calling it "just a quick draft"
- You plan to test afterward and count that as equivalent
```

## Token Discipline

The context window is shared infrastructure.

Default to aggressive compression:

- keep descriptions compact
- avoid repeating what is already obvious from filenames or commands
- prefer one excellent example
- prefer pointers to `--help` over flag catalogs
- split heavy reference material instead of letting `SKILL.md` sprawl

If the skill keeps growing, cut before you add.

## Naming Guidance

Prefer short, active, trigger-friendly names:

- `creating-skills`
- `condition-based-waiting`
- `gh-address-comments`

Avoid vague or static names:

- `skill-creation`
- `debugging-techniques`
- `misc-tools`

## Final Check

Before considering the skill done, verify:

- the baseline failure was real
- the wording addresses that failure specifically
- the description is trigger-oriented
- the skill is smaller than the mistakes it prevents
- scripts, references, and assets are present only when they add clear value
- shell examples preserve literal `$skill-name` references in `default_prompt`

Small, sharp, and well-tested beats comprehensive but ignorable.
