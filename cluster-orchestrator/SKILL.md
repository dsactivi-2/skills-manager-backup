---
name: cluster-orchestrator
description: "Orchestration Skill for managing the 10-agent cluster."
version: 1.0.0
---

# CLUSTER ORCHESTRATOR

Dieser Skill ermöglicht es, komplexe Missionen an das 10-Agenten Cluster zu delegieren.

## Rollenverteilung
- **Dispatcher:** Empfängt Aufträge und identifiziert den passenden Agenten.
- **Worker:** (dev-op, research, etc.) Führen spezialisierte Teilaufgaben aus.
- **Reviewer:** (agent-builder) Validiert Ergebnisse.

## Workflow
1. **Dekomposition:** Zerlege die Mission in Teilaufgaben.
2. **Delegation:** Nutze `terminal(command="<agent-name> chat -q '...'")` für asynchrone oder parallele Aufgaben.
3. **Aggregation:** Sammle Ergebnisse in einer zentralen Datei.

## Befehle (Aliases)
- `dev-op`: Infrastruktur & Automatisierung
- `research`: Tiefenanalyse & Reports
- `creative`: Visuelles & Design
- `mlops`: Modell-Optimierung
- `xai-voice-dograh`: Echtzeit-Intelligence (X)
...und weitere Profile.

## Best Practice
Nutze `~/.hermes/shared_workspace/` für den Dateiaustausch zwischen Agenten.

## Wichtige Unterscheidung: Agent vs. MCP-Server
Viele Profile in einem Cluster enthalten primär MCP-Server-Definitionen (via Codex ↔ Hermes Sync). Nur Profile, die aktiv über `delegate_task` (role: orchestrator) angesprochen werden, zählen als echte orchestrierbare Agenten.

## OpenClaw Integration
OpenClaw kann sowohl über **MCP** (Tool-Ebene) als auch über **ACP** (Agent-Ebene) angebunden werden. Für echte Orchestrierung bevorzugt ACP nutzen, damit OpenClaw als gleichwertiger Child-Agent behandelt wird.

## Produktionsreife Orchestrierung
Für VPS-Deployments:
- Variante 1 (empfohlen zum Start): Dedizierter Hermes-Orchestrator + `delegate_task` + ACP
- Variante 2: Hybrid (Hermes + OpenClaw Worker)
- Variante 3: Temporal + k3s (hochskalierbar)

Der Orchestrator sollte immer zuerst ACP-fähige Worker priorisieren.
