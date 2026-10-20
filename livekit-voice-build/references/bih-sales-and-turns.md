# BiH LiveKit sales + turns (session 2026-08-24)

## Sales (user)

- Open: who + **bokal/water** in sentence 1. Hiding the product is wrong.
- Soft no stays in sale. Hard end = DNC / ne zovi / third hard no.
- Reply to last callee words, not the next checklist item.

Live Cloud worker: `amina-soniox-v2` / Soniox Nina. Fish is local A/B only unless asked.

## Turns

`TurnDetector` works without `bs` in the 14-language list. That list is factory `unlikely_threshold`s. Unmapped → default. Custom `bs` = one scalar (`AMINA_TURN_BS_THRESHOLD`, start 0.55). Not a new model. See `livekit-bih-outbound` `references/turn-threshold.md`.

`asyncio.sleep` in `on_enter` is not pickup-wait (runs during ring).

## Speak to the user

Simple German. After a “too much / wrong” list, say what to **do**. Do not call the detector broken.
