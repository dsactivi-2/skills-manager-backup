# Dograh MCP Setup (2026-07-12)

## Connection

Dograh MCP als nativer Hermes MCP-Server. **NIE Browser-Login — immer MCP.**

```bash
hermes mcp add dograh --url https://api.dograh.com/api/v1/mcp/ --auth header
# Automatisiert:
printf 'Y\nY\n' | hermes mcp add dograh --url https://api.dograh.com/api/v1/mcp/ --auth header
```

## Workflow 8107

Aquaphor Smile Telesales (Bosnisch, Outbound). Lesen: `get_workflow(workflow_id=8107)`. Speichern: `save_workflow(workflow_id=8107, code=...)`.

## Pitfalls

- `hermes mcp configure` braucht interaktives Terminal → `hermes mcp add` mit piped input
- Nach Hinzufuegen: `/reload-mcp` oder neue Session
- MCP2Skill Gateway NICHT noetig wenn Dograh nativ in Hermes config.yaml
