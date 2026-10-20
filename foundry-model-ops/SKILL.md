---
name: foundry-model-ops
description: "Use when picking/deploying Foundry/Azure OpenAI models (QA, embeddings, TTS catalog) via az cognitiveservices — EU DataZone + Dograh 1536-dim rule."
version: 1.3.0
---

# Foundry model ops (pick + deploy)

## When to use
- Choose a Foundry/Azure OpenAI model for **non-realtime** work: Dograh QA node, variable extraction, batch eval, cheap analysis
- **Embeddings** deploy/pick for Dograh BYOK Knowledge Base or other Azure OpenAI embedding use
- **Catalog search** for Foundry-deployable **TTS / audio / realtime** models (`tts`, `tts-hd`, `gpt-audio*`, `gpt-realtime*`)
- Deploy a model to an existing AIServices resource in a target region
- Check EU residency (DataZone vs Global) and relative cost
- Foundry MCP / MCP2Skill gateway is down — fall back to Azure CLI
- User says "Foundry CLI" — often **no** `foundry` binary; use `az cognitiveservices` (this skill)

## When not to use
- Live voice STT/LLM/TTS stack selection → `foundry-multistack-voice-agent` + `balkan-voice-agent-stack`
- **Voice cloning** on a Foundry model deploy → wrong surface; Azure Speech Personal/Custom Neural Voice (`references/foundry-tts-voice-clone.md`)
- DE/BS **live** telephony STT → Deepgram/Azure Speech (`balkan-voice-agent-stack`, `DE_LIVE_TELESALES_STT_UPDATE.md`) — not chat LLM deploy
- Dograh platform/API capability questions → Dograh MCP docs/tools first
- Quota increase tickets only → Foundry quota skill / Azure Portal
- Browser custom-connector OAuth (Claude/Grok/ChatGPT: Client-ID, Auth/Token URL, scopes, PKCE, `AADSTS500113`) → `entra-oauth-mcp-connectors`

## Hard rules
1. **EU residency for inference** = SKU `DataZoneStandard` on an **EU** AIServices resource (e.g. `swedencentral`, `westeurope`, `germanywestcentral`, `francecentral`). `GlobalStandard` can process outside the EU.
2. **Never invent availability** — always query catalog + usage before recommending or deploying.
3. **Confirm target resource** (name, RG, region, endpoint) before `deployment create`.
4. Prefer **reuse of an existing DataZone deployment** over a new deploy when quality is good enough.
5. **No Foundry voice-clone model** — re-verify with catalog; sample clone = Azure Speech only.
6. **Dograh embeddings = 1536 dims only** — use `text-embedding-3-small` (or ada-002), never bare `text-embedding-3-large` (3072 default; Dograh client does not pass `dimensions=`).

## Dograh QA node (post-call)
Dograh QA runs **after** the call on transcript segments → structured JSON (tags, score, sentiment, summary). Latency is secondary; **cost + JSON fidelity + EU** dominate.

Schema fields (Dograh MCP `get_node_type` name=`qa`):
- `qa_use_workflow_llm: false` when QA should not share the live-call LLM
- `qa_provider: azure`
- `qa_model: <deployment-name>`
- `qa_endpoint: https://<account>.cognitiveservices.azure.com/`
- `qa_api_key: <key>`

### Model shortlist (Data Zone prices, Azure list $/1M tokens — verify on pricing page if stale)
| Goal | Model | SKU | Approx DZ price | Notes |
|------|--------|-----|-----------------|-------|
| Cheapest EU analysis | `gpt-5-nano` | DataZoneStandard | ~0.06 in / 0.44 out | Best default for high-volume QA |
| Cheap + mature | `gpt-4.1-nano` | DataZoneStandard | ~0.11 in / 0.44 out | Strong cheap alt |
| Quality sweet spot | `gpt-4.1-mini` | DataZoneStandard | ~0.44 in / 1.76 out | Often already deployed; better nuance |
| Avoid for bulk QA | `gpt-5.4-mini`, `o4-mini` | any | much higher | Overkill cost |
| Not EU-DZ | `gpt-5.4-nano` | GlobalStandard only | — | No DataZone SKU in catalog |

If nano QA quality is weak on empathy/frustration tags → step up to `gpt-4.1-mini` DataZone without changing region strategy.

## Embeddings (Azure OpenAI + Dograh BYOK)

Dograh Knowledge Base **Chunked Search** needs org BYOK Embedding. Upstream hard-codes **1536 dims** and does **not** pass `dimensions=` on the Azure call. Details: `references/dograh-embedding-byok.md`.

