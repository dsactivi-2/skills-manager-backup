---
name: Voiceinfraai
description: Use when building, configuring, and deploying AI voice agents for inbound and outbound calls. Reach for this skill when agents need to create voice workflows, integrate with PBX systems, connect APIs and CRMs, manage call transfers, or troubleshoot agent behavior and call routing.
metadata:
    mintlify-proj: voiceinfraai
    version: "1.0"
---

## Codex wiring

This host already has global VoiceInfra tooling:

- Live MCP `voiceinfra` at https://eu.portal.voiceinfra.ai/mcp (OAuth, region-specific)
- Docs MCP `voiceinfra-docs` at https://docs.voiceinfra.ai/docs/mcp (public docs, no login)
- Plugin `voiceinfra@mcpmarket` at ~/plugins/voiceinfra

Use `search_voice_infra`, then `query_docs_filesystem_voice_infra` (`head`/`cat` on `.mdx` paths). Live workspace tools only after `codex mcp login voiceinfra`. Never print API keys or OAuth tokens.

The live address is `https://<region>.portal.voiceinfra.ai/mcp`. Regions: `eu`, `us`, `anz`, `pk`. `https://<region>.voiceinfra.ai/mcp` does not resolve on this host. If OAuth fails, copy the address from Connected apps in the portal.

Two different MCP roles:

1. VoiceInfra **as an MCP server for Codex/Claude** — this live MCP, manage agents/numbers/logs from the client.
2. VoiceInfra **as an MCP client during a call** — Settings → Integrations, the agent calls external tools mid-conversation.

REST uses header `X-API-Key: vk_...`. Keys stay out of Git, chat, YAML, and reports.

# VoiceInfra AI Skill

## Product summary

VoiceInfra AI is a platform for deploying AI voice agents that integrate with your existing phone system (PBX, Twilio, Telnyx, WhatsApp) without replacing infrastructure. Agents register as SIP extensions on 3CX, Yeastar, FreePBX, or any SIP-compatible PBX, or use provisioned phone numbers. Every call produces a transcript, summary, and structured data. Key files and concepts: **Agents** (the AI handling conversations), **Workflows** (branching conversation graphs with nodes and edges), **Functions** (REST API integrations), **Knowledge bases** (documents for RAG-powered answers), **Extensions** (SIP registration on your PBX), **Numbers** (provisioned or imported phone lines). Primary docs: https://docs.voiceinfra.ai/docs

## When to use

Use this skill when:
- Building or configuring AI voice agents for customer support, lead qualification, appointment booking, or after-hours handling
- Integrating agents with existing PBX systems (3CX, Yeastar, FreePBX, Asterisk) via SIP extensions
- Connecting agents to external systems: CRMs (Salesforce, HubSpot, Pipedrive), custom APIs, webhooks, or automation platforms (Zapier, Make, n8n)
- Designing multi-step conversation flows with branching logic, transfers, and real-time API calls
- Setting up call transfers to humans or other agents with context briefing
- Troubleshooting agent behavior, call routing, or integration failures
- Deploying agents to live phone numbers or PBX extensions
- Managing agent versions, drafts, and publishing workflows

## Quick reference

### Core Concepts

| Term | Definition |
|------|-----------|
| **Agent** | The AI handling a conversation — its greeting, instructions, model, voice, and attached tools |
| **Workflow** | A branching conversation graph with nodes (Start, Conversation, Tool, Transfer, Knowledge, End) and edges (routing conditions) |
| **Extension** | SIP registration on your PBX; appears as a standard desk phone extension |
| **Number** | A phone line: provisioned from VoiceInfra, imported from Twilio/Telnyx, or a WhatsApp Business number |
| **Function** | A REST API endpoint your agent can call mid-conversation to fetch or update data |
| **MCP Server** | Model Context Protocol integration for real-time tool access during calls |
| **Knowledge Base** | Documents or crawled web pages your agent answers from (RAG-powered) |
| **Draft vs Published** | Drafts are edits you test; published versions are live to callers. Test Call uses draft; live calls use published |

