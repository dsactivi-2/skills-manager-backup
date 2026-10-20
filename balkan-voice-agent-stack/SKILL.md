---
name: balkan-voice-agent-stack
description: "Full STT→LLM→TTS stack selection for Bosnian/Croatian/Serbian voice agents. Use when building a voice agent for the Balkan market — covers provider support verification, architecture decisions (cascaded vs S2S), and concrete model recommendations."
trigger: "Use when selecting models and providers for a Bosnian, Croatian, or Serbian voice agent — especially for Dograh outbound telesales, but applicable to any BKS voice agent project."
author: activi
version: 2
created_at: 2026-07-12
---

# Balkan Voice Agent Stack Selection

## When to use
Use when building a voice agent targeting Bosnian (bs-BA), Croatian (hr-HR), or Serbian (sr-RS) speakers. Covers the full pipeline: STT, LLM, TTS, and the architecture decision between cascaded and speech-to-speech.

## Verified Provider Support Matrix (as of July 2026)

### STT (Speech-to-Text)

| Provider | Bosnian (bs) | Croatian (hr) | Serbian (sr) | Latency | Notes |
|----------|-------------|---------------|-------------|---------|-------|
| Deepgram Nova-3 | ✅ since Jan 2026 | ✅ since Jan 2026 | ✅ since Jan 2026 | <300ms streaming | Keyterm Prompting supported |
| Azure Speech | ✅ bs-BA | ✅ hr-HR | ✅ sr-RS | ~300-500ms | Custom Speech available, EU regions |
| ElevenLabs Scribe v2 | ❌ not listed | ❌ not listed | ✅ listed | <150ms | Serbian only, not full BKS |
| OpenAI Whisper | ⚠️ via multilingual | ⚠️ via multilingual | ⚠️ via multilingual | varies | No dedicated bs/hr/sr models |
| Google Cloud STT | ❌ not listed | ❌ not listed | ❌ not listed | — | Chirp 3 has no BKS support |

### LLM (Language Model)

| Model | BKS Quality | Voice Suitability | Latency | Cost | Notes |
|-------|------------|-------------------|---------|------|-------|
| GPT-4.1 | ✅ Good (full model) | ✅ Best voice balance | ~400ms TTFT | $2/$8 per 1M | Industry standard for voice agents (40M+ calls/month on Retell) |
| GPT-4.1 Mini | ⚠️ Known issues with non-English | ⚠️ Weaker multi-turn | Faster | $0.40/$1.60 | Community reports quality drops for Italian, Romanian — test Bosnian before production |
| GPT-4.1 Nano | ❌ Poor non-English | ❌ Not for customer-facing | Fastest | $0.10/$0.40 | Classification/routing only, not conversation |
| Claude Sonnet 4.6 | ✅ Strong multi-turn | ✅ Good instruction following | ~500ms | ~$3/$15 | No speech-to-speech mode, cascaded only |
| Gemini 3.0 Flash | ⚠️ Untested for BKS | ✅ Fast, cheap | Fast | Low | Speech-to-speech available but BKS support unclear |

### TTS (Text-to-Speech)

| Provider | Bosnian | Croatian | Serbian | Quality | Notes |
|----------|---------|----------|---------|---------|-------|
| OpenAI gpt-4o-mini-tts | ✅ listed | ⚠️ via Bosnian | ⚠️ via Bosnian | Good | cedar/marin; EN-optimized; `instructions` steers delivery |
| Higgs TTS 3 | ✅ polished (HF) | ✅ | ✅ | Best quality | Research/NC; commercial/Boson API for products |
| ElevenLabs v3 | ✅ BOS listed | ✅ | ✅ | High | A/B cost/latency/quality |
| Google Cloud TTS | ❌ | ✅ hr-HR (30 voices) | ❌ | Good | Croatian only, not Bosnian |
| Azure Speech TTS | ✅ bs-BA Vesna/Goran | ✅ Gabrijela/Srecko | ✅ Sophie/Nicholas | Good | Live Neural GWC; **EU**; BS **no StyleList**; SSML rate/pitch/break |
| Azure Personal Voice | ✅ docs target `bs-BA` | ✅ hr listed | ⚠️ | Higher expressivity if clone warm | Gated+consent; Speech not Foundry; `vesna` API 200 empty profiles (2026-07-30) |
| Azure EN MultilingualNeural | ✅ SSML `lang bs-BA` | ✅ | ✅ | Livelier than Vesna; less native | 29 EN names on GWC; always set `<lang>`; A/B before prod |
| Camb.ai MARS | ⚠️ locale matrix | ⚠️ | ⚠️ | High (clone/emotion) | Dograh-native `provider=camb`; **no EU residency** |

