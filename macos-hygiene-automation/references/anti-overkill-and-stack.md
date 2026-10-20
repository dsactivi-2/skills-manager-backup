# Anti-overkill + reliability stack

## Decision rule
1. Run Phase 0 (manual + reboot) and baseline counts.
2. If problem does not return → stop. No cron/MCP.
3. If stale Hermes/Hivemind returns → mini scan script + notify + HITL apply.
4. Disk junk → existing CleanMyMac / Mole / PureMac, not a parallel custom disk engine.
5. Structure organizer and MCP server → later only.

## What we almost overbuilt
- MCP server embedding "all skills/plans/apps"
- LLM generating fresh kill/delete scripts per run
- Dry-run auto-promoting to real without human freigabe
- Structure auto-move of ~/Code
- Multi-skill orchestrator before one working scan

## Correct MCP mental model
MCP exposes **tools** (and optional resources). It does not ship Hermes skill memory or runbook judgment by itself. You can wire once (tools + skill rails + cron) so **scans** run automatically later; **destructive apply** stays freigabe-gated in fixed code.

## External pointers (as of 2026-07)
- Mole: `brew install mole` — CLI maintenance; skill wrappers exist on skills.sh (`mole-mac-cleaner`)
- PureMac: OSS GUI cleaner, trash-only, review-before-delete
- Plan SoT for this user: `~/Downloads/Mac-Hygiene-Plan-2026-07-27.md`
