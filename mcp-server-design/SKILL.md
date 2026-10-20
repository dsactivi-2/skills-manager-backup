---
name: mcp-server-design
description: "Use when designing how an MCP server should expose tools."
version: 1.0.0
license: MIT
metadata:
  hermes:
    tags: [MCP, architecture, tools, router, workflow]
    related_skills: [native-mcp, mcp-scraper-server, mcp-hub-management]
---

# MCP server design (agent-facing architecture)

Use when the user asks how MCP works, how to build a server, whether the agent must follow the server, how to filter tools by need/category/use-case, or how to stack levels (wizard / Entscheidungsbaum).

Not for: wiring a server into Hermes (`native-mcp` / `hermes-mcp-http`), scraping a site (`mcp-scraper-server`), or installing a multi-client hub GUI (`mcp-hub-management`).

User-facing answers: short German, tables, no protocol dump unless asked.

## Mental model

MCP is a **socket with real buttons**, not a system prompt.

| Layer | Guaranteed? | What it is |
|---|---|---|
| Whether the agent presses a button | **No** (soft) | Same as a prompt. Model can skip, pick wrong, or invent. |
| What runs after `tools/call` | **Yes** (hard) | Your code, schema, auth, refusals. Like an API. |

Official protocol: host calls `tools/list` (full catalog, optionally paginated), model chooses, host sends `tools/call`. The server usually **never sees the user question**. MCP does not dictate how the LLM uses tools.

Skills (SKILL.md) are **not** an MCP primitive. Expose them yourself as tool text, resources, or prompts.

## Discovery is not a filter

The host does **not** ask “I need X — show matching tools.” It asks for the catalog.

| User hopes | What actually happens |
|---|---|
| Agent: I need X → server shows 2 matches | Host: `tools/list` → server returns **all advertised tools** |
| Host picks category “CRM” | Host picks nothing. It registers the list or defers it. |
| Pagination = category pages | Pagination is just a long list. Hosts fetch everything. |

You can **fake** “I need X” only by advertising a small entry set (`ich_brauche`, `bereich_*`, `usecase_*`) and returning matches **in the tool result**. Do not rely on live `tools/list` mutation + `listChanged` in Hermes — session tool registries often stay stale.

## Patterns (pick the hardest one that still fits)

### 1. Open toolbox (weak)

Expose every domain tool (`get_workflow`, `list_nodes`, …). Agent may ignore any router/meta-tool.

### 2. Category door (medium)

Advertise only `bereich_voice`, `bereich_n8n`, `bereich_crm` + `ausfuehren`. Domain tools stay hidden. Agent must open a door to see the next knobs — still chooses among legal doors (soft).

### 3. Use-case façade / router (strong) — prefer this for mixed platforms

Advertise use-cases, not products: `usecase_neuer_voice_agent`, not “here are 20 n8n tools.”

- **Façade (hard):** router calls Dograh / n8n / CRM APIs internally. Agent never sees platform catalogs.
- **Zettel-Router (soft, avoid):** reply “now use MCP n8n.” Agent can ignore; that MCP may not even be connected. MCP-1 **cannot** retarget the host onto MCP-2.

Hubs (ToolHive) start many servers. They do **not** filter by use-case.

### 4. Multi-level wizard (strong for branching)

State machine with a **ticket**. Two durable tools:

- `start(usecase)` → `ticket`, level-1 runbook, 2–3 legal buttons
- `waehle(ticket, knopf)` → reject illegal transitions; return next runbook + next legal buttons

Different level-1 choices yield different level-2 tool sets. Store state server-side keyed by ticket; MCP requests are not a reliable session. Never swap the host’s tool list between levels — put next buttons **in the result**.

Choice among the **legal** buttons stays soft (system prompt). Make a step hard by offering **one** button.

Detail + example payloads: `references/layered-usecase-router.md`.

## Build checklist

1. Name the use-case, not the vendor.
2. Advertise as few tools as possible (`start` / `waehle` or one `mach`).
3. Validate args; refuse unknown tickets and illegal knobs.
4. Put runbook + expected result shape in every reply.
5. Execute side effects in server code, not in “please call MCP X” prose.
6. Verify with a real `tools/call`, not only “connected.”

## Pitfalls

- Packing 80 tools and hoping the model asks only for X — catalog size hurts **selection**, not just tokens.
- Adding `ich_brauche` **plus** all domain tools — agent skips the door.
- Treating tool descriptions as a workflow engine — descriptions are soft; code is hard.
- Mid-session `listChanged` as the branching mechanism on Hermes.
- Confusing host deferred-tool search (`tool_search`) with server-side intent routing.
