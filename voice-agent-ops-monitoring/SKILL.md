---
name: voice-agent-ops-monitoring
description: "Use when LiveKit ops dashboards or lead/call KPIs."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [livekit, observability, telesales, dashboards, cekura]
    related_skills: [livekit-voice-build, voice-ops-console, livekit-agents]
---

# Voice-agent ops monitoring (Cloud vs QA vs leads)

## When

- Dashboards for agents **running on LiveKit Cloud** (Steuerung, Calls, Live-Status)
- „wieviele Leads / Calls / Abschlüsse“
- Monitoring tools for Callcenter-AI inkl. Leadsteuerung und Statistiken
- User asks what **Voice-Ops-Console** is vs LiveKit UIs

## Three layers (do not collapse)

| Layer | What it answers | Tools |
|---|---|---|
| Transport / worker | Agent up? Session count? SIP logs? | LiveKit Cloud Agents, Console, Sessions/Insights, Telephony |
| Call quality | Latency, interruptions, evals, alerts | Cekura, Hamming, Bluejay, Coval; Langfuse traces |
| Sales funnel | Leads, dispositions, orders | Voice-Ops-Console (Dograh+n8n+ARI), CRM — **not** LiveKit |

No mature GitHub repo does all three. Skip 0-star `voice-ai-observability-copilot` clones.

## LiveKit Cloud UIs

| UI | Does | Does not |
|---|---|---|
| Agents | Worker status, deploy, Launch Console | Leads/closes |
| Agent Console | Live debug, RPC, DTMF, hidden Observe | Hangup other calls |
| Sessions + Insights | Transcript, traces, audio (30d) | Funnel |
| Telephony | Trunks, dispatch, call logs | CRM |

Sandbox deprecated. `lk agent console` ≠ browser Console. Insights: observability ON + Python SDK ≥1.3 (Console ≥1.5.2). Analytics API = Scale; no sale fields.

## Not ops dashboards

- https://github.com/livekit/agents-playground — dev lab
- https://github.com/livekit-examples/agent-starter-react — customer UI

If user says **„links bitte“**, numbered URLs only.

## Voice-Ops-Console (this org)

Lovable + MCP `https://project-foundation-light.lovable.app`. Dograh/ARI, not LiveKit. Live 2026-08-25: only Guard Dograh; leads/orders empty; Phase 2 Live-Cockpit planned. LiveKit agents appear only after POST `/api/public/calls/result`.

More Cloud/SIP detail: skill `livekit-voice-build` → `references/ops-dashboards-not-frontends.md` and `references/cloud-observability-and-sip.md`.

## Pitfalls

- Calling playground / starter-react an ops cockpit
- Expecting LiveKit Cloud to show leads/Abschlüsse
- Treating Voice-Ops as LiveKit admin
- Ranking 0-star GitHub clones over Cekura/Hamming/Langfuse
