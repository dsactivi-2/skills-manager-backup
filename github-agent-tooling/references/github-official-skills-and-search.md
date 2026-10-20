# Official GitHub skills vs search tools (first-party)

User standard: **offiziell = org:github first-party**. Do not treat `github/awesome-copilot` as official (README + docs: community-contributed). Do not install Community Hub “search-tools” skills.

## First-party SKILL.md (live, 2026-08)

| Skill | Repo | What it is |
|---|---|---|
| `dependency-scanning` | `github/copilot-advanced-security-plugin` | Dependabot / advisory scan via GitHub MCP |
| `secret-scanning` | `github/copilot-advanced-security-plugin` | Secrets via MCP `run_secret_scanning` (remote only) |
| `build-performance-analysis` | `github/copilot-plugins` | C++ vcperf on Windows/MSVC |
| `spark-app-template` | `github/copilot-plugins` | Recipe to scaffold a Vite/React/TS web app (not a finished app) |

Install (full tree, Hermes + Copilot user):

```bash
gh skill install github/copilot-plugins plugins/spark/skills/spark-app-template --dir ~/.hermes/skills --force
gh skill install github/copilot-plugins plugins/spark/skills/spark-app-template --agent github-copilot --scope user --force
```

`hermes skills install <url>` only pulls `SKILL.md` and drops `references/` + `stacks/` — prefer `gh skill install` for Spark.

`github/github-mcp-server` has **no** SKILL.md. GitHub MCP has **no** skill catalog tool.

## Search-Tools is not a skill

| Term | Meaning | Use case |
|---|---|---|
| Skill | Anleitung (`SKILL.md`) | „Wie scannst du Secrets?“ |
| Search-Tools | GitHub-Suche nach Repos/Code/Issues/PRs | „Finde öffentliche Repos für X“ |
| Skill-Suche | `gh skill search` / `hermes skills search` | Katalog von Anleitungen |

Live search path (already enough; no extra skill):

```bash
gh search repos "USE CASE" --sort stars --limit 20 --json fullName,description,stargazersCount,updatedAt,url
gh search code "SYMBOL" --language python --limit 20 --json repository,path,url
```

MCP equivalents after GitHub remote MCP is connected: `search_repositories`, `search_code`, `search_issues`, `search_pull_requests`, `search_commits`, `search_users`. Same job as `gh search`. Workflow: skill `repo-by-usecase`.

GitHub search is not “all public repos at once” — ranked hits, API candidate cap.

Explain this split in **simple DE + Use-Case-Tabelle** when the user mixes the words.