### Essential Workflows

| Task | Path |
|------|------|
| Create first agent | Sculptor (⌘J) → describe what you want → review diff → approve → Test Call → Publish |
| Register PBX extension | Phone Numbers → PBX Extensions → Add Extension → fill SIP credentials → whitelist VoiceInfra IP → assign agent |
| Add custom function | Settings → Functions → Create Function → set endpoint, auth headers, description → assign to agent |
| Set up call transfer | Agent → Call Transfer tab → add destination (phone/SIP/extension) → set transfer message → test |
| Connect webhook | Settings → Webhooks → Add Webhook → enter endpoint URL → set secret → test → enable |
| Publish changes | Agent → review diff → Publish → optionally add label and summary → new calls use published version |

### API Endpoints

| Method | Path | Purpose |
|--------|------|---------|
| `POST` | `/api/v1/outbound_call` | Place an outbound call from an agent |
| `GET` | `/api/v1/agents/active-calls` | List calls currently in progress |

### Authentication

- **REST API**: Pass `X-API-Key: vk_YOUR_API_KEY` header on every request
- **MCP Server**: Use OAuth 2.0 with PKCE; clients exchange authorization code for access token
- **API Keys**: Created in portal under **API Keys**; shown once at creation; start with `vk_` prefix

### Sculptor (AI Builder)

- Open with **⌘J** (Ctrl+J on Windows) or click **Sculptor** in sidebar
- Describe what you want in plain language: *"Create a receptionist that books appointments"*
- Sculptor shows each action as a card; approve diffs before they apply
- Low-risk edits (greeting, voice) apply automatically with Undo link
- Sculptor cannot delete agents, publish without approval, or spend money without asking

## Decision guidance

### When to use Sculptor vs Manual Builder

| Scenario | Use Sculptor | Use Manual Builder |
|----------|--------------|-------------------|
| First agent, unclear requirements | ✓ | — |
| Simple agent (greeting + knowledge) | ✓ | — |
| Complex multi-step workflow with many branches | — | ✓ |
| Rapid iteration and testing | ✓ | — |
| Fine-grained control over every node | — | ✓ |
| Adjusting existing agent | ✓ | — |

### When to use Function vs MCP Server vs Webhook

| Use case | Tool | Timing |
|----------|------|--------|
| Look up data during call (e.g., account balance) | Custom Function or MCP | Mid-call |
| Create ticket or update CRM during call | Custom Function or MCP | Mid-call |
| Send SMS or email while caller waits | Custom Function (Async) | Mid-call |
| Log call data to your system after call ends | Webhook | Post-call |
| Trigger outbound call from CRM event | Automation platform + Outbound API | Async |
| Complex tool ecosystem (calendar, DB, API) | MCP Server | Mid-call |

### When to use Cold vs Warm vs Attended Warm Transfer

| Transfer Type | When to use |
|---------------|------------|
| **Cold Transfer** (SIP Refer) | Simple escalations; agent drops off immediately |
| **Warm Transfer** (SIP Invite) | Agent stays on line until human answers; good for continuity |
| **Attended Warm Transfer** | VIP callers or complex issues; AI briefs human agent with context before stepping back |

### When to use PBX Extension vs Provisioned Number vs Imported Number

| Channel | When to use |
|---------|------------|
| **PBX Extension** | You have existing PBX (3CX, Yeastar, FreePBX); no new phone number needed; agent joins your ring groups |
| **Provisioned Number** | You need a new phone line; available in US, Australia, Singapore; ready in minutes |
| **Imported Number** | You already have numbers on Twilio or Telnyx; no porting required |

## Workflow

### Building and Deploying an Agent

1. **Describe the agent** — Open Sculptor (⌘J) and describe what you want: *"Support agent that answers questions about our hours and transfers billing to extension 500"*

