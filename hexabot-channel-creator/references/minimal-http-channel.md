# Minimal HTTP Channel

Use the files under `../examples/acme-http-channel/` as an illustrative text-only starting point when no closer channel exists. Reconcile every import, constructor, DTO field, and helper with the target project's installed Hexabot declarations before adapting it.

The example demonstrates:

- a strict per-source settings schema with Hexabot credential references;
- `SubscriberChannelDict` augmentation for reply routing;
- loose third-party webhook schemas parsed with zod;
- a discoverable default-exported `HttpChannelHandler`;
- text-only capabilities;
- raw-body HMAC verification with constant-time comparison;
- source/tenant filtering and synthetic inbound text events;
- outbound text delivery using a resolved API credential;
- complete subscriber mapping;
- seconds-versus-milliseconds timestamp normalization.

Keep the example compact only for the first version. Split conversion and I/O when adding more behavior:

- Move multiple inbound variants into a `ChannelInboundEventDecoder` plus concrete event classes.
- Move rich outbound formats into a `ChannelOutboundMessageEncoder`.
- Move HTTP calls, timeouts, rate-limit handling, file transfer, and upstream error decoding into an injectable API service.
- Add source lifecycle and health only when the platform requires webhook registration or a long-lived client.

Before enabling an adapted channel:

1. Confirm the host exposes the exact raw request bytes required for signature verification.
2. Confirm `CredentialService`, `ModuleRef` lookup, and credential widget metadata against current official channel code.
3. Replace the illustrative endpoint, header, payload, tenant, identity, and response contracts with the provider's official definitions.
4. Add GET verification only when the provider requires it.
5. Replace generic subscriber names with a profile lookup outside `decode()` when useful.
6. Add settings, signature, decoder, outbound, subscriber, build, discovery, and runtime registration tests.
7. Enable only capabilities covered by the adapted encoder and tests.

Do not ship the Acme example as-is. It intentionally omits provider-specific retry policy, rate limiting, webhook replay windows, request timeouts, rich messages, attachments, and integration health.
