# Channel Contract Guide

Design these contracts before writing transport code. Stable boundaries make channels easier to test and prevent provider details from leaking into workflows.

## Contents

- [Source settings](#source-settings)
- [Subscriber channel attributes](#subscriber-channel-attributes)
- [External payload schemas](#external-payload-schemas)
- [Event context and inbound mapping](#event-context-and-inbound-mapping)
- [Subscriber identity](#subscriber-identity)
- [Webhook authentication](#webhook-authentication)
- [Outbound capabilities and encoding](#outbound-capabilities-and-encoding)
- [Attachments](#attachments)
- [Lifecycle and multi-source isolation](#lifecycle-and-multi-source-isolation)
- [Error and retry behavior](#error-and-retry-behavior)

## Source settings

Define per-source credentials and operational options with zod. Use a name literal and a strict object:

```ts
import z from "zod";

export const ACME_CHANNEL_NAME = "acme" as const;

export const ACME_CHANNEL_SOURCE_SETTINGS_SCHEMA = z
  .strictObject({
    api_url: z.url().default("https://api.acme.example").meta({
      title: "API URL",
      description: "Base URL used for Acme messaging requests.",
    }),
    tenant_id: z.string().default("").meta({
      title: "Tenant ID",
      description: "Optional tenant filter for inbound events.",
    }),
  })
  .meta({ title: "Acme Channel" });
```

- Parse `source.settings` before use; do not trust database JSON shape.
- Add editor-facing `title` and `description` metadata.
- Keep platform account configuration on the source, not on the subscriber.
- Use safe defaults. Do not make an empty credential silently disable authentication.
- Prefer Hexabot credential references for secrets when the target version exposes `CredentialService` and the admin credential widget. Resolve values only at use time. Follow current official channel code for widget metadata and service lookup.
- Never log resolved tokens, signing secrets, raw authorization headers, or complete source settings.

## Subscriber channel attributes

Augment the global dictionary with data describing the platform relationship:

```ts
declare global {
  interface SubscriberChannelDict {
    [ACME_CHANNEL_NAME]: {
      tenantId: string;
      recipientId: string;
    };
  }
}

export {};
```

Store only attributes needed for identity, routing, threads, or replies. Do not confuse them with source credentials. Examples include page ID, phone number ID, workspace ID, chat ID, guild/channel ID, thread ID, or bot application ID.

## External payload schemas

- Accept `unknown` at the trust boundary and parse it immediately.
- Use `z.strictObject()` for payloads the channel owns.
- Use `z.looseObject()` for third-party webhooks that may add fields, while validating every field the implementation reads.
- Model discriminants and variant-specific fields so unsupported events return an empty event list instead of producing malformed message events.
- Validate timestamps, IDs, URLs, arrays, pagination, attachments, and nested content.
- Keep raw payload types separate from standard Hexabot message types.

## Event context and inbound mapping

Create each event with a `ChannelInboundEventContext` containing, in the current constructor order:

1. channel name;
2. parsed raw event;
3. typed subscriber channel attributes;
4. occurrence date;
5. external event/message ID or `null` where permitted;
6. sender foreign ID or `null` for non-user events;
7. recipient foreign ID or `null`.

Confirm the constructor against installed declarations before coding.

Use `SyntheticMessageInboundEvent` for a small text/payload channel. Create concrete `MessageInboundEvent` subclasses when the platform needs custom attachment, location, quick-reply, postback, echo, delivery, read, typing, or error behavior.

For each inbound variant, decide:

- `StdEventType` and `IncomingMessageType`;
- standard message data and optional payload;
- sender and recipient direction;
- stable message/event ID;
- timestamp unit and fallback;
- channel attributes;
- whether it represents a user, bot echo, or status event;
- whether preprocessing must download/persist attachments or enrich state.

Return multiple events for batched provider payloads. Filter events that belong to a different configured tenant, page, workspace, phone number, bot, guild, or account.

## Subscriber identity

Return a complete `SubscriberCreateDto` matching installed types. At minimum, verify:

- `foreignId` is stable and represents the intended end user or conversation identity.
- `channel` comes from `event.getChannelData()`.
- `source` is included when required by current types.
- assignment, labels, dates, avatar, locale, language, timezone, gender, and country use valid values.

Choose identity deliberately for groups and shared channels. A channel-level identity produces one Hexabot subscriber per room; a user-level identity produces one per user. Preserve the routing attributes necessary for replies. Document the choice because changing it later can split or merge conversation history.

Keep profile lookup out of `decode()`. Fetch it in `getSubscriberData()` and fail safely according to the target project's conventions. Treat avatar download as an optional hook.

## Webhook authentication

- Implement GET verification separately from POST authentication.
- Resolve the source-scoped secret before validation.
- Compute HMAC over the exact raw request bytes when required; never recompute from parsed JSON.
- use constant-time comparison after checking buffer lengths.
- enforce timestamp freshness when the provider includes a signed timestamp.
- reject absent secrets and signatures; do not downgrade to unauthenticated mode.
- scope tenant/account IDs after signature validation.
- return only safe 400/401 responses and keep sensitive details in redacted internal logs.

Account for raw-body capture in the host application. If it is unavailable, flag the integration requirement instead of authenticating the reserialized body.

## Outbound capabilities and encoding

Override `getCapabilities()` and set every supported format truthfully:

- text;
- quick replies;
- buttons;
- attachments;
- lists;
- carousels;
- typing indicator;
- maximum text length, or `0` only when no known limit exists.

Start with text only. Add a format after its semantics and limits have tests. An encoder that extends `ChannelOutboundMessageEncoder` should use the current envelope dispatch helper and explicitly map every enabled type.

For each outgoing format, validate:

- title, text, payload, URL, element, row, section, and button limits;
- allowed button combinations and URL schemes;
- pagination and “view more” behavior;
- platform-specific media type and accessibility;
- source ID and recipient/thread routing;
- whether one standard envelope expands to multiple platform messages.

Return `{ mid }` using the last or canonical platform message ID when a format expands into multiple requests. Do not return a random placeholder unless the platform truly supplies no identifier and the limitation is documented.

## Attachments

For inbound files:

1. decode metadata into an attachment-capable inbound event;
2. expose remote attachments on that event;
3. implement `getMessageAttachments(event)` to download and return the file metadata expected by current Hexabot types;
4. let message preprocessing persist files through the handler.

For outbound files, resolve a source-scoped public URL with `ChannelAttachmentService` or upload media to the provider. Override `getAttachmentPublicUrl()` when the provider cannot fetch Hexabot's signed URL or requires its own reusable media identifier. Preserve access control and the download route contract.

Set download timeouts, maximum sizes, MIME validation, redirect policy, and safe filenames in the platform API service. Avoid fetching arbitrary user-controlled URLs without SSRF protections established by the target project.

## Lifecycle and multi-source isolation

Key caches and SDK clients by `source.id`, not only by channel name. Include a fingerprint of relevant credentials/settings when deciding whether to reconnect, without retaining or logging raw secrets.

For long-lived clients:

- connect active sources at module startup;
- react to source changes using hook names verified in current code;
- disconnect disabled or deleted logical sources;
- remove listeners before destroying clients;
- handle module shutdown;
- prevent one source's bot, tenant, or token from processing another source's events;
- propagate the source's configured default workflow when the transport bypasses the webhook controller.

Implement integration health only when current APIs expose it. Report actionable counts and safe error summaries for missing settings, invalid credentials, webhook configuration failures, and disconnected clients.

## Error and retry behavior

- Authenticate and parse before acknowledging success.
- Acknowledge valid webhook deliveries quickly to limit provider retries.
- Treat provider retries as normal and preserve stable external event IDs for deduplication mechanisms.
- Do not retry non-idempotent sends blindly.
- Surface upstream status and safe correlation IDs without leaking response secrets or full user payloads.
- Isolate failures per event in batched deliveries so one bad event does not corrupt the others unless the provider requires all-or-nothing handling.