2. **Review and approve changes** — Sculptor shows each action as a card. Review diffs and approve before they apply. Reject and ask for adjustments if needed.

3. **Add knowledge** — If the agent needs to answer from documents, upload files or crawl your website in the **Knowledge Base** section. Attach the knowledge base to the agent.

4. **Connect integrations** — If the agent needs to call APIs or look up data:
   - For REST endpoints: Create a **Custom Function** in Settings → Functions
   - For complex tools: Set up an **MCP Server** in Settings → Integrations
   - For post-call logging: Configure a **Webhook** in Settings → Webhooks

5. **Assign a phone channel** — Choose one:
   - **PBX Extension**: Register on your existing PBX (Settings → Phone Numbers → PBX Extensions)
   - **Provisioned Number**: Buy a number from VoiceInfra (Settings → Phone Numbers → Provision)
   - **Imported Number**: Connect Twilio or Telnyx (Settings → Phone Numbers → Import)

6. **Test the agent** — Click **Test Call** on the agent. Speak to it as a caller would. Watch the transcript and tool execution in real time. Adjust the prompt, voice, or functions and test again.

7. **Publish** — When satisfied, click **Publish**. Optionally add a label and change summary. New calls immediately use the published version. Calls already in progress finish on the previous version.

8. **Monitor** — Check **Calls** → **Analytics** to see volume, duration, outcomes, and transcripts. Use **Webhooks** to sync call data to your own systems.

### Integrating with a PBX

1. **Create extension on PBX** — In your PBX admin console, create a standard SIP extension. Note the extension number, SIP username, realm/domain, and password.

2. **Whitelist VoiceInfra IP** — Copy the IP from your portal (Phone Numbers → your number → Connection details). Add it to your PBX firewall's allowed IP list. This is required.

3. **Register in VoiceInfra** — Go to Phone Numbers → PBX Extensions → Add Extension. Fill in:
   - Display Name (e.g., "Support AI")
   - Extension Number
   - PBX Domain (SIP realm)
   - SIP Username
   - SIP Password
   - Call Direction (Inbound, Outbound, or Both)

4. **Assign agent** — Select which agent answers this extension. Save. The extension registers immediately.

5. **Test** — Call the extension from a desk phone or softphone. The agent should answer.

### Adding a Custom Function

1. **Go to Settings → Functions → Create Function**

2. **Name the function** — Use alphanumeric and underscores only (e.g., `check_order_status`)

3. **Write a description** — Be specific: *"Call this when the user asks about their order status or delivery. Requires the order ID."* The AI uses this to decide when to invoke the function.

4. **Set the endpoint** — Enter the full URL. Use `{placeholder}` for dynamic path parameters (e.g., `https://api.example.com/orders/{order_id}`)

5. **Choose request type** — GET (fetch data), POST (create/update), or Async (fire-and-forget)

6. **Add auth headers** — Include any headers your API requires (e.g., `Authorization: Bearer YOUR_KEY`). Headers are encrypted at rest.

7. **Define request body** (POST only) — Specify the JSON structure with placeholders for caller-provided values

8. **Test** — Click Test Function, enter sample parameters, review the response

9. **Assign to agent** — Open the agent, go to Functions tab, enable this function

### Setting Up a Call Transfer

1. **Open agent → Call Transfer tab**

2. **Select transfer type** — Cold, Warm, or Attended Warm

3. **Add destination** — Enter phone number (E.164 format), SIP URI, or PBX extension. Give it a label (e.g., "Billing Team")

4. **Set transfer message** — What the agent says before transferring (e.g., *"Let me connect you with our billing specialist."*)

5. **For Attended Warm**: Add **context instructions** — the script the AI uses to brief the human agent

6. **Set decline message** — What to say if the destination is unavailable (e.g., *"Our team is unavailable. I can schedule a callback."*)

7. **Test** — Use Test Call and trigger the transfer condition to hear it

## Common gotchas

- **Whitelist VoiceInfra IP before registering PBX extension** — Without this, SIP registration fails silently. The IP is region-specific; copy it from your portal, not from docs.

