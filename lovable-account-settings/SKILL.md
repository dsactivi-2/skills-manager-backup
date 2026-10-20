---
name: lovable-account-settings
description: "Use when auditing Lovable LinkedIn/account skill unlocks."
version: 1.0.0
license: MIT
metadata:
  hermes:
    tags: [mcp, lovable, account]
---

# Lovable account settings and LinkedIn skills

Use this for **account-level** questions: LinkedIn skills (Beta), which skills can unlock, profile/preferences, 2FA, training opt-out. For building/deploying apps, load `lovable-mcp` instead.

Official docs: https://docs.lovable.dev/introduction/lovable-account-settings.md
UI: https://lovable.dev/settings/account
Catalog: `references/linkedin-skills.md`

`lovable-mcp` is hub-installed and overlaps on MCP tool names. Do not duplicate its setup; call its tools from here.

## Unlock rules

A LinkedIn skill unlocks when **one** project meets **both**:

1. Classified in that skill's category (auto after **≥5 messages**)
2. Live app has **≥20 visitor sessions**, bots excluded, cumulative

Fraud/abuse accounts are ineligible. Each skill is independent. Only **one** skill can be posted to LinkedIn at a time. "Vibe coding level" is sunset.

## Pitfalls

- `list_workspace_skills` is **not** LinkedIn skills. It lists workspace agent `SKILL.md` files.
- MCP has **no** official classification or unlock endpoint. Settings UI is source of truth.
- `get_project_analytics` `visitors` is a **proxy**, not bot-filtered sessions.
- `list_messages` `limit=100` can be multi-MB. Count `role=user` on the persisted file. If the first page already has ≥5 user messages, stop paging.
- A public marketing site with a lead form is **Website Development**, not Sales Enablement (that wants a CRM / lead-gen **tool** / deck).
- Unpublished projects cannot meet the live-session rule.

## Eligibility audit (MCP proxy)

1. `get_me` then `list_workspaces` / `get_workspace`
2. `list_projects` with `visibility=all`, paginate (`publish_status=any` then filter `is_published`)
3. Per published project: `list_messages` — count user roles; stop once ≥5 is proven
4. `get_project_analytics` from project `created_at` through now (RFC 3339)
5. Map `display_name` / descriptions / analytics page paths to **one** of the 12 categories
6. Report inferred vs official. Do not claim unlock unless Settings UI was actually read

Answer in German with compact tables when the user writes German.
