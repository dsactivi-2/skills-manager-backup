# Open-Laudable (Electron) on OrbStack

Repo: `https://github.com/ishandutta2007/Open-Laudable` (Dyad/OpenLovable-Fork, `openlovable@0.36.0`). Clone: `~/Code/Projects/Open-Laudable` — nicht in ein anderes Agent-CWD.

Compose: `docker --context=orbstack compose -f docker-compose.orbstack.yaml up -d --build`
Image: `open-laudable:orbstack`. GUI: noVNC, nicht natives Fenster.

## URLs (live-verifiziert)

- noVNC: `http://127.0.0.1:6080/vnc.html?autoconnect=1&resize=scale` (auch `http://open-laudable.orb.local:6080/…`)
- Preview-Apps intern: `32100 + (appId % 10000)` (`shared/ports.ts`). Compose published `32100-32110`.
- Host-Ollama: `OLLAMA_HOST=http://host.docker.internal:11434` + `extra_hosts: host.docker.internal:host-gateway`

## Image

- Base: `node:20-bookworm` (ARM smoke: `uname -m` → `aarch64`). `.npmrc` hat `engine-strict=true` → `npm i -g npm@11.8.0`.
- Native: `better-sqlite3` im Linux-Image bauen, Host-`node_modules` nicht mounten.
- Volumes: `/root/.config/openlovable` (Electron userData) und `/app/userData` (sqlite.db). `shm_size: 2gb`.
- Stack im Container: Xvfb `:99` 1920x1080, fluxbox, x11vnc `:5900`, websockify/noVNC `:6080`.

## electron-forge

Falsch: `npm start -- --no-sandbox` → Forge sieht `--no-sandbox` als eigene Option, Exit 1, Restart-Loop.
Richtig: `npx electron-forge start -- --no-sandbox --disable-gpu --disable-dev-shm-usage --ozone-platform=x11`
plus `ELECTRON_EXTRA_LAUNCH_ARGS` / `ELECTRON_DISABLE_SANDBOX=1`.

## npm 404 des Forks

`@openlovable-sh/supabase-management-js@v1.0.1` ist auf registry 404. Original: `@dyad-sh/supabase-management-js@1.0.1`.
In `package.json`: `"@openlovable-sh/supabase-management-js": "npm:@dyad-sh/supabase-management-js@1.0.1"`.
Lockfile mit 404-`resolved` nicht mit `npm ci` verwenden.

## Nicht fatal / ehrlich weglassen

- dbus `system_bus_socket` fehlt ohne `dbus`-Paket — Electron startet trotzdem.
- Cloud-Keys (OpenAI/Anthropic/Google) optional; lokal reicht Host-Ollama.
- Apple-Notarization N/A im Linux-Container.
- pnpm für generierte Apps: `corepack enable && corepack prepare pnpm@10 --activate`.
