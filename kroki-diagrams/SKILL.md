---
name: kroki-diagrams
description: Diagramme als Code rendern über die Kroki-API (kroki.io oder Self-Host). Text-Diagramm rein, Bild (SVG/PNG/PDF) raus — ohne Konto, ohne API-Key. Nutze diesen Skill IMMER wenn der Nutzer Diagramme, Organigramme, Architektur-Skizzen, Flowcharts, UML o.ä. als Bild/Datei/URL haben will und kein anderes Tool vorgibt. Triggert auf "diagramm erstellen", "render diagram", "flowchart als bild", "org chart", "architekturdiagramm".
---

# Kroki — Diagramme-als-Code über eine HTTP-API

Kroki ist ein Unified Gateway: ein Endpunkt, ~25 Diagrammformate. Kein Konto, kein Key.

## API-Verbindung

- Basis-URL (öffentlicher Free Service, von Yuzu Tech/Exoscale betrieben, kein SLA):
  `https://kroki.io`
- Self-Host (Docker): `http://localhost:8000` — Image `yuzutech/kroki`, Companion-Container für mermaid/bpmn/excalidraw: `yuzutech/kroki-mermaid`, `yuzutech/kroki-bpmn`, `yuzutech/kroki-excalidraw`

## Aufrufe

**POST Plaintext (einfachster Weg, kein Encoding):**

```bash
curl -sS https://kroki.io/graphviz/svg \
  -H 'Content-Type: text/plain' \
  --data-binary 'digraph G { Hello -> World }' \
  -o diagram.svg
```

Format auch in der URL oder via `Accept`-Header setzen:
`POST https://kroki.io/mermaid/png` mit `Content-Type: text/plain`.

**POST JSON:**

```bash
curl -sS https://kroki.io \
  -H 'Content-Type: application/json' \
  -d '{"diagram_type":"mermaid","output_format":"svg","diagram_source":"graph TD; A-->B"}' \
  -o diagram.svg
```

**GET (für embeddable URLs):**
`GET https://kroki.io/<type>/<format>/<deflate+base64url(source)>`

Encoding (Python):
```python
import base64, zlib
enc = base64.urlsafe_b64encode(zlib.compress(src.encode(), 9)).decode()
```

**Optionen** an die Rendering-Library (z.B. PlantUML-`theme`, Mermaid-Config) als Query-Param `?key=value`, im JSON-Feld `diagram_options`, oder Header `Kroki-Diagram-Options-Key: value`. Präzedenz: JSON-Body > Header > Query.

## Typen (`diagram_type`)

blockdiag, seqdiag, actdiag, nwdiag, packetdiag, rackdiag, bpmn, bytefield, c4plantuml, d2, dbml, diagramsnet (experimentell), ditaa, erd, excalidraw, goat, graphviz, mermaid, nomnoml, pikchr, plantuml, structurizr, svgbob, symbolator, umlet, vega, vegalite, wavedrom, wireviz

**Output-Formate:** `svg` (Default), `png`, `pdf` (nicht jeder Typ unterstützt alle — bei Fehler `svg` probieren).

## Womit was zeichnen (Empfehlung)

| Ziel | Typ |
|---|---|
| Flowchart/Sequence/Gantt/Mindmap/State | mermaid |
| Klassen-/Komponenten-/Architektur-UML, C4 | plantuml / c4plantuml |
| Freiform-Graphen, Hierarchien, Org-Charts | graphviz (dot) |
| Netzwerk-Diagramme | nwdiag |
| DB-Schema | erd oder dbml |
| Timing/Digital-Schaltungen | wavedrom |
| Verschachtelte Diagramme, Clean Layouts | d2 |

## Regeln

1. Immer `curl` mit `--data-binary` (nicht `-d`) für Plaintext-POSTs — Zeilenumbrüche bleiben erhalten.
2. `svg` bevorzugen (skalierbar, klein). PNG nur wenn nötig.
3. Empfindliche Inhalte → Self-Host; öffentlicher Service bekommt den Diagramm-Quelltext im Klartext.
4. Vor dem Liefern: Datei schreiben, kurz prüfen (erste Zeile `<svg` o.ä.).
5. Für schlichtes Design siehe Skill `minimal-diagram-style`; für Organigramme `org-chart-diagrams`.

Docs: https://docs.kroki.io/kroki/
