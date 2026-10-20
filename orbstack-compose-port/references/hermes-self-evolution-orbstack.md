# NousResearch/hermes-agent-self-evolution on OrbStack

Verified 2026-09-03. Repo is a **Python CLI** (DSPy + GEPA), not a skill pack and not a Hermes setup wizard. No root `SKILL.md`, no HTTP service. Do not `npx skills add` it.

## What it is

Optimizer that mutates Hermes `SKILL.md` files, scores variants, writes a PR. A run is autonomous **inside** the loop; merge stays human. Phase 5 (cron/unattended) is planned, not built.

Default GEPA models are `openai/gpt-4.1` / `gpt-4.1-mini`. Do **not** start a real `--iterations` loop unless the user asked — ~$2–10. `--dry-run` is the live verify.

## Layout (Mac)

- Project: `/Users/activi/Code/Projects/hermes-agent-self-evolution`
- Compose template: `docker-compose.prod.yml` (no `docker-compose.yml`)
- Image: `python:3.12-slim` (smoke `uname -m` → `aarch64`; not `*-bookworm-slim`)
- Container: `hermes-self-evolution`, `command: sleep infinity`, **no published port**
- Hermes source: sparse clone `vendor/hermes-agent` (skills only) → `/opt/hermes-agent:ro`
- Env: `HERMES_AGENT_REPO=/opt/hermes-agent`, dummy `OPENAI_API_KEY=ollama`, `OPENAI_BASE_URL=http://host.docker.internal:11434/v1`
- **Never mount `~/.hermes`**

```
docker --context=orbstack compose -f docker-compose.prod.yml --env-file .env up -d --build
docker --context=orbstack exec hermes-self-evolution pytest -q
docker --context=orbstack exec hermes-self-evolution python -m evolution.skills.evolve_skill --skill arxiv --dry-run
```

Host Ollama: `extra_hosts: host.docker.internal:host-gateway`. Probe from a throwaway container before claiming the LLM path works.

## Verify (no /health)

CLI-only. Table is Dienst|Check|Ergebnis, not URL|HTTP.

| Check | Pass |
|---|---|
| `ps --filter name=hermes-self-evolution` | Up |
| `exec … uname -m` | aarch64 |
| pytest | 145 passed (this build) |
| `--skill arxiv --dry-run` | Loaded `skills/research/arxiv/SKILL.md` |
| urlopen `host.docker.internal:11434/api/version` | JSON version |

`github-code-review` may be absent in a skills-only sparse clone. `arxiv` is in `skills/research/`.
