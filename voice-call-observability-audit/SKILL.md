---
name: voice-call-observability-audit
description: "Audit and repair UnaViva Dograh/Langfuse voice-call observability, including local call analysis, full-observation inventory, and Cekura/n8n-to-Langfuse post-call score relay checks. Use this skill when asked to analyze a UnaViva Dograh voice call, calibrate the local analyzer, or verify that Dograh workflow 8184 sends post-call QA scores/timeline data to Cekura and Langfuse."
trigger: "Use this skill when asked to analyze a UnaViva Dograh voice call, calibrate the local analyzer, or verify that Dograh workflow 8184 sends post-call QA scores/timeline data to Cekura and Langfuse."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019f5e90-59a4-7632-af41-c585f88b7e53
  - activi_dsactivi's Organization_default_019f5e72-69ba-71c3-93eb-03b1ffb815d9
  - activi_dsactivi's Organization_default_019f5e92-96f4-7ed2-a7b1-9dca7e5d5420
  - activi_dsactivi's Organization_default_019f5e7c-3dc6-7d40-a8f6-62902ac36385
  - activi_dsactivi's Organization_default_019f5e77-94b8-7f51-8c13-9e62ac3fa6a5
  - activi_dsactivi's Organization_default_019f5e78-58be-7010-9125-c78be0e6a9c5
  - activi_dsactivi's Organization_default_019f5e18-d62b-7c12-93fa-96addd6a281a
  - activi_dsactivi's Organization_default_019f5e47-5e15-76c0-998c-eaf5f0aaa632
  - activi_dsactivi's Organization_default_019f5e2f-eb69-7e13-8f6a-2dcad431bc07
  - activi_dsactivi's Organization_default_019f5ddf-d59e-71b0-9b90-7ef5ddb14e73
contributors:
  - activi
version: 8
created_by_agent: codex
created_at: 2026-07-13T23:50:39.140Z
updated_at: 2026-07-20T14:31:20.249Z
---

# Voice call observability audit

## When to use

Use for UnaViva Dograh/Langfuse call audits, latest-call scoring, local Whisper/pyannote analyzer work, Dograh workflow 8184 QA/webhook checks, Cekura/n8n-to-Langfuse post-call relay fixes, full-observation inventory/preflight work, or guarded repair recommendations.

## Workflow

1. Start from project evidence, not assumptions:

```bash
cat ~/.deeplake/memory/index.md
cat docs/observability/README.md
cat docs/observability/observed-vs-not-observed.md
cat docs/observability/full-observation/README.md
python3 scripts/analyze_call.py --help
```

Keep **nach Plan** separate from **live verified**. A Dograh API check, draft save, local unit test, or mock dry-run is not proof that traces, recordings, PBX CDRs, SIP/RTP metrics, dashboards, or repair apply are end-to-end live.

2. Build an evidence matrix by layer: Dograh workflow/run/version, transcript, recording, QA node, webhook payload; Langfuse trace, STT/LLM/TTS observations, scores, events, tags, errors; recording/audio duration, codec, silence, dead air, clipping, loudness, speech rate, pitch/prosody, interruptions/dropouts; PBX/carrier CDR/CEL, hangup cause, SIP codes, RTP jitter/loss/MOS, cost; CRM/campaign consent, lead source, outcome, join keys without PII. Report every item as Observed, Conditionally observed, or Not observed.

3. Use repeatable local analyzer checks:

```bash
python3 -m unittest discover -s tests -v
python3 scripts/analyze_call.py --manifest examples/call_manifest.example.json --out reports/call-analysis --stt missing --stt-language bs
uv run python scripts/analyze_call.py --manifest examples/call_manifest.example.json --out reports/call-analysis --stt always --stt-language bs --diarize --num-speakers 2
scripts/observability/check_local_audio_setup.sh
```

