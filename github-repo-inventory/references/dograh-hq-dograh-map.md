# dograh-hq/dograh — inventory map (condensed)

Source: public repo via `gh` tree + raw. Offline harvest:
- `~/Downloads/dograh-hq-dograh-inventory/` (UEBERSICHT.md + files/)
- Env-only flat: `~/Downloads/dograh-env/` (00_…07_ numbered copies)

## Product

Open-source voice AI (self-hosted Vapi/Retell alt.): FastAPI `api/`, Next.js `ui/`, Pipecat submodule, Docker/Helm, native MCP authoring, multi-telephony.

## Env SoT — three layers (do not mix)

| Artifact | Role | Executable? |
|----------|------|-------------|
| `docs/developer/environment-variables.mdx` | Human matrix (defaults, required, OSS vs SaaS) | No — docs only |
| `api/constants.py` | Runtime `os.getenv` / defaults / derived URLs | Yes — API import |
| `api/.env.example` | Copy → `api/.env` for local/OSS | Values you set |
| `api/.env.test.example` | Pytest only (`test_db`) — never prod | Values for tests |
| `ui/.env.example` | Next `BACKEND_URL` / `NEXT_PUBLIC_*` | UI |
| `deploy/hostinger/.env.example` | VPS Traefik/TURN/JWT/Postgres/Redis/MinIO | Deploy |
| `examples/*/.env.example` | `DOGRAH_API_ENDPOINT` + `DOGRAH_API_TOKEN` | SDK clients |

**Explain pair when asked:** MDX = what to set; `constants.py` = what the running app reads. Secrets only in env/secrets store.

Required: `DATABASE_URL`, `REDIS_URL`. Prod: `OSS_JWT_SECRET`, MinIO keys, `TURN_SECRET`. Modes: `DEPLOYMENT_MODE=oss|…`, `AUTH_PROVIDER=local|stack`.

## Maintainer skills (≠ runtime voice)

`.agents/skills/`: `review-agents-md`, `review-pr` only.

## AGENTS.md chain — what / when

```
Root AGENTS.md
├── api/AGENTS.md  → integrations/, telephony/(providers/)
├── ui/AGENTS.md
├── docs/AGENTS.md
└── scripts/AGENTS.md
```

| | |
|--|--|
| **Is** | Instructions for coding agents working **in the git checkout** (orientation, org-scoping, thin routes, worker-sync) |
| **Is not** | Deploy runbook, telephony media debug, live call prompts, product UI config |
| **When** | PR/feature work on dograh-hq/dograh source |
| **When not** | ARI ring-no-audio, env on VPS, Barbarez workflow-only sessions (use project AGENTS + SOUL instead) |

Optional twin files: `CLAUDE.md`. Upstream skill `review-agents-md` audits drift.

## MCP — two surfaces

### A) Workspace authoring (builder agents)

| Piece | Job |
|-------|-----|
| `api/mcp_server/` | FastMCP tools |
| Endpoint `…/api/v1/mcp/` (app or api.dograh.com) | Connect |
| Auth `X-API-Key` / Hermes `MCP_DOGRAH_API_KEY` | |
| Client guide `docs/integrations/mcp.mdx` | Humans wire Claude/Codex/Cursor/Hermes |
| `instructions.py` → FastMCP `instructions=` | **Not a script.** Client injects into LLM system prompt: plan→create→review, AST-only SDK TS, tool order |

Tools: create/save/get_workflow(_code), list/get workflows, create/list tools, list docs/creds/recordings, list/get_node_type, get_voice_prompting_guide, search/read/list_docs.

### B) In-call MCP tool

`docs/voice-agent/tools/mcp-tool.mdx` — agent calls external MCP **during** the call. Not the builder session.

## Voice-prompt topics (authoring recipes)

Via `get_voice_prompting_guide` (stage plan|create|review; optional topic/node_type):

| Topic | Point |
|-------|--------|
| common_guidelines | Near-verbatim globalNode template |
| guardrails | scope / abuse / no fabricate |
| call_flow_design | sections; one fact per turn |
| tool_calls | one job; speech XOR tool |
| success_criteria | condition → action at prompt end |
| end_call_logic | few end paths, clear triggers |
| turn_taking | every turn ends with ask/nudge |
| instruction_collision | no contradicting rules/examples |

Do **not** auto-run on production calls — only when embedded into node prompts. Barbarez AGENTS expects the tool in the change loop. Stack with `german-voice-prompts` / `voice-low-latency-patterns` for DE/latency.

## Templates — four meanings

| Meaning | In git? |
|---------|---------|
| Product catalog (`WorkflowTemplates` DB + UI cards) | Schema/API/UI only — **no sales JSON seeds** |
| `POST /workflow/create/template` | NL → LLM workflow (name is misleading) |
| `{{template variables}}` | Docs + `template_renderer` |
| Helm/nginx/ISSUE_TEMPLATE/dto_fixtures/examples | Yes — not product agents |

Version your agents via MCP export / project repo, not upstream git seeds.

## Model defaults vs adding providers

Defaults (`defaults.py`): LLM OpenAI, TTS ElevenLabs, STT Deepgram, embeddings OpenAI.

| Goal | Path |
|------|------|
| Use listed provider + key | UI Models → BYOK / S2S / Dograh managed |
| Extra model name | Dropdown or manual model field |
| Ollama/vLLM/custom OpenAI API | OpenAI-compatible base URL (or Speaches/HF) |
| Brand-new provider id | Self-host fork: `ServiceProviders` + `@register_*` + `service_factory` branches + options lists |

Hosted SaaS cannot ship a private provider type. See `registry.py`, `service_factory.py`, docs `configurations/inference-providers.mdx` + `llm.mdx`.

## Deploy / telephony providers

docker-compose (pgvector, redis, minio, nginx, coturn, api, ui, cloudflared); hostinger; helm values aws|k3s|managed|single-node.

Telephony: twilio, telnyx, plivo, vonage, vobiz, cloudonix, **ari** (Asterisk). ARI audio = externalMedia WebSocket (`chan_websocket`), not browser TURN — ops skill `voice-ai-infrastructure` + `references/dograh-ari-ring-no-audio.md`.
