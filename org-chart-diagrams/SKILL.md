---
name: org-chart-diagrams
description: Organigramme / Organisationsdiagramme erstellen (Hierarchie, Rollen, Abteilungen, Dotted-Line-Reports). Nutze diesen Skill IMMER wenn der Nutzer "Organigramm", "org chart", "Unternehmensstruktur", "Stellenbesetzung", "Teamstruktur", "Hierarchie zeichnen" will. Rendern über Skill `kroki-diagrams`, Stil über `minimal-diagram-style`.
---

# Organigramme zeichnen

## Typwahl nach Anlass

| Anlass | Empfohlener Typ |
|---|---|
| Einfache Hierarchie, schnell | **mermaid** `flowchart TD` |
| Schickes, formales Organigramm | **graphviz** (dot, rankdir=TB) |
| Rollen + Abteilungs-Cluster, viele Personen | **graphviz** mit `subgraph` pro Abteilung |
| WBS-artige Baumstruktur | **plantuml** `wbs` |
| Gepunktete Berichtslinien (dotted line) | graphviz `style=dashed` |

Standard: **graphviz dot** — gibt die beste Kontrolle über Abstand, Cluster und Kanten.

## Graphviz-Template (modern, via minimal-diagram-style)

```dot
digraph org {
  graph [bgcolor="white", pad=0.4, nodesep=0.45, ranksep=0.7, splines=ortho, fontname="Helvetica"];
  node [shape=box, style="rounded,filled", fillcolor="#F9FAFB", color="#4F6BED",
        fontname="Helvetica", fontsize=12, margin="0.2,0.12"];
  edge [color="#9CA3AF", arrowsize=0.7];

  ceo [label="Max Mustermann\nGeschäftsführer", fillcolor="#4F6BED", fontcolor="white"];
  subgraph cluster_it {
    label="IT"; color="#E5E7EB"; fontname="Helvetica"; fontsize=11; fontcolor="#6B7280";
    it1 [label="Anna Berger\nLeitung IT"];
    it2 [label="Tim Huber\nDevOps"];
  }
  subgraph cluster_sales {
    label="Vertrieb"; color="#E5E7EB"; fontname="Helvetica"; fontsize=11; fontcolor="#6B7280";
    s1 [label="Sara Klein\nLeitung Vertrieb"];
  }

  ceo -> it1; ceo -> s1; it1 -> it2;
  { rank=same; it1; s1 }   // gleiche Ebene
  it2 -> s1 [style=dashed, arrowhead=none, color="#C7CBD4"];  // dotted line
}
```

## Mermaid-Template (schnelle Variante)

```mermaid
flowchart TD
  CEO["Max Mustermann<br/><small>Geschäftsführer</small>"]
  CEO --> IT["Anna Berger<br/>Leitung IT"]
  CEO --> SALES["Sara Klein<br/>Leitung Vertrieb"]
  IT --> DEV["Tim Huber<br/>DevOps"]
  DEV -.-> SALES
```

## Regeln

1. **Pro Node: Name + Rolle** (zwei Zeilen, Rolle klein/grau). Nie nur Namen ohne Funktion.
2. **Cluster = Abteilungen**, mit dezentem Label oben.
3. Gleiche Hierarchieebenen mit `{ rank=same; ... }` ausrichten.
4. Dotted lines (`style=dashed` / `-.->`) nur für Nebenlinien — Legende einbauen wenn mehr als eine.
5. >~25 Personen: nicht ein Diagramm quetschen — pro Abteilung ein Chart oder interaktiv (HTML).
6. Render-Call (Kroki):

```bash
curl -sS https://kroki.io/graphviz/svg \
  -H 'Content-Type: text/plain' --data-binary @org.dot -o org.svg
```

7. Ergebnis-Datei kurz prüfen (existiert, beginnt mit `<svg`), dann dem Nutzer Pfad + Datei geben.
8. PII-Hinweis: echte Namen in Diagrammen — Nutzer ggf. auf Self-Host-Kroki hinweisen (siehe `kroki-diagrams`).
