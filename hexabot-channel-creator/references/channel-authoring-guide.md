# Channel Authoring Guide

Use this guide after inspecting the current target repository. Prefer the active project and installed package types whenever they differ from this versioned guidance.

## Contents

- [Architecture](#architecture)
- [Choose the target shape](#choose-the-target-shape)
- [Select the transport](#select-the-transport)
- [Start with the smallest structure](#start-with-the-smallest-structure)
- [Implement in dependency order](#implement-in-dependency-order)
- [Preserve handler invariants](#preserve-handler-invariants)
- [Avoid common dead ends](#avoid-common-dead-ends)

## Architecture

A channel is a transport boundary:

1. Resolve an active Hexabot `Source` and its per-source settings.
2. authenticate and parse an external event.
3. convert it to one or more typed `ChannelInboundEvent` objects.
4. resolve or create the subscriber represented by the event.
5. emit message or status events into the conversational workflow pipeline.
6. convert standard outgoing envelopes into platform wire payloads and deliver them.

Keep platform payloads out of workflows. Keep standard Hexabot envelopes out of platform API services. Put conversion between them in event decoders and outbound encoders.

## Choose the target shape

### Local extension

Use the active project's extension source directory. In the standard Hexabot starter layout, place the handler at:

```text
src/extensions/channels/<name>/index.channel.ts
```

Ensure the build emits:

```text
dist/extensions/channels/<name>/index.channel.js
```

### npm package

Use an unscoped package name beginning with `hexabot-channel-` unless current discovery code supports another convention. Ensure at least one compiled file ends in `.channel.js`. Read `package-and-integration-guide.md` before finalizing package metadata.

## Select the transport

### HTTP webhook

Extend `HttpChannelHandler` for most providers. Implement:

- `decode(req, source)` to return typed events.
- `doSendMessage(event, envelope, options)` to send a platform message and return `{ mid }`.
- `getSubscriberData(event)` to return a valid `SubscriberCreateDto`.

Override as needed:

- `verifyWebhook(req, res, source)` for a GET challenge.
- `verifySignature(req, res, source)` for POST authentication; throw on rejection.
- `getCapabilities()` to declare the exact supported formats and limits.
- attachment/profile hooks and `normalizeSenderId()` when the platform requires them.

The current HTTP base performs signature verification and decoding before acknowledging success, then attaches the handler and source context, resolves the subscriber, preprocesses message events, and dispatches them. Keep authentication and decoding cheap enough for the platform deadline. Avoid profile fetches, file downloads, and outbound API calls inside `decode()`.

Override `handle()` only when the protocol requires an early branch the base cannot provide. When overriding it, preserve all of the base invariants; do not accidentally omit `workflowId`, `setHandler`, `setSourceContext`, `resolveSubscriber`, `setInitiator`, `preprocess`, or the correct message/status event-bus call.

### Socket.IO client

Extend `WebSocketChannelHandler` only for a live Hexabot client transport. Implement `processSocketGet`, `processSocketPost`, `doSendMessage`, and subscriber mapping. Use the built-in web channel for CORS, sessions, thread history, ordered socket dispatch, room membership, broadcast, and connection cleanup.

Do not treat a provider's proprietary Gateway SDK as Hexabot's Socket.IO transport.

### Platform SDK or Gateway

When the provider uses a long-lived connection:

- Manage a client runtime keyed by source ID.
- Connect active sources during initialization and react to source create/update hooks.
- reconnect only when relevant settings change.
- remove listeners and destroy clients when sources become inactive or the module shuts down.
- reject or clearly mark the normal webhook `handle()` path when it does not apply.
- convert SDK callbacks into the same decoder/event pipeline used by HTTP channels.
- set handler, source context, optional workflow ID, and initiator before event-bus dispatch.
- expose health information for missing settings, connection failures, and ready clients when supported by current APIs.

Use the Discord reference for this shape.

## Start with the smallest structure

For a text-only first version, use:

```text
<channel>/
  index.channel.ts
  settings.schema.ts
  types.ts
  globals.d.ts
```

Split growing code into:

```text
<channel>/
  index.channel.ts
  settings.schema.ts
  types.ts
  globals.d.ts
  inbound/
    <name>-inbound-event-decoder.ts
    events/
  outbound/
    <name>-outbound-message-encoder.ts
  services/
    <name>-api.service.ts
  i18n/
    en.translations.json
  __tests__/
```

Keep the handler focused on transport and source orchestration. Split when multiple event types, message formats, or external API operations make it hard to audit.

## Implement in dependency order

1. Define the channel name literal and strict source settings schema.
2. Augment `SubscriberChannelDict` with stable platform relationship attributes.
3. Define external payload schemas with zod and infer the TypeScript types.
4. Write the API/SDK service with safe request construction and explicit upstream errors.
5. Map each relevant inbound platform event to a concrete or synthetic Hexabot event.
6. Map each supported outgoing envelope to a platform payload.
7. Implement the handler and inject per-channel helpers with the current `@ExtensionInject()` pattern when appropriate.
8. Add subscriber, attachment, profile, lifecycle, and health behavior only when required.
9. Add tests before enabling capabilities beyond text.

## Preserve handler invariants

- Decorate the discoverable handler with `@Injectable()` and default-export it when the current loader expects that shape.
- Pass the channel name and source settings schema to `super()`.
- Return the actual external message identifier from `doSendMessage()` whenever the platform provides one.
- Use the inbound sender identity for subscriber resolution. Correct the direction for delivery receipts, read receipts, bot echoes, and channel-level events.
- Construct valid dates and normalize seconds versus milliseconds explicitly.
- Attach platform tenant/account attributes that allow replies to use the same source and destination context.
- Declare only capabilities the encoder and transport fully support.
- Keep one channel name literal aligned across the handler, settings, decoder, typing augmentation, tests, and package identity.

## Avoid common dead ends

- Do not add per-source channel settings as a dynamically discovered `*.settings.js` provider. Pass their zod schema to the handler constructor.
- Do not parse third-party payloads with TypeScript casts alone.
- Do not put every concern into a thousand-line handler when codecs and services can be tested independently.
- Do not copy private monorepo aliases such as `@/` into a standalone npm package unless its TypeScript and runtime build support them.
- Do not copy a provider implementation mechanically. Preserve the target platform's actual identity, acknowledgement, retry, and rich-message semantics.
- Do not enable a rich capability with a lossy fallback unless the user explicitly accepts that behavior.
