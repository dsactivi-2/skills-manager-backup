# Session start prompts

## User → new Hermes session (preferred)

Open and paste **entire** file:

```text
/Users/activi/Downloads/Mac-Hygiene-START-PROMPT.txt
```

Same content:

```text
/Users/activi/Code/Tools/mac-hygiene/START_PROMPT.txt
```

That prompt orders: read `AGENTS.md` → `cd` project → `python3 scripts/verify_progress.py` → show next_step only → no kill without approval.

## Minimal fallback if file unavailable

```text
Mac-Hygiene weiterbauen.
1) Lies /Users/activi/Code/Tools/mac-hygiene/AGENTS.md
2) cd /Users/activi/Code/Tools/mac-hygiene
3) python3 scripts/verify_progress.py
4) Zeig next_step + open required + live hermes/swap
5) Nur next_step. Nichts killen/löschen ohne Freigabe in diesem Chat.
```

## Manual marks (after user confirms the real-world step)

```bash
cd /Users/activi/Code/Tools/mac-hygiene
python3 scripts/verify_progress.py --mark phase0_docs_saved
python3 scripts/verify_progress.py --mark phase0_browser_trimmed
python3 scripts/verify_progress.py --mark phase0_ai_apps_trimmed
python3 scripts/verify_progress.py --mark phase0_hermes_trimmed
python3 scripts/verify_progress.py --mark phase0_login_items_reviewed
python3 scripts/verify_progress.py --mark phase0_reboot_done
# after reboot mark, capture baseline:
python3 scripts/scan_hermes.py --save
python3 scripts/verify_progress.py
```

IDs must exist in `state/checklist.json`.
