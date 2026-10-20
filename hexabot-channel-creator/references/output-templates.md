# Output Templates

Use the smallest template that makes assumptions, decisions, and verification clear. Omit empty sections.

## Contents

- [Channel design](#channel-design)
- [Implementation handoff](#implementation-handoff)
- [Review report](#review-report)
- [Illustrative scaffold without a target repo](#illustrative-scaffold-without-a-target-repo)

## Channel design

```markdown
## Proposed channel

- Target: local extension | `hexabot-channel-<name>` package
- Transport: HTTP webhook | Hexabot Socket.IO | provider SDK/Gateway
- Subscriber identity: <stable identity and group/thread policy>
- Source scope: <tenant/account/bot/page/workspace identifiers>
- Authentication: <GET verification and POST/Gateway authentication>

## Contract

| Boundary              | Decision                                 |
| --------------------- | ---------------------------------------- |
| Source settings       | <credential refs and options>            |
| Channel attributes    | <stored routing/identity data>           |
| Inbound events        | <supported variants and mappings>        |
| Outbound capabilities | <formats and limits>                     |
| Attachments           | <download/upload/public URL strategy>    |
| Lifecycle             | <source hooks, clients, cleanup, health> |

## File plan

- `<path>` — <responsibility>

## Validation plan

- <unit, build, discovery, and runtime checks>

## Assumptions or open decisions

- <version-sensitive or product decision>
```

## Implementation handoff

```markdown
Implemented <channel and scope>.

Key behavior:

- <inbound/authentication behavior>
- <outbound/attachment behavior>
- <identity/lifecycle behavior>

Validation:

- `<command>` — passed
- `<command>` — passed
- Runtime registration — passed | not available because <reason>

Deliberate limitations:

- <unsupported event or format>

Platform setup still required:

- <webhook URL, permissions, intents, credentials, or source settings>
```

## Review report

```markdown
## Findings

1. **[High] <finding title>** — `<file:line>`
   <Observed data path, impact, violated contract, and bounded fix.>

## Open questions

- <question that changes the implementation decision>

## Validation gaps

- <check not run and why>

## Summary

<Brief overall assessment after the findings.>
```

## Illustrative scaffold without a target repo

```markdown
This scaffold is illustrative because no target Hexabot project or installed package declarations were available. Before use, reconcile imports, handler methods, event constructors, DTO fields, dependency versions, and discovery output against the target runtime.

Files:

- `settings.schema.ts`
- `globals.d.ts`
- `types.ts`
- `index.channel.ts`
- focused tests

Runtime verification still required:

- typecheck against installed `@hexabot-ai/api` and `@hexabot-ai/types`;
- compiled `.channel.js` discovery;
- `GET /api/channel` registration;
- active source and inbound/outbound round trip.
```
