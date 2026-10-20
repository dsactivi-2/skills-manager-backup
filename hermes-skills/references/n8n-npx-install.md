# n8n official skills install (Hermes)

Official repo: https://github.com/n8n-io/skills

`hermes skills install skills-sh/n8n-io/skills/...` is the wrong installer for the full pack.

Working path (other-platforms README + Hermes flags):

```bash
npx skills add n8n-io/skills -g -y --skill '*' --agent hermes-agent --copy
```

Installs all 14 official skills into `~/.hermes/skills/<name>/`:

- `using-n8n-skills-official` (router)
- 13 capability skills (`n8n-*-official`)

Plain skill installs have no SessionStart hook. Add the official snippet to `AGENTS.md` so n8n work starts at `using-n8n-skills-official`.

Claude Code / Codex want the vendor plugin (`/plugin` / `codex plugin`) plus instance MCP. That is a separate step and needs the n8n base URL + OAuth.
