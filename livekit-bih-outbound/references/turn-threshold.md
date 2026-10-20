# TurnDetector patience number

LiveKit audio `TurnDetector` still runs when STT is `bs`. Unmapped languages keep the calibrated **default** threshold (docs: turn-detector).

- Scalar `unlikely_threshold=0.55` — Amina is bs-only; do not rely on `{"bs": 0.55}` (may stay unmapped).
- Env `AMINA_TURN_BS_THRESHOLD` (0–1). Higher = more patient (less barge-in on “znači…”). Lower = faster reply.
- VAD is always underneath. Detector ≠ VAD-only.
- Tune one number per ear-test. Not a language model.
