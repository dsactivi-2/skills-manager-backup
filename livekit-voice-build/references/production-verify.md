# Live checks — do not claim “configured” from repo text (2026-08)

## TurnDetector (docs `/agents/logic/turns/turn-detector`)

Audio model. Works **without** `bs` on the 14-language list. Unmapped languages keep the calibrated default. Cloud default `v1`. Do not disable. Optional: `min_delay` 0.5–0.8 if it cuts Bosnian mid-sentence.

## Langfuse OTLP (docs `/deploy/observability/tracing`)

Code in `src/amina/telemetry.py` is not enough.

| Check | Command / fact |
|---|---|
| Local keys exist | names in `.env.local`: `LANGFUSE_PUBLIC_KEY`, `SECRET`, `BASE_URL` |
| Cloud worker has them | `lk agent update --secrets-file=.env.local` after user pastes keys |
| Really exporting | after a call: `langfuse --env .env.local api traces list --limit 1` |
| Missing keys | log a warning; official sample **raises**. Silent no-op hides Cloud gaps |
| Leaked keys | rotate in Langfuse UI before re-upload |

OTLP ≠ LiveKit Insights. STT text empty in a trace = half-blind review.

## eu-central

Region is **immutable** after `lk agent create`. SoT = `lk agent list --project aai` column Regions.

- `CA_J8AZ7K6yJ5o3` / `amina-soniox-v2` = eu-central (verified 2026-08-24).
- Three empty agents on **us-east** — never use for Amina. New create without `--region eu-central` lands there.
- `livekit.eu-central.toml` having no `region` field ≠ not deployed in EU. Still document the process.
- `LIVEKIT_URL` host `*.livekit.cloud` is normal; agent region is separate from the URL hostname.
- `LK_AGENT_REGION` missing in `.env.local` is a process gap, not proof the live agent is US.

## Outbound greet

`wait_until_answered` + `wait_for_participant`, then greet. Never `asyncio.sleep` in `on_enter`.
