# Defang sample on OrbStack

Verified 2026-08-20 with Defang CLI 3.13.0 + sample `agentic-langgraph`.

## CLI install (Homebrew formula is stale)

`brew install DefangLabs/defang/defang` builds from source with `depends_on "go@1.24"`. Sample `src/go.mod` requires `go >= 1.25.5`, so the tap build fails with `GOTOOLCHAIN=local`.

Working path:

1. `brew upgrade go` (need current `go`, not `go@1.24`).
2. Patch tap formula `depends_on "go@1.24"` → `depends_on "go"` in `/opt/homebrew/Library/Taps/defanglabs/homebrew-defang/Formula/defang.rb`.
3. `brew install defanglabs/defang/defang`.
4. If `~/.local/bin/defang` exists from the official zip, it shadows `/opt/homebrew/bin/defang` (PATH puts `~/.local/bin` first). Remove the local copy after brew succeeds.

`brew update` can revert the tap formula. Fallback: official macOS zip from GitHub releases + SHA-256 from `defang_*_checksums.txt`.

`defang new` = `defang init`. Sample lands as files only — no login, no deploy. Put it under `~/Code/Projects/<sample>`.

## MCP

`defang mcp setup --client=cursor|vscode|claude-code` writes `defang mcp serve --client=<name>`. Hermes is not a `--client`. Codex already has a `mcp_servers.defang` block — do not rewrite `~/.codex/config.toml` as SoT. Cursor.app may be missing even when `~/.cursor/mcp.json` exists.

## Local OrbStack run (agentic-langgraph)

Upstream `compose.yaml` publishes host `3000` + `80` and starts `defangio/openai-access-gateway`. `compose.dev.yaml` bind-mounts `./app:/app` (hides image `node_modules`) and AWS creds onto `llm`.

Do not take occupied 3000 from another healthy stack. Overlay `compose.orbstack.yaml`:

- `ports: !override ["3001:3000"]`
- `platform: linux/arm64`
- `LLM_URL: http://host.docker.internal:11434/v1/`
- `LLM_MODEL`: a **local** Ollama tag (`:cloud` needs extra auth). Live: `huihui_ai/gemma-4-abliterated:latest`
- `OPENAI_API_KEY: ollama` (library wants a non-empty key)
- `extra_hosts: ["host.docker.internal:host-gateway"]`
- `depends_on: !override []` and give `llm` `profiles: [cloud-llm]` so the gateway stays off
- `volumes: !override []` so the image `node_modules` stays

Dockerfile: `FROM node:22-alpine` + `apk add --no-cache curl`. `node:22-bookworm-slim` / `node:22-slim` → `exec format error` on this OrbStack.

`package.json`: `ts-node` needs `typescript` in dependencies; start with `--transpile-only`.

`TavilySearch` throws at import if `TAVILY_API_KEY` is empty — app never listens. Construct the tool only when the env is set; chat still works without search.

Up:

```
DOCKER_HOST=unix://$HOME/.orbstack/run/docker.sock COMPOSE_BAKE=0 \
  docker --context=orbstack compose -p agentic-langgraph \
  -f compose.yaml -f compose.dev.yaml -f compose.orbstack.yaml up --build -d
```

Verify: `curl` UI on `http://127.0.0.1:3001` (200) and `POST /agent` `{"input":"…"}`.

What the sample actually does: one-shot chat (`POST /agent`, no history), optional Tavily (max 3 hits). No login, files, or email.

Cloud (`defang compose up`) still needs `defang login` + `defang config set TAVILY_API_KEY`.
