---
name: github-repo-inventory
description: "Use when inventorying a GitHub repo via gh (env/MCP/skills)."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [GitHub, gh, inventory, config, env, MCP, templates, skills]
    related_skills: [github-agent-tooling, repo-by-usecase, codebase-inspection]
---

# GitHub repo inventory (gh-only, no full clone)

Class-level workflow when the user wants a **structured harvest** of a remote GitHub repo: env/config, skills, MCP, agent/docs templates, deploy artifacts — plus a short DE overview table and files under `~/Downloads/`.

Not for: finding an unknown repo (`repo-by-usecase`), PR lifecycle (`github-pr-workflow`), or local LOC stats (`codebase-inspection`).

## User preference

- Direct DE, tables OK, no fluff.
- Agent runs `gh` — user does not type CLI.
- Deliverable = real files in Downloads + overview, not a plan.
- Prefer lean `gh api` over cloning whole monorepos unless deep code search needs a worktree.
- After the overview, user often asks **what two specific files do** (e.g. MDX vs `constants.py`, `instructions.py` vs MCP client guide). Answer with a short comparison table: what / executable? / where used / for what — no full inventory re-dump.
- Sequential single-bullet follow-ups (AGENTS chain, templates, providers, voice-prompt topics): answer **only that bullet** — no full overview dump.
- Optional second drop: numbered flat copies under `~/Downloads/<topic>-env/` when user only wants env artifacts.
- When user asks what diagnostic shell blocks do: short DE table command → effect → why; mark read-only vs mutating.

## Preconditions

```bash
which gh && gh auth status
```

Active account must have read access (public repos: any authed account).

## Workflow

### 1. Staging dir

```bash
OUT=~/Downloads/<owner>-<repo>-inventory
mkdir -p "$OUT/files"
cd "$OUT"
```

### 2. Repo metadata

```bash
gh repo view OWNER/REPO --json name,description,defaultBranchRef,url,homepageUrl,isPrivate,pushedAt,repositoryTopics
```

### 3. Full path tree (once)

```bash
gh api "repos/OWNER/REPO/git/trees/HEAD?recursive=1" \
  --jq '.tree[] | select(.type=="blob") | .path' > repo_all_paths.txt
```

Categorize with `rg` into files (keep lists for the overview):

| List | Pattern focus |
|------|----------------|
| `cat_env.txt` | `.env`, `env.example`, `environment` |
| `cat_skills.txt` | `SKILL.md`, `.agents/skills` |
| `cat_mcp.txt` | `mcp`, `MCP` |
| `cat_templates.txt` | `template`, `templates/` |
| `cat_agents_guides.txt` | `AGENTS.md`, `CLAUDE.md`, `prompt`, `guide` |
| `cat_config_deploy.txt` | docker-compose, Dockerfile, helm values, `pyproject`, nginx, turnserver |

### 4. Selective download (raw)

Prefer GitHub raw contents API (handles large trees without clone):

```bash
gh api -H "Accept: application/vnd.github.raw" \
  "repos/OWNER/REPO/contents/PATH/TO/FILE" > "files/PATH/TO/FILE"
```

Always pull first:

- All `*.env.example` / `.env.*.example`
- Root + package `AGENTS.md` / `CLAUDE.md`
- `.agents/skills/**/SKILL.md` (+ short references)
- MCP server entrypoints, instructions, tool modules, MCP docs pages
- Deploy: `docker-compose*.yaml`, helm `values*.yaml` / `Chart.yaml`, deploy `.env.example`
- Config SoT docs (`environment-variables`, MCP setup)
- Example SDK scripts + README under `examples/`
- Template/fixture JSON only if small and illustrative

Track paths in `DOWNLOADED_FILES.txt`. Do **not** dump entire alembic history or binary assets unless asked.

### 5. Interpret before writing the table

Open key files and extract:

- Env keys from examples + any `constants.py` / documented env reference
- MCP tool names from server registration / tool modules
- Skill frontmatter `name` + `description`
- Whether “templates” are git seeds vs DB/API-generated (do not invent seed files)

### 6. Overview deliverable

Write `$OUT/UEBERSICHT.md` (or DE name user prefers) with sections:

1. Env files
2. Deploy/config
3. Skills
4. AGENTS/CLAUDE hierarchy
5. MCP (endpoint, auth, tools)
6. Prompt/guide atoms
7. Agent/workflow templates + examples
8. Model/provider registry if present
9. Download layout

Terminal reply: short DE tables + absolute path to `UEBERSICHT.md`. No MEDIA tags on CLI.

## Output shape (tables)

Each row: **Name | Pfad | Was es ist | Was es kann / wofür**

Keep rows scannable; put long key lists in the markdown file, not the chat dump.

## Pitfalls

- **Contents JSON + base64** is slower/fragile for bulk; prefer `Accept: application/vnd.github.raw`.
- Recursive tree can be huge — filter with `rg` before downloading.
- Product “templates” may live only in **DB/UI/API**, not as repo JSON seeds (Dograh: `WorkflowTemplates` + create-from-NL API). Always disambiguate: catalog templates vs NL-generate API vs `{{vars}}` vs Helm/fixtures.
- Env **docs** (`environment-variables.mdx`) ≠ env **runtime** (`constants.py`) ≠ **values** (`.env.example`). Three layers.
- MCP **instructions.py** is system-prompt for builder LLMs (injected on connect) — not a shell script and not the human client guide (`docs/integrations/mcp.mdx`).
- Voice-prompt **topics** are authoring recipes via `get_voice_prompting_guide`; they do not auto-apply on live calls.
- Repo `.agents/skills` = **maintainer/contributor** skills, not runtime voice-agent skills — label them correctly.
- MCP “workspace authoring” vs “in-call MCP tool” are different surfaces; separate rows.
- **AGENTS.md chain** = coding-agent house rules in a monorepo checkout — not deploy runbooks, not ARI media debug, not live call prompts.
- **Model providers:** UI BYOK uses built-in registry. New provider names need self-host fork (`registry.py` + `service_factory.py`). OpenAI-compatible base URL / OpenRouter / Speaches cover most custom endpoints without new code.
- Do not claim secrets from examples are live credentials; examples are placeholders.
- Active `gh` account matters for private org repos (`gh auth switch` if needed).

## Verify

```bash
test -s "$OUT/repo_all_paths.txt"
test -f "$OUT/UEBERSICHT.md"
find "$OUT/files" -type f | wc -l   # non-zero when harvest requested
```

## References

- `references/dograh-hq-dograh-map.md` — condensed map (env SoT, MCP pair, voice-prompt topics, templates×4, AGENTS when/not, BYOK vs fork, ARI pointer)
