---
name: dograh-azure-openai-byok-debug
description: "Diagnose Dograh Azure OpenAI BYOK failures by correlating Langfuse traces, Dograh model configuration, Codex Langfuse MCP/CLI access, and Azure CLI deployment facts."
trigger: "Use when Dograh LLM steps fail with Azure/OpenAI transport errors such as `API version not supported`, especially after BYOK or Langfuse setup."
author: activi
source_sessions:
  - activi_dsactivi's Organization_default_019ef70b-1a7e-7591-ad1b-e3edbe038813
  - activi_dsactivi's Organization_default_019ef701-41c9-7d73-8de6-8127cae961f2
  - activi_dsactivi's Organization_default_019ef6f6-64b1-7bb3-b048-947e383d3c44
  - activi_dsactivi's Organization_default_019ee052-6e19-79b1-ac6f-7ddbc6204a3c
  - activi_dsactivi's Organization_default_019ee810-06c0-77c1-97a3-c5df9a18e36d
  - activi_dsactivi's Organization_default_019ee7f4-17ed-7843-9792-9c123d764e9a
  - activi_dsactivi's Organization_default_019ee7c2-df29-7ef1-8be8-e1b961786aea
  - activi_dsactivi's Organization_default_019ee7b9-5ae0-71c0-af3a-14746f251469
  - activi_dsactivi's Organization_default_019ee7aa-b026-72c1-a1ac-9513353b4949
  - activi_dsactivi's Organization_default_019ee7a0-4057-7221-848a-d890f7d445ae
contributors:
  - activi
version: 4
created_by_agent: codex
created_at: 2026-06-22T21:16:24.890Z
updated_at: 2026-06-24T00:35:37.029Z
---

# Dograh Azure OpenAI BYOK debug

## When to use

Use when a Dograh workflow reaches an LLM step and fails with Langfuse/Dograh errors such as `BadRequestError`, `API version not supported`, provider `az.ai.openai`, or after configuring Azure OpenAI BYOK.

## Workflow

1. Prove the failing layer before editing.
   - Read the latest Langfuse trace via `langfuse-cloud` MCP or `npx langfuse-cli api traces list --limit 1`.
   - Capture trace id, observation name such as `llm-start-call`, provider, model, and exact error.
   - Treat `401`/`403` as key/auth-first; treat `API version not supported` as endpoint/API-version-first.

2. Ensure secret-safe local access.
   - Load env with `source ~/.config/dograh/env`.
   - Verify lengths, not values: `echo ${#DOGRAH_API_KEY} ${#LANGFUSE_PUBLIC_KEY} ${#LANGFUSE_SECRET_KEY}`.
   - If needed, configure Codex MCPs with Docs `https://langfuse.com/api/mcp` and Cloud EU `https://cloud.langfuse.com/api/public/mcp`.
   - Build Cloud MCP auth from `LANGFUSE_PUBLIC_KEY:LANGFUSE_SECRET_KEY`, e.g. `LANGFUSE_MCP_AUTH="Basic $(printf '%s:%s' "$LANGFUSE_PUBLIC_KEY" "$LANGFUSE_SECRET_KEY" | base64)"`.
   - Smoke-test `initialize` plus `tools/list`, or run `npx langfuse-cli api traces list --limit 1`.
   - Never print secrets, decoded auth headers, private env contents, or pasted API keys; rotate keys that appeared in chat.

3. Inspect Dograh read-only first.
   - Use Dograh MCP to list workflows, fetch the affected workflow, list tools, list credentials, and check node types.
   - If the workflow only has nodes like `startCall`, `agentNode`, `globalNode`, `endCall` and no model fields, assume the issue is outside the workflow in org-level `Model Configurations` or agent `Settings -> Model Overrides`.

4. Inspect the Dograh UI fields.
   - Open `Model Configurations -> BYOK -> LLM`.
   - Also inspect `Settings -> Model Overrides` on the affected agent if present.
   - Record exactly: `Provider`, `Model`, `Endpoint`, and whether API keys are present. Do not expose key values.

5. Verify Azure as source of truth.
```bash
az cognitiveservices account show --name <resource> --resource-group <rg>
az cognitiveservices account deployment list --name <resource> --resource-group <rg>
```
   - Confirm the resource exists, region matches, and the intended deployment exists.
   - Use the Azure deployment name as Dograh `Model`, not the generic base-model label.

6. Apply the Dograh/Azure endpoint rule.
   - `Provider` stays `Azure OpenAI`.
   - `Model` is the Azure deployment name, for example `gpt-4.1-mini`.
   - `Endpoint` must be the classic Azure OpenAI resource endpoint: `https://<resource>.openai.azure.com/`.
   - Do not use the Foundry/project endpoint: `https://<resource>.services.ai.azure.com/api/projects/...`.
   - If Dograh has no API-version field and the trace says `API version not supported`, the wrong endpoint is the prime suspect. If the endpoint is already classic, check agent overrides or hidden API-version settings next.

7. Retest one change at a time.
   - Save the Dograh configuration, run the workflow again, then inspect the next Langfuse trace.
   - Confirm LLM transport errors are gone before tuning prompts, latency, STT, or TTS.

## Local example

For Azure resource `activids` with deployment `gpt-4.1-mini`, Dograh BYOK LLM should use:

```text
Provider: Azure OpenAI
Model: gpt-4.1-mini
Endpoint: https://activids.openai.azure.com/
```

## Anti-patterns

- Blaming prompt wording when the trace shows provider transport failure
- Treating a key prefix as proof of root cause; bad keys usually produce `401` or `403`, not `API version not supported`
- Using `services.ai.azure.com/api/projects/...` in Dograh BYOK LLM
- Entering the base model name when Dograh expects the Azure deployment name
- Changing key, endpoint, model, and overrides all at once
- Printing API keys, decoded Basic auth, or private env contents in chat/logs
- Claiming Azure is wrong before checking deployments with Azure CLI