**BS vs HR neural:** BiH prod = Vesna/Goran only. Gabrijela is monolingual HR — `xml:lang=bs-BA` does not convert (live A/B). Emotion on BS ≈ **service** SSML + phrasing — **not** LLM `<break>` (Pipecat escapes agent text). Dograh maps `speed`→`rate` only; control tags billable. Verify: `dograh-upstream-platform` → `references/dograh-azure-ssml-runtime.md`.

**Vesna monotony (live 2026-07-30):** `bs-BA-Vesna/Goran` have **no StyleList** — flat delivery is structural, not misconfig. Mitigations in order: (1) short sales phrasing + punctuation, (2) org `speed` / service prosody rate·pitch·break, (3) A/B **EN MultilingualNeural + `<lang xml:lang="bs-BA">`** (29 EN voices on GWC list; livelier, less native BiH), (4) Azure **Personal Voice** (~1 min + consent; docs include **bs-BA** target; `vesna` customvoice API 200 empty). Multilingual/Personal Voice: **timbre ≈ independent of language**; Vesna couples both. Do **not** promise Foundry `tts` deploy for clone. Ops: `foundry-model-ops` → `references/azure-speech-bs-multilingual-clone.md` + `references/foundry-tts-voice-clone.md`.

### Camb.ai TTS (Dograh-native — residency gate)

- Already in Dograh/Pipecat on voiceeu (`CambTTSService`; `mars-flash` / `mars-pro` / `mars-instruct`). **Do not** install `camb-sdk` as a separate VPS service for live calls.
- Wire via Dograh org/user TTS: `provider=camb` + API key + integer `voice_id` + BCP-47 `language`. Local SDK only for clone/batch.
- Residenz (live 2026-07-30): `client.camb.ai` → GCP **US (Iowa)**; Privacy = **UAE or any country** of facilities; legal **Ento.ai FZ LLC / Dubai**. No public EU region picker.
- **Prod rule:** Azure Vesna/Goran (or freigegeben mini-tts) remain default for **strict-EU DE/BS**. Camb = A/B, cloning, non-residenz experiments until written EU-region + DPA.
- Detail: `references/camb-tts-dograh.md`

## Verifying support from DograhV2 config source (not just provider docs)

The registry is authoritative for what a Dograh instance actually offers. In `dsactivi-2/dograhV2`:
- **Provider registry:** `api/services/configuration/registry.py` — `ServiceProviders` enum + per-provider `*_PROVIDER_MODEL_CONFIG` and default LLM models (`GOOGLE_MODELS`, `gpt-4.1`/`gpt-5` families, OpenRouter `anthropic/claude-sonnet-4`, Bedrock, Groq llama, etc.).
- **Language/voice lists:** `api/services/configuration/options/*.py` (one file per provider: `google.py`, `cartesia.py`, `elevenlabs.py`, `azure.py`, `sarvam.py`, `smallest.py`, ...).

**TRAP — `*_LANGUAGES` constants gate STT only, not TTS.** In the options files, `ELEVENLABS_STT_LANGUAGES`, `CARTESIA_STT_LANGUAGES` (= `CARTESIA_INK_WHISPER_STT_LANGUAGES`), etc. are the **transcriber** language sets. ElevenLabs/Cartesia **TTS** engines are multilingual and are *not* gated by any per-language list — they synthesize `bs` text via the multilingual model even though `bs` never appears in a TTS constant. Do NOT read `ELEVENLABS_STT_LANGUAGES` and conclude anything about ElevenLabs TTS.
- **Google is the exception:** `GOOGLE_TTS_LANGUAGES` (model `chirp_3_hd`) is a real closed list and genuinely has **no `bs-BA`** — only `hr-HR` and `sr-RS`. Confirmed by reading the full block. So Google TTS truly cannot do Bosnian; ElevenLabs/Cartesia can.
- STT `bs` in-repo (explicit list membership): ElevenLabs `scribe_v2_realtime`, Cartesia `ink-whisper`, Gladia `solaria-1`, Deepgram `nova-3-general`, Google `chirp_3` (`bs-BA`).

