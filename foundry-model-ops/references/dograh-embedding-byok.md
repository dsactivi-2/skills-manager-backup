# Dograh BYOK Embedding (Azure OpenAI)

Last verified: 2026-07-30 against dograh-upstream + live SE deploy.

## Dograh hard constraints (source)

- DB: `Vector(1536)` on document chunks (`api/db/models.py`, alembic)
- Azure client: `api/services/gen_ai/embedding/azure_openai_service.py`
  - `EMBEDDING_DIMENSION = 1536`
  - `embeddings.create(input=..., model=deployment)` — **no** `dimensions=` arg
  - validates len == 1536 else ValueError
- Allowed Azure model IDs in options: `text-embedding-3-small`, `text-embedding-ada-002`
- Default api_version in client: `2024-02-15-preview`
- Chunked Search KB needs embedding key; Full Document mode does not

## Winner for Dograh

**`text-embedding-3-small`** on EU resource with **DataZoneStandard** when catalog allows.

Do **not** set Custom Value `text-embedding-3-large` in Dograh UI — default vector is 3072 and Dograh rejects it. (Non-Dograh RAG may still prefer large + optional dims.)

## UI fill-in (Models → BYOK → Embedding)

```text
Provider:    Azure OpenAI
Model:       text-embedding-3-small   # Azure deployment name
Endpoint:    https://<resource>.openai.azure.com/
Api Version: 2024-02-15-preview
API Key:     <resource key — never log>
```

Endpoint rule (same as LLM BYOK): classic `*.openai.azure.com/`. Live SE test: embeddings on `*.cognitiveservices.azure.com` returned DeploymentNotFound/404 while openai host worked after propagation.

## Azure deploy (SE example)

Resource used: `dsselmanovic-6165-resource` / `rg-dsselmanovi` / `swedencentral`.

```bash
az cognitiveservices account deployment create \
  --name dsselmanovic-6165-resource -g rg-dsselmanovi \
  --deployment-name text-embedding-3-small \
  --model-name text-embedding-3-small --model-version 1 \
  --model-format OpenAI --sku-capacity 50 --sku-name DataZoneStandard
```

Catalog note SE: 3-small has **no** Standard SKU (only GlobalStandard / DataZoneStandard). 3-large still has Standard (existing deploy may be Standard + area EUR).

## Smoke test

```bash
KEY=$(az cognitiveservices account keys list -g rg-dsselmanovi -n dsselmanovic-6165-resource --query key1 -o tsv)
curl -sS -H "api-key: $KEY" -H "Content-Type: application/json" \
  -d '{"input":"Zdravo bosanski test.","model":"text-embedding-3-small"}' \
  "https://dsselmanovic-6165-resource.openai.azure.com/openai/deployments/text-embedding-3-small/embeddings?api-version=2024-02-15-preview"
# expect HTTP 200, embedding length 1536
```

Propagation: Succeeded deploy can 404 for 10–30s — retry before declaring failure.

## Multilingual / BS quality note

OpenAI MIRACL: large ≫ small ≫ ada. For **Dograh**, platform dim lock wins over quality → small. Outside Dograh (e.g. LightRAG), prefer large for BCS/BS and re-embed on model change.

## Related skills

- `foundry-model-ops` — deploy + catalog
- `foundry-dograh-llm-selection` — LLM/QA pick (not embeddings)
- `dograh-azure-openai-byok-debug` — transport/endpoint failures
