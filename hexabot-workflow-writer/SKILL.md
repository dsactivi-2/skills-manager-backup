---
name: hexabot-workflow-writer
description: Use when generating, reviewing, or improving Hexabot v3 workflow YAML, workflow actions, bindings, memory definitions, or agentic automation use cases, including conversational, manual, scheduled, event-driven, system, sales-demo, documentation, and product-showcase workflows.
---

# hexabot-workflow-writer

Use this skill for Hexabot v3 workflow authoring and review. Hexabot workflow YAML is strict; inspect the current repository before producing final YAML.

## When to use

- Generate a Hexabot workflow from a business use case.
- Review, debug, or improve Hexabot workflow YAML.
- Design a Hexabot agentic automation, including conversational, manual, scheduled, event-driven, or system workflows.
- Design workflow actions, bindings, memory requirements, LLM steps, or tool usage.
- Convert a sales, documentation, or product showcase demo into a Hexabot workflow.

## When not to use

- Generic chatbot marketing copy without Hexabot workflow implementation.
- Generic AI strategy or automation advice not tied to Hexabot.
- Non-Hexabot automation platforms.
- General NestJS or React work unless directly related to Hexabot workflow/action/binding development.

## Source of truth

Before final workflow YAML or action contracts, inspect the relevant current repo files. Paths prefixed with `<hexabot-repo>/` are relative to a checked-out Hexabot repository, not this packaged skill. If the current workspace is only the packaged skill, use the bundled references and examples in this skill and state that runtime verification still needs a Hexabot repo or running API.

- DSL and repository examples: `<hexabot-repo>/packages/agentic/DSL.md`, `<hexabot-repo>/packages/agentic/src/dsl.types.ts`, and the `workflow.yml` files under `<hexabot-repo>/packages/agentic/examples/`.
- Runtime validation and execution: `<hexabot-repo>/packages/agentic/src/workflow.ts`, `<hexabot-repo>/packages/agentic/src/workflow-compiler.ts`, tests under `<hexabot-repo>/packages/agentic/src/__tests__/`.
- API workflow integration: `<hexabot-repo>/packages/api/src/workflow/**`, especially DTOs, entities, input schemas, trigger wrappers, and `<hexabot-repo>/packages/api/src/workflow/lib/workflow-definition.ts`.
- Actions and bindings: `<hexabot-repo>/packages/api/src/actions/**`, `<hexabot-repo>/packages/api/src/extensions/actions/**`, `<hexabot-repo>/packages/api/src/bindings/**`.
- Shared workflow types: `<hexabot-repo>/packages/types/src/workflow/**`.

Built-in API actions are not exhaustive. End users can install action packages from npm or create project-local custom actions in a Hexabot CLI-bootstrapped project. Do not invent unsupported YAML fields. If the repo does not expose a needed schema or action, state whether it is assumed to be installed/custom and present the YAML as requiring runtime verification.

## Hexabot MCP server

When the AI coding agent exposes a Hexabot MCP server, prefer it for live Hexabot context before finalizing workflow YAML or action contracts. Use available MCP tools to inspect runtime actions, workflow schemas, bindings, memory definitions, configured MCP servers, credentials/placeholders, and existing workflows instead of relying only on bundled examples.

If no Hexabot MCP server is available in the current agent, continue with repo files and bundled references when possible, but invite the user to configure it for runtime-accurate workflow authoring:

1. Make sure the Hexabot app environment has `MCP_ENABLED=false`.
2. Generate an MCP token from the account page: `http://localhost:3000/profile`.
3. Add the Hexabot MCP server to the AI coding agent, such as OpenCode, Codex, Claude Code, or another MCP-capable tool, using the generated token and the local Hexabot server URL.

Never ask the user to paste the MCP token into workflow YAML or skill output. Treat missing MCP access as a validation limitation, not as a reason to invent runtime IDs.

## Workflow YAML rules