**Recon commands:** `gh api repos/OWNER/REPO/contents/PATH --jq '.content' | base64 -d` to dump a file; `gh search code --repo OWNER/REPO "TERM"` to locate constants. The bottleneck for Bosnian is TTS voice quality, not the LLM.

## MCP auth in DograhV2 (no OAuth)

Two separate "MCP" surfaces, **neither uses OAuth**:
1. **Dograh MCP Server** (`api/mcp_server/auth.py`) — Claude/Cursor drive Dograh. Auth = `X-API-Key`, `Authorization: Bearer dgr_...` (API key), Stack-Auth access token, or local JWT. 16 tools registered in `api/mcp_server/server.py` (`create_workflow`, `create_tool`, `get/list_workflow*`, `list_credentials/documents/recordings/tools`, `list/get_node_type`, `save_workflow`, `get_voice_prompting_guide`, `list_docs`/`read_doc`/`search_docs`).
2. **External MCP server as a voice-agent tool** (`create_tool` + `credential_uuid`) — uses the 5 `WebhookCredentialType` values only: `none, api_key, bearer_token, basic_auth, custom_header` (`api/db/models.py`, validated in `api/routes/credentials.py`). Docs recommend `bearer_token`.

The `oauth` hits in the repo are **user login** (`ops-dashboard/src/lib/auth/*` Better-Auth `genericOAuth`; `ui/src/app/handler/[...stack]/*` Stack Auth), unrelated to MCP.

## Architecture Decision: Cascaded vs Speech-to-Speech

### Choose CASCADED (STT → LLM → TTS) when:
- You need observability (transcripts, per-stage debugging)
- STT errors are expected (Bosnian phone audio)
- You need to A/B test prompts
- Compliance/audit requirements exist
- You need to optimize sales performance from transcripts

### Choose SPEECH-TO-SPEECH when:
- Latency is the absolute top priority
- The language is well-supported by the S2S model
- You accept reduced observability
- The use case is simple (FAQ, routing) not complex sales

**For Bosnian telesales: Cascaded wins.** STT errors are unavoidable, sales optimization needs transcript-level debugging, and prompt control is critical for objection handling.

## Recommended Stacks

### Primary (strict EU Dograh BiH): Deepgram Nova-3 (bs) → GPT-4.1 / Foundry EU → Azure Vesna/Goran @ GWC

- STT: Deepgram Nova-3 `bs` + keyterms + **EU host `api.eu.deepgram.com`** (FRA DE, GA). Default `api.deepgram.com` is **US**. See `references/deepgram-eu-endpoint.md`
- **Live voiceeu API (2026-07-30):** image **`dograhv2-api:dg-eu`** — `DEEPGRAM_BASE_URL=api.eu.deepgram.com` verified. UI still Hub 1.43.0. Rollback: `dograhai/dograh-api:rollback-pre-dg-eu`. Recipe: `dograh-upstream-platform` → `references/voiceeu-prebuilt-deploy-fork.md`
- STT fallback EU: Azure Speech `bs-BA` @ germanywestcentral
- LLM: GPT-4.1 (or Foundry DataZone when EU inference preferred)
- TTS: `bs-BA-VesnaNeural` / `GoranNeural` + Dograh `speed` ~0.95; **not** Gabrijela-as-BS
- **Apply TTS/STT org-wide** via `PUT /api/v1/user/configurations/user` (voiceeu: **X-API-Key**) — not workflow TS. Recipe: `dograh-upstream-platform` → `references/org-tts-stt-config-api.md`
- Live voiceeu Org **2** (`ds@activi.io`, 2026-07-30): TTS Vesna+GWC+0.95; **STT = Deepgram `nova-3-general` + `language=bs`** (EU API). Better than SM ghosts; short noise still garbles. **Keyterms off** until WF `dictionary` CSV. PAS Open can map unclear/`Ali` → refuse/DNC — prompt/edges.

### A/B non-strict-EU TTS: gpt-4o-mini-tts (cedar) or Camb (`provider=camb`)

Only when customer does **not** require EU audio processing. Camb = US API / no public EU residency. Dograh OpenAI factory often omits `voice`/`instructions` until patched — verify factory before promising emotion-steer.

### Budget LLM: Deepgram Nova-3 (bs) → GPT-4.1 Mini → Azure Vesna

~80% cheaper LLM. MUST validate Bosnian quality with real calls before production.

## Deepgram Keyterms (Nova-3)

