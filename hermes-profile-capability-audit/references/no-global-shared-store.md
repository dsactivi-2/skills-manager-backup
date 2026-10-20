# No global shared skills/tools/MCP store

## Verdict (Hermes docs)

Profiles are separate `HERMES_HOME` trees. Isolation is intentional.

- Skills, MCP, toolsets, `.env`, SOUL, memory, sessions → **per profile**
- Shared: Hermes install/binary; `hermes update` reseeds **bundled** skills to all profiles
- FAQ: profiles are completely isolated for memory/sessions/skills dirs

## Why a single global skills folder is a bad default

- Prompt bloat (every role loads irrelevant skills index)
- Role contamination (sales profile gets devops skills)
- Kanban workers must have skills installed on the **assignee** profile
- Curator/usage telemetry is per-profile `skills/.usage.json`

## Official share mechanisms

1. `hermes profile create X --clone` / `--clone-from SRC` — config + skills
2. `hermes profile create X --clone-all` — almost everything except heavy history
3. `hermes skills snapshot export|import` — portable skill set (hub-oriented)
4. Profile Distributions — git package of SOUL/config/skills/MCP defs
5. Selective file/config sync (this skill's `scripts/hermes-profile-sync.sh`)

## Recommended ops model

- **default** (`~/.hermes`): canonical fat install (many skills, shared MCP like dograh/hivemind/bhtelecom as needed)
- **role profiles**: lean; copy only required skills/MCP with dry-run-then-`--apply`
- Do not symlink entire `skills/` trees across profiles unless the user explicitly wants that experiment — not documented as supported

## MCP note

`mcp_servers` live in each profile's `config.yaml`. Copying a block does not copy secrets — target `.env` must define referenced vars. Reload MCP after write.
