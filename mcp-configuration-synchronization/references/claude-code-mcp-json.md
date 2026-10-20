# Claude Code `.mcp.json` — adding a server + verifying credentials

Claude Code uses a **JSON** MCP config (a third target format alongside Hermes
YAML `~/.hermes/config.yaml` and Codex TOML `~/.codex/config.toml`). Do not
assume the shapes are interchangeable — map fields deliberately.

## File locations
- Project-scoped: `<project>/.mcp.json`
- Global: `~/.claude/.mcp.json` (may not exist)
- Note: a top-level `~/.mcp.json` is also commonly used and picked up. Check
  which one already exists before writing — don't create a competing file.

## Shape
```json
{
  "mcpServers": {
    "servername": {
      "command": "npx",
      "args": ["-y", "@vendor/cli", "mcp"],
      "env": { "VENDOR_API_KEY": "..." }
    },
    "http-server": {
      "type": "http",
      "url": "https://api.example.com/mcp"
    }
  }
}
```
stdio servers use `command`/`args`/`env`; remote servers use `type: "http"` +
`url` (optionally `headers`).

## Workflow — ADD, never overwrite
1. `read_file` the existing `.mcp.json` first. It usually already has other
   servers (github, deepgram, etc.).
2. Add the new server block **inside** `mcpServers`, preserving the rest.
   Prefer a targeted `patch` over a full `write_file` when the file already has
   content, so you can't accidentally drop a sibling server.
3. Re-read to confirm the existing servers are intact and the new block landed.

## Verify the API key BEFORE trusting the MCP (key pitfall)
MCP clients load config only at **startup**, and a wrong/expired key does not
surface at config-write time — it silently 401/403s *inside* every tool call
later. So validate out-of-band by running the vendor CLI directly with the env
var, before telling the user it's "connected":

```bash
VENDOR_API_KEY="<key>" npx -y @vendor/cli <auth-or-account-command>
```

Example (json2video): the CLI both validates+saves the key and prints account
info, so it doubles as a connectivity + credits check:
```bash
JSON2VIDEO_API_KEY="<key>" npx -y @json2video/cli <account cmd>
# -> "API key validated and saved." + plan/credits
```
A clean exit with real account data = key good. A 401/403 = key missing,
expired, or wrong environment.

## Two places the key can live
Many vendor CLIs (json2video included) ALSO cache the key to their own config
(`~/.config/<vendor>/config.json`) when you run the auth/validate command. So
after a CLI validation you have a choice:
- keep the key in `.mcp.json`'s `env` (self-contained, but plaintext in that file), or
- empty the `env` and let the MCP fall back to the CLI-cached key.
Mention the plaintext-in-config tradeoff to the user; let them pick.

## Final handoff steps (user must do)
- Restart Claude Code so the new MCP config is loaded.
- Run `/mcp` to confirm the server shows as *connected*.
These cannot be done from inside the agent session — always spell them out.
