# Official GitHub MCP (docs + repo, live 2026-08)

Authoritative product: **one** server, `github/github-mcp-server`. Not many official GitHub MCPs.

| Surface | What it is | Use |
|---|---|---|
| Remote | Hosted `https://api.githubcopilot.com/mcp/` | Default. OAuth or PAT. Extra toolsets only here. |
| Local | Docker `ghcr.io/github/github-mcp-server` or binary | Custom/security, **GHES (remote hosting unsupported)** |
| MCP Registry | https://github.com/mcp (public preview) | Partner/community catalog — not the GitHub API server |
| Copilot built-in | Copilot CLI / Cloud Agent / Code Review | Often prewired. Cloud Agent default token = read-only current repo |

Docs (GitHub Docs, Copilot section):

- Concept: https://docs.github.com/en/copilot/concepts/context/mcp
- Setup: https://docs.github.com/en/copilot/how-tos/provide-context/use-mcp-in-your-ide/set-up-the-github-mcp-server
- Use: https://docs.github.com/en/copilot/how-tos/provide-context/use-mcp-in-your-ide/use-the-github-mcp-server
- Toolsets: https://docs.github.com/en/copilot/how-tos/provide-context/use-mcp-in-your-ide/configure-toolsets
- Enterprise: https://docs.github.com/en/copilot/how-tos/provide-context/use-mcp-in-your-ide/enterprise-configuration
- Repo MCP for Cloud Agent: https://docs.github.com/en/copilot/how-tos/copilot-on-github/customize-copilot/configure-mcp-servers
- Secret scan (remote only): https://docs.github.com/en/code-security/how-tos/use-ghas-with-ai-coding-agents/scan-for-secrets-with-github-mcp-server

Toolset list and headers: repo README + `docs/remote-server.md` (Docs defer here).

## Default vs extra

Default when unspecified (repo): `context`, `repos`, `issues`, `pull_requests`, `users`. Docs page sometimes lists only repos/issues/PRs — **trust the repo**.

Keywords: `default`, `all`. Combine: `default,stargazers`.

Also: `actions`, `code_quality`, `code_security`, `copilot`, `copilot_issue_intents`, `dependabot`, `discussions`, `gists`, `git`, `labels`, `notifications`, `orgs`, `projects`, `secret_protection`, `security_advisories`, `stargazers`.

**Remote-only:** `copilot_spaces`, `github_support_docs_search`. Secret-scanning MCP tools: remote only.

GHE Cloud data residency remote URL: `https://copilot-api.SUBDOMAIN.ghe.com/mcp`.

## Connect (remote)

OAuth (recommended):

```json
{ "servers": { "github": { "type": "http", "url": "https://api.githubcopilot.com/mcp/" } } }
```

PAT: same URL + `Authorization: Bearer <PAT>`. Scopes = PAT scopes (org PAT/OAuth policies apply).

Read-only: `…/mcp/readonly` or header `X-MCP-Readonly: true`.

One toolset: `https://api.githubcopilot.com/mcp/x/issues/readonly` (single name only).

Several toolsets: header `X-MCP-Toolsets: repos,issues,pull_requests` (not comma in path). Also `X-MCP-Tools`, `X-MCP-Lockdown`, `X-MCP-Insiders`.

Local Docker: `-e GITHUB_PERSONAL_ACCESS_TOKEN` and/or OAuth callback `127.0.0.1:8085`. GHES: `GITHUB_HOST=https://github.example.com`.

Copilot on github.com: Repo Settings → Copilot → MCP servers. Built-in GitHub MCP is read-only current repo unless customized (`/readonly` off + `COPILOT_MCP_GITHUB_PERSONAL_ACCESS_TOKEN`). Cloud Agent: no OAuth remotes.

Paid GitHub/Copilot features keep the same license on the matching MCP tool.

## Hermes / this machine

Lean default: **do not** add GitHub MCP when authenticated `gh` works (repo/issue/PR/code search). There is no GitHub Docs MCP — search `site:docs.github.com` + `web_extract`.

If the user explicitly wants it in Hermes: HTTP URL above, `--auth oauth` then **user** `hermes mcp login` (browser; agent TTY cannot complete OAuth). Or PAT via `http_headers.Authorization`. See skill `hermes-mcp-http`. Tools live only after `/reload-mcp` or a new session.

Official org repos: `gh search repos --owner github` or `org:OWNER`.
