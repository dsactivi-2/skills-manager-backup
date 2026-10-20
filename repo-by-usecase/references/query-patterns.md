# Query patterns for repo-by-usecase

## Qualifiers (gh search repos)

Put these inside the query string or as flags where supported:

| Intent | Pattern |
|--------|---------|
| Language | `--language python` or `language:python` |
| Topic | `topic:voice-ai` |
| Org / user | `org:livekit` `user:someuser` |
| Stars floor | `stars:>500` |
| Forks | `forks:>50` |
| Recently pushed | `pushed:>2025-01-01` (adjust date) |
| In name/desc/readme | `in:name,description` |
| Not forks | often default behavior varies — check results |

Sort: `--sort stars` | `--sort updated`  
Limit: `--limit 15`–`30`  
JSON: always `--json fullName,description,stargazersCount,updatedAt,url,language,topics` for agents

## Code search (partial functions)

| Intent | Example |
|--------|---------|
| API symbol | `gh search code "create_agent" --language python` |
| Config key | `gh search code "LIVEKIT_API_KEY" --language typescript` |
| Endpoint | `gh search code "/v1/chat/completions" --language go` |
| Scoped | `gh search code "repo:owner/name Symbol"` |

Use code search when product names are unknown but interfaces are known.

## Angle templates

### A. Product + role
`"livekit agents"`, `"temporal worker python"`, `"dokploy compose"`

### B. Behavior without brand
`"openai compatible proxy"`, `"webhook retry queue"`, `"phone number lookup scraper"`

### C. Stack combo
`"fastapi websocket agent" language:Python`  
`"nextjs realtime voice" language:TypeScript`

### D. File / manifest smell
code: `"kind: Workflow"` + `temporal`  
code: `"pipecat"` + `"transport"`

### E. Alternative to known tool
`"n8n alternative"`, `"airflow lightweight"`, then verify README claims live

### F. Awesome-list bootstrap
1. `gh search repos "awesome voice ai" --limit 10`
2. Open list README
3. Extract project names → `gh search repos` / `gh repo view` each serious candidate

## Anti-patterns

- Query = only "best", "awesome", "simple"
- One English query when ecosystem is Chinese/Russian-heavy — try product tokens still
- Stopping at awesome-list repo as the answer
- Ignoring `updatedAt` when user said production/maintained

## Ranking weights (soft)

1. Must-have function evidence (code/README) — highest  
2. Maintenance (`updatedAt`, release cadence if checked)  
3. Language/runtime fit  
4. Stars/forks as popularity prior only  
5. License only if user cares (note SPDX if viewed)
