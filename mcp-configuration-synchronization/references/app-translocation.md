# macOS App Translocation & MCP Paths

## What is App Translocation?
When macOS launches an app that is not properly signed/notarized or is run from certain locations (Downloads, external drives, etc.), it moves the app into a temporary randomized path under:

```
/private/var/folders/.../T/AppTranslocation/<random-uuid>/d/<AppName>.app
```

This path is **different on every launch** of the app.

## Impact on MCP Configuration
- Codex records the **current** translocated path when it discovers the MCP.
- Hermes config becomes invalid as soon as the user quits and re-launches the source app.
- Never hardcode `/Applications/...` paths for apps that are subject to translocation.

## Correct Workflow
1. In Codex, inspect the current `mcp_servers.<name>` block.
2. Copy the exact `command` + `args` (including the full translocated path).
3. Paste into Hermes `~/.hermes/config.yaml`.
4. Restart Hermes.

## Example (Open Design)
Codex shows:
```toml
[mcp_servers.open-design]
command = "/private/var/folders/.../T/AppTranslocation/.../open-design/bin/node"
args = [".../daemon-cli.mjs", "mcp"]
```

This must be copied fresh after every relevant app restart.