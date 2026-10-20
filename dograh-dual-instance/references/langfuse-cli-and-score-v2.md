# Langfuse CLI + post-call score v2 (pointer)

## CLI
- Install: `npm i -g langfuse-cli` → binary `langfuse`
- DograhEU keys: default `LANGFUSE_*` / `LANGFUSE_VOICEEU_*` in `~/.hermes/.env`
- Smoke: `langfuse --env ~/.hermes/.env api projects get-public` → name DograhEU
- Full API surface — do not rebuild via skills

## Skill library
- Single skill `langfuse` (duplicate `langfuse-official` removed)
- Dual MCP: `langfuse-voiceeu` / `langfuse-dograh-cloud` / `langfuse-docs`

## Post-call QA scores (voiceeu Dograh → n8n → Langfuse)
Canonical contract: `dograh-mcp-workflow-ops/references/langfuse-qa-score-relay-v2.md`

Summary:
- QA JSON: `call_quality_score`, `overall_sentiment`, `tags[{tag,reason}]`, `summary`
- 10 BOOLEAN `tag_*` scores always 0/1
- Trace via `conversation.id` == `workflow_run_id` (OTel; no minted trace_id)
- `save_workflow` = draft only until UI publish

## Overlap note
`voice-call-observability-audit` still documents the older four-score set
(`audio_quality`, `overall_score`, `silence_ratio`, `overall_status`). Prefer v2
for new PAS/voiceeu wiring; keep audit skill for UnaViva/8184-era paths until adopted/merged.
