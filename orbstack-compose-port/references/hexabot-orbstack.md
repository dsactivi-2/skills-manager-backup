# Hexabot v3 on OrbStack

Official path is the CLI starter, not the Hexabot monorepo `docker/` tree. Host Node 22 fails `engines.node ^24.17.0` — run the app in Compose.

## Layout

Clone `hexabot-ai/hexabot-template-starter` (do not invent a custom Dockerfile). From the project root:

```
docker --context=orbstack compose --env-file .env.docker \
  -f docker/docker-compose.yml \
  -f docker/docker-compose.dev.yml \
  -f docker/docker-compose.postgres.yml \
  -f docker/docker-compose.redis.yml \
  -f docker/docker-compose.orbstack.yml \
  up --build -d
```

Keep `docker-compose.dev.yml`: `SEED_ADMIN_*` runs only when `NODE_ENV` is not production. Overlay `postgres.dev` only if you want pgAdmin.

## Overlay (OrbStack)

- Publish API as `127.0.0.1:${API_PORT:-43000}:3000` — never host `:3000` (Dograh).
- Pin images in `docker-compose.orbstack.yml`, not upstream compose. Smoked aarch64: Postgres `pgvector/pgvector:0.8.6-pg16-trixie` (not bare `pg16`), Redis `redis/redis-stack-server:7.2.0-v20` (stay on 7.2, not 7.4), pgAdmin `dpage/pgadmin4:9.17` (upstream `postgres.dev` still has 8.9). Do not bump Node off `24.17` or Postgres off 16.
- `extra_hosts: host.docker.internal:host-gateway` for host Ollama. Coding agent: `~/.orbstack/run/docker.sock` → `/var/run/docker.sock`.

## Env that makes the UI work

Copy `.env.docker.example` → `.env.docker`, then:

- `API_PORT=43000`
- `API_ORIGIN=http://localhost:43000/api` — must be absolute. Relativ `/api` wirft in der SPA `new URL(apiUrl)` (Socket.IO) TypeError → weiße Seite trotz 200 auf HTML/JS/CSS und `/api/health`.
- `FRONTEND_ORIGIN` includes `http://localhost:43000`, `http://127.0.0.1:43000`, and `http://hexabot-api-1.hexabot.orb.local:3000`
- Recreate the **api** container after changing these; health 200 on an old process is stale config.

Default seed (dev overlay): identifier `admin@admin.admin`, password `adminadmin`.

Verify:

```
curl -sS http://localhost:43000/api/health
curl -sS http://localhost:43000/api/config   # apiUrl must be http://localhost:43000/api
node -e 'new URL("/api")'                   # must throw; do not ship that as API_ORIGIN
curl -sS -X POST http://localhost:43000/api/auth/local \
  -H 'Content-Type: application/json' \
  -d '{"identifier":"admin@admin.admin","password":"adminadmin"}'
```

Tell the user `http://localhost:43000/login` (hard-refresh after env change). Do not send them to `:3000` or treat email-only curl as UI proof.

## Host CLI (3.5+)

`@hexabot-ai/cli@3.5` requires Node `>=24.17.0`. Do not replace `~/.local/bin/node` (Hermes 22).

1. `nvm install 24.17.0` — keep nvm default on 22.
2. Install the CLI *with that node binary*, not PATH npm:
   `/Users/activi/.nvm/versions/node/v24.17.0/bin/node /Users/activi/.nvm/versions/node/v24.17.0/lib/node_modules/npm/bin/npm-cli.js install -g @hexabot-ai/cli`
3. nvm shims are `#!/usr/bin/env node` and the CLI checks version via `execSync('node --version')`, not `process.version`. PATH Node 22 still fails. Wrappers must prepend nvm 24.17 `bin` and `exec` that `node` onto `.../lib/node_modules/@hexabot-ai/cli/dist/index.js`.
4. Replace `~/.local/bin/hexabot` with that wrapper. Replace `~/.local/bin/npx` only as a dispatcher: if any arg matches `@hexabot-ai/cli` / `@hexabot-ai/cli@*`, run the same wrapper (strip `--yes`); else `exec /Users/activi/.hermes/node/bin/npx`. **rm the npx symlink first** — writing through it overwrites Hermes npx.
5. Do not `npm uninstall -g @hexabot-ai/cli` under Node 22 — prefix is `~/.local` and it deletes the hexabot shim. Remove only `~/.local/lib/node_modules/@hexabot-ai/cli`.

Verify: `hexabot --version` and `npx @hexabot-ai/cli --version` both print `CLI v3.5.0` with exit 0 and no “Current version: v22” line; `node -v` stays Hermes 22; `npx --version` stays Hermes npx.

Do **not** `exec` nvm’s `bin/npx` from the dispatcher — that file is also `#!/usr/bin/env node` and still runs Hermes 22. Always `exec` the nvm 24.17 `node` binary onto the CLI `dist/index.js`.

## App packages vs running stack

Host `package.json` can list extras while the **image** was built earlier. After adding `hexabot-helper-pgvector`, `hexabot-helper-sqlite-vector`, `hexabot-channel-openai-compatible`, or `hexabot-action-ai-coding-agent`, rebuild (`compose up --build`) and confirm in the **container**:

- `docker exec … node -e` on `./package.json` lists the packages
- logs: `Helper "pgvector"`, `Action "ai_coding_agent"`, `OpenAiChannelHandler` routes

`sqlite-vector` stays inactive when `DB_TYPE=postgres` — installed ≠ registered. Enable `CREATE EXTENSION vector` on the pgvector image.

