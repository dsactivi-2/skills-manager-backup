# LiveKit Cloud ops UIs vs frontends vs telesales KPIs (verified 2026-08-25)

User asks for dashboards to **control agents, calls, leads, closes, live status**. Split layers. Do not recommend a WebRTC playground as an ops cockpit.

## Native LiveKit Cloud (first)

| UI | URL pattern | Does | Does not |
|---|---|---|---|
| Agents | `cloud.livekit.io/projects/p_/agents` | Worker status, deploy, secrets, Launch Console, usage/errors | Leads, Abschlüsse |
| Agent Console | `…/agents/console` | Live debug, RPC, DTMF, hidden Observe, metrics/usage | Hangup other calls, SIP trunks |
| Sessions + Insights | `…/sessions` | Transcript, traces, audio replay (30d) | Business funnel |
| Telephony | Telephony → SIP / numbers / dispatch | Trunks, dispatch rules, call logs | CRM dispositions |

Insights: Settings → Data and privacy → Agent observability ON. Python SDK ≥ 1.3.0 (Console ≥ 1.5.2). Works if media is Cloud even when worker is self-hosted. Analytics API (`cloud-api.livekit.io/…/sessions`) = Scale plan; fields are rooms/bandwidth/minutes — **no lead/sale**.

Sandbox is deprecated. CLI `lk agent console` is local/simulated, not the browser Console.

## Official frontends — not ops

| Repo | URL | Role |
|---|---|---|
| livekit/agents-playground | https://github.com/livekit/agents-playground · https://agents-playground.livekit.io | Dev lab: join room, chat/video/RPC, debug waveform |
| livekit-examples/agent-starter-react | https://github.com/livekit-examples/agent-starter-react | Customer UI template (`lk app create --template agent-starter-react`) |

Neither lists agents, SIP, or sales KPIs. Token routes are not production-auth.

## Telesales KPIs (leads / calls / closes)

LiveKit will never grow a sales funnel. Disposition must be written by the agent.

| Layer | Tool | Live 2026-08-25 |
|---|---|---|
| Lead/order ops | Voice-Ops-Console (Dograh+n8n+ARI) | https://project-foundation-light.lovable.app — **not** LiveKit. MCP instance = Guard Dograh only. Leads/orders empty. Phase 2 Live-Cockpit = planned |
| Call quality | Cekura, Hamming, Bluejay, Coval | LiveKit-listed QA. No lead CRM |
| LLM traces | Langfuse | Already in stack. Not a funnel |

LiveKit Cloud agent → Voice-Ops only if Call-End posts `/api/public/calls/result` (`prodaja`/`termin`/…).

## GitHub monitoring search

Queries like `voice AI observability copilot` return **0-star assignment clones**. Do not rank those. Mature OSS for this class is Langfuse (traces) + Twenty (generic CRM), not a LiveKit call-center cockpit.

OSS ops UI that talks RoomService (rooms/kick/SIP) if user wants extra control: `thinhdanggroup/livekit-dashboard` (community, Cloud keys work). Not official.

## Answer shape

DE table-first. If user says **„links bitte“**, print numbered GitHub/product URLs only — no recap.
