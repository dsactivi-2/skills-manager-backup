# HITL approve protocol

## Report row shape
Each finding gets a stable ID for the report revision:
- Process: `P1`, `P2`, …
- Disk: `D1`, `D2`, …
- Structure: `S1`, `S2`, …

Fields per row: id, kind, summary, evidence (pid/cmdline/path, rss or size, age), risk (low/med/high), suggested action, default_in_safe (bool).

Save: `~/Logs/mac-hygiene/reports/<ts>_<module>.json` + `.md`

## User commands (chat)
```text
hygiene latest
hygiene approve safe          # only risk=low and default_in_safe
hygiene approve P2 P5 D1
hygiene skip
hygiene apply status
```

## Apply rules
1. Load the **latest** report revision referenced by the approve message.
2. For each ID: **recheck** live state still matches fingerprint.
3. Process: signal/kill **session parent tree** (hermes PID), never orphan-kill only watchdog child expecting permanence.
4. Disk: move to Trash (`trash` CLI or `~/.Trash`), log original path.
5. Structure: only approved safe moves (e.g. into `~/Archive/...`) — never surprise `~/Code` reshuffles.
6. Append apply log: who/when/ids/results/skips.

## Non-goals for approve safe
High-risk kills (gateway), bulk Downloads wipe, anything under denylist paths.
