# Safari tabs, tab groups, Web Apps vs RAM

## Tab groups
- A tab **group** is organizational (sidebar names). Cheap.
- A tab **loaded in memory** costs RAM (often its own `com.apple.WebKit.WebContent` process).
- Measure load, not sidebar count:
  - `pgrep -lf WebKit.WebContent | wc -l`
  - Sum Safari + WebKit RSS
- High WebContent count (dozens–hundreds) ⇒ many tabs truly loaded even if user "only sees groups".

## When a tab costs almost no RAM
- Never opened in this Safari session
- Discarded/unloaded by Safari
- Safari fully quit (list usually restores later; RAM released)

## Safari Web Apps (`Web App.app`)
- Created via Safari "Add to Dock" / File → Add to Dock; live under `~/Applications/`.
- Process: `/System/Library/CoreServices/Web App.app` with `--bundlepath ...`
- **Running** instances: typically tens of MB each (+ page weight).
- **Not running** (only `.app` on disk): disk only, not RAM.
- Do not recommend deleting unused Web App icons to fix RAM pressure.

## User-facing one-liners (DE)
- "Tab-Gruppe = Ordner. Geladene Seite = kostet Speicher."
- "Web-App-Symbol im Ordner = aus. Offene Web-App = an."
