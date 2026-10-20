---
name: workflow-diagram-maps
description: "Use when drawing numbered workflow maps in Eraser."
version: 1.0.0
author: activi
license: MIT
metadata:
  hermes:
    tags: [eraser, workflow, versioning, n8n, livekit]
    related_skills: [eraser, eraser-diagrams]
---

# Workflow-Diagramm-Karten (Eraser)

Ops-Workflows als Arbeitskarte: Schritte, Drähte, Status, Lücken. Nicht hübsche Architektur.

Immer mit Skill `eraser` + `mcp__eraser__*`. Nie curl `/api/render`.

## When to Use

- User will einen Prozess zeichnen, um Überblick / erledigt-offen / Blocker zu sehen
- LiveKit + n8n + Leads + Ja/Nein/Termin
- Tausch-Sprache über Knoten-IDs

## Pflicht-Reihenfolge

1. Verstanden spiegeln. Welcher Workflow? Name festlegen (unterscheidbar).
2. Zeichenliste in Stichpunkten. User bestätigt oder ändert. **Nicht vorher zeichnen.**
3. Lokalen Projektordner anlegen: `diagrams/`, `phases/`, `versions/`, `VERSIONING.md`.
4. Knoten fortlaufend: `N01`, `N02`, … Unterquellen `N01.1`, `N01.2`, `N01.3`, danach Kreis `+` (nächste = N01.4).
5. Eraser: leere Datei `create_file`, dann `manually_create_diagram` mit DSL (IDs müssen exakt bleiben). NL-`create_diagram` frisst IDs.
6. Jede Phase als Tabelle: ID | Bedeutung | Was gemacht wird. Datei unter `phases/`.
7. **Vor jeder Änderung Version ziehen** — siehe unten.

## Versionierung (vor jeder Änderung)

1. Snapshot nach `versions/vNNN/` (DSL, PNG, Phasen-MD, NOTE).
2. Eraser-Archiv: `create_file` mit `sourceFileId` der Arbeitsdatei.
3. Zeile in `versions/CHANGELOG.md`.
4. Erst dann Arbeitsdatei ändern (`manually_update_diagram` bei ID-Änderungen).
5. Arbeitskopie bleibt `diagrams/*` = aktuelle Version.

Ohne Snapshot keine Mutation.

## Layout

- Quer: `direction right`, `typeface clean`, `styleMode plain`, `colorMode outline`.
- Kurze Labels, ID im Label (`N07 Queue`).
- Gruppen G1…Gn. Tausch-Satz: „N12 mit N07 tauschen“.

## Pitfalls

- `npx skills install` gibt es nicht. Install: `npx skills add eraserlabs/eraser-io -g -y --skill '*' --agent hermes-agent`.
- `update_diagram` (NL) für exakte IDs unsicher — DSL schreiben.
- Destination nicht raten: neue Datei, Team-Root ok wenn User „ersten Entwurf“ sagt.
- Plan braucht einen Namen, sonst vermischen sich spätere Zeichnungen.
- Skill `eraser` ist oft gepinnt — Inhalt dort nicht von Cron/Hintergrund ändern.

## References

- `references/energy-warmup-sales.md` — erster benannter Plan + Eraser-IDs
