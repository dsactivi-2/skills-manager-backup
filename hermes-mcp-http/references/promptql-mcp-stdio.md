# PromptQL MCP (stdio, v1) — Activi

Repo: `https://github.com/hasura/promptql-mcp` — **unstable, PromptQL v1 only**. Not a skills.sh pack. Do not `npx skills add` it.

HTTP skill owns *how* Hermes stores MCP. This file is the local stdio case (clone + venv), same family as `bhtelecom-mcp`.

## Local install (verified 2026-09-04)

- Clone: `/Users/activi/Code/Tools/promptql-mcp`
- Venv: Homebrew `python3.12` (system `/usr/bin/python3` is 3.9; package wants ≥3.10)
- Pin: `mcp>=0.5.0,<2` in the **server** venv and `setup.py` — `from mcp.server.fastmcp import FastMCP` dies on mcp 2.x (`FastMCP renamed to MCPServer`)
- Hermes: `mcp_servers.promptql` `command` = `.venv/bin/python`, `args` = `[-m, promptql_mcp_server]`
- Secrets file: `~/.promptql-mcp/config.json` mode `600`. Never in `config.yaml`, never in memory, never echo.
- `hermes mcp test promptql`: Connected, 8 tools. In-chat only after `/reload-mcp`.

`--args` on `hermes mcp add` must be the **last** option. `--connect-timeout 60` after `--args` was swallowed into argv. Repair:

```bash
hermes config set mcp_servers.promptql.args '["-m","promptql_mcp_server"]'
hermes config set mcp_servers.promptql.connect_timeout 60
hermes config set mcp_servers.promptql.enabled true
hermes mcp test promptql
```

Connection closed on add: run `.venv/bin/python -m promptql_mcp_server` and read stderr before saving disabled.

## Three secrets — not one

| Field | Env | What | Typical shape |
|---|---|---|---|
| `api_key` | `PROMPTQL_API_KEY` | Chat/API key | `pql_ut_…` |
| `playground_url` | `PROMPTQL_PLAYGROUND_URL` | v1 Playground HTTP API | `https://promptql.<name>.public-ddn.hasura.app/playground` |
| `auth_token` | `PROMPTQL_AUTH_TOKEN` | DDN **data** header | Playground Auth → Headers |
| `auth_mode` | `PROMPTQL_AUTH_MODE` | `public` / `private` | `Auth-Token` vs `x-hasura-ddn-token` |

`PROMPTQL_AUTHORIZATION` / `pat pt_pql_ut_…` is not those three. A lone `pql_ut_…` is only `api_key`. Server starts unconfigured without all three.

## Three UIs — do not mix

| Surface | URL / look | For this MCP |
|---|---|---|
| PromptQL App v2 | `prompt.ql.app/project/<id>/my-board` — Threads, Wiki, Rooms | Not v1 Playground. No Auth button. Board URL ≠ `playground_url`. |
| DDN console | Hasura home, project cards | Data graph. **dsactivi-2 AI**, id `g-251224132`, badge `plg-public`. |
| GraphiQL | `https://data.prompt.ql.app/g-251224132/graphql` | Header `x-hasura-ddn-token` is the DDN token. Path `/graphql` ≠ `playground_url`. |

v1 Playground: left of chat → **Auth** → **Headers** → `Auth-Token` (public) or `x-hasura-ddn-token` (private).

GraphiQL 400 `Header name Authorization not found` + **No Auth Config Found** means GraphQL wants `Authorization`, not that the DDN token is missing.

Do not claim `…/graphql` or `…/my-board` as playground URL. v1 client calls `/threads/v2/…` on `playground_url`.
