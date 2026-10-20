# Two clocks: Soniox tags vs LiveKit turns (2026-08)

Soniox *Emotion & tone*: `[pause]` = one default gap; `[long pause]` rare; `,` / `...` = short breath. **No millisecond control.** Tags shape **her** sentence. `speed` is overall rate.

LiveKit *turns/tuning*: `endpointing` 0.5–3 s = wait after **you** stop. `min_consecutive_speech_delay` 0.2–0.4 s = gap between **her** utterances. `TurnHandlingOptions.interruption` default on; use `mode=adaptive`, `min_duration=0.5` (not a lone `allow_interruptions=True`).

`TurnDetector` 14 languages, **no `bs`**. Do not disable. Raise `min_delay` if it cuts BS mid-thought.

**Optimal Amina GSM:** both clocks. Tags ≠ SDK rhythm.

Outbound: docs = `wait_for_participant` after answer; **do not** `asyncio.sleep` in `on_enter` (job starts while ringing).

SIP noise: prefer agent `krisp.voice_isolation_telephony()` (cost) over trunk `krisp_enabled`. A/B — can swallow quiet halo.

Handoffs/tasks: start one agent. Split only on instruction bloat / order fields. Not 4 personas for one bokal call.
