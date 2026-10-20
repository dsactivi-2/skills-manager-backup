# Dograh QA + Azure Foundry wiring

## Source of truth
- Dograh MCP: `get_node_type` with `name=qa` (not path-only docs)
- Docs path: `voice-agent/qa` (thin overview)
- Model config: `configurations/inference-providers` — LLM is also used for QA/extraction when S2S realtime is selected
- Related BYOK debug: `dograh-azure-openai-byok-debug` (transport errors; org BYOK LLM)

## What QA does
Post-call only. Splits transcript by node, scores against `qa_system_prompt`, returns JSON tags/score/sentiment/summary. Not realtime → optimize cost + structured JSON + residency.

## Recommended cheap EU setup
1. Prefer existing warm DZ deployment; else deploy `gpt-5-nano` **DataZoneStandard** on warm EU AIServices.
2. Wire QA **separately** from live-call LLM:

```yaml
qa_enabled: true
qa_use_workflow_llm: false
qa_provider: azure
qa_model: gpt-5-nano          # must match Azure deployment name
qa_endpoint: https://<account>.cognitiveservices.azure.com/
qa_api_key: <key — never print>
```

### Endpoint note
- AIServices multi-service accounts from `az cognitiveservices account show` return `*.cognitiveservices.azure.com` — use that for Foundry-style accounts.
- Classic Azure OpenAI-only resources may be `*.openai.azure.com` (see BYOK debug skill). Match the live `properties.endpoint`, do not invent.

## Fallback if deploy blocked on requested region
- Error `715-123420` unusual activity → stop retrying that resource/region account.
- Prefer EU resource that already has OpenAI deployments (pattern: Sweden DZ worked when Germany West empty resource blocked).
- Immediate no-deploy option: existing `gpt-4.1-mini` DataZoneStandard if present on Sweden or West Europe.

## Quality / cost ladder (DataZone)
1. `gpt-5-nano` DZ — volume/cost default (~$0.06/$0.44 per 1M)
2. `gpt-4.1-nano` DZ — ~$0.11/$0.44
3. `gpt-4.1-mini` DZ — ~$0.44/$1.76 if tags/sentiment quality weak on nano
4. Avoid bulk QA on `gpt-5.4-mini` / `o4-mini`
5. Never claim EU residency with `GlobalStandard` or Global-only models (`gpt-5.4-nano`)

## Do not
- Point Dograh Azure QA at GlobalStandard when user required EU hosting
- Reuse expensive live/realtime models for bulk post-call QA
- Assume Foundry MCP / MCP2Skill (`localhost:3571/mcp/foundry`) is up — always have `az` path ready
- Spam deploy create after 715-123420
