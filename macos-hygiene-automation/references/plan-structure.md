# Mac-Hygiene plan document structure

Required sections when writing/updating the user plan:

1. **Ist** — live symptoms, swap/RAM, Hermes multiplicity, tools present, automation not yet on
2. **Soll** — one working Hermes session norm, HITL reports, low surprise autostart, measurable baseline
3. **Nachgezogen** — autostart inventory, session-tree kill, report+recheck, trash-only, script scan, notify, heartbeat
4. **Architecture** — Phase0 / process / disk / structure / reports / apply-on-demand
5. **Rules** — allow/deny paths, heuristics, risk tiers
6. **Phases 0–7** — ground cleanup → design freeze → manual scan → apply → crons → structure
7. **Runbook** — dirs, config sketch, manual test cmds, approve examples, cron table, tool coexistence
8. **Gate before cron** — completeness, scan≠apply, gateway safe, CleanMyMac path non-conflict, logs exist
9. **Open defaults** — notify channel, stale hours, keep_newest, downloads age, gateway keep, heartbeat
10. **Next steps** — freigabe plan → gate → Phase0 → scripts → …

User SoT file example: `~/Downloads/Mac-Hygiene-Plan-2026-07-27.md`

## Gate checklist (must pass before cron)
- [ ] Phase 0 defined and done or scheduled first
- [ ] Process + disk + structure in plan
- [ ] Autostart in process module
- [ ] Session-tree kill (not child-only)
- [ ] Recheck on apply
- [ ] Trash-only deletes
- [ ] Script-owned scan facts
- [ ] Notify path real (Telegram and/or files)
- [ ] Apply not on cron
- [ ] CleanMyMac role non-overlapping auto-delete paths
