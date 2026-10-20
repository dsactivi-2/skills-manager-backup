---
name: macos-local-install-inventory
description: "Use when locating or deleting a named Mac CLI/app install."
---

# macOS local install inventory

## When to Use

- User will wissen, wo ein benanntes CLI/App/Agent lokal liegt
- Inventar vor Uninstall, oder Löschen nur der Pfade aus seiner Liste

Deutsch, kurz: jeder Treffer als Pfad + eine Zeile was es ist. Credentials/auth.json nur nennen, nie Inhalt.

## Procedure — find

1. CLI: `which`/`type`, `brew list`, `pip3 show`, `pipx list`, `npm list -g --depth=0`, `ls ~/.local/bin`.
2. Bundles: `/Applications`, `~/Applications`, `mdfind` on display name and bundle id. Electron-Daten ohne `.app` heißt: App wurde genutzt, Bundle liegt nicht an den üblichen Orten — nicht erfinden.
3. Homes: `~/.<name>`, `~/.config/<name>`, `~/Library/Application Support/<name>` **und** Bindestrich-Varianten (`interpreter` vs `open-interpreter`). Cache: `~/.cache/<name>`, `~/Library/Caches/<name>-updater`. Case-Varianten unter Application Support per `stat` inode vergleichen — gleicher inode = ein Ordner, zwei Schreibweisen, nicht zwei Treffer.
4. Prozesse: `pgrep -lf` auf Home + Binary. LaunchAgents nur wenn der Name matcht.
5. Klassifizieren, nicht zusammenwerfen:
   - laufendes Binary / Symlink auf Release (auch toter `~/.local/bin` Link ins Produkt-Home)
   - aktuelles Produkt-Home (config, sessions, sqlite)
   - Desktop-App Support (Electron Cache/Local State) + Workspace aus `simpleWorkspacePath`/`Documents/<Name>`
   - Reste eines anderen Produkts gleichen Namens (altes `~/.<name>` vs neues `~/.<namezusammengeschrieben>`)
   - Namenskollisionen (cairo-script-interpreter, Hermes `interpreter_shutdown`, UV-Caches)
6. Python-Paket: `importlib.util.find_spec` **und** projektlokale venvs (`*.venv-<name>`, `pip show` darin). Fehlendes globales Paket ≠ leere Support-Ordner und ≠ vorhandenes venv.

## Procedure — delete

1. Exist-check der **exakt genannten** Pfade + laufende Prozesse. Aus einer gepasteten Inventarliste nur absolute Pfade extrahieren, Erklärungstext ignorieren.
2. `rm` nur diese Pfade (Symlink mit `rm -f`, Trees mit `rm -rf`).
3. Wenn der User zusätzlich dazugehörige Reste verlangt: nur Bindungen des genannten Pfads — gleicher Application-Support-inode (andere Großschreibung), `~/Library/Logs/<Name>`, `Saved Application State`, `HTTPStorages` zum Bundle. Nicht Docs/Skripte/ZIPs/Projektordner, die nur den Namen teilen.
4. Nachher: jeder Pfad GONE / STILL; `command -v` für den CLI-Namen.

## Pitfalls

- Ein Produktname kann zwei Installationen sein (Python-venv + Desktop-Home unter `~/.openinterpreter`). Getrennt listen, sonst löscht man die falsche.
- Wenn der User eine Inventarliste zum Löschen schickt **ohne** Rest-Klausel: nur diese absoluten Pfade. Geschwisterreste unberührt, bis sie namentlich drin sind oder er Reste zum genannten Pfad verlangt.
- `mdfind` leer ist kein Beweis gegen `~/.local/bin` oder Application Support — Spotlight indexiert Hidden-Homes oft nicht.
- Nicht `rm` ohne Exist-check: ein bereits weggeworfener Tree als Erfolg zu melden ist falsch; STILL nach `rm` ist der Fehler.