`hexabot-channel-openai-compatible` is **inbound** (clients call Hexabot as an OpenAI API). It does not wire Hexabot’s LLM to host Ollama. LLM keys: UI `/credentials` or a workflow AI action → model binding. Ollama provider `openai-compatible`, base `http://host.docker.internal:11434/v1`, dummy key, model from `ollama list`. pgvector helper defaults to OpenAI embeddings — empty key means RAG is not live. Coding agent is two things: workflow action `ai_coding_agent` (harness credential Codex/Claude/Grok/OpenCode; Ollama is not enough) vs MCP from `/profile` so Cursor/Codex/Hermes talk *to* Hexabot at `/api/mcp`.

## Hermes MCP and Ollama (do not invent URLs)

Two different MCP objects — never mix them:

1. **Hexabot as MCP server** — `POST /api/mcp`. This is what Hermes/Cursor connect to. Token: UI `/profile` or `POST /api/mcp-token` (CSRF header `X-CSRF-Token`). Without Bearer: 401 `MCP bearer token is required`.
2. **Hexabot as MCP client** — Integrations → MCP Servers (`/api/mcpserver`). Empty list means no *outbound* servers, not that `/api/mcp` is wrong.

Host vs container port: the API process listens `PORT=3000` inside the container. OrbStack publishes `127.0.0.1:${API_PORT:-43000}:3000`. Official coding-agent docs use `http://localhost:3000/api/mcp` only when host port equals 3000. From the Mac, read `docker ps --filter name=hexabot-api` and use the **published** host port. Do not curl guessed `*.orb.local` MCP hosts or host `:3000/api/mcp` after the remap — those names often do not resolve, and `:3000` on the Mac is not Hexabot.

Hermes (token never in chat unless the user asks):

```
hermes config set mcp_servers.hexabot.url "http://localhost:43000/api/mcp"
hermes config set mcp_servers.hexabot.enabled true
hermes config set mcp_servers.hexabot.headers.Authorization "Bearer $TOKEN"
hermes mcp test hexabot   # expect HTTP → localhost:43000/api/mcp, ~41 tools
```

Then one real tool call (`hexabot_workflow_search`). `hermes mcp test` green ≠ tools in the current chat until `/reload-mcp` or a new session. `/api/config` `mcpEnabled` is not a connection proof.

Ollama is not an MCP server and Hexabot has no `ollama` provider. Do not `hexabot_mcp_server_create` against `:11434`. Wire LLM through a **model binding** (`hexabot_binding_get` kind `model`):

1. From the API container, `GET http://host.docker.internal:11434/v1/models` must be 200 and list the intended model.
2. Confirm `@ai-sdk/openai-compatible` exists in the **image** `node_modules`.
3. MCP credentials are search/get only — no create. Reuse an existing credential UUID (`api_key` in YAML). Ollama accepts any Bearer.
4. `hexabot_workflow_yaml_validate`, then `hexabot_workflow_create` / `yaml_commit`. Do not publish unless asked.

```yaml
defs:
  ollama_gemma:
    kind: model
    settings:
      provider: openai-compatible
      model_id: <name from ollama list>
      api_key: <credential-uuid>
      base_url: http://host.docker.internal:11434/v1
      supports_structured_outputs: false
  reply:
    kind: task
    action: ai_generate_reply
    inputs:
      input_mode: prompt
      prompt: "=$input.text"
    bindings:
      model: ollama_gemma
flow:
  - do: reply
```

`docker-compose.postgres.dev.yml` publishes Postgres `5432:5432` on all interfaces. Overlay: `127.0.0.1:15432:5432`. pgAdmin: `127.0.0.1:19000`, image `dpage/pgadmin4:9.17`, `PGADMIN_CONFIG_MASTER_PASSWORD_REQUIRED: "False"` (Python `False`). The Master Password dialog is pgAdmin's vault, not Postgres — Cancel leaves saved passwords locked. Persist `pgadmin-data` plus `docker/pgadmin/servers.json` (Host `postgres`, Port `5432`, user/db `hexabot`) and gitignored `pgpass` mounted at `/pgpass`. First boot log: `Added 1 Server(s).` Hexabot Sign-In is seed `admin@admin.admin` / `adminadmin` (UI label Email, API field `identifier`) — never pgAdmin's `PGADMIN_DEFAULT_*`.

After recreating Redis or Postgres, restart the **api** container. A live API hits Redis `SocketClosedUnexpectedlyError` (unhandled) and goes unhealthy / empty-reply on `:43000`.

After swapping the pgvector Debian base on an existing PG16 volume (glibc collation 2.36 → 2.41):

```
ALTER EXTENSION vector UPDATE;
ALTER DATABASE hexabot REFRESH COLLATION VERSION;
```

Keep Postgres **16**. Do not jump major.

## Completeness

Do not invent a Hexabot license key. Logs `No license key set (bootstrap)` + empty `/api/credential` means commercial features and LLM/harness are **not** done. If asked ja/nein “alles vollständig”: **Nein** until license (from the user) and at least one credential exist — health 200 and login 201 are not enough.

Community vs Pro is the **same** starter+`@hexabot-ai/api` with a key. Extra UI gates (not extra engine): `/users` admin accounts and Inbox **assign conversation** (human takeover of a bot thread — not sales conversion). Quotas: Community 1 user / 10 workflows. SSO/RBAC is Enterprise. Explain Inbox assign in that language when the user does not know Hexabot.