"Nova-3 bs + Keyterms" = brands/SKUs via repeated `keyterm=` (no `:weight`). See `references/deepgram-keyterms.md`.

**Dograh:** Org UI has no keyterm field. `run_pipeline.py` reads `workflow_configurations.dictionary` (comma-separated) → `create_stt_service(..., keyterms=)`. Empty dictionary ⇒ no boost. Aquaphor: `Aquaphor,Firmira,Smile,Amina,bokal,pouzećem,flaširana,slavina`.

## LLM full vs Mini

Full default for bs sales (short streamed answers). Mini only after real-call A/B. Perceived lag often STT/TTS/endpointing.

## Open source / HF

No mature **bs-only** high-download STT/TTS on HF. Practical open path (live 2026-07-29):
- STT: `openai/whisper-large-v3-turbo` (tags hr/sr/bs) or classla ParlaSpeech-HR / juznevesti-SR; WER on real calls first
- TTS: HF thin (sr VITS/F5 only) → keep managed Azure/OpenAI/ElevenLabs
- Optional Whisper FT: ParlaSpeech-HR/RS + own BS call audio — only if turbo WER fails
- Live Dograh: managed STT preferred; do **not** run CPU-only large Whisper on the Dograh app host for multi-call
- HF serverless turbo = only `hf-inference` + `deepinfra`, **no EU pin** → never live primary (BS or DE)
- Sizing/search: `huggingface-bcs-search` (+ `references/whisper-turbo-sizing.md`, `references/hf-inference-providers-stt.md`)
- Tables: `references/opensource-hf-stack.md`

### Camb open-source MARS (self-host) — not for BS

| Model | VRAM | Language (OS) | License | voiceeu |
|-------|------|---------------|---------|---------|
| MARS5-TTS | **≥ ~20 GB** | **English only** | AGPL-3.0 | no GPU / ~8 GB RAM → unfit |
| MARS6-turbo | ~70M; ~4–8 GB est. | English-centric | check repo | needs separate GPU node |

Zero-shot cloners, not ready voices. EN ckpt ≠ reliable bs phonetics. Multilingual MARS = **cloud only**. EU BS clone: Azure Speech Personal/Custom Neural or multilingual OS + GPU-EU + Dograh `speaches`. See `references/camb-tts-dograh.md`.

### Microsoft Foundry TTS vs clone
Foundry catalog (`az cognitiveservices model list`): `tts`/`tts-hd`/`gpt-audio*`/`gpt-realtime*` = **no sample clone**. Clone = Azure Speech. Ops: `foundry-model-ops` → `references/foundry-tts-voice-clone.md`.

## DE Live-Telesales (cascaded, same platform)
German market: keep cascaded STT→LLM→TTS; change locales in Dograh UI Model Config only (not Workflow-TS):
- STT primary: Deepgram Nova-3 **`de`** + DE keyterms
- STT strict-EU/fallback: Azure Speech **`de-DE`** (e.g. `vesna` @ germanywestcentral)
- Reject HF Whisper serverless for live
- Doc: `dograh-aquaphor-telesales/docs/DE_LIVE_TELESALES_STT_UPDATE.md`
- Spoken DE prompts: `german-voice-prompts` (user-owned; `hermes curator adopt german-voice-prompts` if curator should own STT notes there)

## Pitfalls

