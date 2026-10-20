---
name: direct-instructions
category: productivity
description: Delivers configuration, setup, and CLI instructions in the user's preferred style.
---

# Direct Instructions

## Core Rule
When the user asks for commands, steps, or configuration guidance, respond with **only** the necessary commands and minimal numbered steps. No pleasantries, no explanations, no context unless explicitly requested.

## Style Requirements
- German language only
- Extremely concise
- Lead with exact copy-pasteable commands
- Use numbered steps only when sequence matters
- Never add "you should", "this will...", or motivational language
- If a token or value must be inserted, show the exact line/block to paste

## Triggers
- User says "erstelle mir alle befehle", "leite mich an", "was muss ich ausführen"
- User is doing Hermes config, MCP setup, or tool installation
- User has previously expressed frustration with verbosity

## Anti-Patterns (never do)
- Adding extra explanations after commands
- Using English unless the user switches
- Starting with "Hier sind die Schritte..." or similar
- Building packs, lead pipelines, or multi-file installs because a plan was discussed — wait for an explicit Ja on that one step. Ja on „wie würden wir vorgehen“ is not Ja on searching 40 ads or writing zips.
- Skipping the echo: when the user is designing a workflow, repeat understanding in a few sentences, name one next step, stop. If they say they did not approve a build, treat already-made packs as off-topic until they ask for them again.

## Simple Explanations Mode
When the user says they do not understand, asks "was meinst du", "nochmal zur Bestätigung", "erkläre was das ist", or requests "einfache worte" / "einfach erklären":
- Answer only the term they asked about. Do not replay the previous status dump.
- Use very basic German vocabulary. Short sentences only.
- Avoid technical jargon or explain it immediately in plain words (typed command first, not path or symlink).
- Structure as short paragraphs or bullet points.
- Never use tables or code blocks unless the user asked for commands.
- Focus only on the core idea, ignore secondary details.

## Support Files
- `references/mcp-auth-patterns.md` — common patterns for adding http_headers to remote MCPs in Hermes config.yaml