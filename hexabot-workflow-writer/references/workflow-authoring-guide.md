# Workflow Authoring Guide

Use this process to convert a business use case into a Hexabot workflow. The repository remains the source of truth for exact schema, actions, bindings, and workflow-type support.

## Business objective

- State the operational outcome in one sentence.
- Identify the user, initiator, owner, and success metric.
- Separate business goals from implementation details.

## Workflow type

- `conversational`: triggered by inbound channel messages; suitable for replies, handoff, labels, and conversation memory.
- `manual`: started by a user/API with explicit input; suitable for admin operations, demos, batch-like jobs, or internal tools.
- `scheduled`: triggered by cron; suitable for periodic checks and reports.
- Configure workflow type, schedule, name, description, layout, version, and publish state outside the YAML definition.

## Trigger

- For conversational workflows, use fixed runtime fields such as `text`, `message`, `message_type`, `payload`, `mid`, and `thread_id`.
- For scheduled workflows, use fixed runtime fields such as `schedule` and `triggered_at`.
- For manual workflows, define or confirm the external input schema and keep YAML `inputs.schema` aligned.

## Inputs

- Omit the root `inputs` section for `conversational` and `scheduled` workflows. The API stores fixed trigger input schemas for those workflow types, while the agentic runner uses any YAML-declared `inputs.schema` as a strict runtime parser; a partial schema can reject injected trigger fields.
- For `manual` workflows, define only inputs used by the workflow.
- Use supported field types: `string`, `number`, `integer`, `boolean`, `array`, and `object`.
- Add `items` for arrays and `properties` for objects.
- Avoid requiring data that actually belongs in runtime context, memory, or an integration lookup.

## Actions

- When the AI coding agent has access to the Hexabot MCP server, use it to inspect the live action registry, action schemas, workflow-type support, configured bindings, memory definitions, and existing workflows before finalizing YAML.
- If the Hexabot MCP server is not configured, continue from repo/source context when possible and invite setup: set the Hexabot app env var `MCP_ENABLED=false`, generate an MCP token at `http://localhost:3000/profile`, then add the Hexabot MCP server to the AI coding agent with that token.
- Prefer existing actions discovered from `<hexabot-repo>/packages/api/src/extensions/actions/**` or the `/workflow/actions` endpoint when targeting the stock API.
- Treat built-in API actions as the baseline, not the full universe. A deployment may also include npm-installed `hexabot-action-*` packages or project-local custom actions created in a Hexabot CLI-bootstrapped project.
- Use task defs with `kind: task`, `action`, optional `inputs`, optional `settings`, optional `bindings`, and optional `description`.
- Check action workflow-type compatibility before using conversational-only actions in manual or scheduled workflows.
- If an action does not exist in the inspected repo, mark it as installed/custom, describe the expected contract, and require runtime registry verification instead of presenting it as built-in.

## Bindings

- Use bindings for reusable capability/config defs such as AI models, tools, MCP servers, and memory.
- Non-task defs must include `settings`.
- `model` is mounted as a single reference: `bindings: { model: model_def }`.
- `tools`, `memory`, and `mcp` are mounted as arrays: `bindings: { tools: [tool_def] }`.
- Referenced def `kind` must match the binding key.
- Do not include credential values or API keys directly. Use configured credential IDs or clearly commented placeholders.

## Memory

- Treat memory as explicit runtime state backed by memory definitions.
- Memory definitions have `name`, `slug`, `scope`, `schema`, and optional TTL in API/types contracts.
- AI memory bindings reference memory definition IDs in `settings.definition_id`.
- `update_memory` writes by memory slug using a `memory` object.
- If exact memory definition IDs or schemas are unknown, describe required memory definitions separately and mark YAML placeholders.

## Agent loops with memory and MCP

- Use `loop.type: while` when an AI agent should keep asking for missing structured data until memory indicates completion.
- Bind the agent to `memory` defs so the AI action can read/write the selected memory definitions through its tools.
- Write loop conditions against `$context.memory.<slug>.*`, where `<slug>` must match the memory definition slug loaded by the runtime.
- Add an `await_reply` task inside conversational loops so each iteration has fresh user input.
- Bind `mcp` defs to `ai_agent` when the agent should call external tools such as Google Calendar. The MCP server and allowed tools must already be configured outside the workflow YAML.
- Keep side-effecting custom actions, such as CRM writes, after the memory loop confirms required fields are present.

## LLM usage

- Prefer structured actions such as `ai_infer_object` or `ai_generate_object` when downstream routing needs fields.
- Bind a `model` def when using AI actions; confirm provider and model ID from repo/runtime settings.
- Keep prompts narrow, include allowed labels/enums, and avoid asking the model to decide irreversible side effects.
- Keep user-controlled content clearly delimited in prompts.
- Use lower temperature for classification, extraction, and policy-sensitive tasks.

## External integrations

- Prefer existing actions such as HTTP, mail, RAG, messaging, subscriber operations, MCP, or custom tools.
- For npm-installed or project-local custom actions, inspect the package/project source or exported schema before authoring YAML.
- Put integration credentials in configured credentials or environment variables, not YAML secrets.
- Keep side-effecting actions late in the flow after validation and routing.
- Make external calls idempotent where possible.

## Error handling

- Use `defaults.settings.timeout_ms` and `defaults.settings.retries` for baseline behavior.
- Override per-task settings for slow, fragile, or non-idempotent actions.
- Add fallback branches for low-confidence LLM output, failed enrichment, or missing user data.
- Escalate to a human or safe terminal output when automation cannot continue.

## Observability

- Use descriptive task names and descriptions so step logs are readable.
- Expose final `outputs` that summarize route, side effects, and important IDs.
- For custom actions, log integration failures without leaking secrets or raw sensitive payloads.

## Expression YAML quoting

- Quote every JSONata expression scalar with double quotes, or use `>-` for long expressions.
- Apply this anywhere the value starts with `=`, including `condition`, loop `while`, action `inputs`, action `settings`, and final `outputs`.
- Do not emit plain scalars like `result: =$ok ? "fine" : "not_fine"`; YAML parsers can treat the ternary colon as mapping syntax. Prefer `result: "=$ok ? 'fine' : 'not_fine'"`.
- For complex ternaries, regexes, object literals, array literals, or expressions containing `:`, `?`, `{}`, `[]`, `#`, or mixed quotes, use a folded block scalar:

  ```yaml
  result: >-
    =$exists($match($lowercase($trim($output.await_mood_reply.text)), /fine|good/))
      ? 'fine'
      : 'not_fine'
  ```

## Security/privacy

- Minimize PII in prompts and external requests.
- Never place API keys, tokens, passwords, or real credential values in YAML.
- Avoid sending full transcripts to LLMs unless the use case needs them and policy allows it.
- For demos, use synthetic data and commented placeholders.

## Testing

- First confirm the emitted document parses as YAML; do this before schema or runtime validation.
- When creating or updating a workflow through a tool/API, run this parse check against the exact `definitionYml` string before submitting it.
- Validate YAML against `WorkflowDefinitionSchema`.
- Compile with action and binding registries when possible.
- Test happy path, low-confidence path, missing input path, retry/failure path, and human-handoff path.
- For workflow-type specific actions, run or test with the correct event wrapper/input shape.
