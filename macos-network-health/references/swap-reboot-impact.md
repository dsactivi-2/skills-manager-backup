# Freeing swap + restart impact

## How to clear swap
1. Quit heavy apps (browsers, idle local AI, extra Hermes sessions).
2. **Reboot macOS.**
3. There is no supported "delete swap only, keep all processes" button.

Do **not**: manually delete swapfiles, install RAM "cleaner" apps, purge for show.

## What swap is (plain DE)
- RAM = schneller Tisch (z.B. 48 GB).
- Swap = Notlager auf SSD wenn zu viel gleichzeitig.
- Inhalt = Speicher**seiten** von Prozessen (Tabs, Heaps, Caches) — keine Liste "Film.mp4 liegt im Swap".
- Always report: `sysctl vm.swapusage`, compressor pages, swapins/swapouts if extreme.

## Pre-reboot live checklist (run before advising reboot)
```bash
# Editors / docs
ps -Ao args= | egrep -i 'BBEdit|TextEdit|Pages|Word|Code|Obsidian|One Markdown|NotePad|wpsoffice'
lsof -nP -u "$USER" 2>/dev/null | egrep '\.docx|\.md|\.txt|\.pages|\.pdf' | head
# Chats / AI
ps -Ao args= | egrep -i 'Telegram|Slack|Claude|ChatGPT|Codex|Hermes|Gemini|Mail'
# Terminals / SSH
ps -Ao args= | egrep -i 'Terminal|Tabby|Termius|iTerm|ssh |tmux'
# Hermes sessions
pgrep -lf 'hermes-agent/venv/bin/hermes|gateway run'
osascript -e 'tell application "System Events" to get name of (every process whose background only is false)'
```

## Loss matrix
| Category | Lost on reboot? | Notes |
|---|---|---|
| Unsaved editor buffers | **Yes** | Save first (e.g. BBEdit open files) |
| Chat **windows** | Yes (UI) | Server/cloud history usually kept |
| Chat **draft** in input box | Often yes | |
| In-flight AI generation / agent run | **Yes** (aborts) | History may remain on disk/cloud |
| Terminal scrollback / running commands | **Yes** | Finish or note jobs |
| SSH sessions | **Yes** disconnected | |
| Files already on disk | No | |
| Installed apps, Hermes skills/config/profiles | No | |
| Safari tab **lists**/groups | Usually restore | Loaded page state/forms may reset |
| VPN/login items | Restart with OS | |

## After reboot verify
`sysctl vm.swapusage` (used near 0), Safari WebContent count, Hermes node/Hivemind process count, load averages.
