---
name: openui-setup
description: Use when scaffolding or explaining OpenUI locally.
---

# OpenUI setup (this user)

## When to Use

User wants a local OpenUI chat, CLI create, Thesys keys, or a short German explanation of Demos vs Agent Interface vs Gateway vs assistant-ui vs CopilotKit vs OpenUI Lang.

Load the installed `openui` skill for APIs. This file is the local workflow and explanation rules.

## Explain, do not catalog

Answer in short German. One use case with a concrete example, not an index dump and not a URL table. Website Demos are not installable apps. Agent Interface is a React shell inside a Next.js folder, not a desktop program.

assistant-ui and CopilotKit are existing chat shells. OpenUI there only replaces the assistant-message body; `onAction` plus `useAui()` / `useAgent()` sends a button click back as the next user turn. If there is no existing chat, use Agent Interface — assistant-ui adds nothing extra. CopilotKit is a product runtime, not GitHub Copilot.

OpenUI Lang is not a separate install: parser/renderer live in `@openuidev/lang-core` and `@openuidev/react-lang` already in the Cloud scaffold. Do not run another `npx skills add` for the language.

Doc lookup: installed OpenUI skill `references/llms.txt` first, then only that canonical URL. Do not web-search OpenUI docs. Lab/playground/community items live on the Demos page even when they have no own index row — fetch that page and explain from it. If the user supplies an OpenUI URL (blog included), fetch that URL; do not stop at “not in llms.txt”.

## Scaffold (verified CLI 0.5.2)

Do not pass `--backend-framework default` — the CLI rejects it. Allowed: `langgraph`, `vercel-ai-sdk`, `vercel-eve`.

Unattended first chat (Gateway, no TTY login):

```bash
cd /Users/activi/Projects
npx @openuidev/cli@latest create --name openui-agent --template openui-cloud --backend-framework vercel-ai-sdk --no-interactive --no-immediate --no-skill --auth skip --no-telemetry
cd openui-agent
npx next dev -p 3030
```

`--auth skip` writes `.env` without `THESYS_API_KEY`. The page can return 200; generation throws `Missing required env var: THESYS_API_KEY` until the user writes the backend key into `.env` themselves. Never ask them to paste the key in chat. Restart `next dev` after `.env` changes.

Port 3000 is not required. Probe `lsof -nP -iTCP:<port> -sTCP:LISTEN` first. On this Mac, 3000 is often Pitchpipe; 3030 may already hold another Next app — pick the next free port (3031 worked). Port 8000 is often OrbStack; an OpenUI config client that hardcodes `:8000` will hit the wrong process — bind a free port and give that URL.

If they name `--backend-framework langgraph` and a project name, use those flags. Unattended still needs `--no-interactive --no-immediate --no-skill --auth skip --no-telemetry`. After skip, copy `THESYS_API_KEY` from an existing sibling `.env` under `/Users/activi/Projects/*/openui*` only if that file already has a set backend key; never invent or print it. Report copied/empty only.

LangGraph Cloud route is `POST /api/chat` with `{threadId, model, messages:[{type:"human",content:...}]}`. A made-up `threadId` can still stream OpenUI Lang, then end with `store chat completion history failed: 404 Conversation not found` — that is Gateway conversation storage, not a failed generation. Browser chat that minted a thread via `/api/frontend-token` does not hit that 404. Kill the listener with the PID from `lsof` on that port; do not leave `next dev` running after they ask to stop.

## OpenUI steers an external agent (config API)

When OpenUI must configure a live agent (voice, prompt, tools, calendar) without embedding secrets in the UI:

1. Single file `config/agent_config.json` is the source of truth.
2. Agent process loads voice/prompt/tools from that file at start and hot-reloads on mtime/watchdog.
3. FastAPI: `GET /api/config` returns `{status, agent_running, agent_pid, config}`; `POST /api/config/update` writes the JSON atomically and restarts the agent process.
4. Calendar connectors (google_calendar / outlook / cal.com) are permission-gated stubs until tokens exist — never commit tokens.
5. CORS open for the OpenUI origin. Verify GET then POST with curl before telling the UI it can attach.

Do not `openui deploy` unless they asked for a shareable URL. Local-only test stays on localhost.

