---
name: repo-by-usecase
description: "Use when finding GitHub repos by use case, not name."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [GitHub, gh, search, discovery, use-case, repos, lean]
    related_skills: [github-agent-tooling, github-pr-workflow, find-skills, huggingface-hub, llama-cpp]
---

# Repo by use case (no name known)

Find and rank GitHub repositories from a **capability / use-case description**, not a repo name.

## When to use

- User describes a need: "LiveKit voice agent Python", "self-hosted n8n alternative", "GGUF server with OpenAI API"
- User does not know owner/repo
- Need candidates from functions, partial functions, stack, language, or "similar to X"
- Agent must search live and compare — not invent famous repos from memory

## When NOT to use

| Need | Use instead |
|------|-------------|
| Install/choose gh vs MCP vs extensions | `github-agent-tooling` |
| PR/issue/CI on a **known** repo | `github-pr-workflow` |
| Agent **skills** (not code repos) | `find-skills` / `hermes-skills` |
| HF models/datasets/GGUF | `huggingface-hub` / `llama-cpp` |
| Voice **provider** pick (STT/TTS), not GitHub | domain stack skills (e.g. balkan-voice-agent-stack) |

## User preference (this environment)

- Answers in **German**, direct, tables OK, no fluff
- **Live verify** with `gh` — never claim a repo fits without search/view output
- Prefer core `gh search` (JSON) over interactive TUI when the agent runs commands
- Human may use `gh s` interactively; agent should pass query args or use `gh search`
- Lean: no GitHub MCP required if `gh` works

## Prerequisites

```bash
which gh && gh auth status
# Active account affects rate limits and private visibility
```

If `gh` missing: point to `github-agent-tooling` (brew install gh). Do not invent results.

## Workflow (mandatory order)

### 1. Parse the use case into a search brief

Extract (guess only if needed; label guesses):

| Field | Example |
|-------|---------|
| Goal (1 line) | Realtime voice agent with LiveKit |
| Must-have functions | room/agents, STT/TTS hooks, Python SDK |
| Nice-to-have | Docker compose, examples, active commits |
| Language / runtime | Python, TypeScript, Go |
| Deploy shape | library / full app / helm / docker |
| Exclude | toy demos, abandoned, wrong stack |
| Seeds | known product names, API symbols, topics |

If the brief is too vague (only "best AI tool"), ask **one** tight clarifying question OR run 2–3 broad probes and show directions.

### 2. Build query set (3–6 queries, not one)

Always run **multiple** angles:

1. **Natural keywords** — user words + domain nouns
2. **Language/topic filters** — `language:Python` `topic:…`
3. **Code/symbol search** — unique API or config strings
4. **Negative / refine** — drop noise after first pass (filter in ranking)
5. Optional **org/user** if ecosystem known (`org:livekit`)

Agent-friendly commands (prefer these):

```bash
# Repos by keywords + language, sorted by stars
gh search repos "livekit voice agent" --language python --sort stars --limit 20 \
  --json fullName,description,stargazersCount,updatedAt,url,language,topics

# Topic-oriented
gh search repos "topic:voice-ai topic:livekit" --sort stars --limit 15 \
  --json fullName,description,stargazersCount,updatedAt,url

# Partial function / API surface in code
gh search code "AgentSession" --language python --limit 20 \
  --json repository,path,url

# Library name unknown but behavior known
gh search repos "openai compatible proxy local llm" --sort stars --limit 15 \
  --json fullName,description,stargazersCount,updatedAt,url
```

Human TUI (optional, user terminal):

```bash
gh s "livekit voice" -l python
```

Do **not** rely on bare `gh s` inside the agent (interactive).

More query patterns: `references/query-patterns.md`.

### 3. Merge and de-dupe

- Key by `owner/repo` (fullName)
- Keep highest stars + newest signal
- Note which query produced the hit (traceability)

### 4. Quick filter (before deep dive)

Drop or demote if:

- No description and very low stars (unless brand-new official org)
- `updatedAt` very old vs. must-have "maintained"
- Clearly wrong language/stack
- Awesome-list only (lists are **sources of names**, not the solution — open list, then search listed projects)
- Name match only, zero functional overlap

### 5. Deepen top 3–7 candidates (live)

For each shortlist item:

```bash
gh repo view OWNER/REPO --json name,description,url,stargazersCount,forkCount,updatedAt,primaryLanguage,repositoryTopics,licenseInfo,hasIssuesEnabled,defaultBranchRef

# Optional signals
gh api repos/OWNER/REPO/readme --jq .name 2>/dev/null
gh search code "repo:OWNER/REPO YOUR_SYMBOL" --limit 5
```

Read README/description enough to map **must-have functions** → present / partial / missing. Prefer evidence (paths, code search hits) over marketing blurbs.

### 6. Rank and present (DE, table-first)

Output shape:

1. **Suchbrief** (1–3 bullets: goal, must-haves, filters used)
2. **Tabelle** (ranked):

| Rang | Repo | Stars | Updated | Fit | Warum / Lücke | URL |
|------|------|-------|---------|-----|---------------|-----|
| 1 | org/name | … | … | high/med/low | … | … |

3. **Empfehlung**: 1 primary + 1–2 runners-up
4. **Nächster Schritt**: clone, compare licenses, or second search with refined keywords
5. **Nicht gefunden / schwach**: say so; propose better queries — never pad with memory celebrities unverified

Fit heuristic:

- **high**: must-haves evidenced + maintained + right language
- **med**: partial functions or thin docs but real code
- **low**: adjacent only / abandoned / wrong layer (e.g. only client when user needs server)

### 7. Optional follow-ups

- Clone top pick into a workdir only if user asks
- PR/issue work → hand off to `github-pr-workflow`
- If user wanted a **skill** not a repo → `find-skills`

## Query design rules

- Prefer **specific nouns** (protocol, product, file format) over adjectives ("best", "simple", "powerful")
- Split compound needs: search "STT streaming" and "LiveKit agents" separately, then intersect by reading
- For monorepos, `gh search code` beats repo title search
- Rate limits: batch JSON searches; avoid spam loops
- Private org needs: ensure correct `gh auth` account (`gh auth switch`)

## Pitfalls

- Answering from training memory without `gh search` / `gh repo view`
- Single query → "no results" → give up (always vary language/topic/code)
- Ranking only by stars (stars ≠ fit)
- Treating tutorials/awesome-lists as implementations
- Interactive `gh s` / `gh f` as agent-only path
- Confusing HF model repos with GitHub app repos
- Installing GitHub MCP just to search when `gh` works

## Verify skill path works

```bash
gh search repos "test" --limit 1 --json fullName
gh search code "TODO" --language python --limit 1 --json repository
```

## Minimal example

User: "Repo für lokalen OpenAI-kompatiblen LLM-Proxy, self-hosted"

```text
Brief: local OpenAI-compatible API proxy; self-hosted; preferably active
Queries:
  gh search repos "openai compatible proxy" --sort stars --limit 20 --json ...
  gh search repos "openai compatible reverse proxy llm" --language go --sort stars --limit 15 --json ...
  gh search code "chat/completions" "openai" --language go --limit 15 --json ...
→ de-dupe → view top → DE table with fit vs "compatible API + self-host"
```
