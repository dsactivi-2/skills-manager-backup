---
name: barbarez-three-lanes
description: "Use when Barbarez works on voiceeu Self-Host: Spur A infra/ARI, B workflow graph, C prompts. MCP dograh-voiceeu, 3-lane orchestration."
version: 1.0.0
author: activi
license: MIT
metadata:
  hermes:
    tags: [barbarez, dograh, voiceeu, three-lanes, mcp, self-host]
    related_skills:
      - dograh-dual-instance
      - dograh-mcp-workflow-ops
      - dograh-setup
      - dograh-selfhost-guides
      - german-voice-prompts
      - dograh-voice-workflow-optimizer-v2
---

# Barbarez — 3-Wege-Plan (voiceeu)

## Default-Instanz + Dual-Welten

| | Dograh Self-Host (Default) | Dograh Cloud |
|--|--|--|
| URL | **https://voiceeu.activi.io** | app/api.dograh.com |
| MCP | **`dograh-voiceeu`** → `mcp__dograh_voiceeu__*` | **`dograh`** → `mcp__dograh__*` |
| Auth | `X-API-Key` / `MCP_DOGRAH_VOICEEU_API_KEY` | Bearer / `MCP_DOGRAH_API_KEY` |
| Langfuse-MCP | **`langfuse-voiceeu`** | **`langfuse-dograh-cloud`** |

**Zwei Dograh + zwei Langfuse-Routen.** Skill **`dograh-dual-instance`** = wann welche Fernbedienung. Nie mischen.

| User-Kontext | Dograh-MCP | Langfuse-MCP |
|--------------|------------|--------------|
| voiceeu / Self-Host / ARI | dograh-voiceeu | langfuse-voiceeu |
| Cloud / app.dograh.com | dograh | langfuse-dograh-cloud |
| unklar | nachfragen (Default = voiceeu) | wie Dograh-Wahl |
**Profil barbares (aktuell):** Cloud-Dograh + langfuse-dograh-cloud sind **disabled**. Nur `dograh-voiceeu` + `langfuse-voiceeu` (+ docs).



## Focus (user 2026-07-28): BS-only on voiceeu

| Do | Don't |
|----|-------|
| Work BS WFs on voiceeu (#9/#10 marge primary candidates; confirm live) | DE Cloud #8783 / DE handoff as SoT |
| Opening/greeting P0 → skill `dograh-voice-opening-greeting` + `bosnian-voice-prompts` | Touch DE template #7 as Amina prod |
| Langfuse DograhEU traces for BS calls | Mix marge BS with DE todos |

P0 skills: dograh-telesales-pacing + dograh-human-conversation + dograh-voice-opening-greeting.
Opening edit loop: guide turn_taking + call_flow_design → startCall greeting+prompt+interrupt/delay → freigabe → draft.

## Die 3 Spuren

| Spur | Name | Typische Symptome | Erste Aktion |
|------|------|-------------------|--------------|
| **A** | Self-Host / Infra | UI down, Health fail, **klingelt kein Ton**, Docker | doctor / ARI-runbook / Logs — **kein** Prompt-Rewrite |
| **B** | Workflow-Bau | Nodes, Edges, Tools, Graph | MCP get/save + node_types |
| **C** | Prompt-Write | Texte, DE/BS, Closing, Dead-Air im Dialog | `get_voice_prompting_guide` + DE-Skills |

Bei Unklarheit: erst belegen (Run/Log/Sim), dann Spur wählen. Eine Spur pro Runde priorisieren.

## Skills laden (scharf)

### Spur A
- `dograh-setup` (+ `scripts/doctor.sh` auf Dograh-Server)
- `dograh-selfhost-guides` (asterisk-ari, docker-deploy, env)
- `voice-ai-infrastructure` → `references/dograh-ari-ring-no-audio.md`
- `dograh-telephony` nur Carrier-UI, nicht ARI-Media
- `live-stack-verification` vor „Prod ready“

### Spur B
- `dograh-mcp-workflow-ops`
- `dograh` / `dograh-official`
- `dograh-stepwise-tool-wiring` (wenn Tools verdrahten)
- `dograh-telesales-base-template-builder` (neue Telesales-Basis)

### Spur C
- MCP `get_voice_prompting_guide` (plan → create → review) **immer**
- `german-voice-prompts`, `dograh-workflow-localization`
- `dograh-voice-workflow-optimizer-v2`, `voice-low-latency-patterns`
- `closing`, `objection-handling`, `marketing-psychology`
- Langfuse Skills: `langfuse`, `langfuse-official`, `langfuse-voice-call-quality-optimization`, `voice-call-observability-audit`
- Langfuse-MCP der **gleichen** Dograh-Welt (`langfuse-voiceeu` vs `langfuse-dograh-cloud`)
- Sim/virtuelle Kunden: `simulate_dialogues*.py` + Dialog-JSONL (ohne Langfuse möglich)

**Improve-Loop:** Sim oder Live-Call → Langfuse (richtige Welt) → eine Rubrik → Dograh-MCP derselben Welt Draft.

Leeres skill_view: absolute Pfade unter `~/.hermes/skills/` oder `~/.hermes/profiles/barbares/skills/`.

## MCP-Orchestrierung (Spur B/C)

```
Session-Start
  handoff SESSION_RESUME → HANDOFF → NEXT_ACTIONS
  list_workflows (voiceeu) live

PLAN     get_voice_prompting_guide(stage=plan)
CREATE   get_voice_prompting_guide(stage=create[, node_type])
         topic=common_guidelines für globalNode
         list_node_types / get_node_type
         list_tools | create_tool
         get_workflow_code → edit → save_workflow (Draft)
         oder create_workflow (neu)
REVIEW   get_voice_prompting_guide(stage=review)
         Sim / Testcall
PUBLISH  nur User in UI
```

Truncation großer Codes: JSON-RPC auf Platte (Projekt `de/workflow/*.py` Muster).

## Spur A — ARI Stille (Kurz)

1. Browser-Audio OK? → Models OK, nicht BYOK zuerst
2. Nie `apt install asterisk` wenn PBX schon klingelt
3. GonoPBX: echten Asterisk finden (`docker ps`) → `chan_websocket` / `res_websocket_client`
4. `websocket_client.conf` → voiceeu `/api/v1/telephony/ws/ari`, **ulaw**
5. DograhEUV2: API-Logs parallel zum Testcall
6. Doku: selfhost-guides `asterisk-ari.mdx` + ARI-runbook

## AGENTS.md / SOUL

| Datei | Rolle |
|-------|--------|
| Profil `SOUL.md` | Identität Barbarez, Behavior, Output-Contract |
| Projekt `AGENTS.md` | Ops, Spuren DE/BS, Change-Loop, Freigabe |
| Diese Skill | 3-Wege + MCP voiceeu Schnellreferenz |

Upstream dograh-hq `AGENTS.md` (8 Dateien) = nur Quellcode-Beiträge, nicht Runtime.

## Anti-Patterns

- Cloud-MCP auf voiceeu-Workflows
- Spur A mit Prompt-„Fix“ abwürgen
- Mehrere inhaltliche Fixes pro Runde
- IDs aus SOUL/Memory
- Publish ohne User
- Secrets im Chat

## Guides (offline)

`~/.hermes/skills/dograh/dograh-selfhost-guides/references/`:
asterisk-ari, docker-deploy, environment-variables, inference-providers, mcp, deployment-introduction