## Thesys keys

- Backend / inference (`THESYS_API_KEY`): Gateway, Autofix, server tracking. Required for chat. Server-only.
- Client (`pk-th-…`): Observability SDK in the browser (parse/render). Not Autofix. Skip on a first Gateway scaffold.
- Frontend tokens: minted from the backend key for a `user_id`. Not the Client API Key row.

A Gateway scaffold with `generateSystemPrompt({ cloud: true })` already corrects in-stream. Do not add a second Autofix client unless generation bypasses Gateway.

Let the user write keys only in `/Users/activi/Projects/openui-agent/.env` (open in TextEdit). Never ask them to paste a key in chat. After save, classify by prefix only (`pk-th-` = client, otherwise backend) and report set/empty — never print the value. A backend key in a tool log is leaked: tell them to rotate in the Thesys console and write the new value only in `.env`.

`NEXT_PUBLIC_THESYS_CLIENT_API_KEY` is `pk-th-…` only. Init: `src/components/observability-init.tsx` in `layout.tsx` — read the key from env, never hardcode `Observability.init({ apiKey: 'pk-th-…' })`. Package `@openuidev/observability-cloud` in the app root. Console name field is a label (`web-app`), not a key. If the user pastes a key in chat anyway: write it into `.env` without echoing the value, classify by prefix, then tell them to rotate because the chat is leaked.

A Next.js watch match on `error` from zsh/gitstatus is not an app crash — confirm `localhost` still 200 before treating it as failure. Restart `next dev` after `.env` edits. `npm i @openuidev/observability-cloud` in this project is already done at 0.0.3 — verify with `npm ls` before installing again.

## OUI-1

OUI-1 is an open-weight DiffusionGemma finetune that writes OpenUI Lang (26B / 4B active, Apache 2.0). Source of truth is the blog `https://www.openui.com/blog/oui-1` and weights `https://huggingface.co/thesysdev/OUI-1`, not llms.txt. It is not a Gateway model ID and not a BYOK provider. Gateway BYOK is only OpenAI, Anthropic, and Google. A private HF Space URL is not a documented Gateway backend. Self-host: your route calls OUI-1 (GPU must be up), the OpenUI renderer consumes the stream; Autofix may repair after generation without replacing the GPU.

## AppLess

AppLess is an Expo (SDK 54) phone-shell experiment: ask → streamed OpenUI Lang → native Cupertino/Material screens. Actions are simulated. It is not a VS Code toggle and not an App Store install.

The model does not run in the app. Serve OUI-1 with vLLM ≥0.24 (`bash scripts/serve-oui.sh`); FP8 weights ~25.8 GiB plus cache — documented on CUDA GPU, not this Mac. Point `EXPO_PUBLIC_MODEL_BASE_URL` at that host’s OpenAI `/v1` URL (or an HF Space/endpoint that exposes the same). On a real phone, `localhost` is the phone.

A Hugging Face user token is for downloading weights on the GPU host (`huggingface-cli login`), not for pasting into VS Code. App auth is a vLLM `--api-key` plus `EXPO_PUBLIC_MODEL_AUTH_REQUIRED=1` (prompt) or `EXPO_PUBLIC_MODEL_API_KEY` (dev only; bundled). Do not put HF tokens in chat.

If the user sets up the app first and deploys the model later: clone anyway.

```bash
git clone --depth 1 https://github.com/thesysdev/appless.git /Users/activi/Projects/appless
cd /Users/activi/Projects/appless && npm install
```

`.env.local`: `EXPO_PUBLIC_APPLESS_MODEL=OUI-1`, `EXPO_PUBLIC_POSTHOG_DISABLED=1`, `EXPO_PUBLIC_MODEL_AUTH_REQUIRED=1`. Leave `EXPO_PUBLIC_MODEL_BASE_URL` commented until a URL exists. HF Inference Endpoint URLs need a trailing `/v1`. Read the CLI token from `~/.cache/huggingface/token` into `EXPO_PUBLIC_MODEL_API_KEY` without printing it — that value is bundled; local test only. Probe `GET {base}/v1/models` with Bearer before calling the app ready: HTTP 503 means the endpoint is not running (paused, scaledToZero, or still starting). Then `npm start`.
