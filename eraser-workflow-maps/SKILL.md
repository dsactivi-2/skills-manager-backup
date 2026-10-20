---
name: eraser-workflow-maps
description: "Use when mapping Eraser workflows with node/route IDs."
version: 1.0.0
author: activi
license: MIT
metadata:
  hermes:
    tags: [eraser, workflow, n8n, livekit, versioning]
    related_skills: [eraser, eraser-diagrams]
---

# Eraser Workflow Maps

Versionierte Prozesskarten in Eraser + lokalem Ordner. Knoten `Nxx`, Routen `Rxx`. MCP rendert; Skills liefern DSL.

## When to Use

User will einen Ablauf zeichnen, später vergleichen, Knoten tauschen, oder Status/Lücken sehen. LiveKit/n8n/Telesales-Pläne. Nicht: einzelnes Infra-Bild ohne IDs.

Zuerst Pairing-Skill `eraser` laden (`skill_view eraser`). Rendern nur `mcp__eraser__*`.

## Pflicht-Ablauf

1. Verstehen spiegeln. Erst zeichnen nach Freigabe der Zeichenliste.
2. Lokaler Projektordner: `diagrams/`, `phases/`, `versions/`, `VERSIONING.md`.
3. **Vor jeder Diagramm-Änderung** Snapshot `versions/vNNN/` (DSL, PNG, betroffene MD). Nie überschreiben ohne Kopie.
4. Feste IDs: Knoten `N01`, Teilquellen `N01.1`. Verbindungen `R01`. Sprechen: „N12 mit N07“, „R38“.
5. Exakte IDs → `manually_create_diagram` / `manually_update_diagram`. Nicht `create_diagram` (NL frisst IDs).
6. Nach Edit: Eraser-Link + lokale Dateien + `CHANGELOG.md` eine Zeile.

## Zwei Kalender (Telesales)

Nicht einen Termin-Kasten für alles.

| Kalender | Wann | Wohin |
|---|---|---|
| Human (G7) | Kunde Ja (Vertragsgespräch Mensch) | Kein Rückweg Agent-Call |
| AI (G9) | Kunde will später zurückgerufen werden | Zur Zeit → G2 `N07`, nie direkt G3 |
| Queue | Nicht erreicht | Zurück G2, **max 2 Anrufe/Tag**, kein Human |

SIP/Dispatch/Call-ID nur über G2. Ohne Call-ID kein Check.

## Eraser MCP (kurz)

- URL: `https://app.eraser.io/api/mcp` — OAuth, nicht curl `/api/render`.
- CLI Skills: `npx skills add eraserlabs/eraser-io -g -y --skill '*' --agent hermes-agent` (`add`, nicht `install`).
- Neue Datei: fragen private/team nur wenn User kein Default will. Arbeitsdatei-Titel = Plan-Name.
- Labels einzeilig. Quer: `direction right`. Lesbarkeit: `typeface clean`, `styleMode plain`, kurze Labels.

## User-Stil (diese Klasse)

Deutsch, Tabelle ID | Bedeutung | Was gemacht wird. Kein Essay. Phasen einzeln erklären, erst nach OK weiter. Plan-Namen vergeben zum Unterscheiden.

## Pitfalls

- `npx skills install` existiert nicht → `add`.
- Vendor-SKILL.md hat noch curl — ignorieren.
- `create_diagram` NL zerstört N/R-IDs.
- N18 (nicht erreicht) nicht auf Human-Kalender legen.
- Gepinnte Skill `eraser` hier nicht patchen. Inhalt-Updates: User `hermes curator unpin eraser` oder adopt.

## Support

- `references/energy-warmup-sales-no-contract.md` — aktueller Plan, Datei-IDs, Versionen.
