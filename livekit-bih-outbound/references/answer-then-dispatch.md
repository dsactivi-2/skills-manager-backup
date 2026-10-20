# Answer, then dispatch (Amina GSM)

Verified 2026-08-24 against LiveKit docs `/telephony/making-calls/outbound-calls` and SDK `JobContext.wait_for_participant`.

## Wrong (was in `scripts/call-cloud-pick-agent.sh`)

1. `lk dispatch create` → agent `on_enter` runs  
2. `lk sip participant create --wait` → phone still ringing while she talks  

`--wait` is the CLI for `wait_until_answered`. It does not help if the agent already joined.

## Right (script-dials, Cloud worker already exists)

1. Pick room name + trunk + dest  
2. `lk sip participant create --trunk … --call … --room … --wait --timeout 90s`  
3. Non-zero sip exit → **no** dispatch  
4. Then `lk dispatch create --room … --agent-name amina-soniox-v2`  
5. Agent: if SIP, do not `generate_reply` until `sip.callStatus=active`; prefer user-first; 2.5 s silence → one opener  

## Right (agent-dials, docs sample)

`create_sip_participant(..., wait_until_answered=True)` → `wait_for_participant(identity=…)` → `session.start` → **no** automatic greet on outbound.

## Not enough

- `asyncio.sleep(1.8)` in `on_enter`  
- `wait_for_participant()` alone  
- `sip.callStatus` unchecked (`ringing` vs `active`)
