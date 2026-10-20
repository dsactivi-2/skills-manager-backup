---
name: livekit-docs-local-library
description: "Use when dumping LiveKit docs into AI Bibliothek txt files."
---

# LiveKit docs → local AI Bibliothek

Trigger: User pastes `docs.livekit.io` URLs (or `@url:`) and asks to extract/save as txt into **AI Bibliothek**. Also when they say „LiveKit llms“, Docs-Dump, or „alle Texte aus folgenden Links“.

This is **not** the LiveKit git repo. Project `AGENTS.md` forbids `llms.txt` dumps **in the repo**. The library lives outside the repo.

## Library roots

| Folder | Inhalt |
|--------|--------|
| `/Users/activi/AI Bibliothek/LiveKit llms` | Intro, models, **deploy** (default if user names this path) |
| `/Users/activi/AI Bibliothek/LiveKit llms Agents & Framework` | Agents SDK pages |

Match the path the user named. Do not write into `~/Code/Projects/LiveKit`.

## Fetch (source of truth)

Do **not** treat `https://docs.livekit.io/<path>.md` HTTP as the dump source. Project rule: APIs/docs via MCP `livekit-docs` or `lk docs`. HTTP `.md` can 404 (e.g. `/deploy.md` → `Markdown document not found`) while the page still exists.

For each URL:

1. Strip `#fragment` for fetch. Path = URL path without `.md` (`https://docs.livekit.io/deploy/agents/builds.md` → `/deploy/agents/builds`).
2. Fetch with `lk docs get-page /deploy/agents/builds` **or** MCP `get_pages` (`paths: ["/deploy/agents/builds"]`).
3. Drop the CLI warning line (`warning: the LiveKit docs server is version…`) and a leading `## /path` header if present.
4. Fail a file if body is under 200 chars. Retry MCP if `lk` is empty. Do not invent content from chat attachments when truncated.

Batch unique paths; reuse the body for `#fragment` URLs.

## Filename

Same convention as the Agents dump:

- Path slashes → dots, drop `.md`: `/deploy/agents/builds` → `deploy.agents.builds.txt`
- Fragment → `__<anchor>`: `#static-ips` → `deploy.admin.regions.endpoints__static-ips.txt`
- Fragment files get the **full page**, not a sliced section (user asked „jeweils als txt“ per link).

## File header

```
SOURCE: <original URL including #fragment if any>
FETCHED_FROM: <URL without fragment>
FINAL_URL: <same as FETCHED_FROM>
HTTP_STATUS: 200
CHARS: <len of body only>
========================================================================

<body>
```

UTF-8. Do not wrap body.

## _INDEX.txt

Merge, do not wipe. Pre-existing intro/model files in `LiveKit llms` stay. Append a section for this batch:

```
OK   HTTP   CHARS  FILE  <- URL
OK    200   18818  deploy.agents.builds.txt  <- https://docs.livekit.io/deploy/agents/builds.md
```

## Verify before claiming done

Spot-check long pages still contain their late sections (not truncated):

- `builds` → Dockerfile templates **and** „Bring your own container“
- `log-drains` → Google Cloud **and** Syslog / RFC 5424
- `observability/data` → `make_session_report` **and** OpenTelemetry
- `insights` → „Session recording options“ / `record=`

Confirm every requested URL has a file. Count = number of links (fragments included).

## Pitfalls

- Do not `curl` `.md` first and stop on 404. `lk docs get-page` is the dump path.
- Do not overwrite unrelated `agents-models-*` / `intro.*` files in the same folder.
- Do not commit these txts into the LiveKit project repo.
- Attached `@url:` chat context is often truncated; write from `lk`/MCP, not from the attachment.
