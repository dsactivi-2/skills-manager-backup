# Lovable LinkedIn skills (account settings)

Official: https://docs.lovable.dev/introduction/lovable-account-settings.md
UI: https://lovable.dev/settings/account

These are **account** badges from how the user builds. They are not workspace skills (`list_workspace_skills` / `SKILL.md`).

## Unlock rules

Both must hold on **one** project, evaluated per skill:

- Project classified in that category. Classification runs after **≥5 messages**.
- Live app has **≥20 visitor sessions**, bots excluded. Sessions accumulate and do not reset.
- Fraud/abuse accounts are ineligible.

MCP cannot read official classification or unlock state. `get_project_analytics.visitors` is a proxy only — not the bot-filtered session count.

## The 12 skills

| Skill | Build this |
| --- | --- |
| Website Development | Business or portfolio site, or landing page |
| Business Application Development | Internal app: portal, workflow, compliance, BMS, field/fleet, design system / UI prototype |
| Marketplaces & Platforms | Marketplace, booking, subscription, or network connecting user groups |
| AI Tools | Assistant/chatbot, or AI image/video generator |
| Data Visualization & Analytics | Analytics or management dashboard |
| Marketing Collateral | Document/content generator, or brand assets / invitations |
| E-commerce Development | Storefront (Shopify integration helps) |
| Productivity Software Development | Personal tracker (habits, tasks, goals) |
| EdTech Development | Course, lesson, or study tool |
| Sales Enablement Tools | Sales CRM, lead-gen **tool**, or presentation deck (a marketing site with a form is usually Website, not this) |
| Games Development | Browser game |
| FinTech Development | Financial calculator, or trading/investing tool |

LinkedIn: post **one** skill at a time (Add to LinkedIn). Disconnect removes it. Previous **Vibe coding level** is gone.

## MCP eligibility audit

1. `get_me` + `list_workspaces` / `get_workspace`
2. `list_projects` (`visibility=all`, `publish_status=any` or `published`, paginate)
3. Unpublished projects cannot meet the live-session rule
4. `list_messages` `limit=100`: count `role=user` (and total). If `has_more`, ≥5 is already proven — do not page the whole thread into context. Persist-and-count; bodies are huge
5. `get_project_analytics` from `created_at` through now (RFC 3339). Use `visitors.total` as a lower-bound proxy for sessions
6. Classify from `display_name`, `description`, `generated_description`, and analytics page paths. One project → one primary category; do not stretch lead forms into Sales Enablement or dashboards into Analytics unless that is the product
7. Report: skill / evidence / gap. Label classification and session count as **inferred** unless the Settings UI was actually read

Do not invent extra workspaces or projects. Do not treat preview traffic as published live sessions.
