# Testing And Review Checklist

Use this checklist when reviewing an action or planning validation for a new action.

## Contract tests

- Parse valid input, output, and settings with the action schemas.
- Assert invalid inputs fail for required fields, formats, enums, and cross-field constraints.
- Assert custom settings do not redefine `timeout_ms` or `retries`.
- Assert default settings behave as expected.
- Assert outputs match the declared output schema on both success and failure paths.

## Registration and schema tests

- For API actions, instantiate with a mocked `ActionService` and assert registration through `onModuleInit()` when relevant.
- For built-in or module-loaded actions, verify `ActionService.getAllSchemaDefinitions()` exposes name, description, group, icon/color, workflow types, bindings, input schema, output schema, and settings schema.
- Check action names are unique and `snake_case`.
- Confirm workflow type filters hide incompatible actions.

## Execution tests

- Mock external SDKs, HTTP clients, mailers, subscriber services, credentials, memory stores, and LLM providers.
- Assert safe request construction, timeout usage, headers, payload normalization, and idempotency key propagation.
- Cover upstream success, non-2xx responses, network failure, malformed JSON, missing credentials, and invalid configuration.
- Assert logs use safe metadata and do not include raw secrets.

## Binding tests

- Assert actions reject unsupported binding kinds through the base runtime when applicable.
- For actions using `model`, `tools`, `mcp`, or `memory`, test missing required bindings and malformed binding settings.
- For custom binding kinds, test registration through `RuntimeBindingsService` and generated JSON schema definitions.
- Check nested binding allowlists when tools can mount other actions or bindings.

## Memory tests

- Test reads/writes through `context.memoryStore`.
- Validate memory slug constraints and selected memory definitions.
- Assert memory output is stable and JSON-serializable.
- For LLM memory, test prompt construction without leaking unrelated memory.

## Idempotency and retry review

- Mark read actions as retry-safe.
- For write actions, require an idempotency strategy or explicitly document that retries may duplicate side effects.
- Check task or default retry settings in any accompanying workflow YAML.
- Ensure failure outputs give workflows enough information to branch or escalate.

## Security review

- No raw secrets in inputs, outputs, workflow YAML, logs, thrown messages, or snapshots.
- No full PII payloads in logs unless already established by repo policy.
- External URLs and methods are constrained when the action could become an SSRF or data-exfiltration path.
- LLM prompts avoid unnecessary sensitive context and tool access is bounded.

## Commands

Use the target project's existing package manager and scripts. In the Hexabot monorepo, package-scoped checks usually look like:

```bash
pnpm --filter @hexabot-ai/api run typecheck
pnpm --filter @hexabot-ai/api run lint
pnpm --filter @hexabot-ai/api run test
pnpm --filter @hexabot-ai/api run build
```

For standalone `@hexabot-ai/agentic` action examples:

```bash
pnpm --filter @hexabot-ai/agentic run typecheck
pnpm --filter @hexabot-ai/agentic run test
```

For a separate `hexabot-action-*` package, run that package's local typecheck, lint, test, and build scripts, for example `pnpm run typecheck`, `pnpm run test`, and `pnpm run build` when those scripts exist. If the workspace is only this skill bundle, report that no Hexabot runtime checks were available.
