---
name: project-akte-handoff
description: "Use when picking a project Akte/task store."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [agents, memory, tasks, MCP, handoff, beads, spec-kitty]
    related_skills: [repo-by-usecase, file-driven-multi-session-supervision, workspace-dispatch]
---

# Project Akte + session handoff

Choose a **project-scoped store** so a new/empty agent session can continue work. This is not person-memory (name, prefs) and not a code index.

Score **hart/weich**. Empty chat is never filled by MCP connect.

Discovery of new candidates: skill `repo-by-usecase` (user-owned — `hermes curator adopt repo-by-usecase` before curator patches). That skill’s `gh repo view` example still lists `stargazersCount`; **view JSON is `stargazerCount`**. Search JSON stays plural. Use `pushedAt` as “Zuletzt”, not search `updatedAt`.

Known snapshot: `references/known-systems.md` (re-verify stars/push before recommending).

## Mindestziel (all five)

1. Projektakte außerhalb des Chats (Tasks, Stand, Docs, Logs)
2. Checkliste anlegen und abhaken
3. Docs oder Progress fortschreiben
4. Agent-Tür (MCP **oder** CLI/AGENTS.md — gleichwertig)
5. Weiterarbeiten nach Session-/Agent-Wechsel, sobald der Stand geladen ist

~70–80 % noch aufnehmen und die Lücke sagen. Nur Personen-Memory, nur Code-Index, nur Spec-Prozess ohne laufende Akte: benachbart oder weglassen.

## Hart vs weich (immer benennen)

| | Bedeutung |
|---|---|
| **Hart** | Nach Tool-Call/CLI gilt der Store (`bd close`, `set_task_status`, `log_progress`, spec-kitty accept) |
| **Weich** | Datei/MCP existiert, aber die leere Session muss selbst `next` / `ready` / `prime` / Datei lesen |

**MCP verbinden füllt den Chat nie.** Nur Hooks (z. B. claude-mem) injecten hart — und das ist Session-Kompressat, keine Task-Akte.

## Default stack (Activi / Hermes)

1. **Primär: [gastownhall/beads](https://github.com/gastownhall/beads)** — laufende Akte, `bd ready/claim/close` hart, `bd init` schreibt AGENTS.md, `bd prime` = Startknopf. CLI bevorzugen (weniger Tokens als `beads-mcp`). Nicht `user:steveyegge` annehmen.
2. **Ebenen/Review: [Priivacy-ai/spec-kitty](https://github.com/Priivacy-ai/spec-kitty)** — spec → plan → tasks → next → review → accept. Nächstes „legal next buttons“.
3. **Optional Inject:** `thedotmack/claude-mem` (hart, keine Tasks) **oder** `Daliagents-com/agentsge-1` (AGENTS.md-Zeiger, weich, keine Tasks). Nicht beides zuerst.

Task-master nur wenn PRD→Checkliste ohne Git-Lanes nötig ist — `pushedAt` zuletzt 2026-04 prüfen.

## Was niemand öffentlich erfüllt

- Ein Use-Case = Voice + n8n + CRM als eine Karte
- Connect = Chat ist voll
- Ebenen-UI, die nach der Wahl den Rest **erzwingt** (spec-kitty Lanes / beads Deps kommen am nächsten)

Mixed-Stack weiter über `workspace-dispatch` / `file-driven-multi-session-supervision` modellieren, nicht ein Memory-MCP dafür verbiegen.

## Bewertungstabelle (Ausgabe)

DE, Tabelle zuerst. Spalten: Rang, Repo, Stars, Zuletzt (`pushedAt`), Fit (high/med/low), Tasks, Docs, Akte/Stand, Agent-Tür, Session-Wechsel, Mehr, Lücke, URL.

## Search pitfalls (this class)

- Quoted `gh search repos "beads agent issue tracker"` → oft `[]`. Token ohne Anführungszeichen oder `gh repo view`.
- `topic:mcp-server memory` zieht Celebrity-Repos (n8n, gemini-cli). Keine Treffer.
- Memory-Bank-MCP-Klone (Templates only) sind kein Store.

## Verify

```bash
gh repo view gastownhall/beads --json pushedAt,stargazerCount,description
bd --help 2>/dev/null || true
```