| Use case | Model | Why |
|---|---|---|
| **Dograh BYOK KB** | `text-embedding-3-small` | Native 1536d; Dograh allow-list |
| Dograh alt | `text-embedding-ada-002` | 1536d; legacy |
| **Not for Dograh** | `text-embedding-3-large` | Default 3072d → ValueError |
| Non-Dograh RAG / BS quality | `text-embedding-3-large` | Best MIRACL if app stores 3072 or sets dims |

### SKU quirks (SE live 2026-07-30 — re-check)
- `text-embedding-3-small`: GlobalStandard + **DataZoneStandard** only (no Standard)
- `text-embedding-3-large`: Standard + Global + DataZone
- Prefer DataZoneStandard on EU resource

### Dograh UI (BYOK → Embedding)
```text
Provider: Azure OpenAI
Model: text-embedding-3-small
Endpoint: https://<resource>.openai.azure.com/
Api Version: 2024-02-15-preview
API Key: <resource key — never log>
```
Smoke on `*.openai.azure.com` after deploy; expect dims=1536. CS host may 404. Wait 10–30s if DeploymentNotFound right after create.

## Live discovery commands
```bash
az account show -o table

az cognitiveservices account list \
  --query "[?kind=='AIServices'].{name:name,rg:resourceGroup,loc:location,endpoint:properties.endpoint}" -o table

az cognitiveservices account deployment list -g <RG> -n <ACCOUNT> -o table

az cognitiveservices model list --location <region> -o json

az cognitiveservices usage list --location <region> -o json
# Look for: OpenAI.DataZoneStandard.<model>
```

### TTS / audio catalog
```bash
az cognitiveservices model list --location swedencentral -o json > /tmp/cs_models.json
# Filter names/caps: tts|audio|speech|whisper|transcribe|realtime|voice|clone
# SKUs under model.skus[].name (top-level skus often null)
```

Snapshot (2026-07-30 SE/WE/DE): `tts`, `tts-hd` (Standard, no clone); `gpt-audio*` / `gpt-realtime*` (mostly Global; `gpt-realtime-1.5` has DataZone); `whisper`/transcribe STT; **`gpt-4o-mini-tts` absent**; **zero clone hits**. Full table: `references/foundry-tts-voice-clone.md`.

Optional Foundry skill scripts (if present under Azure Foundry skills tree):
- `capacity/scripts/query_capacity.sh <model>` — versions
- `capacity/scripts/discover_and_rank.sh` — **run with `/bin/bash` or bash 4+**; macOS `/bin/sh` fails on `declare -A`

## Deploy (DataZone, EU)
```bash
az cognitiveservices account deployment create \
  --name "<ACCOUNT>" \
  --resource-group "<RG>" \
  --deployment-name "gpt-5-nano" \
  --model-name "gpt-5-nano" \
  --model-version "2025-08-07" \
  --model-format "OpenAI" \
  --sku-capacity 100 \
  --sku-name "DataZoneStandard" \
  -o json

az cognitiveservices account deployment show \
  -g "<RG>" -n "<ACCOUNT>" --deployment-name "gpt-5-nano" \
  --query "{name:name,model:properties.model.name,ver:properties.model.version,sku:sku.name,cap:sku.capacity,state:properties.provisioningState}" -o json
```

Capacity tip: for post-call QA, **50–100 TPM** is usually enough; do not allocate half of remaining quota by default.

Embedding deploy example:
```bash
az cognitiveservices account deployment create \
  --name "<ACCOUNT>" -g "<RG>" \
  --deployment-name "text-embedding-3-small" \
  --model-name "text-embedding-3-small" --model-version "1" \
  --model-format "OpenAI" --sku-capacity 50 --sku-name "DataZoneStandard"
```

