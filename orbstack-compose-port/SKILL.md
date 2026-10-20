---
name: orbstack-compose-port
description: "Use when porting a localhost stack onto OrbStack."
version: 1.0.0
author: hermes-curator
license: MIT
category: devops
metadata:
  hermes:
    tags: [orbstack, docker, compose, apple-silicon]
    related_skills: [live-stack-verification, verify-first-workflow]
---

# OrbStack Compose Port

Port a Windows/Linux "bind 127.0.0.1" stack onto OrbStack on Apple Silicon. User wants live containers, tables, no GPU-model download unless asked.

## When to Use

- "bau das in OrbStack" / Compose auf dem Mac
- Repo hat viele `127.0.0.1` / `.ps1` / llama.cpp / OpenClaw
- Dual Docker Desktop + OrbStack auf demselben Host

## Analyse before build (activi)

If the user says analyse / Optionen erklären **bevor** du baust: run `github-repo-inventory`, list real compose vs host-Taskfile apps, ports, required keys, then **stop**. No clone/`compose up` until they pick. "Alles" still needs LiveKit/SIP IDs from them — do not invent trunks.

`docker-compose*.yml` that only starts Postgres/Redis is **deps-only**. The product (console/API/worker) often runs on the host via Taskfile. Full OrbStack then means a **custom** multi-compose, not wrapping the upstream file and calling it done.

activi: do not publish a new console/UI on host **:3000** (Dograh). Remap.

Telephony in a SaaS clone (Twilio/Telnyx number-buy) is not FreePBX/Yeastar. User "PBX" → LiveKit SIP trunk IDs they supply; never guess Nebenstellen.

## Steps

1. **Context hart setzen.** Nicht nur `docker context use orbstack`. Jeder Build/Up:
   `docker --context=orbstack …`
   Probe vorher: `docker --context=orbstack info --format '{{.Name}} {{.Architecture}}'`.
   Compose-Bake kann trotz aktivem Context den Desktop-Builder nehmen.
2. **Port-Kollision live.** `docker ps` + `lsof` auf Zielports. Crash-loop (Restarting, Missing config) anderer Compose-Projekte auf 18789/8080 stoppen — nicht `~/.openclaw` anfassen.
3. **Base-Image vor langem Build smoke-testen.**
   `docker --context=orbstack run --rm IMAGE uname -m`
   `inspect`/`pull --platform linux/arm64` reicht nicht. Gesehen: `python:3.12-slim-bookworm` und `debian:bookworm-slim` → `exec format error`; `python:3.12-slim` und `alpine` → `aarch64`.
   Offizielles `nousresearch/hermes-agent`: ENTRYPOINT ist `/init` — CMD `uname` läuft nicht. Smoke: `--entrypoint uname … -m`.
4. **Ein Runtime-Container** für alles, was sich gegenseitig über 127.0.0.1 spricht (supervisord). Offizielle Images (OpenClaw, Qdrant) extra.
4b. **Electron/Desktop-GUI.** Kein natives macOS-Fenster. Ein Container: Xvfb + fluxbox + x11vnc + noVNC (`:6080`), `shm_size: 2gb`, `ELECTRON_DISABLE_SANDBOX=1`. Forge-Flags nach `--` an Electron, nicht an `electron-forge`: `npx electron-forge start -- --no-sandbox --disable-gpu --disable-dev-shm-usage --ozone-platform=x11`. `npm start -- --no-sandbox` → `error: unknown option '--no-sandbox'` und Restart-Loop. Preview-Server der generierten Apps auf 127.0.0.1 im selben Container reichen für die in-app Preview; Host-Publish nur wenn der Mac-Browser sie braucht.
4c. **Module Federation dev remotes.** Wenn der Browser die Remote-Entry-URLs mit `localhost:<port>` lädt, muss jeder Remote-Port auf exakt denselben Host-Port publiziert werden. Ein Container-Port-Remap (z. B. `13004:3004`) bricht die Browser-Auflösung, sofern nicht auch die erzeugten Remote-URLs konfiguriert werden. Ports vorher mit `lsof` prüfen.
5. **Bind-Hosts.** Bind `0.0.0.0` per Env; Headless-Daemon ohne pystray. Host-Dienste (Ollama) via `extra_hosts: host.docker.internal:host-gateway`.
   Auf OrbStack Mac **kein** `network_mode: host` — bridge + `127.0.0.1:<host>:<container>` publish. Mac-Hermes hält schon `:8642`; Klon auf `18642`/`19119`.
   Nach einem Host-Port-Remap CORS und öffentliche API-URL neu setzen. Browser-Origins `localhost`, `127.0.0.1` und OrbStack `*.orb.local:<container-port>` sind verschieden — `FRONTEND_ORIGIN` muss jede Origin enthalten, die der User öffnet. Relative API-Base (`/api`) nur, wenn nichts `new URL(apiUrl)` ohne Base aufruft. Socket.IO-Clients wie Hexabot tun das: `/api` → TypeError → weiße Seite. Dann absolute Origin, identisch zur URL die du dem User nennst. Login erst als erledigt werten, wenn die **Login-Seite im Browser** rendert (nicht nur `/health` oder ein curl mit anderem JSON-Feld).
