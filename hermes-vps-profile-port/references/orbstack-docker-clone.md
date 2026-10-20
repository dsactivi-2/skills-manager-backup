# Mac default → OrbStack Docker (ohne Memory)

Verified 2026-09-01 on OrbStack aarch64 with `nousresearch/hermes-agent:latest` (image 0.21.0 vs Mac git 0.20.6 — version skew is expected; do not rsync the Mac venv).

Live tree: `/Users/activi/Code/Projects/hermes-orbstack`
- compose: `docker-compose.orbstack.yml`
- volume: `./data` → `/opt/data` (never `~/.hermes`)
- secrets: `.credentials` (API_SERVER_KEY, dashboard basic auth)

## Do not

- `hermes profile export` (packs memory/sessions)
- Mount Mac `~/.hermes` (two writers)
- `network_mode: host` on OrbStack Mac (use bridge + published ports)
- Reuse Mac `:8642` / `:9119` — Mac gateway already owns 8642
- Copy `TELEGRAM_*` / Discord / Slack tokens
- Copy `honcho.json`, `memories/`, `sessions/`, `state.db*`, cron jobs, sibling `profiles/`

## Overlay allow-list

In: `config.yaml`, `SOUL.md`, `AGENTS.md` if present, `skills/`, `hooks/`, `plugins/`, `mcp-tokens/`, `auth.json`, sanitized `.env`.
Out: memory files, Honcho, sessions, logs, cron, profiles, `hermes-agent/` source.

Then in the copy:
- `memory.memory_enabled: false`, `user_profile_enabled: false`, `provider: ''`
- `hermes memory off` inside the container after first boot
- blank `hooks:` (Mac hivemind node paths)
- disable MCP with Mac paths: `hivemind`, `bhtelecom`, `kimi-cu`
- rewrite `127.0.0.1` MCP/custom_providers → `host.docker.internal`
- strip `HONCHO_*`, `TELEGRAM_*`, `AGENT_BROWSER_EXECUTABLE_PATH` from `.env`
- new `API_SERVER_KEY`; `API_SERVER_ENABLED=true`, `API_SERVER_HOST=0.0.0.0`

## Compose shape

```yaml
# docker-compose.orbstack.yml — template, not a shared ~/.hermes mount
services:
  hermes:
    image: nousresearch/hermes-agent:latest
    platform: linux/arm64
    container_name: hermes-orbstack
    command: ["gateway", "run"]
    extra_hosts:
      - "host.docker.internal:host-gateway"
    ports:
      - "127.0.0.1:18642:8642"
      - "127.0.0.1:19119:9119"
    volumes:
      - ./data:/opt/data
    environment:
      HERMES_DASHBOARD: "1"
      HERMES_DASHBOARD_HOST: "0.0.0.0"
      HERMES_DASHBOARD_BASIC_AUTH_USERNAME: ${DASHBOARD_USER}
      HERMES_DASHBOARD_BASIC_AUTH_PASSWORD: ${DASHBOARD_PASSWORD}
      HERMES_DASHBOARD_BASIC_AUTH_SECRET: ${DASHBOARD_SECRET}
      API_SERVER_ENABLED: "true"
      API_SERVER_HOST: "0.0.0.0"
      API_SERVER_KEY: ${API_SERVER_KEY}
```

Every docker call: `docker --context=orbstack …`.
Image smoke: `docker --context=orbstack run --rm --entrypoint uname --platform linux/arm64 nousresearch/hermes-agent:latest -m` → `aarch64`.
Do **not** pass `uname` as CMD — image ENTRYPOINT is `/init`.

Dashboard non-loopback bind requires an auth provider; `HERMES_DASHBOARD_INSECURE` is a no-op. Form login at `/login`, not HTTP Basic on `/`.

## Verify

| Check | Expect |
|---|---|
| `curl -sS http://127.0.0.1:18642/health` | 200, `hermes-agent` |
| `/v1/models` with Bearer | 200; without | 401 |
| `hermes memory status` in container | injection/profile/tool disabled |
| `env \| grep TELEGRAM_` | none |
| `lsof -nP -iTCP:8642` | still Mac python, not the container |
| `hermes chat -q …` | live model reply |
