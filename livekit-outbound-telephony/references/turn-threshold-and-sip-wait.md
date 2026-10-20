# Turn threshold + SIP wait (verified 24.08.2026)

## TurnDetector

- Audio model; 14 calibrated languages, **no `bs`**.
- Unmapped → factory default. Still works (pitch/pause).
- Override: `TurnDetector(unlikely_threshold=float)` scalar. Env `AMINA_TURN_BS_THRESHOLD`.
- Higher = waits longer. Change anytime; not a new language model.
- `TurnHandlingOptions` is a TypedDict: `turn_detection`, `endpointing`, `interruption`.

## SIP / greet

- `lk sip participant create --wait` = wait until answered.
- Participant may join room **while ringing**. `wait_for_participant` ≠ pickup.
- Current bug: `call-cloud-pick-agent.sh` dispatches **before** SIP `--wait`.
- Fix: SIP `--wait` first, then dispatch. After `sip.callStatus=active`, callee speaks first; 2.5s silence → one opener.
- Never `asyncio.sleep` in `on_enter` as pickup wait.

## Overlap

`livekit-bih-outbound` and `livekit-voice-build` cover related ground (user-owned). This skill holds the verified outbound + team rules. Suggest `hermes curator adopt livekit-bih-outbound` if those should merge.
