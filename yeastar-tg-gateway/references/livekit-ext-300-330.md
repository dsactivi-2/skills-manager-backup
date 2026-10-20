# LiveKit vs TG400 extensions

| Ext | Role |
|---|---|
| **300** | Yeastar TG400 GSM register |
| **330** | LiveKit SIP auth (not a phone, not a TG register) |
| 310 | Guarddograh — leave alone |

Yeastar trunk password = **that ext’s secret**, never ARI or Websocket.

Do **not** register 330 on the TG if LiveKit also authenticates as 330 (contact clash).

LiveKit INVITE From is often `+387…@*.sip.livekit.cloud`. Without PJSIP Identify on LiveKit IPs → ext 330, Asterisk uses the artificial endpoint → 401 / `max auth retry`.
