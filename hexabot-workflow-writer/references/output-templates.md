# Output Templates

Use these response shapes when the user asks for polished workflow work.

## Generate a workflow

````markdown
Assumptions:
- ...

Workflow metadata to configure outside YAML:
- Type: conversational|manual|scheduled
- Schedule: ...
- Required credentials/bindings: ...

```yaml
# workflow YAML here
```

Validation notes:
- Confirmed all JSONata expression scalars are quoted or block-style before schema validation.
- ...
````

## Review a workflow

````markdown
Findings:
- Critical: `path.to.field` - ...
- High: `path.to.field` - ...
- Medium: `path.to.field` - ...

Open questions:
- ...

Suggested changes:
```yaml
# focused patch/example
```

Validation steps:
- ...
````

## Design a custom action

````markdown
Action: `action_name`

Purpose:
- ...

Workflow types:
- conversational|manual|scheduled

Input schema:
```ts
// zod schema sketch
```

Output schema:
```ts
// zod schema sketch
```

Settings schema:
```ts
// zod schema sketch
```

Supported bindings:
- ...

Runtime behavior:
- Idempotency: ...
- Errors: ...
- Observability: ...
- Tests: ...
````

## Propose a demo use case

````markdown
Demo: ...

Audience:
- ...

Narrative:
- ...

Workflow design:
- Type: ...
- Trigger: ...
- Actions: ...
- Bindings/memory: ...

Happy path:
- ...

Failure/handoff path:
- ...

What to show:
- ...
````
