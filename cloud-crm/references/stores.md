# Token-Stores (Gegenspeichern)

Ein Token, mehrere Kopien. Primärdatei ist die Quelle für zshrc.

| Store | Pfad / Key | Inhalt |
|---|---|---|
| Datei | ~/.codex/crm-remote-mcp.token | nur Token, Mode 600 |
| Backup | ~/.codex/backups/crm-remote/token-YYYYMMDD-HHMMSS | alte Datei vor Überschreiben |
| Keychain | Service crm_remote_mcp_token, Account $USER | Token |
| launchctl | CRM_REMOTE_MCP_TOKEN | Token, für Codex.app |
| zshrc | export CRM_REMOTE_MCP_TOKEN="$(cat ~/.codex/crm-remote-mcp.token ...)" | kein Klartext-Token |
| Codex | [mcp_servers.crm-remote] + bearer_token_env_var = "CRM_REMOTE_MCP_TOKEN" | URL + Env-Name |
| Kimi | ~/.kimi-code/mcp.json -> crm-remote.headers.Authorization | Bearer + Token |
| Codex-Env-Script | ~/.codex/bin/set-codex-manifest-env.sh | set_env_from_keychain CRM_REMOTE_MCP_TOKEN crm_remote_mcp_token 0 |

## Regeln

- Vor jedem save die vorhandene Datei nach backups/crm-remote/ kopieren.
- Token nie in SKILL.md, Chat oder ungeschützte Logs.
- Worker erwartet Authorization: Bearer. Codex hängt Bearer über bearer_token_env_var an; Kimi braucht das Prefix im Header.
- Nach Token-Wechsel: neue Codex-Session, sonst bleibt der alte Header im laufenden Prozess.
