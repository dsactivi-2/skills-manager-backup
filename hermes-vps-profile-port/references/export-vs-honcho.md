# Export vs Honcho vs built-in memory

Official `hermes profile export default` uses `_DEFAULT_EXPORT_INCLUDE_ROOT` (allow-list). Credential files and Honcho config are excluded.

| Store | In export? | Notes |
|---|---|---|
| `memories/MEMORY.md`, `USER.md` | yes | What “ganze Memory” means for Option B |
| `sessions/` transcripts | yes | Not the FTS index |
| `state.db` | no | `session_search` starts empty on the VPS |
| `.env`, `auth.json` | no | Keys. Re-auth on the VPS |
| `honcho.json` | no | Provider config + secrets. Observations stay in Honcho cloud |
| `profiles/` | no | Sibling agents never ride along |
| `hooks/` | no | Not on the allow-list |

After import: `hermes memory setup` if Honcho is wanted. New peer, same user workspace — do not copy `honcho.json`.