- Do NOT use Google Cloud TTS for Bosnian — Croatian only (hr-HR)
- Do NOT assume GPT-4.1 Mini/Nano work for Bosnian without testing
- Do NOT use Speech-to-Speech for Bosnian sales — lose stage observability
- Do NOT mix Croatian STT with Bosnian TTS
- Do NOT claim Deepgram has **no EU datacenter** — pin `api.eu.deepgram.com` (FRA); US default is the residenz mistake
- Do NOT treat EU Deepgram `/v1/projects` 404 as no access — probe `/v1/listen` instead.
- Do NOT conclude Deepgram EU is dead when `dg listen` fails with `agent_rest` / login project errors — prove with curl EU listen first (`references/deepgram-eu-endpoint.md` CLI section)
- Do NOT require a separate Deepgram key for EU — same key; only host changes (1P vault DograhEU / item Deepgram)
- Do NOT blame Vesna/`speed` for ghost user text — check STT (SM `hr` + noise/echo; garbage → PAS Open stuck on `permission_granted=false`)
- Do NOT substitute `hr-HR-GabrijelaNeural` for BiH prod — keep Vesna/Goran
- Do NOT redeploy Speech/Foundry for SSML — request-time only; lean markup (tags billable)
- Do NOT skip Deepgram Keyterm Prompting for product names
- Do NOT treat ElevenLabs Scribe as automatic bs STT default without live lang-matrix check
- Do NOT embed Higgs TTS research/NC weights in commercial agent products
- Do NOT default XTTS-v2/Kokoro for bs without language proof
- If `hf` CLI OAuth fails: public `huggingface.co/api/models` — not a permanent "HF broken" rule
- Do NOT use HF Inference Providers Whisper as DE/BS live STT just because tags include `de`/`bs`
- Do NOT install standalone `camb-sdk` on voiceeu for Dograh calls — Camb TTS is already in the API image via Pipecat
- Do NOT claim Camb EU data residency / EU inference without a written Camb enterprise commitment — public surface is US API + UAE legal
- Do NOT switch DE/BS prod TTS to Camb solely for quality/clone if the customer requires EU audio processing — keep Azure Neural EU
- Do NOT pick Camb OS MARS5/MARS6 for bosnian prod — EN-only open weights; heavy GPU; not on voiceeu
- Do NOT treat Vesna monotony as a config bug — BS neural has **no StyleList**; use phrasing/speed/prosody → Multilingual+`lang bs-BA` A/B → Personal Voice (`foundry-model-ops` / `references/azure-speech-bs-multilingual-clone.md`)
- Do NOT expect Microsoft **Foundry model deploy** for sample voice cloning — use Azure Speech Personal/Custom Neural (`foundry-model-ops` / `references/foundry-tts-voice-clone.md`)
- Do NOT assume Multilingual autodetect is enough for BS — always SSML `<lang xml:lang="bs-BA">`
- Do NOT claim LLM classic SSML works on Dograh Azure until escape/passthrough is patched — use `speed` + punctuation; map: `dograh-upstream-platform` → `references/dograh-azure-ssml-runtime.md`
- Do NOT edit workflow TS to set Vesna/locale/speed — org config API only
- Do NOT assume Dograh OpenAI TTS maps `instructions` without reading `service_factory` OPENAI branch
- Do NOT use Nova-2 `keywords=term:weight` on Nova-3 — API 400; use plain repeated `keyterm=`
- Do NOT expect `dg listen --keyterm` — flag missing; curl/API only
- Do NOT set default deepctl profile to EU if daily `dg listen` must work — default **us**, EU via `scripts/dg-eu-listen.sh`
- Do NOT claim Deepgram EU inactive after 2026-07-30 ship without `docker exec` on `DEEPGRAM_BASE_URL` — live default is EU on `dograhv2-api:dg-eu`; missing ⇒ image rolled back
- Do NOT use `update_remote.sh` expecting dograhV2 patches — tracks dograh-hq only; re-ship custom API image after Hub upgrades if fork still needed
- Do NOT build fork API Dockerfile on voiceeu without BuildKit workaround: strip `# syntax` + `--mount`, pass `--build-arg TARGETARCH=amd64`, `DOCKER_BUILDKIT=0`

## References

- `references/provider-support-evidence.md`
- `references/deepgram-keyterms.md` — live keyterm vs keywords + BS defaults
- `references/deepgram-eu-endpoint.md` — EU base + Dograh pin + CLI us/dograheu
- `scripts/dg-eu-listen.sh` — EU listen curl helper (deepctl 0.2.25 EU listen broken)
- `references/opensource-hf-stack.md`
- `references/live-verify-2026-07-bs-telesales.md` (if present)
- `references/camb-tts-dograh.md` — Camb Dograh wiring + residency + OS MARS hardware
- Foundry TTS/clone: `foundry-model-ops` → `references/foundry-tts-voice-clone.md` + `references/azure-speech-bs-multilingual-clone.md`
- Dograh Azure SSML: `dograh-upstream-platform` → `references/dograh-azure-ssml-runtime.md`
- Org TTS/STT API: `dograh-upstream-platform` → `references/org-tts-stt-config-api.md`
- voiceeu fork ship/rollback: `dograh-upstream-platform` → `references/voiceeu-prebuilt-deploy-fork.md`
- Project DE STT: `docs/DE_LIVE_TELESALES_STT_UPDATE.md` under dograh-aquaphor-telesales

- See also: `bosnian-tts-provider-comparison`; `dograh-voice-workflow-optimizer`; `huggingface-bcs-search`; `dograh-upstream-platform`