- **API key in X-API-Key header is case-sensitive** — Typos or wrong casing cause 401 errors. Copy directly from your secrets manager.

- **Functions need specific descriptions** — Vague descriptions ("look up data") lead to missed or incorrect invocations. Start with "Call this when the user asks about…"

- **Test Call uses draft; live calls use published version** — Changes don't reach callers until you publish. Always test before publishing.

- **Publishing blocked by unpublished dependencies** — If an agent uses a function or MCP server, those must be published first. Publish dependencies before the agent.

- **Knowledge base changes take effect immediately** — Unlike agents, knowledge base documents are not versioned. Adding or removing a document affects live calls right away.

- **Webhook endpoints must return 200 within timeout** — Endpoints that time out or return non-2xx are retried automatically but eventually marked failed. Check your server logs.

- **Custom function parameters must match conversation context** — If a function needs `order_id` but the agent never extracted it, the function won't be called. Ensure the agent's prompt or workflow extracts required values.

- **Transfer destinations must be reachable** — Phone numbers must be valid E.164 format; SIP URIs must be resolvable; extensions must exist on your PBX. Test transfers before going live.

- **Drafts are lost if you discard them** — Discarding a draft cannot be undone. If you might want the changes back, publish instead and roll back later if needed.

- **Region cannot be changed after signup** — Choose the region closest to where you operate during account creation. It cannot be moved later.

- **Outbound calls require full account verification** — Phone verification unlocks inbound calls; full verification (ID check) is needed for outbound. Check your account status in Settings.

## Verification checklist

Before publishing an agent or deploying to production:

- [ ] **Agent has a greeting** — Test Call should hear an opening message
- [ ] **Knowledge base is attached** — If the agent should answer from documents, verify the knowledge base is attached and contains the right content
- [ ] **Functions are tested** — Run Test Function for each custom function; verify the API response is what you expect
- [ ] **Transfer destinations are valid** — Phone numbers are E.164 format; SIP URIs are resolvable; extensions exist on your PBX
- [ ] **Test Call works end-to-end** — Speak to the agent, trigger tool calls, test transfers, verify the transcript is accurate
- [ ] **Dependencies are published** — Any function or MCP server the agent uses must be published (not draft)
- [ ] **Webhook endpoint is live** — If using webhooks, confirm your endpoint is publicly accessible and returns 200 on test
- [ ] **PBX extension is registered** — If using a PBX, confirm the extension shows as registered in your PBX admin console
- [ ] **Caller ID and transfer routing are correct** — For transfers, verify the destination receives the right Caller ID and routing information
- [ ] **Publish with a label** — Add a descriptive label and change summary so version history is clear

## Resources

- **Comprehensive page navigation**: https://docs.voiceinfra.ai/docs/llms.txt
- **Introduction & key concepts**: https://docs.voiceinfra.ai/docs/introduction
- **Quickstart (first agent in 10 minutes)**: https://docs.voiceinfra.ai/docs/quickstart
- **Workflow Builder (multi-step conversations)**: https://docs.voiceinfra.ai/docs/agents/workflow-builder
- **API Reference (outbound calls & webhooks)**: https://docs.voiceinfra.ai/docs/api/overview
- **Integrations overview (CRM, webhooks, MCP, functions)**: https://docs.voiceinfra.ai/docs/integrations/overview
- **PBX Extensions (SIP registration)**: https://docs.voiceinfra.ai/docs/channels/pbx-extensions
- **Custom Functions (REST API integration)**: https://docs.voiceinfra.ai/docs/integrations/custom-functions
- **Call Transfer (human & agent handoff)**: https://docs.voiceinfra.ai/docs/calls/transfer
- **Publishing & Versions (drafts, rollback)**: https://docs.voiceinfra.ai/docs/agents/publishing

---

> For additional documentation and navigation, see: https://docs.voiceinfra.ai/docs/llms.txt