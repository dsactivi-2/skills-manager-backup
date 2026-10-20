# Output Templates

Use these response shapes when the user wants polished Hexabot action work.

## Action design

````markdown
Action: `action_name`

Purpose:
- ...

Runtime:
- Target: Hexabot monorepo API action | application API extension action | npm `hexabot-action-*` package | standalone agentic action
- Workflow types: conversational | manual | scheduled
- Pattern: `createAction` | `BaseAction` | `defineAction`

Contract:
```ts
// input schema
// output schema
// settings schema
```

Bindings:
- ...

Behavior:
- Side effects: ...
- Idempotency: ...
- Failure handling: ...
- Observability: ...

Tests:
- ...
````

## Scaffold or implementation summary

````markdown
Implemented:
- ...

Contract:
- Action name: `...`
- Inputs: ...
- Outputs: ...
- Settings: ...
- Bindings: ...

Validation:
- ...

Notes:
- ...
````

## Action review

````markdown
Findings:
- Critical: `path:line` - ...
- High: `path:line` - ...
- Medium: `path:line` - ...

Open questions:
- ...

Suggested changes:
```ts
// focused patch or contract sketch
```

Validation gaps:
- ...
````

## External integration action

````markdown
Integration: ...

Action contract:
- Name: `...`
- Inputs: ...
- Outputs: ...
- Settings: ...
- Credential handling: ...

Runtime behavior:
- Request: ...
- Response normalization: ...
- Error handling: ...
- Idempotency: ...
- Rate limits/retries: ...

Required setup:
- Credential record: ...
- Environment/config: ...
- Dependency/package: ...

Tests:
- ...
````

## Action documentation

````markdown
### `action_name`

Purpose: ...

Inputs:
- `field`: ...

Outputs:
- `field`: ...

Settings:
- `field`: ...

Bindings:
- ...

Example workflow task:
```yaml
defs:
  task_name:
    kind: task
    action: action_name
    inputs:
      field: =$input.field
```

Operational notes:
- ...
````
