---
name: soniox-voice-platform
description: "Use when wiring Soniox STT/TTS, clone, or EU endpoints."
version: 1.0.0
author: Agent
license: MIT
---

# Soniox Voice Platform

Class-level notes for Soniox STT+TTS+translation on production voice agents. Verified 2026-07-30 (GitHub org + docs).

## When to use
- Compare Soniox vs Deepgram/Azure/OpenAI for BS/BKS or multilingual agents
- Need **EU data residency** speech with same models as US
- Brand voice via **cloning** for BS telesales
- LiveKit Agents Soniox plugin or Soniox docs MCP

## Product surface
- STT realtime + async, TTS REST + realtime WS, speech translation
- 60+ languages: **Bosnian `bs`**, Croatian `hr`, Serbian `sr`
- `bs`/`sr` TTS: **Latin only** (not Cyrillic)
- Privacy claim: audio in-memory, not used for training (confirm DPA for prod)

## EU hosting
Region **per project** in Console. Full API in-region.

| Region | Domains |
|--------|---------|
| US | `api.soniox.com`, `stt-rt.soniox.com`, `tts-rt.soniox.com` |
| **EU** | **`api.eu.soniox.com`, `stt-rt.eu.soniox.com`, `tts-rt.eu.soniox.com`** |
| JP | `api.jp.soniox.com`, … |

EU enablement may need support@soniox.com. Audio+transcripts stay in region; system/billing metadata may not. GDPR / ISO27001 / SOC2 / HIPAA + self-serve DPA.

### EU is request-gated, NOT a self-serve dropdown (verified 2026-08)
The EU option only appears in the project **Region** dropdown **after** Soniox
enables the EU region for your org. Before that you can *name* a project "eu"
but it still shows `Region: United States` and its keys only work against
`api.soniox.com` (US) — hitting `*.eu.soniox.com` gives the 401 above. This is
the real reason a "test eu" project 401s on EU endpoints. Region is fixed **at
project creation** and is NOT changeable later — a US project never becomes EU;
you must create a fresh project once EU is enabled.

**No hard obligations to get EU:** no minimum spend, no contract, no
certification on your side; same model / API / **same prices**. DPA is optional
and self-serve (Console → Organisation → Security & compliance, pre-signed by
Soniox, one-click countersign). EU AI Act: STT/TTS are general-purpose
components; most voice-agent cases are "limited risk" (Art. 50 transparency —
tell the callee it's AI), not high-risk. Enablement email to support@soniox.com
needs only: org name + login email (+ login method). Legal entity / country are
optional niceties, not required for the flip.

### No org/account metadata via REST (org ID not API-readable)
Soniox REST exposes only `files`, `transcriptions`, `models`, temporary keys.
There is **no** `/v1/organizations`, `/v1/organization`, `/v1/me`,
`/v1/projects`, or `/v1/api-keys` — all return **404**. You cannot read the
org ID from an API key. Get it from the **Console URL** when logged in:
`console.soniox.com/org/<ORG_ID>/...`. The support email works fine without the
org ID (org name + login email identify the account).

### API keys are region-scoped (401 diagnostic)
A key belongs to **exactly one region** (the Console org/workspace region it was created in). A **global/US key returns HTTP 401 `unauthenticated` "Incorrect API key provided"** against `*.eu.soniox.com` — even though DNS/TLS/connect all succeed. This looks like a bad key but is a region mismatch.

Diagnose by running the **same key** against both regions:
```bash
# global — 200 if key is valid at all
curl -s -H "Authorization: Bearer $SONIOX_API_KEY" https://api.soniox.com/v1/models -o /dev/null -w '%{http_code}\n'
# EU — 401 with the same key ⇒ key is global, not EU
curl -s -H "Authorization: Bearer $SONIOX_API_KEY" https://api.eu.soniox.com/v1/models -o /dev/null -w '%{http_code}\n'
```
`200` global + `401` EU ⇒ mint a **new EU key** (switch org/workspace to EU region in Console). Do NOT conclude the key is invalid or the EU endpoint is down. Note: hitting the bare WS hosts (`stt-rt.*`, `tts-rt.*`) with a plain GET returns `404` — that is normal (they want a WS upgrade on `/transcribe-websocket` / `/tts-websocket`), not an auth or reachability failure.

## TTS voices (BS telesales)
**Any built-in voice × any language** via `language` — no separate native bs-BA pack in repos/docs.

```text
language=bs  voice=Maya|Adrian|<clone-uuid>  model=tts-rt-v1
```

### Built-in shortlist (persona, not locale)
- Female warm/clear: **Maya**, Mina
- Male authority: **Adrian**, Daniel
- Friendly discovery: Jack
- Soft support: Grace
- Skip for BiH brand if accent leak matters: UK / ES / AU / IN packs
- Compare demos often hardcode **Nina** — not automatic BS sales default

### Voice cloning (native BS path)
- Short clear sample → Console or `client.voices.create(ref, name=…)`
- Use **UUID** as `voice` (non-UUID = built-in name)
- Works across 60+ languages; project-scoped; recompute on new TTS models
- SDK: `soniox-python` `client.voices`, `soniox-js`
- For BiH brand: clone **native BS speaker**, don’t rely on Maya alone

## Agent integrations
- LiveKit: `pip install "livekit-agents[soniox]"` + `SONIOX_API_KEY` (+ EU base if needed)
- Useful org repos: `soniox-python`, `soniox-js`, `soniox_examples` (voice-bot/Twilio), `soniox-compare`, `soniox-twilio-realtime-transcription`, `soniox-pipecat-voicebot` (demo; env may use other TTS)
- No voice WAV catalogs in GitHub — API only

## Docs MCP
```bash
hermes mcp add soniox-docs --url "https://soniox.com/docs/api/mcp/mcp" <<'EOF'
n
Y
EOF
```
See `hermes-mcp-http` → `references/soniox-docs-mcp.md`. Prefer search → section/page; avoid `soniox_full_docs`.

## Fit vs strict-EU Dograh BiH baseline
Default often stays Deepgram EU STT + Azure Vesna/Goran. Soniox A/B when:
- One vendor STT+TTS+translation
- Clone quality beats Vesna monotony under EU residency
- LiveKit-native stack preferred

Always live-A/B real BS sales audio before replace.

## Pitfalls
- No GitHub “bs voice pack”
- Multilingual built-in ≠ verified native BiH accent without listen
- EU project key must hit `*.eu.soniox.com`
- No Cyrillic for `bs`/`sr` TTS
- `hermes mcp test` green ≠ tools in current session without `/reload-mcp`
- Don’t dump full_docs into context

## References
- `references/eu-endpoints-and-voices.md`
- Related: `hermes-mcp-http`; user-owned `balkan-voice-agent-stack` / `bosnian-voice-agent-stack` (recommend `hermes curator adopt` if Soniox rows should land there)
