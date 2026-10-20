---
name: dograh-upstream-platform
description: "Use for dograh-hq layout, dual-instance MCP, DograhV2 public fork branding."
version: 1.5.0
author: Hermes Agent
license: MIT
---

# Dograh upstream platform map

Class-level map of **dograh-hq/dograh** + Activi dual-instance ops. Prefer `gh` + live probes over memory.

## Dual instances (Activi)

| | Cloud | Self-host |
|--|-------|-----------|
| UI | app.dograh.com | **https://voiceeu.activi.io** |
| MCP | api.dograh.com/api/v1/mcp/ | voiceeu.activi.io/api/v1/mcp/ |
| Hermes | `dograh` | `dograh-voiceeu` |
| Env | `MCP_DOGRAH_API_KEY` | `MCP_DOGRAH_VOICEEU_API_KEY` |
| Create key | Cloud /api-keys | voiceeu **/api-keys** only |

Never mix keys. Explain as two remotes / two keys (simple DE). Restart Hermes after `.env` changes. Bare GET MCP → often 405 OK. Health: `curl -sS https://voiceeu.activi.io/api/v1/health` → oss. Header: `Authorization: Bearer ${ENV}`.

## Public source forks (DograhV2)

Activi public code + optional ship path for voiceeu backend patches:

