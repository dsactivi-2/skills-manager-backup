# OpenCodex dashboard (this user's defaults)

Configure at http://localhost:10100/. Do not use these controls to rewrite `~/.codex` identity.

## Leave off (rewrite app identity or wrap `codex`)

- opencodex mit Codex starten — shim runs `ocx ensure` before Codex; wraps the binary the app launches.
- Codex ohne Anmeldung — injects `[model_providers.opencodex]` and drops ChatGPT login chrome; old threads tagged with the previous provider id vanish from the history view.
- Clientseitige Komprimierung — compaction, not zip. Same dedicated `opencodex` provider injection.
- Bestimmtes Codex-Konto in der Modellauswahl — extra picker rows per ChatGPT account; changes the list Codex shows.
- Im Default-Modus nachfragen — writes Codex `[features]`.
- Ultra-Fast-Diensttarif — advertises a tier OpenAI often does not actually serve.
- Automatische Fensteraktivierung — sends warmup requests that spend ChatGPT quota.

## Codex-Auth (ChatGPT only)

Pool shares new threads across added ChatGPT accounts; Direct uses only the caller/main bearer. Expired main-account token: App-Login on this page, not a Models-page change. Extra pool accounts are optional. Rotationsstrategie Kontingent is the default. Proaktiver Wechsel (e.g. 80%) only matters with more than one ChatGPT account.

## Models page

- Neue Modelle zunächst deaktivieren: hide newly discovered ids until enabled. Default off.
- Shadow-Call-Abfangen: reroute Codex helper calls (often `gpt-5.6-luna`) to another model. Default off so billing and traces stay obvious.
- Aliase: optional short names; upstream still gets the real id. Not required. Do not invent ChatGPT names for Grok/Claude/Cursor.
- Standardfenster 350k: fallback context for routed providers missing their own window. Native OpenAI rows keep real windows. Default off.
- Sub-Agent v1 / base / v2: how spawn_agent workers talk. `base` follows Codex per model. v1 for ChatGPT spawning routed children; v2 can encrypt native-to-routed tasks so Grok/Claude cannot read them. Change only when sub-agents fail across providers; existing sessions keep the old surface.
- Reihenfolge anwenden: saves picker sort only. Do not click unless the user wants a custom order.
- Alle an / Alle aus and custom model add: visibility for that provider. Safe for chats.
