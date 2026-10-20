---
name: apple
description: "Class-level umbrella for Apple ecosystem integrations on macOS: Notes.app via memo CLI, Reminders.app via remindctl, and related Apple apps (iCloud sync patterns)."
tags: ["apple", "macos", "notes", "reminders", "iclou d"]
---

# Apple Umbrella Skill

Consolidated skill for Apple macOS app management via terminal CLIs.

## Notes
Manage Apple Notes via memo CLI: create, search, edit, folders, export. Syncs via iCloud.

See original `apple-notes` for install (brew tap), permissions, quick reference commands, and rules preferring it for cross-device sync over Obsidian.

## Reminders
Apple Reminders via remindctl: add, list, complete, due dates, alarms, lists.

See original `apple-reminders` for install, date formats, alarm vs due distinction, JSON output, and clarification rules (Reminders vs cronjob alerts).

## Shared Rules
- macOS only.
- Grant Automation/Reminders permissions on first use.
- Prefer these for native iCloud sync to iPhone/iPad.
- Use memory tool for agent-internal notes.

## Networking
Ethernet/USB-LAN diagnostics: see `references/macos-ethernet-diagnostics.md` for the full pipeline — interface discovery, link status, adapter details, Realtek RTL8153 quirks, and WLAN failover.

## References
- Original skill content archived.