| | Value |
|--|-------|
| Upstream OSS | `dograh-hq/dograh` (keep as `upstream` remote) |
| Public fork | **https://github.com/dsactivi-2/dograhV2** (brand **DograhV2**) |
| Local mirror cache | `~/.cache/repo-mirrors/dograh.git` / `dograhV2-work` |
| Live voiceeu API | **`dograhv2-api:dg-eu`** (PR #6 Deepgram EU; shipped 2026-07-30) @ `/root/dograh/dograh` |
| Live voiceeu UI | still **`dograhai/dograh-ui:1.43.0`** |
| Rollback API | `dograhai/dograh-api:rollback-pre-dg-eu` (= prior Hub 1.43.0) |
| Stock update | `update_remote.sh` → **dograh-hq releases + Docker Hub** — **not** the fork |

**Ship rule:** Fork features need custom **API image** + compose pin + rollback tag. API-only keeps Postgres/MinIO/`.env`. Server often **no buildx** → strip Dockerfile `# syntax`/`--mount`, build with `DOCKER_BUILDKIT=0 --build-arg TARGETARCH=amd64`. → `references/voiceeu-prebuilt-deploy-fork.md`.

**Branding rule (compatibility-first):** surface only — README banners, docs install/raw URLs, package *metadata* names (`dograhv2-api` / `dograhv2-sdk` / `dograhv2-ui`, Helm chart name), UI GitHub star badge. **Keep** runtime IDs: `@dograh/sdk`, `dograh_sdk`, images `dograhai/dograh-api|ui`, `dograh-hq/dograh-plugins`. Never global-replace `github.com/dograh-hq/dograh` (creates `dograhV2-plugins`, breaks upstream remotes). Surgical README edits only — greedy regex can wipe the file. Recipe: `references/public-fork-branding.md`.


### Local sandbox of a fork feature branch (GitHub untouched)

Preview a large branch (sales API, voice-ops UI, etc.) before remote merge:

- Disposable path under `~/Code/Projects/…-local`; branch `local/main-plus-<feature>`; merge **no-ff**; **never push**.
- Do **not** use stock `start_docker.sh` / `compose --pull always` — that runs registry `dograhai/dograh-api|ui:latest`, not the branch.
- Compose override: build from repo Dockerfiles, tags `*:test`, `pull_policy: never`, unique `COMPOSE_PROJECT_NAME`.
- Fresh DB: `alembic upgrade heads` if multiple heads (upstream multi-head + new migrations).
- UI typecheck may fail after sidebar-heavy merges → sandbox-only ignoreBuildErrors **or** type fixes.
- Defaults: UI **:3010**, API **:8000**; 307 before login OK with local auth + signup.
- **Login bounce:** API login 200 but UI returns to login → cookies with **`Secure`** on http://localhost are dropped. Next `next build` inlines `NODE_ENV=production`. Local: `COOKIE_SECURE=false` + session/logout `secure: process.env.COOKIE_SECURE === 'true'` only. Clear cookies; retest. Full recipe: `github-branch-consolidation` → `references/local-sandbox-merge-and-compose.md`.
- No default admin; Sign up or `POST /api/v1/auth/signup` (valid email, password ≥8).
- **Superuser:** only `users.is_superuser` in compose Postgres (not git). UI needs login/`/api/auth/oss` to expose the flag + logout/login. Superadmin: Impersonate Stack-oriented; local useful **View All Runs**. Recipe: `github-branch-consolidation` → `references/oss-local-superuser-session.md`.
- Feature sidebar footer: often **Settings** → `/settings` (old Platform Settings); Stack Account settings absent on local auth.
- Checklist: skill `github-branch-consolidation` → `references/local-sandbox-merge-and-compose.md`.

## Env / config layers

| Artifact | Role |
|----------|------|
| `*.env.example` | Operator templates |
| `docs/developer/environment-variables.mdx` | Human tables |
| `api/constants.py` | Runtime getenv — wins on doc drift |
| `defaults.py` | Default LLM/TTS/STT/embed only |
| `registry.py` + `service_factory.py` | BYOK list; new brand needs code (full recipe: `references/add-tts-provider-codeside.md`) |

BYOK without fork: existing provider + key + optional manual model / OpenAI-compatible URL.

### Camb.ai TTS (already in image)

- Registry + factory ship `provider=camb` → Pipecat `CambTTSService` (`mars-flash` / `mars-pro` / `mars-instruct`).
- Live voiceeu (`DograhEUV2`, dograh-api ≥1.43): Camb import OK — **no** extra `camb-sdk` on the VPS for live calls.
- Put API key in **Dograh org/user TTS config**, not as a host-daemon requirement.
- Local clone/batch SDK is separate (Mac venv only).
- Residenz: public Camb API → **US (GCP)**; privacy UAE/multi-country — not EU-pin. Strict DE/BS prod stays Azure Neural EU unless Camb commits EU region in writing. Notes: `balkan-voice-agent-stack` → `references/camb-tts-dograh.md`.

### Org STT/TTS/LLM config (NOT workflow TS)

Locale/voice live in **org AI model configuration**, never in workflow TypeScript.

| | |
|--|--|
| GET | `/api/v1/user/configurations/user` |
| PUT | same + body `{ "tts": {…} }` |
| Validate | `/api/v1/user/configurations/user/validate` |
| Auth voiceeu | **`X-API-Key`** MCP key (Bearer → 401) |

Masked `api_key` from GET is restored on merge. **BS Stufe 1:** `azure_speech` + `germanywestcentral` + `bs-BA-VesnaNeural` + `bs-BA` + `speed` 0.9–0.95 (org-wide). Recipe: `references/org-tts-stt-config-api.md`. Project: `dograh-aquaphor-telesales/docs/STAGE1_VESNA_TTS.md`.

### Azure Speech TTS + SSML (no agent-tag passthrough)

- Pipecat `AzureTTSService` **always** builds SSML and **escapes** agent text (`_escape_text`). LLM `<break>` / nested `<prosody>` = **not** applied.
- Dograh factory maps only **`speed` → rate** (plus voice/language/region). pitch/style/volume exist in Pipecat Settings but not in `AzureSpeechTTSConfiguration` yet.
- SSML = **request-time** (no Speech redeploy). Verify: code + Hörtest `Zdravo <break time="2000ms"/> x` (expect no 2s pause). Not Azure Portal.
- Paths: `api/services/pipecat/service_factory.py` (AZURE_SPEECH); pipecat `src/pipecat/services/azure/tts.py`; fork **dsactivi-2/dograhV2** pin `555a9b2`. Live: `docker exec dograh-api-1` site-packages copy.
- Detail: `references/dograh-azure-ssml-runtime.md`
- User-owned `tts-ssml-prompt-hardening` lacks this gate until `hermes curator adopt tts-ssml-prompt-hardening`.

### Fish Audio TTS (NOT shipped — self-host code-side add)

Fish Audio is **not** in Dograh's provider list, and the "point OpenAI-TTS at Fish" trick fails (Fish cloud has no OpenAI-compatible `/v1/audio/speech`). Only viable self-hosted by patching source at the same **5 sites** as any new provider (registry enum, `service_factory.create_tts_service` elif, options, frontend list, requirements). Clone `reference_id` → `voice` field; model default `s2-pro`. **Trap:** Dograh vendors a *pinned pipecat fork as a git submodule* — verify the real `FishAudioTTSService` import/Settings shape in the submodule (`grep -ri FishAudio pipecat/src/pipecat/services/fish/`) before coding; never trust public pipecat docs. Do **not** enum-lock language (would coerce `bs`→English). Proper-name mispronunciation (e.g. `Đenita`) = G2P error on OOV words; Fish has no lexicon/SSML, so **phonetic respelling** (`Dženita`) is Fish's official fix — automate it in an agent via a replacement `text_filter` before TTS, not the LLM prompt. Full recipe: `references/fish-audio-tts-codeside.md`.

### OpenAI TTS factory gap

Pipecat supports `voice` + `instructions` + `speed` for `gpt-4o-mini-tts`. Dograh OPENAI factory often passes **only `model`**. Do not claim Dograh has OpenAI emotion-instructions until mapped. BS+EU: prefer Azure Vesna even after fix.

### Deepgram EU inference (fork vs live)

| Layer | Status |
|-------|--------|
| Fork `dograhV2` main | PR #6: `DEEPGRAM_BASE_URL` default **`api.eu.deepgram.com`**; `_deepgram_inference_urls()` STT/Flux/TTS; key validate stays global `api.deepgram.com` |
| Org UI Transcriber | no Endpoint field — host is code/env |
| Live voiceeu API | **`dograhv2-api:dg-eu`** — `DEEPGRAM_BASE_URL=api.eu.deepgram.com` verified |
| UI | still Hub 1.43.0 (backend-only ship) |
| Nova-3 BS | `language=bs` + repeated `keyterm=` (not `keywords`); org UI has **no** endpoint field |

EU inference is live on API. Org 2 STT is now **Deepgram nova-3-general + `bs`** (2026-07-30). Keyterms still need WF `workflow_configurations.dictionary` CSV (not Org UI). Deploy/build/rollback: `references/voiceeu-prebuilt-deploy-fork.md`. Call host check: `references/deepgram-call-verify.md` (logs show Creating STT but not EU URL; US `/v1/projects` = key only).


## MCP product surface

- Tools: `api/mcp_server/` (~16)
- Builder system text: `instructions.py` (LLM client injection)
- Human attach guide: `docs/integrations/mcp.mdx`
- Voice topics: common_guidelines, guardrails, call_flow_design, tool_calls, success_criteria, end_call_logic, turn_taking, instruction_collision via `get_voice_prompting_guide` (plan/create/review)

## Templates

No sales JSON seeds in git. DB `WorkflowTemplates` + UI; `POST …/create/template` = NL→LLM. `{{vars}}` = runtime context. Repo: SDK examples, dto_fixtures, Helm/nginx templates.

## AGENTS.md chain

Root→api→ui→docs→scripts→integrations→telephony — coding-agent monorepo rules only. Not deploy, not phone prompts.

## ARI ring / no audio

Browser OK + handset rings + silence → media WS/ulaw/modules. DograhEUV2=app, GonoPBX=Asterisk. Never `apt install asterisk` if phones ring (apt → `n`). ARI ≠ browser TURN. Secret mask sed: `s/=.*/=***/` not `s/=./`. Runbook: `voice-ai-infrastructure` / `references/dograh-ari-ring-no-audio.md`.

Fork vs upstream: live git only — `references/ari-live-diff.md`. Audio-Pfad (transport/serializers/8 kHz) identisch; dograhV2 HEAD oft **älter** als dograh-hq `origin/main` (Betrieb: Auto-Deactivate, `ws_client_name`-Park). Self-Host ohne CPaaS: Provider-Register nur **ARI**. TG400 = SIP zur PBX, nicht zu Dograh. PBX-Ranking ohne Ist-System (Bias).

**ARI-Schubladen:** nie ganze `factory.py` / `organization.py` / UI / Original-Alembic über den Fork. Chirurgisch: 3 Spalten + neue Migration am Fork-Head (`00b0201ad918` Stand 2026-08-14) + 3 Client-Methoden + `failure.py` weich + kleiner Reactivate + factory-Guard. Halb (Model ohne Migration) crasht Telephony. Vollständig: bestehende Configs bleiben `inactive=false`, kein Anruf-Diff bis etwas parkt. SoT: `~/Downloads/dograhV2-ari-fixes/`.

## Comms

Direct DE tables; explain commands before paste; live verify before production-ready.

## References

- `references/ari-live-diff.md` — live git ARI: dograh-hq vs dograhV2
- `references/dual-mcp-voiceeu.md` — dual MCP auth routing
- `references/upstream-paths-cheatsheet.md` — monorepo path map
- `references/public-fork-branding.md` — mirror push + DograhV2 surface branding
- `references/dograh-azure-ssml-runtime.md` — Azure TTS SSML escape / factory / verify
- `references/org-tts-stt-config-api.md` — PUT org TTS/STT/LLM (Stufe 1 Vesna)
- `references/voiceeu-prebuilt-deploy-fork.md` — fork API image → voiceeu; dry-run Freigabe; rollback; no DB wipe
- `references/deepgram-call-verify.md` — live call logs + DEEPGRAM_BASE_URL one-liner + dictionary keyterms
- `dograh-voice-opening-greeting` (user-owned): PAS Open unclear STT → refuse/DNC — adopt to patch

## Adopt note

User-owned `dograh-selfhost-guides` + `dograh-setup` + `tts-ssml-prompt-hardening` + `foundry-multistack-voice-agent`: run `hermes curator adopt <name>` before curator patches.