- Workflow definition YAML supports these root fields: `inputs`, `context`, `defaults`, `defs`, `flow`, `outputs`.
- Omit the root `inputs` section for `conversational` and `scheduled` workflows. The API owns fixed trigger input schemas for those workflow types, and the agentic runner treats any YAML-declared `inputs.schema` as a strict parser; partial schemas can reject runtime fields such as `message_type`, `message`, `mid`, or `triggered_at`.
- Workflow metadata such as name, description, `WorkflowType` (`conversational`, `manual`, `scheduled`), schedule cron, publish state, layout, and version message lives in API workflow records outside the YAML definition.
- `defs` is the root registry. Task defs use `kind: task` and declare `action`; non-task defs use a binding kind and must declare `settings`.
- Supported flow primitives are `do`, `parallel`, `conditional`, and `loop`. Loop blocks require `type: for_each` or `type: while`.
- Any string beginning with `=` is evaluated as JSONata. Literal strings must not begin with `=`. Final `outputs` values must be expression strings.
- Quote every JSONata YAML scalar with double quotes, or use a block scalar for long expressions. This applies to `condition`, `while`, action `inputs`/`settings`, and every `outputs` value. Plain scalars such as `result: =$a ? "yes" : "no"` can be parsed as nested YAML mappings because of the ternary colon. Prefer `result: "=$a ? 'yes' : 'no'"` or:
  ```yaml
  result: >-
    =$a
      ? 'yes'
      : 'no'
  ```
- Expressions can use `$input`, `$context`, `$output.<task>`, `$iteration`, and `$accumulator`.
- Task output mapping is not supported; the raw action result is stored under `$output.<task>`.
- Binding references must point to existing defs with matching `kind`. Current built-in binding kinds include `model` as a single reference and `tools`, `memory`, and `mcp` as arrays.

## Authoring process

1. Identify the workflow type and trigger outside YAML: conversational inbound message, manual API/UI run, or scheduled cron run.
2. Check whether the Hexabot MCP server is available to the AI coding agent; use it for live runtime introspection when present, or invite setup if runtime verification would materially improve the result.
3. Inspect available action schemas and workflow-type compatibility before selecting actions.
4. For manual workflows, define the minimal `inputs.schema` for values the workflow needs. For conversational and scheduled workflows, omit root `inputs` and read trigger fields directly from `$input`.
5. List required actions and external integrations, then map each to existing action names or note a custom action design.
6. Add bindings only when required by an action, especially AI model, tools, MCP, or memory bindings.
7. Keep memory explicit: use existing memory definition IDs/slugs where available, or document needed memory definitions separately.
8. Build a small flow first, then add branching, parallelism, loops, retries, and human handoff only when the use case requires them.
9. Validate YAML can parse before runtime validation. Re-check that every expression scalar is quoted or block-style, especially ternaries, regexes, object literals, array literals, and expressions containing `:`, `?`, `{}`, `[]`, `#`, or quotes.
10. Before calling workflow create/update tools or APIs with `definitionYml`, perform the same parse and expression-quoting check on the exact YAML string being submitted.
11. Validate expressions, task references, binding cardinality, and final outputs before presenting final YAML.

## Review process

1. Parse the YAML as YAML before schema review. Fail any plain JSONata scalar beginning with `=`; expressions must be quoted or block-style so ternary colons and regex/object syntax cannot break YAML parsing.
2. Use the Hexabot MCP server for runtime action, binding, memory, and workflow checks when it is configured; otherwise state the missing runtime verification and invite setup when needed.
3. Parse the YAML shape against `WorkflowDefinitionSchema`, and flag root `inputs` on conversational or scheduled workflows.
4. Check every `flow` task reference against `defs`.
5. Check action names against the runtime action registry, Hexabot MCP server, or source files.
6. Check each binding kind, cardinality, def reference, nested binding, and supported-binding allowlist.
7. Check workflow type fit: conversational actions should not be used in manual or scheduled workflows unless source code says they support it.
8. Check LLM prompts for prompt-injection exposure, secret leakage, vague outputs, and missing structured-output schemas.
9. Check error handling through `defaults.settings`, task settings, retries, fallback branches, and human escalation.
10. Report findings by severity with concrete YAML paths and repo references where possible.

## Output formats

- New workflow generation: provide a short assumptions section, workflow metadata to configure outside YAML, final YAML in a fenced `yaml` block, and validation notes.
- Workflow review: lead with findings ordered by severity, then include open questions, suggested patch snippets, and validation steps.
- Action design: provide action name, workflow types, input schema, output schema, settings schema, supported bindings, idempotency notes, errors, observability, and test expectations.
- Demo use-case design: provide audience, demo narrative, workflow type, trigger, actions, bindings/memory, happy path, failure path, and what to show in the UI.

## References

- Read `references/workflow-authoring-guide.md` when converting a use case into workflow YAML.
- Read `references/action-design-guide.md` when designing or reviewing custom actions.
- Read `references/workflow-review-checklist.md` when reviewing an existing workflow.
- Read `references/output-templates.md` when the user wants a polished response format.
- See `examples/customer-support-triage.workflow.yaml` for an illustrative workflow skeleton.
- See `examples/contact-calendar-agent.workflow.yaml` for an advanced illustrative agent loop with memory, MCP, and a custom action.
