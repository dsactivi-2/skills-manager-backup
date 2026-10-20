---
name: livekit-docs-library
description: "Use when dumping LiveKit docs into AI Bibliothek llms."
---

# LiveKit docs → AI Bibliothek

Trigger: User gibt LiveKit-Docs-URLs (`docs.livekit.io/...md`) und will den Text als `.txt` in der lokalen Bibliothek.

## Destination

`/Users/activi/AI Bibliothek/LiveKit llms`

Bestehende Dateien und `_INDEX.txt` nicht überschreiben, außer der User will genau diese Seite neu ziehen. Batch an `_INDEX.txt` anhängen.

## Dateinamen

Pfad nach `https://docs.livekit.io/` → Slashes zu Dots, `.md` weg, Suffix `.txt`.

| URL | Datei |
|-----|--------|
| `/frontends/agents-ui.md` | `frontends.agents-ui.txt` |
| `/frontends/authentication/tokens.md#overview` | `frontends.authentication.tokens.txt` (collapse) |

- `#overview` (und gleiche Seite) **nicht** extra speichern.
- Andere Fragmente nur wenn der bestehende Dump das so macht (`stem__fragment.txt`).
- Header wie die anderen Dateien:

```
SOURCE: <original url>
FETCH: <url without fragment>
FETCHED: <ISO-UTC>
NOTE: raw markdown via curl (docs.livekit.io .md)

<markdown body>
```

## Fetch (verbindlich)

1. Unique-URLs ohne Fragment.
2. `curl -fsSL` + Browser-UA, **kein** `Accept: text/markdown`.
3. `.md`-Pfad direkt: `https://docs.livekit.io/frontends.md` → `content-type: text/markdown`.

### Pitfall: `Accept: text/markdown` → 404

Vercel `vary: Accept`. Mit `Accept: text/markdown` wird auf `/api/markdown/{slug}.md` umgeschrieben (doppeltes `.md`) und 404.

- urllib/requests mit diesem Header: fail.
- curl ohne den Header: 200 Markdown.

Nicht Python-HTTP als kaputt merken — Header weglassen oder curl nutzen.

### Nicht primär

- `web_extract`: lange Seiten werden gekürzt; Chat-Attach ist kein Volltext.
- HTML-Pfad (`/frontends/`) nur Fallback, wenn `.md` wirklich 404 ist.

## Ablauf

1. Zielordner existiert meist schon — `mkdir -p`, dann Namensschema aus vorhandenen `.txt` übernehmen.
2. Unique Pages holen, Dateien schreiben.
3. Verifizieren: Body beginnt mit `LiveKit docs ›`, Bytes > ~200, kein HTML-Doctype.
4. `_INDEX.txt` um die neuen Zeilen ergänzen (`bytes  filename  url`).
5. User: knappe Tabelle (Datei, Bytes, Quelle). Deutsch.

## Duplicate pages

`/frontends/authentication/tokens.md` und `/frontends/reference/tokens-grants.md` können denselben Body haben (kanonisch oft tokens-grants). Trotzdem **beide** Dateien, wenn beide Links da waren.
