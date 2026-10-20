# Workflow Review Checklist

Use this checklist when reviewing Hexabot workflow YAML or proposed workflow designs.

## Schema validity

- The document parses as YAML before schema validation.
- Every JSONata expression scalar beginning with `=` is quoted or block-style, especially values under `condition`, loop `while`, action `inputs`/`settings`, and `outputs`.
- No plain expression scalar contains ternary `:`, regex syntax, object/array literals, `#`, or mixed quotes that can be reinterpreted as YAML syntax.
- Root fields are limited to supported workflow definition fields.
- `defs`, `flow`, and `outputs` are present.
- Task defs use `kind: task` and declare valid `action` names.
- Non-task defs use binding kinds and include `settings`.
- Unknown fields are not present in strict DSL objects.

## Workflow type correctness

- Workflow type is configured outside YAML as `conversational`, `manual`, or `scheduled`.
- Conversational and scheduled workflows omit root `inputs`; fixed trigger inputs are supplied by the runtime. Manual workflows define a clear input schema when they require external input.
- Actions are compatible with the workflow type.
- Scheduled workflows have cron configured outside YAML.

## Trigger correctness

- Conversational workflows read inbound fields such as `text`, `message`, `message_type`, `payload`, `mid`, and `thread_id` from `$input` without redeclaring them under root `inputs`.
- Manual workflows define a clear input schema when they need external inputs.
- Scheduled workflows do not assume user message fields unless they fetch them.

## Action dependencies

- Every `flow` `do` reference exists in `defs`.
- Action names are either built-in, npm-installed, or project-local custom actions, and the runtime registry can load them.
- Downstream expressions reference outputs from tasks that are guaranteed to have run, or guard with `$exists`.
- Side-effecting actions run after validation/classification gates.
- Fallback or human-handoff actions exist for uncertain routes.

## Binding correctness

- Every binding reference points to an existing def.
- Binding key matches referenced def `kind`.
- Single bindings such as `model` use a string reference.
- Multi bindings such as `tools`, `memory`, and `mcp` use arrays.
- Action `supportedBindings` allow mounted binding kinds.
- No duplicate binding references or circular binding chains.

## Memory usage

- Memory defs reference real memory definition IDs when production-ready.
- Memory scope and schema match the workflow need.
- Expressions using `$context.memory.<slug>` match actual memory definition slugs, not just binding def names.
- `update_memory` writes valid slug-keyed values.
- Sensitive memory is not overexposed to LLM prompts.

## LLM prompt safety

- Prompts delimit user-provided content.
- Classification/extraction tasks request structured fields with constrained labels.
- Prompts avoid hidden policy bypasses or instructions to reveal secrets.
- Low-confidence output leads to clarification or handoff.

## Data privacy

- YAML does not contain secrets, API keys, passwords, tokens, or real customer data.
- External requests send only the minimum required data.
- Logs and outputs avoid raw sensitive payloads unless required.

## Error handling

- Defaults include sane `timeout_ms` and retry settings.
- Non-idempotent side effects avoid unsafe retries.
- Branches handle missing fields, failed lookups, and low-confidence model responses.
- The workflow has a clear safe terminal state.

## Retry/fallback behavior

- Retry count and backoff are appropriate for each external dependency.
- Fallbacks do not silently hide failed critical actions.
- Human escalation carries enough context for a human to continue.

## Observability

- Task names are descriptive and stable.
- Outputs expose route, status, important IDs, and summary fields.
- Custom actions log failures with safe correlation details.

## Testability

- Happy path has deterministic expected outputs.
- Branches, loops, and fallback paths can be exercised with small inputs.
- LLM-dependent tasks can be mocked or constrained with structured schemas.
- YAML can be validated and compiled with runtime action and binding registries.

## Production readiness

- Placeholder IDs and demo-only data are replaced.
- Required built-in, installed, and custom actions are loadable by the runtime.
- Required bindings, memory definitions, credentials, and MCP servers exist.
- If the AI coding agent cannot access the Hexabot MCP server, the review states that runtime registry/configuration checks are limited and invites setup: set `MCP_ENABLED=false`, generate a token at `http://localhost:3000/profile`, and add the Hexabot MCP server to the agent.
- Workflow type, schedule, input schema, and publish/version state are configured outside YAML.
- Operational owner and rollback/versioning process are known.
