# Outbound GSM + ear (LiveKit Amina, 2026-08)

Repo: `/Users/activi/Code/Projects/LiveKit`. Desktop: `~/Desktop/LiveKit Agents/`.

| Item | Fact |
|---|---|
| Cloud agent | `amina-soniox-v2` `CA_J8AZ7K6yJ5o3` eu-central |
| Dial | not Cloud UI — `00-Cloud-Anruf.command` |
| Logs | `logs/calls/<YYYYMMDD-HHMMSS>/` (run.log, error.log, diagnose.txt) |
| TG / LiveKit ext | **300** = Yeastar GSM, **330** = LiveKit SIP auth |
| 401 `max auth retry` | PBX saw From `+387…@*.sip.livekit.cloud` as artificial endpoint — Identify LiveKit IPs on 330 |
| Halo | `on_enter`: sleep ~1.8 s then short opener |
| Interrupt | `allow_interruptions=True`, min ~0.45 s |
| Soft no | do not hang up; third **hard** no or DNC only |

Langfuse: session `agent_session`. Compare `agent_speaking` spans (often 8–11 s) with `user_speaking` (0.3–0.9 s overlapping). e2e after a real turn can be 1.3 s while the ear still feels late because she never stopped.

Headset speed 0.9 ≠ GSM feel. Change speed only after a phone listen, not from console alone.
