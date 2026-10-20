---
name: eraser
description: "Use when Eraser/diagram work. Pair MCP with diagram skills."
version: 1.0.0
author: activi
license: MIT
metadata:
  hermes:
    tags: [eraser, mcp, diagrams, architecture]
    related_skills: [eraser-diagrams, aws-diagrams, azure-diagrams, bicep-diagrams, terraform-diagrams]
---

# Eraser = MCP + Skills (immer zusammen)

Eraser-MCP: `https://app.eraser.io/api/mcp` (OAuth). Vendor-Skills = DSL/Syntax. Rendern und Workspace nur über `mcp__eraser__*`.

## When to Use

Jedes Diagramm, Architektur-Bild, Eraser-File, Flowchart, ERD, Sequenz, BPMN, Terraform/AWS/Azure visualisieren. Immer diese Skill plus Domain-Skill plus MCP.

## Pflicht

1. `skill_view(name='eraser')` bei jedem Diagramm-/Eraser-Task.
2. Domain-Skill laden:
   - allgemein → `eraser-diagrams`
   - AWS / CloudFormation / EC2 → `aws-diagrams`
   - Azure / ARM → `azure-diagrams`
   - `.bicep` → `bicep-diagrams`
   - `.tf` / Terraform → `terraform-diagrams`
3. Ausgabe nur über `mcp__eraser__*`. Kein curl, kein `POST https://app.eraser.io/api/render/*`, kein `ERASER_API_KEY`.

## Tool-Routing

| Absicht | Tool |
|---|---|
| Neu aus natürlicher Sprache | `mcp__eraser__create_diagram` — nur `text`; `diagramType` nur wenn User einen Typ nennt |
| Bestehendes ändern (NL) | `mcp__eraser__update_diagram` |
| DSL aus Skill 1:1 schreiben | `mcp__eraser__manually_create_diagram` / `mcp__eraser__manually_update_diagram` |
| PNG/JPEG | `mcp__eraser__export_diagram` |
| Datei anlegen | `mcp__eraser__create_file` |
| Suchen / lesen | `mcp__eraser__search`, `get_file`, `get_diagram`, `list_files` |
| Wer / Team | `mcp__eraser__get_me` |

DSL-Typen: `flowchart-diagram`, `entity-relationship-diagram`, `cloud-architecture-diagram`, `sequence-diagram`, `bpmn-diagram`. Syntax: `eraser-diagrams/references/*.md`.

## Ablauf

1. Diese Skill + Domain-Skill laden.
2. Quelle analysieren — DSL-Regeln aus dem Domain-Skill.
3. MCP-Call. Nicht bei generiertem DSL stehen bleiben.
4. User: Bild, Editor-Link, Quellen, DSL-Block.

## Pitfalls

- Vendor-SKILL.md kann noch curl-Beispiele enthalten — ignorieren, MCP nutzen.
- `npx skills add eraserlabs/eraser-io` überschreibt die fünf Vendor-Kopien; diese Pairing-Skill bleibt. Danach Domain-Skills wieder auf MCP patchen.
- Tools live nur nach `/reload-mcp` oder neuer Session.
- OAuth-Credits = eingeloggter User. API-Key wäre Team-Credits — hier nicht konfiguriert.