Known model paths: `models/whisper/ggml-large-v3-turbo.bin` and `models/pyannote/speaker-diarization-community-1`. If HF download hits Xet errors, retry with `HF_HUB_DISABLE_XET=1`. A pyannote folder without `config.yaml`/`pipeline.yaml` is a gap. Plain `.txt` transcripts are allowed but must create gaps for missing speaker labels and timestamps; prefer JSON with `speaker`, `start`, `end`, `text`.

4. Calibrate findings before calling a call failed. For Bosnian telesales, `Aquafor`, `Aquafor Smile`, `Aquafor Smile Vrc`, and common STT variants are valid product mentions in `config/call_quality_thresholds.json`. Short near-zero spans surrounded by active speech can be dropouts; normal customer thinking pauses should be dead air/answer pause, not technical dropout. `WARN` means usable but suspicious; `FAIL` needs critical evidence such as long dead air, mostly silence, severe audio failure, or missing core compliance.

5. For Dograh workflow 8184, verify active published version vs draft before judging behavior. Draft saves are not live. If only `save_workflow` is available through MCP, report that publish must happen in Dograh UI before a new test call can validate production behavior. Do not modify workflow 8184 unless explicitly approved; prefer duplicate/draft for changes.

6. For post-call Langfuse relay, distinguish QA output from real Langfuse scores/events. QA may produce `timeline_events` and `langfuse_score_candidates`, but Cekura/n8n/relay must write them to Langfuse. The required four score names are exact: `audio_quality` NUMERIC 0-10, `overall_score` NUMERIC 0-10, `silence_ratio` NUMERIC 0-1, `overall_status` CATEGORICAL PASS/PASS_WITH_GAPS/WARN/FAIL. Verify trace linkage via `traceId` or resolvable `conversation.id`, `workflow_run_id`, `workflow_id`, `environment=production`, dedup key, tags, and timeline events. If the webhook points only to `https://api.cekura.ai/observability/v1/observe/`, confirm Cekura forwards to Langfuse; direct Langfuse endpoints are `/api/public/scores` or `/ingestion` depending on implementation.

7. For n8n ingest, use a Webhook node production URL for Dograh post-call callbacks, not the MCP Client node endpoint. Put the production webhook URL in `OBS_INGEST_PUBLIC_WEBHOOK_URL` and `DOGRAH_WEBHOOK_TARGET_URL`. The Ingest-Orchestrator is only the connector service/workflow: it receives Dograh webhooks, fetches Dograh/Langfuse/PBX/carrier/CRM/audio evidence, deduplicates by join keys, and writes reports/scores. It is not Dograh, Langfuse, PBX, Telnyx, or OpenAI.

8. For full-observation inventory, use local ignored files and redacted reports: `inventory/full-observation-access-inventory.local.env`, `inventory/full-observation-access-inventory.local.md`, and `scripts/observability/populate_full_observation_inventory.py`. Search existing env/configs without printing secrets. Status may be `PASS_WITH_GAPS` until workflow IDs, trace IDs, storage, PBX, SIP/RTP, CRM, dashboard, and guarded-repair fields are filled.

9. Production repair requires recommendation/draft/dry-run first, then explicit approval, change ID, risk level, rollback plan, approved apply, and post-check/test call. Block self-approval, failed dry-run, duplicate lock key, high-risk automatic apply, and any secret/PII in diff, report, chat, or memory.

## Anti-patterns

- Calling transcript-only review complete call analysis.
- Treating QA webhook candidates as live Langfuse TOOL/RETRIEVER/EVENT spans.
- Assuming draft v5/v6 changes affected a test call before publish and a fresh call.
- Sending scores without exact Langfuse score names or trace/conversation linkage.
- Using n8n MCP Client URL as the Dograh post-call webhook.
- Running STT unnecessarily when reliable timestamped transcript exists.
- Inferring prosody, packet loss, hangup cause, SIP behavior, or AEC status without evidence.
- Printing, decoding, or storing credentials/customer data.
