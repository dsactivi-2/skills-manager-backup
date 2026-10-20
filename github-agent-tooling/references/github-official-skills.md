# Official GitHub agent skills (not community)

Live-checked 2026-08-23 via `gh`, `gh skill`, and code search. GitHub MCP has **no** skill-catalog tools — skills are `SKILL.md` files in repos.

## First-party only (org `github`, not community)

| Skill | Repo | Use |
|---|---|---|
| `dependency-scanning` | `github/copilot-advanced-security-plugin` | Dependabot / advisory scan via GitHub MCP |
| `secret-scanning` | `github/copilot-advanced-security-plugin` | `run_secret_scanning` via GitHub MCP |
| `build-performance-analysis` | `github/copilot-plugins` | C++ vcperf on Windows/MSVC |
| `spark-app-template` | `github/copilot-plugins` | GitHub Spark web-app defaults |

Install:

```bash
gh skill install github/copilot-advanced-security-plugin secret-scanning
gh skill install github/copilot-advanced-security-plugin dependency-scanning
gh skill install github/copilot-plugins spark-app-template
gh skill install github/copilot-plugins build-performance-analysis
```

There is **no** official GitHub skill pack for everyday Issues/PRs/search. That surface is `gh` + optional remote MCP (see `hermes-mcp-http` → `references/github-remote-mcp.md`).

## Explicitly not official

- `github/awesome-copilot` — GitHub Docs and the repo README call it **community-contributed**. `gh skill search --owner github` mostly hits this repo. Do not present those as first-party.
- Hermes hub / skills.sh / ClawHub GitHub skills — community. `hermes skills search github` is not a GitHub-official catalog.

Docs: https://docs.github.com/en/copilot/concepts/agents/about-agent-skills (`gh skill`; examples point at awesome-copilot).
