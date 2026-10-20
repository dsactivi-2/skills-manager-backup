# n8n official skills — wozu / wie / wo (DE, einfach)

Live-Quelle: https://github.com/n8n-io/skills (Pack v1.2.0, 14 Skills).
Kein Workflow-Katalog. Bedienungsanleitung für den Agenten + n8n-Instance-MCP.

Install Hermes: siehe `references/n8n-npx-install.md`.
Ort: `~/.hermes/skills/<name>/SKILL.md`. Tiefe in `references/`.
Wirkung nur in der Agent-Session, nicht in der n8n-UI.

Ablauf immer: `using-n8n-skills-official` → Fachskill → MCP. Nicht raten.

Wenn der User nach Inventar „erkläre alle Skills genauer, einfach, wozu/wie/wo“ fragt: diese Datei nutzen, kein zweites Path-Tree-Dump.

## 1. using-n8n-skills-official — Türsteher

Wozu: Welcher der 13 Skills jetzt. Kurzliste aller n8n-MCP-Tools.
Wie: Immer zuerst. Hermes: AGENTS.md-Snippet. Claude/Codex: SessionStart-Hook (Hermes hat den Hook nicht).
Wo: Jede n8n-Arbeit. Energy WarmUP: vor Monolith-Änderungen.

## 2. n8n-workflow-lifecycle-official — Plan bis Live

Wozu: Plan → Build → Validate → Test → Publish → Handoff.
Wie: Vor create/update/validate/publish. Nach Write `get_workflow_details` (Connections). Validate-grün ≠ publish-fertig.
Wo: Neuer Workflow, großer Umbau. Energy: nicht publishen ohne User-Freigabe.

## 3. n8n-subworkflows-official — Bausteine

Wozu: Wiederholbare Logik als Mini-Workflow, nicht Graph-Kopie.
Wie: Erst `search_workflows` (Tag `subworkflow`). Trigger Define Below, nicht Passthrough (außer Binary).
Wo: JWT, Sheet-Read, Event-Log. Energy: kein zweiter Monolith.

## 4. n8n-node-configuration-official — eine Node

Wozu: Parameter nicht aus Gedächtnis.
Wie: `get_node_types` mit resource/operation. Dropdowns über `explore_node_resources`, IDs nicht erfinden.
Wo: HTTP, Webhook, Sheets, Merge, Trigger.

## 5. n8n-expressions-official — `{{ }}`

Wozu: Felder verdrahten ohne Code-Node.
Wie: `$('NodeName').item.json.feld`, nicht `$json` (bricht still nach Merge/Aggregate). Datum: Luxon.
Wo: Fast jede Node mit einem Feld.

## 6. n8n-code-nodes-official — wann Code

Wozu: Bremse. Code-Node last resort.
Wie: Expression → Edit-Fields-Pfeilfunktion → Code. Default JS.
Wo: Nur Multi-Source-Aggregation, Library, JWT-Builder.

## 7. n8n-loops-official — viele Items

Wozu: Viele Zeilen, Pagination, „für jeden“. Die meisten Nodes loopen von allein.
Wie: Einmal für alle → `executeOnce`. Batches → Loop Over Items. Fan-out in n8n sequentiell.
Wo: Queue, Cap, Sheet-Zeilen, Slot-Limits.

## 8. n8n-error-handling-official — Fehler laut

Wozu: Webhook/Cron/Calls dürfen nicht still sterben.
Wie: Error-Ausgang an jeder unsicheren Node. Webhook: beide Pfade → Respond. 4xx Caller, 5xx wir.
Wo: get-kunde, call-result, lk-events, SIP-Fail-Zweig.

## 9. n8n-credentials-and-security-official — Keys

Wozu: Kein Secret in Node-Text oder Chat.
Wie: `list_credentials`, binden. Anlegen nur User in der UI.
Wo: LiveKit, Google, Mail, Kalender.

## 10. n8n-data-tables-official — n8n-Tabellen

Wozu: Kleiner State in n8n (Leads/DNC/Events). Keine Postgres.
Wie: Nur primitive Spalten. `id`/`createdAt`/`updatedAt` nicht selbst anlegen. Nested JSON = String + `_object`.
Wo: Lauf-State, nicht Sheet ersetzen.

## 11. n8n-binary-and-data-official — Dateien

Wozu: Audio/PDF/Bild in `$binary`, nicht `$json`.
Wie: Binary nicht durch Agent-Tools. Erst speichern, URL/Key als JSON.
Wo: Recordings, Uploads. Energy WarmUP kaum.

## 12. n8n-agents-official — n8n-LangChain-Agent-Node

Wozu: LLM mit Tools *in n8n* (nicht Hermes, nicht LiveKit-Gespräch).
Wie: Agent-Node + Subnodes Modell/Memory/Tools.
Wo: Nur n8n-Chat-Agent. Energy G3 = LiveKit, diese Node nicht nachbauen.

## 13. n8n-extending-mcp-official — MCP-Lücke

Wozu: MCP kann X nicht, oder Workflow als Agent-Tool.
Wie: Erst User fragen, dann Workflow + MCP-Access.
Wo: Selten. Kein Wrapper ohne Auftrag.

## 14. n8n-debugging-official — „geht nicht“

Wozu: Symptom ernst nehmen.
Wie: User = Soll, Execution = Ist. Parameter → Execution-Daten → n8n-Source.
Wo: Tote Nodes, falsche Branches, MCP sichtbar aber Workflow unsichtbar (`availableInMCP`).

## Energy-Kurzkarte

| Situation | Skill |
|---|---|
| Session start | using-n8n-skills-official |
| Monolith / irgendwann live | lifecycle |
| JWT/Sheet/Events rausziehen | subworkflows |
| Eine HTTP/Sheets-Node | node-configuration + expressions |
| JWT Code-Node | code-nodes |
| 4 Slots, Queue | loops |
| Fail-Zweig, Webhooks | error-handling |
| Sheet/Google/LiveKit/Mail Login | credentials |
| leads/dnc/events | data-tables |
| Gesprächs-KI | nicht agents-official |
| Workflow spinnt | debugging |
