---
name: dograh-mcp
description: Use when working with Dograh agents, runs, campaigns, telephony configs, or Dograh documentation through an MCP server in Codex.
---

# Dograh MCP

## Overview

Use this skill when Codex should work against a Dograh workspace over MCP or when a Dograh docs question needs current documentation. Prefer Dograh MCP tools for workspace data and use the docs index only for documentation lookup.

## Quick Start

1. Confirm the MCP server is registered:

```bash
~/.codex/skills/dograh-mcp/scripts/check_dograh_mcp.sh
```

2. For documentation questions, fetch the docs index first:

- `https://docs.dograh.com/llms.txt`

3. Then choose the smallest relevant source:

- Agents and workflow schema for agent edits
- Runs and recordings for operational debugging
- Telephony configs for provider or number questions
- Deployment and configuration docs for self-hosted setup

## Preferred Workflow

### Workspace inspection

- Start by listing the relevant Dograh objects before making claims.
- Use exact agent names, IDs, run IDs, or timestamps in responses when available.
- If the user asks for the "latest" run or recording, verify it from the live workspace first.

### Agent changes

- Read the existing agent definition before proposing edits.
- Keep edits minimal and localized to the requested node, edge, model, or prompt.
- If a workflow validation tool is exposed by the MCP server, run validation before declaring the draft ready.
- Treat agent edits as draft-oriented work unless the user explicitly asks to publish elsewhere.

### Documentation lookup

- Always begin with `https://docs.dograh.com/llms.txt` to discover the available pages.
- Open only the pages needed for the task instead of browsing broadly.
- Prefer these doc families:
  - `api-reference/` for request/response details
  - `developer/workflow-schema.md` for workflow definitions
  - `voice-agent/` for node behavior and builder concepts
  - `deployment/` and `configurations/` for infrastructure questions

## Guardrails

- Never echo API keys, secret headers, or credential values.
- Do not invent node fields or workflow schema fields. Check the docs or live object first.
- For risky changes, summarize the exact intended mutation before applying it.
- If a requested operation is not exposed by the MCP server, say so and fall back to docs or local files.

## References

- Read [references/doc-entrypoints.md](references/doc-entrypoints.md) when you need a compact map of the most useful Dograh documentation areas.
