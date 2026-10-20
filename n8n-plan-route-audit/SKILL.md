---
name: n8n-plan-route-audit
description: "Use when comparing Eraser N/R plan routes to live n8n."
version: 1.0.0
license: MIT
metadata:
  hermes:
    tags: [n8n, livekit, eraser, audit, telesales]
    related_skills: [n8n-livekit-outbound, voice-workflow-maps]
---

# Plan-Routen vs n8n-Canvas

Class: every `Rxx` from `phases/ROUTEN.md` against `connections` of a live n8n workflow.

## When to Use

User asks what is wired, what is missing, „28 von 82“, Ist/Soll, or a gap after a monolith import.

## Pflicht

1. Live-Workflow per n8n-MCP `get_workflow_details` (not memory).
2. Every plan route: **SITZT** / **FALSCH** / **KNOTEN FEHLT**, plus one fix line.
3. Counts must add up (e.g. 28 + 54 = 82). Do not ship highlights only.
4. A Set/Code node with a matching N-id is not real (no Sheet, JWT, SIP, calendar, or Data Table).
5. G3 talk edges (N11–N14) are LiveKit, not an n8n build item.
6. Write `phases/ROUTEN-GAP-*.md` in the repo.

## Mapping

Node id is the n8n name prefix (`N07 Queue`). An extra hop (e.g. „N08 Regeln rechnen“ before „N08 OK?“) is not 1:1 SITZT unless the user accepts the detour.

Queue returns (Hold, VM +1 day, N18.1, N19.3, N36 next-call) that die on a dead N36 are **FALSCH**.

## n8n-lk

MCP: `https://n8n-lk.activi.io/mcp-server/http`.
OAuth refresh: `https://n8n-lk.activi.io/mcp-oauth/token` (not the vmi host in `issuer`).
Shell `N8N_API_KEY` may belong to another instance (`n8n-mm`). REST only against the host the user named.

Before create: `search_workflows`. If a monolith already exists, do not add a second.
If `search_workflows` is not in this session's tools: refresh OAuth, then call MCP HTTP (see `references/n8n-lk-oauth-refresh.md`). Do not fall back to another n8n instance.

## Pitfalls

- Quoting „28 sitzen“ without the full missing list.
- Open webhooks reported as done.
- Inbound-busy must not decrement outbound slots.
