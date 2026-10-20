# verify_progress.py auto rules

Source of truth checklist: `state/checklist.json`.

## Manual items

Done only via:

```bash
python3 scripts/verify_progress.py --mark <id>
```

## Auto items

| Item id | auto key | Condition |
|---------|----------|-----------|
| `phase0_baseline_captured` | `hermes_report_after_reboot` | `phase0_reboot_done` marked **and** `reports/hermes_scan_*.json` with timestamp ≥ mark time (and ≥ boot) |
| `phase2_scan_report_exists` | `phase2_official_scan` | `phase1_rules_confirmed` marked **and** at least one hermes scan report exists |

## Failure mode avoided

Pre-Phase-0 `scan_hermes.py --save` during long uptime must not mark baseline or Phase 2 complete.

## Outputs

- Human: stdout summary
- Machine: `state/progress.json`
- Agent must treat `next_step` as the only work queue head
