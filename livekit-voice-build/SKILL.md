---
name: livekit-voice-build
description: "Use when building LiveKit voice agents from briefs."
version: 1.0.0
author: Agent
license: MIT
metadata:
  hermes:
    tags: [livekit, voice, telesales, fish-audio, bosnian, eu]
    related_skills:
      - livekit-agents
      - livekit-simulations
      - balkan-voice-agent-stack
      - tts-pronunciation-correction
      - bosnian-voice-prompts
---

# LiveKit voice build (Activi)

## When

- User says **„projekt LiveKit“**
- New LiveKit agent, or a brief from Dograh/n8n workflow JSON
- Fish Audio TTS tags, phonetics, or EU LiveKit Cloud stack

## Project home

Phrase **„projekt LiveKit“** = only `/Users/activi/Code/Projects/LiveKit`  
Hermes project slug `livekit`. Do not use `livekit-telesales`, `Documents/ChatGPT/LiveKit`, or `hermes-livekit-infra` unless asked.

Session start: `cd` there. Read `AGENTS.md` then `docs/PROJECT.md` if present.

Optional CLI: `hermes --in /Users/activi/Code/Projects/LiveKit`

## Official LiveKit extras (do not reinvent)

| Piece | What it is | Not |
|-------|------------|-----|
| Skill `livekit-agents` | How to think (handoffs, tests, no API-from-memory) | API facts |
| Skill `livekit-simulations` | Local scenario authoring | Load tests |
| MCP `livekit-docs` | `https://docs.livekit.io/mcp` | Second docs MCP |
| CLI `lk docs` | Same docs as the MCP | A second server |

One official Docs MCP. CLI and MCP are the same capability.

Do **not** drop `llms.txt` / `llms-full.txt` into the repo. Index ≈ MCP `get_docs_overview` (~94 KB). Full dump ~3.8 MB / ~960k tokens, goes stale. Browse overview/get-page, then search, then code-search.

## Extract from Dograh exports — do not copy the graph

User rule (verified this class of task): node count is **not** a requirement. Pull **business data** only.

Keep: persona, language lock, product, payment, PAS as *rhetoric*, order-safety, DNC, lexicon, integrations.

Drop: 17-node layout, Dograh QA JSON as runtime, fake tools that are only edges.

LiveKit pattern: few agents + tasks (Opener → Sales → Order TaskGroup → Wrap). Split only on instruction bloat, conflicting tools, or multi-turn data collection. Cite live `lk docs` / MCP for APIs.

## Default stack for BiH phone sales (re-verify via MCP)

| Layer | Default | Why |
|-------|---------|-----|
| STT | Deepgram `nova-3`, `language=bs`, keyterms | `bs` is on the LiveKit Nova-3 list. Not `multi`. EU host `api.eu.deepgram.com` when residency/latency. |
| TTS | Fish **plugin** `s2.1-pro` + custom `voice_id` | Inference s2.1-pro language list has **no `bs`**. Custom clones **not** on Inference. `normalize=false` (docs: EN/ZH only). |
| LLM | GPT-4.1 on **Azure/Foundry EU** | BKS + tools. Gemma 4 31B = latency A/B only. No nano on the call path. |
| Cloud | Agents `eu-central` (Frankfurt) | See `references/eu-cloud-stack.md` |

Cascaded STT→LLM→TTS. Not speech-to-speech for audited sales.

## Fish tags

Official Studio list only. Unknown `[brackets]` may be **spoken aloud**.

Allow: `[excited] [joyful] [sad] [angry] [nervous] [sarcastic] [tired] [soft] [loud] [whispering] [shouting]` + pause/breath + `[emphasis]` before a word + sparse reactions.

**Never** emit Dograh leftovers: `[happy] [calm] [empathetic] [serious]` or `[happy, calm]`. Map: happy→joyful, calm/empathetic/serious→`[soft]` or no tag.

Density ~1 tagged block per 3 sentences. Full table: `references/fish-s21-pro-tags.md`. Project copies: `docs/voice/FISH_TAGS.md`.

Phonetics: Fish has no SSML lexicon. Static replace before TTS (`đ→dž`, syllable hyphens, keep čćšž). See `tts-pronunciation-correction` + `docs/voice/phonetic-lexicon.json`.

## Sales pacing (data, not Dograh nodes)

Permission → discover water habit → one pain beat → 1–2 benefit sentences → order only after yes. COD/`pouzeće` never in the first 30s. Price only if the caller asks (unless the brief says otherwise). One question per turn. No re-intro.

## Pitfalls

- Treating `lk docs` and Docs MCP as two installs
- Dumping llms-full into context or the repo
- Cloning a Dograh graph 1:1 into LiveKit
- Fish via LiveKit Inference for a BiH clone
- Inventing Fish tags; `[calm]` is not official
- Global `*.livekit.cloud` when the user asked for EU latency
- Inventing price, ETA, stock, SIP carrier, or Inbound IDs
- SOUL/AGENTS on a live profile without Freigabe (project `AGENTS.md` in a new folder is OK)

## Verification

- `hermes mcp test livekit-docs`
- `lk docs get-page /agents/models/tts/fishaudio` and `/deploy/admin/regions/endpoints`
- `hermes project show livekit`
- After a brief: `docs/PROJECT.md` exists and names stack + open questions

## Support

- `references/eu-cloud-stack.md`
- `references/fish-s21-pro-tags.md`
- `references/dograh-export-to-brief.md`
