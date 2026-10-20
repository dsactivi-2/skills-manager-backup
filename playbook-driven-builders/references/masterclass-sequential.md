# Masterclass sequential ingest

Live project: `/Users/activi/Code/Projects/hermes-meta-builder`

## Chain

`catalog.yaml` → `chain: [m01…m10]`. Next allowed module: `python3 scripts/next_module.py`.

Per module (same as m01):

```
sources/masterclass/m0N/WISSEN.md
sources/masterclass/m0N/CHECKLIST.md
playbooks/m0N-<kurz>.yaml
```

Then set catalog `status: ingested` + `wissen` + `playbook`. Update `INDEX.md`, `STATE.md`, `HANDOFF.md`.

## Playlist facts (re-check with yt-dlp --flat-playlist)

- Tonbi finale: 10 modules.
- Playlist may list 11 videos = Quickstart + modules 2–10 + July-updated module 1.
- Original module 1 (`R3YOGfTBcQg`) can remain on YouTube but leave the playlist.

## What “module 1 done” is not

Transcript + kurz + table alone ≠ ingested. Ingested = WISSEN + playbook + catalog flag. Do not claim video 1 is “fully implemented” on the user’s Mac (no reinstall, no OpenRouter/Tavily attach).
