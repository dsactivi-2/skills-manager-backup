# Eraser skill install (Hermes)

Eraser docs (`https://docs.eraser.io/using-ai-agent-integrations`) say:

```bash
npx skills install eraserlabs/eraser-io
```

The Skills CLI has **no** `install` verb. Use:

```bash
npx skills add eraserlabs/eraser-io -g -y --skill '*' --agent hermes-agent
```

`-l` first lists 5 skills without installing: `eraser-diagrams`, `aws-diagrams`, `azure-diagrams`, `bicep-diagrams`, `terraform-diagrams`.

Install copies into `~/.hermes/skills/<name>/` (Hermes Agent detected). `hermes skills install eraserlabs/…` is the wrong installer.

Vendor SKILL.md still documents `curl POST https://app.eraser.io/api/render/elements`. On this machine Eraser is the remote MCP (`https://app.eraser.io/api/mcp`, OAuth). After install, render via `mcp__eraser__*` only. Pairing skill: `eraser`. MCP recipe: skill `hermes-mcp-http` → `references/eraser-mcp.md`.

Re-running `npx skills add` overwrites the five vendor copies and restores curl instructions.
