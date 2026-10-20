# Testing And Review Checklist

Use this checklist for a new channel, a substantial change, or an evidence-backed review. Skip only items that do not apply to the chosen transport and state why.

## Contents

- [Settings and typing](#settings-and-typing)
- [Webhook authentication](#webhook-authentication)
- [Inbound decoding](#inbound-decoding)
- [Event dispatch](#event-dispatch)
- [Subscriber mapping](#subscriber-mapping)
- [Outbound encoding](#outbound-encoding)
- [Attachments](#attachments)
- [Gateway and socket lifecycle](#gateway-and-socket-lifecycle)
- [Build and discovery](#build-and-discovery)
- [Security and privacy review](#security-and-privacy-review)
- [Review report severity](#review-report-severity)

## Settings and typing

- Parse empty/default settings and fully configured settings.
- Reject unknown or malformed settings where strictness is intended.
- Verify UI metadata, defaults, credential reference fields, and channel title.
- Resolve missing, invalid, and valid credential IDs without exposing values.
- Check the channel name literal matches the handler, schema, global augmentation, decoder, package, and tests.
- Typecheck `SubscriberChannelDict` augmentation and all channel attributes.
- Confirm source settings and subscriber attributes are not mixed.

## Webhook authentication

- Accept a valid GET challenge when required and reject a wrong verify token.
- Accept a valid POST signature computed over fixture raw bytes.
- Reject absent, malformed, wrong-algorithm, wrong-length, wrong-secret, and stale signatures.
- Verify constant-time comparison and timestamp replay bounds where applicable.
- Verify missing raw body fails closed.
- Verify credentials and tenant/account checks use the resolved source only.
- Assert logs and HTTP errors contain no secrets or full sensitive payloads.

## Inbound decoding

- Parse a representative real provider fixture for every supported event variant.
- Reject invalid payload shapes and tolerate irrelevant additional third-party fields when intended.
- Filter another tenant, page, workspace, phone number, bot, guild, or account.
- Decode batched events in order.
- Normalize seconds/milliseconds and invalid timestamps.
- Preserve stable event/message IDs.
- Verify sender and recipient direction for user messages, groups, bot echoes, deliveries, reads, and errors.
- Verify `StdEventType`, `IncomingMessageType`, standard message data, payload, and channel attributes.
- Return no event for unsupported provider notifications instead of manufacturing malformed messages.

## Event dispatch

- For an HTTP handler integration test, verify authentication runs before decode and invalid requests do not acknowledge success.
- Verify valid webhooks acknowledge within the provider deadline.
- Assert every event receives handler and source context.
- Assert a URL or source workflow ID propagates when supported.
- Assert subscriber resolution and initiator assignment occur before dispatch.
- Assert message preprocessing occurs before message event-bus emission.
- Assert status events use the status path.
- Cover one event failure inside a batch according to intended isolation behavior.

If the handler overrides `handle()`, compare it line-by-line with the current base implementation and test every preserved invariant.

## Subscriber mapping

- Verify stable identity for direct messages, group/channel conversations, and threads.
- Test any normalization and collision-avoidance rule.
- Return a DTO accepted by current validation, including source/channel fields where required.
- Cover profile success, absent optional fields, provider failure, avatar absence, locale/language fallback, and safe defaults.
- Verify profile lookup does not block `decode()` or expose secrets.

## Outbound encoding

- Test every enabled `OutgoingMessageType` with representative data.
- Test every disabled type is rejected by capabilities before transport delivery.
- Enforce platform text, title, payload, URL, button, element, section, file, and pagination limits.
- Cover postback buttons, web URLs, quick replies, lists, carousels, and multi-message expansion only where supported.
- Normalize URLs only according to explicit channel policy.
- Preserve source, recipient, room, thread, tenant, and reply context.
- Return a real or intentionally documented canonical platform message ID.
- Cover upstream success, non-2xx responses, SDK errors, timeouts, malformed response bodies, rate limits, missing credentials, and missing routing attributes.
- Verify non-idempotent sends are not retried blindly.

## Attachments

- Decode each supported remote media type and metadata.
- Download with mocked HTTP/SDK clients; cover non-2xx, redirects, size limits, MIME mismatch, timeout, and unsafe filenames.
- Persist inbound files through preprocessing.
- Generate an authorized outbound public URL or upload to the provider media API.
- Test expired/invalid download access and provider fetch constraints.
- Check for SSRF and unrestricted arbitrary URL retrieval.

## Gateway and socket lifecycle

- Connect every valid active source exactly once.
- Do not connect inactive or incompletely configured sources.
- Isolate clients, settings, caches, workflows, and events by source ID.
- Reuse an unchanged client and reconnect after relevant credential/account changes.
- react to source creation/update/disable hooks verified in current code.
- remove listeners and destroy clients on disable and module shutdown.
- Cover ready, reconnect, error, shard/socket failure, and login rejection states.
- Verify required provider intents, scopes, and permissions.
- Verify default workflow propagation when events bypass the webhook controller.
- Verify health output contains actionable safe information.

## Build and discovery

- Run formatter, lint, typecheck, focused tests, full package tests, and build using existing scripts.
- Confirm the compiled filename ends in `.channel.js` under a discovered path.
- Confirm declaration files resolve and public exports match `package.json`.
- Run a dry-run package listing and inspect included files.
- Install or link the package in a compatible Hexabot runtime.
- Restart the API and confirm `GET /api/channel` returns the channel and settings schema.
- Create an active source and execute one real or local-fixture inbound/outbound round trip.

## Security and privacy review

- No raw credentials in source code, fixtures, snapshots, logs, errors, package contents, or documentation.
- No full personal provider payloads in production logs.
- Signature verification fails closed and uses source-scoped secrets.
- External URLs, redirects, downloads, and uploads follow the target project's SSRF and file policies.
- Platform API permissions and Gateway intents are the minimum required.
- Multi-source caches cannot reuse a token, bot identity, tenant, or routing data across sources.
- Rich message URLs and payloads cannot inject unsupported platform markup or dangerous schemes.

## Review report severity

- Critical: authentication bypass, secret leakage, cross-source/cross-tenant delivery, arbitrary file access, or remote execution/data-exfiltration paths.
- High: missing discovery/build output, broken subscriber identity, dropped event context, incorrect sender direction, lifecycle leaks, or advertised formats that consistently fail.
- Medium: incomplete event variants, limit handling, retry/idempotency gaps, attachment edge cases, weak health signals, or poor error isolation.
- Low: maintainability, metadata, test coverage, naming, or documentation gaps with limited runtime impact.

For every finding, cite the exact file and line, show the failing data path, state the platform/Hexabot contract, and propose a bounded fix.