## Pitfalls
| Symptom | Cause | Fix |
|---------|--------|-----|
| `715-123420` unusual activity | Azure abuse/fraud gate on new/empty account or cold region | Do not spam retries. Deploy to an EU resource that already has OpenAI deployments. User may need Azure Support for the blocked resource. |
| Foundry MCP empty / connection refused | MCP gateway not running | Use `az cognitiveservices` path; do not block the task |
| Recommended Global because cheaper | Global SKU leaves EU for processing | If user asked EU host → DataZoneStandard only |
| `discover_and_rank.sh: declare: -A: invalid option` | Needs bash 4+ associative arrays | `/bin/bash ./discover_and_rank.sh ...` or pure `az` queries |
| Deploy succeeds on one EU region, fails on another | Per-resource / cold-account gating | Prefer warm resources; report blocked region honestly |
| Dograh QA uses expensive live LLM | `qa_use_workflow_llm` left true | Set false + azure endpoint/model for separate cheap DZ deploy |
| User insists Germany West on empty AIServices | First deploy hits `715-123420` even with free DZ quota | Try once; no spam. Fall back to warm Sweden (`dsselmanovic-6165`) / West Europe (`activids`). Azure Support for DE unlock. |
| User asks Foundry CLI for voice-clone TTS | No `foundry` binary; catalog TTS has no clone | `az cognitiveservices model list` + Speech Personal/Custom Neural — `references/foundry-tts-voice-clone.md` |
| Vesna too monotonous / want emotion | BS neural **no StyleList** (structural) | Prosody/text → EN Multilingual + `<lang bs-BA>` A/B → Personal Voice (docs **bs-BA**); not Foundry deploy — `references/azure-speech-bs-multilingual-clone.md` |
| EN voice speak Bosnian? | Multilingual SecondaryLocales include bs-BA | SSML `<lang xml:lang="bs-BA">`; always set lang (autodetect flaky); quality ≠ native Vesna |
| Docs footnote says voice is "Preview/limited regions" | MS `language-support` page marks bs-BA (and other Extended locales) with a "current GA regions" footnote — misleading | Ignore the footnote; hit the live `voices/list` REST endpoint per region and read the actual `Status` field. bs-BA-VesnaNeural/GoranNeural verified **GA** in both `westeurope` and `germanywestcentral` (live 2026-07-31). |
| Recommend `gpt-4o-mini-tts` as Foundry deploy | Name may be **absent** from regional catalog | Only name models present in live `model list` for target region |
| Dograh embedding / KB 3072-dim error | `text-embedding-3-large` without `dimensions` | Use `text-embedding-3-small` (or ada-002) |
| `InvalidResourceProperties` Standard for 3-small | SE has no Standard SKU for 3-small | DataZoneStandard or GlobalStandard |
| Embedding `DeploymentNotFound` after create | Propagation lag | Wait 10–30s; smoke `*.openai.azure.com` |
| Dograh Endpoint = `*.cognitiveservices.azure.com` | Wrong host for Dograh Azure OpenAI client | `https://<resource>.openai.azure.com/` |

## Verify before claiming success
1. `provisioningState == Succeeded`
2. SKU is the one requested (`DataZoneStandard` for EU)
3. Endpoint URL from `az cognitiveservices account show` — Dograh BYOK maps to **openai.azure.com**
4. Smoke-test chat or embeddings (never print keys); embeddings for Dograh must return **1536** dims

## Related
- Live stack STT/TTS: `foundry-multistack-voice-agent`, `balkan-voice-agent-stack`
- Overlap: `foundry-dograh-llm-selection` covers same QA pick — prefer **this** skill for deploy+ops (merge candidate)
- Dograh Azure BYOK failures: `dograh-azure-openai-byok-debug`
- Official pricing: Azure OpenAI pricing page (Data Zone columns)
- BCS HF search: `huggingface-bcs-search`

## Session inventory pattern (always re-verify live)
Before recommending a deploy target, list warm vs cold EU accounts:
```bash
az cognitiveservices account list -o tsv \
  --query "[?kind=='AIServices'].[name,resourceGroup,location]"
# then per account:
az cognitiveservices account deployment list -g <RG> -n <ACCOUNT> -o table
```
Prefer accounts that already have ≥1 OpenAI deployment for new DataZone deploys. Empty AIServices accounts can hit `715-123420` even when region catalog + quota look fine.

Known model versions seen live (re-check if create fails):
- `gpt-5-nano` → `2025-08-07`
- `gpt-4.1-mini` / `gpt-4.1-nano` → `2025-04-14`
- `gpt-4o-mini` → `2024-07-18`
- `text-embedding-3-small` / `text-embedding-3-large` → `1`

## Support files
- `references/dograh-qa-azure.md` — Dograh QA wiring checklist
- `references/dograh-embedding-byok.md` — Dograh BYOK Embedding: 1536-dim rule, UI fields, SE SKUs, smoke test
- `references/eu-account-map.md` — last-verified EU AIServices inventory + deploy outcomes
- `references/foundry-tts-voice-clone.md` — Foundry TTS/audio catalog + Speech clone path (no Foundry clone model)
- `references/azure-speech-bs-multilingual-clone.md` — EN Multilingual→bs-BA SSML, Vesna monotony, Personal Voice on `vesna` GWC (live 2026-07-30)
- `references/foundry-tts-vs-speech-clone.md` — short Foundry vs Speech clone matrix
