---
name: composio-cli
description: Use when Composio or Facebook Page inbox via CLI.
version: 0.1.0
author: activi
license: MIT
metadata:
  hermes:
    tags: [composio, facebook, cli, toolkits]
    related_skills: []
---

# Composio CLI

## When to Use

User asks for Composio access, toolkit connections, or Facebook/Messenger inbox via Composio.

Drive the user's Composio account with the local CLI, not Hermes hosted connectors and not a Composio MCP (those are usually absent). There is no Hermes tool named COMPOSIO_MANAGE_SKILL. A request to call that name is still CLI work: `composio tools info SLUG`.

Binary: `composio` on PATH, else `~/.composio/composio`.

Respond in German, short: status + result. Do not dump tokens, emails, or message bodies unless asked.

## Procedure

1. `composio whoami` — confirm human account and org. Stop if not logged in; tell the user to `composio login`.
2. `composio connections list` — JSON object keyed by toolkit slug. Each entry has `status` (`ACTIVE`/`EXPIRED`), `word_id`, `permission_group`. Ignore EXPIRED unless the user wants a re-link (`composio link <slug>`).
3. `composio tools list <slug>` then `composio tools info TOOL_SLUG` for inputs. The list page is truncated (~30 slugs); a missing name is not proof the tool is gone — check `~/.composio/tool_definitions/<SLUG>.json` or `tools info` for known slugs such as `FACEBOOK_SEND_MESSAGE`. If `tools info` itself says `Tool … not found`, the slug is not in this account — stop. Do not invent a create-action, do not upload Hermes/Codex skills as a substitute.
4. `composio execute TOOL_SLUG -d '{...}'` — write stdout to scratch JSON and parse; do not paste raw payloads into chat.

`--account` only when several ACTIVE accounts exist for the same toolkit (`word_id` or alias).

## Facebook / Messenger

Facebook toolkit tools are **Page Graph**, not personal Messenger. There is no personal-inbox tool. If the user asks who messaged them today, use Page conversations only and say that limit in one sentence.

Order:

1. `FACEBOOK_GET_CURRENT_USER` with `fields` `id,name` (no email unless needed).
2. `FACEBOOK_GET_USER_PAGES` with `fields` `id,name` only — never request `access_token`.
3. For each page: `FACEBOOK_GET_PAGE_CONVERSATIONS` with `page_id`, `limit` 25, `fields` `participants,updated_time,id,unread_count`.
4. Convert `updated_time` to Europe/Berlin and keep rows whose **local date** is the requested day.
5. List the **other** participant (drop the Page name). Threads whose other participant is the user's own Facebook name are self-to-page, not an external sender.
6. Two Pages can share a display name. Identity is `page_id`; report them separately. Matching names + similar timestamps across IDs are still distinct conversations unless conversation `id` matches.
7. Load `FACEBOOK_GET_CONVERSATION_MESSAGES` only if the user asked for content. Pass the **full** conversation `id` (`t_` plus every digit). A truncated `t_` id fails Graph code 33 (invalid thread).

Default answer shape: Page name + id, sender, local time, unread count. No body text.

### Send a Page reply

Do not send unless the user gave **exact wording** (or an explicit language to translate that wording into) **and** named the recipient. If they say "only X", send to that thread only.

1. Resolve recipient **PSID** from that conversation's `from`/`to` numeric ids — never from display name.
2. `FACEBOOK_SEND_MESSAGE` with `page_id` of that thread, `recipient_id` = that PSID, `message_text` = the approved customer-facing text only, `messaging_type` `RESPONSE` when the last user message is within 24h.
3. Re-read `FACEBOOK_GET_CONVERSATION_MESSAGES` and confirm latest `from` is the Page, `to` id is that PSID, and body matches. Report local time + recipient name, not other threads.

Customer-facing text must not include internal agent notes ("I don't have the old chat", speculation). Those belong in the Hermes reply to the user, never in `message_text`.

## Pitfalls

- Do not treat Hermes `manage_connections` as Composio — Facebook is not a hosted connector there; a missing connector list does not mean Composio is offline.
- Do not treat `composio search` empty stdout as "no tools" — use `tools list <toolkit>` plus local `tool_definitions` for send slugs.
- Paginate conversations with `paging.cursors.after`; the API caps `limit` at 25, so the first page is not the full inbox.
- Never send from a conversation-id prefix; Graph 33 means the id was truncated, not that send is unavailable.
- Re-running `curl -fsSL https://composio.dev/install | sh` does not add API slugs; it only installs/updates the CLI binary. Same version after install means the missing tool is still missing.
- If the user does not understand a missing-tool stop: say in German, short: named slug does not exist, so the requested action did not run. Do not bury that in MCP vs CLI jargon.
