# Action Authoring Guide

Use this guide after inspecting the current Hexabot repo, application repo, or standalone action package. Target project code and installed package types win over this reference when details differ. If only this skill bundle is available, treat this guide as versioned background and state that runtime verification still needs a Hexabot project.

## Current API action architecture

- API actions live on top of `@hexabot-ai/agentic` and are exposed by the Hexabot API package.
- `BaseAction` extends `AbstractAction`, is `@Injectable()`, implements `OnModuleInit`, and registers itself with `ActionService`.
- `createAction` returns an injectable `BaseAction` subclass for simple actions.
- `ActionService` stores a registry keyed by action name and exposes JSON Schema definitions for UI/workflow authoring.
- Omitted API input/output/settings schemas default to strict empty objects. Add explicit schemas for real actions.
- There is no repo-defined `@Action` decorator. Do not invent one.

## Pattern selection

- Prefer `createAction` when the action only needs `input`, `settings`, `bindings`, and `context.services`.
- Extend `BaseAction` when the action needs constructor injection, class inheritance, protected helpers, or action-specific lifecycle behavior.
- Use `defineAction` only for standalone `@hexabot-ai/agentic` workflows outside the Nest API extension runtime.
- Use existing base classes for families of actions when present, such as AI and messaging base actions.

## File placement and discovery

- In the Hexabot monorepo, built-in actions are under `packages/api/src/extensions/actions/<group>/*.action.ts`.
- In a generated or standalone `hexabot-action-*` package, inspect the package template, `package.json`, TypeScript config, and source tree before choosing import paths or file placement.
- In an application repo, inspect the configured extension output/source locations before assuming where custom actions compile.
- Runtime discovery loads compiled `.action.js` files from:
  - `node_modules/@hexabot-ai/api/dist/extensions/actions/**/*.action.js`
  - `node_modules/hexabot-action-*/**/*.action.js`
  - `dist/extensions/actions/**/*.action.js`
- Runtime binding kinds load compiled `.binding.js` files from equivalent action extension paths.
- For npm-distributed custom actions, the package name convention is `hexabot-action-*`.

## Implementation steps

1. Inspect the active project's action APIs first. In the Hexabot monorepo, start with `packages/api/src/actions/types.ts`, `base-action.ts`, and `create-action.ts`. Outside the monorepo, inspect the generated package template or installed Hexabot package exports before choosing imports.
2. Inspect at least one nearby action with the same concern:
   - External HTTP: `extensions/actions/web/http-request.action.ts`.
   - Memory writes: `extensions/actions/memory/update-memory.action.ts`.
   - LLM actions: `extensions/actions/ai/*`.
   - Subscriber actions: `extensions/actions/subscriber/*`.
   - Messaging actions: `extensions/actions/messaging/*`.
3. Define Zod schemas before writing business logic.
4. Use `snake_case` action names and stable names that match workflow `defs.*.action`.
5. Set `description`, `group`, and optionally `icon`, `color`, and `workflowTypes`.
6. Return JSON-serializable outputs only.
7. Export the action as both a named export and default export when following built-in examples.

## Workflow types

- API actions default to all workflow types unless `workflowTypes` is specified.
- Restrict conversational-only actions to `WorkflowType.conversational` when they need subscriber, message, thread, or inbound event state.
- Use `WorkflowRuntimeContext` for generic manual/scheduled/conversational actions.
- Use `ConversationalWorkflowContext` when the action requires `context.event.getInitiator()`, subscriber labels, thread context, or channel messaging.

## Runtime context services

Common services available through `context.services` include `logger`, `settings`, `content`, `contentType`, `message`, `subscriber`, `actions`, `credentials`, and `mcp`.

- Prefer `context.services.logger` over `console`.
- Use `context.memoryStore` for workflow memory operations.
- Use `context.services.credentials.findOneValue(id)` for credential values.
- Do not hold workflow runtime context references after execution.

## Localization and UI metadata

- Zod `.meta({ title, description, ... })` drives generated JSON schemas in the editor.
- Built-in actions may provide i18n JSON under paths like `i18n/en.translations.json` and `i18n/fr.translations.json`.
- Do not create or update extra locale files or translations, including French `fr.translations.json`, unless the user explicitly asks for localization work.
- If UI-visible text needs a default-language entry for the target repo pattern, update only that required default locale and mention optional additional translations as a follow-up.

## Guardrails

- Preserve source license headers in Hexabot source files.
- Do not modify generated `dist/` files directly; update source files and rebuild.
- Do not add dependencies without a clear need and without following the target project's package manager and workspace conventions.
- Do not hand-edit lockfiles unless the target project's established workflow requires it.
- Keep workflow orchestration in YAML; keep one bounded capability inside each action.
