# Action Design Guide

Actions are reusable runtime capabilities called by workflow task defs. Design actions as small, typed units with clear contracts and bounded side effects.

## How to think about actions

- A workflow decides when to run; an action performs one capability.
- Actions should be generic enough to reuse, but specific enough to have a stable input/output contract.
- Keep orchestration, routing, and branching in YAML; keep integration details inside actions.
- Hexabot API actions are the built-in baseline. Deployments can also load npm-installed action packages or project-local custom actions from a Hexabot CLI-bootstrapped project.

## Naming conventions

- Use `snake_case` action names.
- Prefer verb-object names: `send_mail`, `retrieve_rag_content`, `subscriber_handover`, `update_memory`.
- Avoid business-specific names when a generic action can support multiple workflows.

## Input/output contracts

- Define zod schemas for input, output, and settings.
- Inputs are task-specific parameters evaluated from YAML literals or JSONata expressions.
- Outputs should be stable, JSON-serializable, and easy to reference from `$output.<task>`.
- Settings should hold execution configuration, not business payload.
- Do not redefine base setting keys such as `timeout_ms` or `retries` in custom settings schemas.

## Idempotency

- Make read actions naturally repeatable.
- For write actions, accept an idempotency key or use stable external IDs when available.
- Treat retries carefully for side effects like sending messages, updating labels, creating tickets, or posting webhooks.
- Document whether retries are safe.

## Error handling

- Validate inputs before calling external systems.
- Throw for unrecoverable configuration errors.
- Return explicit failure objects only when downstream workflow branches should handle the failure.
- Keep error messages actionable and avoid exposing secrets.

## Logging and observability

- Use the Hexabot logger from workflow context services.
- Log action name, target system, status, duration if available, and safe correlation IDs.
- Do not log API keys, bearer tokens, full credentials, or unnecessary PII.
- Return useful identifiers in outputs, such as ticket IDs or HTTP status codes.

## Secrets and environment variables

- Read configuration through existing config, credential, or settings services.
- Do not require workflow YAML to contain secret values.
- If an action uses binding settings like `model.api_key`, treat it as a credential reference, not a raw secret.

## Integration boundaries

- Keep vendor SDKs, HTTP clients, and protocol-specific transformation inside the action.
- Normalize external responses into a stable action output.
- Time out external calls and use retries only when safe.
- Keep side effects explicit in the action description.
- For installed/custom actions, document how the action is discovered, its package or project path, and its required credentials/settings.

## Bindings

- Declare `supportedBindings` only for binding kinds the action actually consumes.
- AI actions commonly support `model`, `tools`, `mcp`, and `memory`.
- Tool binding defs with `actionPolicy: required` need an action name.
- Validate nested binding support if a binding def itself mounts other bindings.

## Testing expectations

- Unit test input parsing, settings parsing, output parsing, and error cases.
- Test supported binding behavior where relevant.
- For side effects, mock external services and assert idempotency behavior.
- Add workflow-level tests when changing how actions are mounted or used by the runner.
