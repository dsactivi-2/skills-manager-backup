# QuickVoice → OrbStack (allgpt-co/QuickVoice)

Inventory drop: `~/Downloads/allgpt-co-QuickVoice-inventory/` (UEBERSICHT.md).
Repo: MIT, pre-stable, `task up:dev`. Last checked main ~2026-08-12.

## What upstream Compose actually is

`docker-compose.dev.yml` = Postgres 16 + Redis 7 only. Optional profile `mail` = Mailpit.
Apps (console :3000, web :3001, docs :3002, server :5000, ai :5555) start on the **host** via Go Task + pnpm + Python venv. Dockerfiles exist for `apps/ai`, `apps/server`, `apps/mcp-server` — not a one-file prod stack.

`AI_WORKER_ENABLED` defaults **false**.

## activi port remap (do not use upstream defaults on the Mac)

Host :3000 is Dograh UI. :5432/:6379 often busy. Publish on unused high ports; inside the compose network keep service names.

## Voice catalog (apps/ai/handlers/voice_catalog.py)

Default: Deepgram Nova-3 STT, AWS Bedrock LLM (Claude/Nova), Deepgram Aura-2 TTS. Extra catalog rows: ElevenLabs, Sarvam. Languages: en / hi / en-IN.

- activi: never enable ElevenLabs.
- No GPT-4.1, no Ollama, no Soniox, no bs-BA in stock catalog.
- Fork via `VOICE_CATALOG_PATH` JSON — required if they want DG + GPT-4.1 + Soniox.

## Telephony vs PBX

Code: Twilio + Telnyx (buy/bind/campaigns). Not FreePBX, not Yeastar, not ARI.
User "PBX" / TG330: LiveKit SIP trunk IDs they paste. Do not invent. Telnyx ≠ TG/ARI.

## MCP marketplace (curated)

Smithery: GitHub, Slack, Notion, Google Drive + custom MCP URL. Separate `apps/mcp-server` exposes QuickVoice as MCP.

## Keys vs inspectable bring-up

Without keys: UI/API/DB/Mailpit health only. Live calls need LiveKit URL+key+secret, STT/LLM/TTS keys, optional Pinecone/S3/Google OAuth/Stripe/Smithery.

User picks (2026-09-01, not yet built): multi-compose (PG, Redis, server, AI, console, web, Mailpit); "alles"; LiveKit worker bind; PBX not Twilio-buy.
