# Why not rsync the whole ~/.hermes

The Mac home includes `hermes-agent/` (git checkout) and platform wheels. Overlaying that onto Ubuntu breaks `hermes`. Official Linux `install.sh` first; then only config, `.env`, SOUL/AGENTS, skills, hooks.

`hermes profile export` packs memory. For "ohne Memory" use the rsync excludes in SKILL.md, then `hermes memory off` + `memory.memory_enabled false`.
