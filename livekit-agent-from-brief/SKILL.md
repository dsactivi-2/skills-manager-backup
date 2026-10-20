---
name: livekit-agent-from-brief
description: "Use when a new LiveKit BiH agent is requested."
version: 1.0.0
author: Activi
license: MIT
metadata:
  hermes:
    tags: [livekit, bosnian, soniox, wizard, template]
    related_skills:
      - bosnian-livekit-template-v1
      - livekit-agents
      - livekit-voice-build
      - bosnian-voice-prompts
      - soniox-voice-platform
---

# LiveKit Agent from Brief

## When to Use

- „neuer Agent“, „baue einen Agenten“, Skill in frischer Session aktiviert
- Nicht: nur Amina-Prompt tunen, Fish Ela, Cloud-Deploy ohne Freigabe

Wenn dieser Skill geladen ist: **zuerst fragen, dann bauen.**  
Kein Code, kein Clone, kein Commit bevor die Antworten da sind.

Repo: `/Users/activi/Code/Projects/LiveKit`  
Vorlage: `src/amina/template_v1/`  
Technik: immer `from amina.agent_soniox import build_session`

## Schritt 0 — Checkliste (livekit-agents)

1. Diesen Skill komplett lesen
2. MCP `livekit-docs` für APIs (nie aus dem Gedächtnis)
3. Tests mitliefern
4. Bestehende Agenten **nicht** überschreiben
5. Dockerfile / Cloud-Amina **nicht** anfassen ohne Freigabe

## Schritt 1 — IMMER zuerst `clarify`

Ein Formular, **nicht** eine Chat-Liste. `questions` Array.

| id | Frage | Art |
|---|---|---|
| typ | Was für ein Agent? | choices: Verkauf Telefon BiH / Support / Familien-Demo / Anderes |
| persona | Wie heißt die sprechende Person? | open |
| display | Anzeigename (Ordner/Desktop) | open |
| brief | Was soll der Agent tun? | open |
| voice | Welche Stimme? | choices: Nina (Frau) zuerst / Daniel (Mann) |

Slug und `agent_name` ableiten. Existiert `src/<slug>/` schon: **stopp**.

## Schritt 2 — Bauen (nach Antworten)

1. Clone mit `scripts/new-from-template-v1.py`
2. Nur `prompts.py`, `soul.md`, `project.toml` `[editable]`
3. `build_session(voice=..., extra_keyterms=...)` — Stack nicht kopieren
4. Hatch-`packages` um `src/SLUG` erweitern
5. Test + Start-Skript + Desktop-`.command`
6. `./scripts/install-desktop-commands.sh`
7. `uv run python scripts/update-agent-registry.py`
8. pytest + ruff

Cloud nur nach extra OK.

Details: `references/locked-stack.md`, `references/soniox-tags.md`.