6. **OpenClaw-Image nicht mit Repo auf `/app` überdecken** — das versteckt `dist/index.js`. Repo nach `/workspace` mounten, `OPENCLAW_WORKSPACE_DIR=/workspace`, Image-WORKDIR lassen.
7. **OpenClaw-Home isolieren** (z.B. `<repo>/.project-openclaw` → `/home/node/.openclaw`). Nie `~/.openclaw` des Users. `gateway.mode=local` + Token. Aktuelles Image (2026.6+): kein `models.providers.*.models[].compat` — Schema reject, Restart-Loop.
8. **GPU-Modelle weglassen, Funktionen ersetzen.** llama-server → OpenAI-Shim auf :8080 gegen Host-Ollama. SoVITS → Edge-TTS. Embeddings → Ollama `all-minilm` (384-d). ComfyUI/Checkpoints/Sakura-GUI/Live2D-Modelle (oft gitignored) ehrlich als Auslassung.
9. **Verify live** (Tabelle Dienst|URL|HTTP). Embed-Proxy: Ollama-Vektoren sind `list`, nicht numpy — kein `.tolist()`.

## Pitfalls

- `docker context use` ≠ Compose/BuildKit benutzt OrbStack.
- Nx Module Federation binds its host and `--devRemotes` servers to `localhost` by default. In OrbStack, use `nx serve <host> --devRemotes=... --host=0.0.0.0` and publish the host plus every remote port; otherwise Docker publishes the ports but host-side requests receive an empty reply.
- Offizielles OpenClaw `command: node dist/index.js` braucht Image-WORKDIR, nicht das Projekt-Root.
- mem0 im Upstream ist **embedded Qdrant-Pfad**, kein Qdrant-Server.
- QQ/Telegram ohne Token disabled lassen.
- `engine-strict=true` in `.npmrc` → npm-Version exakt wie `engines.npm` im Image (`npm i -g npm@…`), sonst bricht `npm ci`/`npm install` ab.
- Fork mit umbenanntem Scope (`@openlovable-sh/…`) kann auf npm 404 sein, während das Original (`@dyad-sh/…`) existiert. Alias: `"pkg": "npm:@original/pkg@version"`. `npm ci` gegen einen Lock mit 404-`resolved`-URL schlägt fehl — dann `npm install` ohne diese Lock-Zeile.
- `node:20-bookworm` auf OrbStack ARM: `uname -m` → `aarch64` (smoke-testen trotzdem; `debian:bookworm-slim` bleibt verdächtig).
- Hermes-Klon: nie `~/.hermes` mounten. Isoliertes `./data`, Messaging-Tokens strippen. Rezept: skill `hermes-vps-profile-port` → `references/orbstack-docker-clone.md`.
- GitHub-Repo ohne Root-`SKILL.md` (z.B. `NousResearch/hermes-agent-self-evolution`) ist kein Skill-Pack. CLI-Optimizer: `docker-compose.prod.yml`, kein Port, `sleep infinity` + `docker exec`. Rezept: `references/hermes-self-evolution-orbstack.md`.
- `pgvector/pgvector:pg16` kann auf OrbStack `linux/arm64` gelabelt sein und trotzdem `exec format error` liefern. Immer `docker --context=orbstack run --rm --entrypoint uname IMAGE -m` smoke-testen. Verifiziert lauffähig: `0.8.6-pg16-trixie`, `0.8.1-pg16`, `pg16-trixie`.
- **Container im falschen Docker-Netzwerk** führt zu `getaddrinfo failed: Name or service not known` beim Datenbank-Connect. Prüfen: `docker inspect CONTAINER --format '{{json .NetworkSettings.Networks}}'`. Wenn der DB-Container nur in `bridge` und der App-Container nur im Compose-`network` hängt, kann PHP den Hostnamen nicht auflösen. Fix: `docker network connect <compose_network> <db_container>` — oder den DB-Container korrekt über `docker-compose.yml` starten lassen, statt manuell mit `docker run`.
- **MySQL 8.0 `caching_sha2_password`** wird von älteren PHP-PDO-Clients nicht verstanden (Fehler: `The server requested authentication method unknown to the client`). Fix ohne Neustart: `ALTER USER 'root'@'%' IDENTIFIED WITH mysql_native_password BY '<password>'; FLUSH PRIVILEGES;` — oder gleich in der Compose `command:` `--default-authentication-plugin=mysql_native_password` setzen.
- Verify-Tabelle: CLI-only Stacks haben kein `/health`. Dann Dienst|Check|Ergebnis, nicht URL|HTTP.
- Hexabot v3: Admin/API teilen einen Port — nicht Host `:3000` (Dograh). Login-JSON ist `{identifier,password}` (`email` allein → 401); Sign-In-UI ist das Seed `admin@admin.admin` / `adminadmin`, nicht pgAdmin. `API_ORIGIN` absolut (`http://localhost:<hostport>/api`); relativ `/api` crasht die UI (`new URL(apiUrl)` für Socket.IO → weiße Seite). `FRONTEND_ORIGIN` für `localhost`, `127.0.0.1` und `hexabot-api-1.hexabot.orb.local:3000`. Hermes-MCP und Doku-`localhost:3000/api/mcp` sind der Container-PORT — vom Mac nur das publizierte Mapping (`docker ps`: `127.0.0.1:43000->3000`). Keine erfundenen `*.orb.local`/`:3000`-MCP-URLs ancurlern. Integrations→MCP-Servers ist Hexabot-als-Client, nicht `/api/mcp`. Host-CLI: `~/.local/bin/node` ist Hermes 22 — nicht ersetzen. Wrapper + nvm 24.17 in PATH *im Wrapper*, sonst `execSync('node --version')` und `#!/usr/bin/env node` sehen 22. Host-`package.json` ≠ laufendes Image: nach npm-Paketen `compose up --build` und in den API-Logs `Action`/`Helper`/`Channel` prüfen. `postgres.dev` publiziert Host-5432 auf `0.0.0.0` — Overlay `127.0.0.1`. Redis/Postgres recreaten → API `SocketClosedUnexpectedlyError`; API restarten und healthy abwarten. pgAdmin 9.17 + `MASTER_PASSWORD_REQUIRED=False` + `servers.json`/`pgpass` + Volume; Master-Password-Dialog ist nicht Postgres — Cancel sperrt. Image-Pins, Collation, Community/Pro, Credentials, Hermes-MCP, Ollama-Binding: `references/hexabot-orbstack.md`.
- `npx eve init` / pnpm in einem Nested-Projekt wandert nach oben bis `~/pnpm-workspace.yaml` (Home ist config-only Workspace). Im Projekt `packages: ['.']` setzen. Wenn init `engines.node: 24.x` in `~/package.json` schreibt: zurücknehmen.
- vercel/eve: `packages/eve/Dockerfile` ist **Sandbox-Basis**, nicht der Agent. Monorepo nicht clonen, um Eve zu betreiben. Rezept: `references/eve-orbstack.md`.
- Better Auth / Paperclip: `localhost` und `127.0.0.1` sind verschiedene Origins. Setze `PAPERCLIP_PUBLIC_URL`, `PAPERCLIP_AUTH_PUBLIC_BASE_URL`, `PAPERCLIP_ALLOWED_HOSTNAMES` und `BETTER_AUTH_TRUSTED_ORIGINS` auf **dieselbe** URL, die der Browser öffnet — sonst `Invalid origin` (403), dann gemeinsamer Rate-Limit-Bucket ohne Client-IP → 429 Too many requests. Auth-Signup nie mit einem echten POST probe-testen: der erste erfolgreiche Sign-up beansprucht den Instance-Admin. Rezept: `references/paperclip-orbstack.md`.

