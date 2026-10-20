---
name: hexabot-action-creator
description: Create, scaffold, implement, review, document, and improve Hexabot v3 actions, including custom workflow actions, external API integrations, LLM-powered actions, memory reads/writes, settings or credential handling, action bindings, extension/plugin action packages, and input/output contract design. Use when wrapping business integration requirements as Hexabot actions. Do not use for generic NestJS, frontend-only work, generic workflow YAML unless action implementation is required, chatbot copywriting, generic API clients not wrapped as Hexabot actions, or non-Hexabot automation frameworks.
---

# hexabot-ai/action-creator

Use this skill for Hexabot v3 action work. Hexabot action APIs are project-defined and can evolve, so inspect the user's active Hexabot repo, custom action package, or installed package types before producing final code.

## Source of truth

Before final action code or review findings, inspect the relevant current project files. If the workspace is only this packaged skill, use the bundled references and examples, then state that runtime verification still needs a Hexabot project or action package.

When the user is working inside the Hexabot monorepo, these are the usual landmarks:

- API action surface: `packages/api/src/actions/**`.
- Built-in API action examples: `packages/api/src/extensions/actions/**`.
- Runtime binding system: `packages/api/src/bindings/**` and action binding files under `packages/api/src/extensions/actions/**/*.binding.ts`.
- Workflow runtime context and services: `packages/api/src/workflow/contexts/**`.
- Agentic action base: `packages/agentic/src/action/**`, `packages/agentic/src/dsl.types.ts`, and `packages/agentic/README.md`.
- Extension discovery: `packages/api/src/actions/actions.module.ts`, `packages/api/src/bindings/bindings.module.ts`, and `packages/api/README.md`.

When the user is working in a separate `hexabot-action-*` package or application repo, inspect that package's `package.json`, source tree, generated templates, TypeScript path aliases, and dependency exports instead of assuming monorepo `packages/*` paths exist.

Do not invent decorators, schema fields, binding kinds, registration hooks, package layout, import paths, or config conventions that are not present in the active project or installed Hexabot packages.

## Core workflow

1. Identify the requested action capability, side effects, workflow type, and target location: Hexabot monorepo API source, custom application action, npm package named `hexabot-action-*`, or standalone `@hexabot-ai/agentic` example.
2. Inspect nearby examples with the same shape when the target project is available: web/API, AI/LLM, memory, subscriber, messaging, or binding-aware action. If only this skill bundle is available, use the bundled example as illustrative guidance and call out unverified runtime assumptions.
3. Choose the implementation pattern:
   - Use API `createAction` for simple Nest-discovered actions with no custom constructor dependencies.
   - Extend API `BaseAction` for constructor-injected services, inheritance, or richer behavior.
   - Use `defineAction` only for standalone `@hexabot-ai/agentic` runtime examples, not Nest API extension actions.
4. Design the contract before code: action name, workflow types, input schema, output schema, settings schema, supported bindings, idempotency, failure behavior, logging, and tests.
5. Implement narrowly with Zod schemas, current context services, safe credential handling, and explicit outputs that workflows can reference through `$output.<task>`.
6. Add focused tests or review notes that cover parsing, settings, output shape, error paths, idempotency, and binding compatibility.

## Bundled resources

- Read `references/action-authoring-guide.md` before implementing or scaffolding action code.
- Read `references/action-contract-guide.md` when designing input/output/settings schemas or supported bindings.
- Read `references/settings-and-secrets-guide.md` for credentials, settings, environment variables, LLM model bindings, and external API calls.
- Read `references/testing-and-review-checklist.md` when reviewing an action or planning validation.
- Read `references/output-templates.md` when the user wants a polished design, scaffold, review, or documentation response.
- See `examples/create-crm-ticket.action.example.ts` for an illustrative API `createAction` pattern.

## Output defaults

- For implementation tasks, make the code change when the target Hexabot repo or action package is available and the user asked for implementation.
- For design-only tasks, provide a decision-complete action contract and call out any missing repo facts or runtime assumptions.
- For reviews, lead with findings ordered by severity and cite files or action contract fields.
- For workflow-only requests, use the Hexabot workflow skill unless action code or action contracts are required.
- Do not add or update extra locale files or translations, including French `fr.translations.json`, unless the user explicitly asks for localization work.
