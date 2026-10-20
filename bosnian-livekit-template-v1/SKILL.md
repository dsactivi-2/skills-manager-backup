---
name: bosnian-livekit-template-v1
description: "Use when cloning Amina Soniox v2 as Template V1."
version: 1.0.0
author: Activi
license: MIT
metadata:
  hermes:
    tags: [livekit, bosnian, soniox, template, telesales]
    related_skills:
      - livekit-voice-build
      - livekit-agents
      - bosnian-voice-prompts
---

# Bosnian LiveKit Template V1

Give this skill to any agent that must build a **new** BiH phone agent.

## When to Use

- „neuer bosnischer Agent“, „Template V1“, Prompt/Firma/Produkt tauschen
- Nicht: Fish-Ela ändern, Gemma-A/B, Dograh-Graph 1:1

## Source of truth

Repo: `/Users/activi/Code/Projects/LiveKit`  
Live original: `amina-soniox-v2` (`src/amina/agent_soniox_v2.py`)  
Template: `src/amina/template_v1/`

LiveKit Cloud **kann Config nicht sperren**. Sperre = Dateien + diese Regeln.

## Locked (NEVER edit)

| Schicht | Wert |
|---|---|
| STT | Deepgram `nova-3`, `language=bs`, EU `api.eu.deepgram.com` |
| LLM | LiveKit Inference `openai/gpt-4.1` `provider=azure` |
| TTS | Soniox `Nina` `tts-rt-v2` `speed=0.9` `language=bs` EU-WS |
| Tags | nur `[warm] [calm] [curious] [sincerely] [reassuringly] [softly] [pause]` |
| Bindestrich | verboten (`Ami-na` = Stottern) |
| Fish | nicht anfassen (`agent.py` Ela) |
| Deploy | `eu-central`, `python -m <pkg>.agent start` |
| Import | immer `from amina.agent_soniox import build_session` |

Datei mit Stack: `src/amina/agent_soniox.py` — **nicht kopieren, nur importieren**.

## Editable (only these)

| Datei | Inhalt |
|---|---|
| `project.toml` `[editable]` | `agent_name`, Display, Persona, Firma, Produkt |
| `prompts.py` | System + Opener (bosanski). Tag-Block **nicht** streichen |
| `soul.md` | Ton, DNC, Verkaufsregeln in Prosa |

Nicht: Dockerfile-CMD außer Modulname, Secrets, 300/310, Gemma.

## Clone

```bash
cd /Users/activi/Code/Projects/LiveKit
uv run python scripts/new-from-template-v1.py \
  --slug firma_x \
  --agent-name firma-x \
  --persona "Lejla" \
  --company "Firma X" \
  --product "Produkt Y"
```

Dann **nur** `src/firma_x/prompts.py` + `soul.md` + `project.toml` umschreiben.

Start lokal:

```bash
uv run python -m firma_x.agent console
```

Deploy (Freigabe):

```bash
# Dockerfile CMD auf python -m firma_x.agent start
lk agent create --project aai --region eu-central --config livekit.eu-central.toml
# oder neuer Agent: andere --config, nicht den Amina-Worker überschreiben ohne Freigabe
```

## Prompt-Regeln (kurz)

- ijekavica, latinica schreiben; hören darf ćirilica
- 1 Frage / Zug, kein Preis ohne Frage
- Opener: erstes Token `[warm]`, kein Produkt
- HR-Wörter verboten (vrč, tjedan, tisuća, …)
- Tools bleiben die von `AminaAgent` (Permission, water, no, DNC)

## Do not

- `google/gemma-4-31b-it` als Default (nur später A/B)
- LiveKit Agent Builder statt dieses Templates (kein Lock)
- Zweiten Soniox-Stack in den Clone pasten
- 300/310 als LiveKit-Auth
- Secrets in den Chat

## Verify

```bash
uv run pytest tests/test_template_v1.py tests/test_prompts_soniox.py -q
rg -n "build_session" src/firma_x/agent.py
```
