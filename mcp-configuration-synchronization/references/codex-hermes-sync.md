# Codex → Hermes MCP Sync Notes

## What we learned

- Codex config lives in `~/.codex/config.toml`.
- Hermes config lives in `~/.hermes/config.yaml`.
- The MCP sections are similar in intent but **not** format-compatible.
- A raw symlink is not appropriate because the file formats differ.

## Practical migration pattern

1. Parse Codex TOML.
2. Read the `mcp_servers` table.
3. Load Hermes YAML.
4. Replace only Hermes `mcp_servers` with the Codex-derived table.
5. Back up the Hermes config first.
6. Validate with `hermes mcp list`.
7. Restart Hermes or open a new session so the tools register.

## Verified session recipe

- Backup created before write.
- Hermes MCP list showed the expected servers afterward.

## Notes

- Keep unrelated Hermes settings intact.
- If future sync needs become bi-directional, prefer a separate shared source file rather than letting either app directly overwrite the other.