## Verify

```
docker --context=orbstack ps --filter name=<project>
curl -sS -o /dev/null -w '%{http_code}\n' http://127.0.0.1:<port>/health
```

## References

- `references/artemis-cpu-stack.md` — momori777/Artemis CPU-Port (Ports, Isolation, Fallbacks)
- `references/open-laudable-electron.md` — Electron/noVNC-Port (Open-Laudable, Forge-Flags, npm-Alias)
- `references/quickvoice-orbstack.md` — allgpt-co/QuickVoice: deps-only compose, ports, voice catalog, PBX gap
- Hermes ohne Memory: `hermes-vps-profile-port` / `references/orbstack-docker-clone.md` (offizielles Image, isoliertes `/opt/data`, Ports 18642/19119)
- `references/eve-orbstack.md` — vercel/eve auf OrbStack (npm-Paket, Ports, `.eve` Volume, Health)
- `references/hexabot-orbstack.md` — Hexabot v3 Starter auf OrbStack (Compose-Overlays, Port 43000, CORS/`API_ORIGIN`, Seed-Login)
- `references/hermes-self-evolution-orbstack.md` — NousResearch CLI-Optimizer (kein Skill, kein Port, dry-run vor GEPA)
- `references/paperclip-orbstack.md` — Paperclip GHCR-Image auf OrbStack (Port 3100, Better Auth Origins, kein Signup-Probe)
