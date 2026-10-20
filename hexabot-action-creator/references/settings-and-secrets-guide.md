# Settings And Secrets Guide

Use this guide for actions that call external systems, use LLMs, or need runtime configuration.

## Principle

Workflow YAML should reference configuration and credentials, not contain secret values. Action code resolves secrets at runtime and never logs or returns them.

## Credentials

- Prefer Hexabot credential references over raw tokens in input or settings.
- Existing API examples use UI metadata with `AutoCompleteWidget` and `entity: 'Credential'`.
- Resolve values with `context.services.credentials.findOneValue(credentialId)`.
- Treat an empty credential value as a configuration error and throw an actionable message.
- Do not include raw credential values in logs, action outputs, errors returned to workflows, or test snapshots.

Example setting field:

```ts
api_key: z.string().optional().meta({
  title: 'Credential',
  description: 'Credential used to authenticate with the external API.',
  'ui:widget': 'AutoCompleteWidget',
  'ui:options': {
    entity: 'Credential',
    valueKey: 'id',
    labelKey: 'name',
    enableEntityAddButton: true,
  },
});
```

## Environment and config

- Inspect current config and settings services before reading environment variables directly.
- API package guidance prefers central config over direct `process.env` access.
- For external action packages, document required env vars or credential records, but keep workflow YAML secret-free.
- Use settings for non-secret runtime choices such as base URL, mode, region, or response limits.

## External API actions

- Use `settings.timeout_ms` as the request timeout when the HTTP client supports it.
- Normalize upstream responses into a stable output shape.
- Include upstream status and safe request IDs when useful.
- Redact headers and payload fields that may contain secrets or PII.
- Use idempotency keys for create/update side effects when supported.
- Decide whether network errors should throw or return `{ success: false, error }` based on whether workflow branching should handle them.

## LLM actions

- Prefer existing AI base actions and schemas before creating new LLM action logic.
- Use `model` bindings for model provider, model ID, base URL, organization, and credential reference when following current built-in AI patterns.
- Do not put provider API keys directly in action inputs, outputs, or workflow YAML.
- Be explicit about prompt source, memory usage, tool access, output schema, and model settings.
- Avoid passing secrets or unnecessary PII into prompts.

## Memory actions

- Use `context.memoryStore` for workflow memory reads/writes.
- Validate memory slugs and fields against current memory definitions when the repo exposes that information.
- Return the updated or read memory values in a stable shape.
- For AI memory bindings, inspect current `memory.binding.ts` and AI base action behavior before generating code.

## Logging

- Use `context.services.logger`.
- Log action name, target system, status, safe IDs, and useful error summaries.
- Do not use `console`.
- Never log raw tokens, authorization headers, credential values, complete customer records, or full model prompts unless the existing observability policy explicitly allows it.
