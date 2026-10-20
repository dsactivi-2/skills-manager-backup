---
name: github-agent-tooling
description: "Use when choosing GitHub agent tooling (gh/MCP/ext)."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [GitHub, gh, MCP, extensions, tooling, lean]
    related_skills: [github-pr-workflow, repo-by-usecase, github-repo-inventory]
---

# GitHub agent tooling (lean stack)

Class-level defaults for installing and recommending GitHub tools for AI agents and multi-framework setups.

## User preference

- Direct DE answers, tables OK, no fluff.
- **Lean default:** global `gh` is enough. Do not add GitHub MCP or bulk gh extensions "for completeness".
- Live verify (`gh auth status`, `which gh`) over theory.
- Natural language to the agent; user should not need to type `gh` for routine work.
- Agent uses **non-interactive** commands (`gh search …`, `gh s "q" -l …`, JSON flags). Never bare interactive TUI (`gh s` with no args, `gh f`) inside the agent loop unless the user is driving the TUI themselves.

## Decision matrix

| Need | Use |
|------|-----|
| PR/issue/CI/repo/search from agent with shell | `gh` + bundled `github-pr-workflow` |
| Many branches / multi-PR merge safety, dry-run, stale ECC cleanup | skill `github-branch-consolidation` (temp-clone dry-run, overwrite guard, cascade poll) |
| Find repo without knowing the name | skill `repo-by-usecase` (full workflow) + `gh search` / optional `gh s` |
| Inventory remote repo for env/config/skills/MCP/templates (download + DE table) | skill `github-repo-inventory` + `gh api` tree/raw (no full clone by default) |
| Client has **no** terminal/`gh` | GitHub MCP (prefer official remote; read-only if possible) |
| Human daily PR/issue triage in terminal | optional `dlvhdr/gh-dash` |
| Stacked PRs | optional `github/gh-stack` |
| CI or org migration project | `gh-actions-importer` / `gh-gei` / `gh-repo-stats` for that project only |
| Copilot-in-gh extension | **Do not install** (deprecated) |

## macOS: global gh for all agents

```bash
brew install gh    # or: brew upgrade gh
gh auth status
# PATH: /opt/homebrew/bin/gh — inherited by Hermes, Codex, Claude Code, etc.
```

No per-agent or per-framework gh install when Homebrew is on PATH.

Auth multi-account: `gh auth switch`. Active account affects search and API.

## Repo search patterns (no name known)

Full workflow: skill **`repo-by-usecase`** (adopt if curator-missing: `hermes curator adopt repo-by-usecase`).

```bash
gh search repos "livekit voice agent" --limit 20 --json fullName,description,stargazersCount,updatedAt,url
gh search repos "topic:voice-ai language:Python" --sort stars
gh search code "create_agent" --language python
# Human TUI only: gh s "keywords" -l python
```

### Discovery domains (do not mix)

| Need | Route |
|------|--------|
| GitHub **repos** by function | `repo-by-usecase` + `gh search` |
| Agent **skills** | `find-skills` / `hermes-skills` |
| HF models/datasets | `huggingface-hub` / `llama-cpp` |
| Voice **providers** STT/LLM/TTS | `balkan-voice-agent-stack` |
## GitHub MCP — only when justified

- **Yes:** MCP-only UI, sandboxed agent without shell, explicit user request for one profile.
- **No:** Hermes/default already has terminal + authenticated `gh` (duplicate tools, token surface, keepalive noise historically).
- Do not enable globally across all Hermes profiles by default (profiles do not share MCP globally anyway).

## gh extensions — catalog pointer

See `references/gh-extensions-catalog.md` for function + use case per common extension.

Rule: install **one** extension after user names a concrete workflow — never a starter pack.

### Installed here (verify with `gh extension list` before install)

| Ext | Command | Role |
|-----|---------|------|
| gennaro-tedesco/gh-s | `gh s` | Repo search by keywords; agent prefers args or `gh search` |
| seachicken/gh-poi | `gh poi` | Local merged-branch cleanup — **always `--dry-run` first** |
| yusukebe/gh-markdown-preview | `gh markdown-preview` | Local GFM preview in browser |

### Explicitly skip unless user insists

| Item | Why |
|------|-----|
| `github/gh-copilot` | Deprecated; separate Copilot CLI is the replacement — default **no** (redundant with Hermes) |
| `gennaro-tedesco/gh-f` | fzf picker over listable objects, not discovery; only if user wants fuzzy pick TUI |
| GitHub MCP default | Duplicate of shell + `gh` |

## Skills layer

- Bundled `github-pr-workflow` owns PR lifecycle commands (protected — do not patch from curator).
- `github-branch-consolidation` owns **multi-branch audit, sequential dry-run merge, overwrite-of-newer-main guard, multi-PR cascade, stale auto-bundle branches** (user standard: DE tables, dry-run first, explain PR paths before live merge).
- `repo-by-usecase` owns **finding/ranking repos from a capability description**.
- `github-repo-inventory` owns **structured harvest** of a known OWNER/REPO (env, MCP, skills, templates → `~/Downloads/…-inventory` + UEBERSICHT).
- This skill owns **which tools to install/recommend**.
- Avoid extra narrow GitHub skills unless encoding a recurring user standard (review checklist, release policy, multi-branch consolidate).

## Pitfalls

- Recommending MCP + gh + extensions together = MCP overkill vs user lean preference.
- Treating human TUI extensions (`gh-dash`, `gh-f`) as agent requirements.
- Assuming missing MCP means GitHub is unavailable when `gh` works.
- `github/gh-copilot` extension is dead; do not suggest it.

## Verify

```bash
which gh && gh --version
gh auth status
gh search repos "test" --limit 1   # smoke search if network ok
```
