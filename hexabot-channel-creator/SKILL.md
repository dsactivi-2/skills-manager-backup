---
name: hexabot-channel-creator
description: Create, scaffold, implement, review, debug, document, and improve Hexabot v3 messaging channel extensions, including local channels and npm `hexabot-channel-*` packages; HTTP webhook, Socket.IO, and SDK/Gateway transports; zod source settings and payload schemas; `SubscriberChannelDict` typing; inbound events and decoders; outbound encoders and capabilities; webhook authentication; subscriber profiles; attachments; lifecycle and health checks; dynamic discovery; packaging; and tests. Use when adapting an external messaging platform to Hexabot. Do not use for generic NestJS integrations, workflow YAML, standalone API clients, chatbot copywriting, frontend-only chat widgets, or non-Hexabot messaging adapters unless channel implementation is required.
---

# Hexabot Channel Creator

Use this skill for Hexabot v3 channel work. Treat channel APIs, platform APIs, and SDKs as version-sensitive. Inspect the active repository and installed dependency types before producing final code.

## Source of truth

Inspect the target project before implementation or review. In the Hexabot monorepo, start with:

- `packages/api/src/channel/**`, especially `README.md`, `lib/Handler.ts`, `lib/transports/**`, `lib/inbound-events/**`, `lib/outbound/**`, and `types.ts`.
- `packages/api/src/extensions/channels/web/**` for the built-in Socket.IO, event, codec, session, history, and attachment patterns.
- `packages/types/src/**` for current standard event, message, source, subscriber, attachment, and action option contracts.
- Dynamic-provider configuration and compiled extension paths in the API bootstrap/module code.

For a separate channel package, inspect its `package.json`, source tree, TypeScript configuration, installed `@hexabot-ai/api` and `@hexabot-ai/types` declarations, build output, tests, and package-manager conventions. Prefer a current official channel with the same transport and platform shape. Target-project code and installed types win over bundled examples.

Do not invent decorators, handler methods, event constructors, schema metadata, hook names, discovery paths, package exports, or internal aliases. Do not edit generated `dist/` files directly.

## Transport decision

- Default to `HttpChannelHandler` for webhook-based platforms.
- Use `WebSocketChannelHandler` only for a client that maintains a Hexabot Socket.IO connection, as the built-in web channel does.
- Use a platform SDK/Gateway client only when the platform delivers inbound events through a long-lived connection. Still extend the closest current channel base, implement required abstract methods, manage one runtime per active source, and dispatch decoded events explicitly.
- Override `handle()` only for protocol behavior the selected base class cannot express, such as an in-body verification challenge, callback acknowledgement, or a non-HTTP Gateway transport. Preserve authentication, fast acknowledgement, event context, subscriber resolution, preprocessing, and event-bus dispatch.

## Core workflow

1. Identify the target: local extension or npm package; transport; source lifecycle; webhook/Gateway authentication; platform tenant/account identity; inbound event types; outbound formats; attachments; profile lookup; and platform limits.
2. Inspect repository instructions, nearby implementations, dependency versions, package manager, and tests. Verify current official platform API or SDK documentation when network access is available.
3. Read `references/channel-authoring-guide.md` and select the smallest viable structure.
4. Design the channel contract before code: source settings, credential references, subscriber channel attributes, raw payload schemas, identity rules, event mapping, capabilities, outbound wire types, error behavior, lifecycle, and test matrix. Use `references/channel-contract-guide.md`.
5. Implement zod-first contracts, the handler, decoder/event classes, outbound encoder, and API/SDK service as the complexity requires. Keep transport orchestration small and platform conversion isolated.
6. Authenticate every external event before trust, parse unknown payloads before use, acknowledge webhooks promptly, scope events and credentials to the resolved source, and avoid secrets or full personal payloads in logs.
7. Add focused tests and run the target project's format, lint, typecheck, test, build, package-content, and registration checks. Use `references/testing-and-review-checklist.md`.
8. Report implemented formats, deliberate limitations, required platform configuration, validation performed, and any runtime checks that remain unavailable.

## Review workflow

1. Establish the expected transport and contracts from current code and platform documentation.
2. Trace inbound delivery from authentication through parsing, event construction, source context, subscriber resolution, preprocessing, and event-bus dispatch.
3. Trace every enabled capability through encoding, platform API/SDK delivery, returned message ID, and attachment URL handling.
4. Check multi-source isolation, lifecycle cleanup, retries and duplicate-event behavior, credential resolution, timestamp units, sender/recipient direction, platform limits, and build discovery.
5. Lead with findings ordered by severity. Cite files and lines, explain impact, and propose the smallest safe correction. Do not implement a review fix unless the user requests changes.

## Bundled resources

- Read `references/channel-authoring-guide.md` before scaffolding or implementing a channel.
- Read `references/channel-contract-guide.md` when designing settings, typing, inbound/outbound conversion, identity, security, attachments, lifecycle, or health.
- Read `references/package-and-integration-guide.md` for local placement, npm packaging, discovery, installation, source setup, and runtime verification.
- Read `references/minimal-http-channel.md` only when a compact HTTP starting point is useful; adapt it to current target types and platform contracts.
- See `examples/acme-http-channel/` for the illustrative files referenced by the minimal HTTP guide.
- Read `references/testing-and-review-checklist.md` for implementation validation or reviews.
- Read `references/reference-implementations.md` to choose the most relevant official example.
- Read `references/output-templates.md` when the user wants a design, implementation handoff, or review report.

## Output defaults

- For implementation requests, make the scoped source changes when the target project is available, then validate them proportionally to risk.
- For design-only requests, provide a decision-complete contract and file plan, with version-sensitive assumptions called out.
- For reviews, report evidence-backed findings before summaries.
- If only this packaged skill is available, provide an illustrative scaffold and state that typecheck, discovery, and runtime registration still require a Hexabot project.
- Add only the default-language translation files required by the target repository. Do not create extra locales unless requested.
