# Paper vs live LiveKit config

Do not claim these from filenames or local code:

| Claim | How to verify |
|---|---|
| Agent is eu-central | `lk agent list --project aai` → Regions column. toml name ≠ region. Empty US-east agents exist. |
| Langfuse OTLP live | Trace after a **Cloud** call. Local `LANGFUSE_*` in `.env.local` ≠ worker secrets. Push with `lk agent update --secrets-file`. Silent `setup_langfuse()` None hides missing Cloud keys. |
| TurnDetector “no Bosnian” | False. Detector runs; `bs` lacks a factory threshold. Scalar number, not a new model. |

Explain to the user in simple German: what changes if we do X. No jargon tables without a “what to do” line.
