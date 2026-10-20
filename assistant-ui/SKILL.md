---
name: assistant-ui
description: "Class-level umbrella for building and extending assistant-ui applications: feature aggregation from multiple examples, tool-ui component integration with Vercel AI SDK, scaffolding patterns, and advanced capabilities (Artifacts, LangGraph, MCP, Voice)."
tags: ["assistant-ui", "frontend", "tool-ui", "vercel-ai-sdk"]
---

# assistant-ui Umbrella Skill

Consolidated skill for assistant-ui ecosystem work.

## Feature Aggregation
Systematically combine multiple assistant-ui examples and advanced capabilities into one unified application. Use when the user wants a single feature-rich app.

See original `assistant-ui-feature-aggregation` for decision lists, explicit Yes/No confirmation, voice requirements handling, and reference templates.

## Tool UI Integration
Scaffolding and integrating @tool-ui components with assistant-ui and Vercel AI SDK (InferUITools, frontend/backend tools, auto-continue).

See original `assistant-ui-tool-ui` for compatibility checks, install patterns, lib/tools.ts scaffolding, client rendering with InferUITools, and pitfalls around server/client boundaries.

## Shared Guidelines
- Always force explicit confirmation on features.
- Distinguish simple Voice Input from full Realtime conversation.
- Never import server tools object into client.
- Use safeParse for schema validation.

## References
- Original skill bodies archived for full workflows and code patterns.
