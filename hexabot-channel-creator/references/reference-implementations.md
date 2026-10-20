# Reference Implementations

Inspect the current default branch and target project's installed versions before using these repositories. Prefer a reference with the same transport and concern; do not copy provider-specific assumptions into another platform.

## Hexabot core

- Channel module contracts and package guidance: <https://github.com/hexabot-ai/Hexabot/blob/main/packages/api/src/channel/README.md>
- Core channel source: <https://github.com/hexabot-ai/Hexabot/tree/main/packages/api/src/channel>
- Built-in web channel: <https://github.com/hexabot-ai/Hexabot/tree/main/packages/api/src/extensions/channels/web>
- Custom-channel documentation: <https://docs.hexabot.ai/developer-guide/develop-custom-channels>
- Agent-friendly Markdown documentation: <https://docs.hexabot.ai/developer-guide/develop-custom-channels.md>

Use core source to confirm:

- dynamic discovery globs;
- `ChannelHandler`, `HttpChannelHandler`, and `WebSocketChannelHandler` methods;
- event context and decoder interfaces;
- outbound encoder dispatch and capabilities;
- source/subscriber resolution and attachment services;
- health provider types and exports.

## Official channel packages

### Facebook Messenger

Repository: <https://github.com/hexastack/hexabot-channel-facebook>

Use for HTTP GET verification, raw-body HMAC verification, batched webhooks, tenant/page filtering, rich outbound formats, typing indicators, profile/avatar lookup, remote attachments, credential references, menu/profile synchronization, and health checks.

### WhatsApp Cloud API

Repository: <https://github.com/hexastack/hexabot-channel-whatsapp>

Use for Meta webhook structure, business-account and phone-number scoping, interactive replies, status/error events, provider media download, strict rich-message limits, credential resolution, and Cloud API services.

### Telegram Bot API

Repository: <https://github.com/hexastack/hexabot-channel-telegram>

Use for webhook secret-token headers, automatic webhook lifecycle, bot identity caching, private/group/thread routing, callback query acknowledgement, commands/mentions, multi-request outbound encoding, and Bot API file download.

### Slack

Repository: <https://github.com/hexastack/hexabot-channel-slack>

Use for timestamped HMAC verification, in-body URL verification, fast acknowledgement, app-home events, workspace/channel/thread identity, bot-event filtering, Block Kit encoding, file handling, and cases that justify a careful `handle()` override.

### Discord

Repository: <https://github.com/hexastack/hexabot-channel-discord>

Use for a provider Gateway/SDK rather than HTTP webhooks, one client per source, source hook synchronization, client lifecycle and cleanup, required intents, DM/guild mention filtering, button interaction acknowledgement, explicit event dispatch, and connection health.

## Choose by concern

| Concern                      | Primary reference        | Secondary reference     |
| ---------------------------- | ------------------------ | ----------------------- |
| Minimal HTTP channel         | Core channel README/docs | Facebook                |
| Raw-body HMAC                | Facebook                 | Slack/WhatsApp          |
| Timestamp replay protection  | Slack                    | Provider documentation  |
| Batched events               | Facebook/WhatsApp        | Core HTTP handler       |
| Rich message encoder         | Facebook                 | WhatsApp/Slack          |
| Platform media API           | WhatsApp                 | Telegram                |
| Group/thread identity        | Telegram                 | Slack/Discord           |
| Long-lived provider SDK      | Discord                  | Provider SDK docs       |
| Hexabot Socket.IO client     | Built-in web             | Core WebSocket handler  |
| Sessions/history/CORS        | Built-in web             | Core services           |
| Source lifecycle/health      | Discord/Telegram         | Facebook/WhatsApp/Slack |
| Credential entity references | Facebook/WhatsApp        | Telegram/Discord/Slack  |

## Inspection approach

1. Read `package.json` and the most recent commit date before code.
2. Read the handler, settings schema, global typing augmentation, payload types, decoder, encoder, API/SDK service, and tests relevant to the requested feature.
3. Compare imports and contracts to the target project's installed declarations.
4. Extract the invariant or pattern, not the provider-specific field names.
5. Verify platform behavior against official provider documentation when implementing current authentication, API versions, SDK events, limits, permissions, or deprecations.
