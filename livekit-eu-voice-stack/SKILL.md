---
name: livekit-eu-voice-stack
description: "Use when LiveKit EU voice. Pin, Fish TTS, Deepgram EU."
version: 1.0.0
license: MIT
metadata:
  hermes:
    tags: [livekit, europe, tts, fish-audio, deepgram, bosnia, residency]
---

# LiveKit EU voice stack (Bosnien / Latenz)

## When
- LiveKit Agent für Telefonie in **Bosnien** oder „muss in Europa bleiben“
- Fish Audio Region, Tags, Clone-ID
- Deepgram Nova-3 Host
- `llms.txt` vs MCP/`lk docs`
- Dograh-Workflows als **Datenquelle**, nicht als Graph-Vorlage

Trigger-Satz des Users: **„projekt LiveKit“** → nur `/Users/activi/Code/Projects/LiveKit`.

## Docs access (do not dump)
- Offiziell: **ein** Docs-MCP `https://docs.livekit.io/mcp` **oder** `lk docs` (gleicher Inhalt).
- Skills: `livekit-agents` (bauen/Tests), `livekit-simulations` (Szenarien).
- **Kein** `llms-full.txt` ins Repo. `llms.txt` höchstens Offline-Index, nie SoT.
- Reihenfolge: overview / get-page → search → code-search.

## LiveKit Cloud: Auto-Route ≠ Pin
Alle Pläne routen zum **nächsten** Cluster. Pin ist **kein** Voraussetzung für EU.

| Hebel | Plan | Wirkung |
|-------|------|---------|
| Agent `lk agent create --region eu-central` | alle Cloud-Agents | Compute Frankfurt |
| SIP `*.eu.sip.livekit.cloud` | alle | Telefonie FR/DE |
| `destination_country=de` | alle | Outbound aus Frankfurt |
| Protocol region-pin `eu` | Scale+, Support | hartes EU-Schloss, kein Übersee-Failover |

Für BiH-Latenz: **nur** `eu-central` + Deepgram EU + LLM EU + SIP `eu`. Pin nur wenn nie US/Asien erlaubt.

## STT
Deepgram Nova-3, `language=bs` (nicht `multi`).  
**Pflicht:** `DEEPGRAM_BASE_URL=https://api.eu.deepgram.com`.  
Keyterms: Aquaphor, Smile, Firmira, Amina, bokal, pouzeće, flaširana, slavina.

## LLM
GPT-4.1 auf **Azure/Foundry Data Zone EU** (France Central vs Sweden Central messen).  
Kein US-Inference/Grok im Hot-Path. Mini/Nano nicht ohne bs-A/B.

## TTS: Fish EU-Pin
**Standard-API nicht auf Europa begrenzbar.** TTS-OpenAPI: nur `api.fish.audio`, kein Region-Header. FAQ: Speicher USA, Inferenz US+Tokio. EU = Enterprise-Self-Host (~10k+10k/Monat).

Aktueller Clone: `FISH_AUDIO_DEFAULT_VOICE=d9b1befa09a34947b8c334268767abb6` (Fish **Ela**, `bs`). LiveKit Inference hat kein bs und keine Custom-Clones → **Plugin** + Key.

EU-Alternativen und Preise: `references/tts-eu-residency.md`.

## Fish-Tags (SoT = Entwickler-Doku, nicht Studio-MCP)
Studio `studio_help` / tags ist eine **enge** Liste und behauptet, Unbekanntes werde vorgelesen.  
**s2.1-pro Doku** (`docs.fish.audio` Emotions): eckige Klammern, **64+** Tags inkl. `[happy]` `[calm]` `[empathetic]` `[serious]` `[confident]`, plus Freitext. S1 = runde `(happy)` — nicht mischen. Pausen in der Doku: `[break]` / `[long-break]`.

Detail: `references/fish-s21-tags.md`.

Phonetik: Fish hat kein Lexikon. Statische Replace-Liste vor TTS (`đ→dž`, Silben). Nicht čćšž zu ch/sh. Siehe Skill `tts-pronunciation-correction` (user-owned).

## Architektur (nicht Dograh-Graph kopieren)
PAS = Verkaufsrhetorik, nicht 17 Knoten. LiveKit: Opener → Sales → Order-Tasks → Wrap. Post-Call n8n außerhalb der Stimme. Jede Implementierung braucht Tests.

## Pitfalls
- `llms-full.txt` oder lokale Doku-Dumps als SoT
- Fish-Tags nur aus Studio-MCP ableiten und `[happy]` verbieten
- Behaupten, Fish-Cloud habe EU-Auto-Routing für BiH
- LiveKit-Pin als einzige EU-Option verkaufen
- Deepgram Default-US-Host
- Cartesia für bs (kein Bosnisch auf der Sprachenliste)
- Node-Anzahl aus Dograh-Export als LiveKit-Pflicht

## Related
- `livekit-agents`, `livekit-simulations` (Hub — nicht hier patchen)
- `balkan-voice-agent-stack`, `bosnian-voice-agent-stack` (user-owned; bei Drift: `hermes curator adopt`)
- Projekt: `/Users/activi/Code/Projects/LiveKit/docs/PROJECT.md`
