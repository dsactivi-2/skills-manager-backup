# Cross-instance Dograh webhook / integration audit

Use after cloning a workflow onto **voiceeu** (or any new org).

## Checklist

1. `GET /api/v1/workflow/{id}/versions` → inspect **published** `workflow_json` nodes.
2. List every `endpoint_url`, `credential_uuid`, `tool_uuids`, `pre_call_fetch_url`, `qa_endpoint`.
3. `list_tools` / `list_credentials` / `list_documents` on **this** instance (often empty on fresh self-host).
4. HTTP probe each webhook with a body shaped like production (not only `{"ping":true}` for broken parsers).
5. Langfuse: confirm project keys (DograhEU) + score configs exist; OTel traces ≠ scores.
6. Publish check: runtime = published version number, not draft MCP view alone.

## Activi PAS (WF22) baseline after 2026-07-29

| Integration | Expected |
|-------------|----------|
| Langfuse scores | Modal `https://dsactivi-2--dograh-lf-scores.modal.run` |
| Order postcall | n8n `aquaphor-postcall` (verify Zoho in n8n) |
| Handoff | n8n `aquaphor-handoff-ticket` |
| Cekura | **removed** while n8n path 500s |
| Tools/KB | none unless created on voiceeu |

## Failure signatures

- `Error in workflow` + 500 → n8n internal; fix UI executions or drop node.
- n8n API `unauthorized` with X-N8N-API-KEY → rotate key.
- Scores empty, STT/TTS present → relay/publish gap (see parent SKILL).
- Order prompt mentions address tools but `tool_uuids` empty → silent no-tool behavior.
