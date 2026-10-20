# Profile vs default MCP env

When dual Dograh MCP is wired:

| Location | Purpose |
|----------|---------|
| `~/.hermes/.env` | default profile sessions |
| `~/.hermes/profiles/<name>/.env` | `hermes -p <name>` sessions |

Missing VOICEEU key in profile env → 401 on profile sessions even if default works.

After fix: `hermes -p <name> mcp test dograh-voiceeu` then one real tool call after MCP reload.
