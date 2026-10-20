# Engine surfaces + Apply/Update

One engine. Four doors. Shared state:

Playbook YAML → user answers → signed plan JSON → drafts → review log

| Door | User name | Role |
|---|---|---|
| Chat conductor | — | Default. `clarify` on 2+ valid options |
| MCP | Lösung 1 | Catalog + `check_constraints`. Not the brain |
| Wizard | Lösung 2 | Same conductor, menu-first |
| Session cron | Lösung 3 | Wake-gate on new/changed session. Propose only |
| Builder + reviewer | Lösung 4 | Apply drafts, then check vs original brief |

## Script contract

**Script 1 Apply** — input: signed plan only. Output: drafts under a dated folder. Never live `~/.hermes/profiles/<name>/`. Refuse unsigned plans.

**Script 2 Update** — input: current drafts + new signed plan. Patch matching points. Append new points. If a change would contradict an already-built unit, build a **separate** unit and say so. Never silent rewrite of a live profile.

## Constraint fields (every option)

- `requires` — must already be chosen
- `conflicts_with` — stop + explain
- `implies` — auto-select or ask once

Example this session wanted caught: Option 1 + Option 3 both accepted while they conflict.

## Tonbi Hermes Agent Masterclass (verified 2026-08-23)

Announced as 11 episodes. Shipped as **10 modules**. Playlist has 11 videos = 10 modules + Quickstart.

Playlist: https://www.youtube.com/playlist?list=PLmpUb_PWAkDx-VWjh00tVCji794xAa_IX

| # | Title | URL |
|---|---|---|
| 1 | Installation, Setup, Basic Commands | https://www.youtube.com/watch?v=R3YOGfTBcQg |
| 1u | Module 1 Updated July 2026 | https://www.youtube.com/watch?v=x89MvP6gLaA |
| 2 | Deploy to VPS, Telegram, Discord | https://www.youtube.com/watch?v=dcXmUUZvDLE |
| 3 | Memory, Plugins, Honcho, Obsidian | https://www.youtube.com/watch?v=ZKZLko9kLm4 |
| 4 | Skills | https://www.youtube.com/watch?v=L3WdVeMaYZM |
| 5 | Providers & Models | https://www.youtube.com/watch?v=1oaaOWy7wSI |
| 6 | Tools & MCP Servers | https://www.youtube.com/watch?v=U140gP-1bEI |
| 7 | Cron & Automation | https://www.youtube.com/watch?v=grMNnzCv2gY |
| 8 | Subagents & Delegation | https://www.youtube.com/watch?v=_6DtQkDpcEs |
| 9 | Profiles & Kanban | https://www.youtube.com/watch?v=KPsMThlFb8Y |
| 10 | Security (finale) | https://www.youtube.com/watch?v=KtlY6ETPyKo |
| QS | Quickstart 10 min (not a module) | https://www.youtube.com/watch?v=BeWUUclCin0 |

First playbook should lean on modules 1, 4, 9. Do not wait for a full transcript dump.

Local transcripts live in `/Users/activi/Documents/Youtube Tranksipt/` (spelling is the real folder name).
