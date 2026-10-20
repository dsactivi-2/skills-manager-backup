# LiveKit Cloud Europe (latency from BiH)

Docs: `/deploy/admin/regions/endpoints` (verified 2026-08).

| Layer | Choose |
|-------|--------|
| Agent deploy | `eu-central` = Frankfurt |
| Realtime pin | region group `eu` = France + Germany (in-region redundancy). Scale plan+; enable via Cloud Support. |
| SIP | `{sip_subdomain}.eu.sip.livekit.cloud` |
| Outbound origin | `destination_country`: `de` (Frankfurt) or `fr` |
| Client URL | `wss://<sub>.eu.rtc.livekit.cloud` — not global `*.livekit.cloud` |

STT: Deepgram plugin + `api.eu.deepgram.com` (`language=bs` on nova-3).  
LLM: Azure/Foundry EU, not US LiveKit Inference, when the user requires Europe.  
Fish: own key; confirm Fish audio region separately (may sit outside EU).

Region pinning ≠ agent deploy. Pin traffic *and* deploy agents to `eu-central`.
