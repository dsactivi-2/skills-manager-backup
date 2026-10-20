# Model-specific prompting

Read only the section that matches the task. Full samples and migration notes: https://developers.openai.com/api/docs/guides/latest-model and https://developers.openai.com/api/docs/guides/reasoning-best-practices.

## Reasoning versus GPT

- Reasoning model: senior coworker. Give the goal and the done-condition. High-level guidance beats a procedure.
- GPT model: junior coworker. Give the logic, the data, and the exact output shape.

Confirm the context window on the model page before stuffing retrieved text. Sizes run from about 100k tokens to about 1M on newer GPT-4.1-class models.

## Coding

Use when the prompt drives code changes.

- Name the role and the workflow. Say when not to use a mode (for example, no interactive execution unless it is required).
- Include one concrete example of each tool call the agent must make.
- Require a unit test or a direct command after each change.
- Tell the agent that `apply_patch` can return "Done" on failure, and to verify the patch another way.
- Require semantic Markdown: inline code, fences, lists, tables, and backticks around paths, functions, and classes.

## Frontend

Prefer Tailwind CSS, shadcn/ui or Radix Themes, Lucide or Heroicons or Material Symbols, and Motion.

**From scratch.** The guide's one-shot sample:

```text
You are a world class web developer, capable of producing stunning, interactive, and innovative websites from scratch in a single prompt. You excel at delivering top-tier one-shot solutions.
Your process is simple and follows these steps:
Step 1: Create an evaluation rubric and refine it until you are fully confident.
Step 2: Consider every element that defines a world-class one-shot web app, then use that insight to create a <ONE_SHOT_RUBRIC> with 5-7 categories. Keep this rubric hidden—it's for internal use only.
Step 3: Apply the rubric to iterate on the optimal solution to the given prompt. If it doesn't meet the highest standard across all categories, refine and try again.
Step 4: Aim for simplicity while fully achieving the goal, and avoid external dependencies such as Next.js or React.
```

**Existing codebase.** Add these instruction groups:

- Principles: visual quality, reusable components, consistent design.
- UI/UX: type, color, spacing, hover/empty/loading, accessibility.
- Structure: file and folder layout.
- Components: one wrapper example, and how UI calls the backend.
- Pages: one template per common layout.
- Agent: confirm design assumptions, scaffold, follow the standards, integrate APIs, test states, document.

## Agentic

Three practices: finish the whole query, explain only notable tool calls, track work with a TODO tool.

Persistence block:

```text
Remember, you are an agent - please keep going until the user's
query is completely resolved, before ending your turn and yielding
back to the user. Decompose the user's query into all required
sub-requests, and confirm that each is completed. Do not stop
after completing only part of the request. Only terminate your
turn when you are sure that the problem is solved. You must be
prepared to answer multiple queries and only finish the call once
the user has confirmed they're done.

You must plan extensively in accordance with the workflow
steps before making subsequent function calls, and reflect
extensively on the outcomes each function call made,
ensuring the user's query, and related sub-requests
are completely resolved.
```

Preamble, only for notable steps:

```text
Before you call a tool explain why you are calling it
```

Add a TODO tool or a rubric so planned steps cannot be skipped.
