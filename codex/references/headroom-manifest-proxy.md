# Headroom → Manifest Proxy Setup (macOS)

## Stable Configuration Pattern

When using Codex with a local Headroom proxy that forwards to Manifest:

### 1. Codex Config (`~/.codex/config.toml`)
```toml
model_provider = "headroom"
openai_base_url = "http://127.0.0.1:8787/v1"
```

Keep the `[model_providers.headroom]` block:
```toml
[model_providers.headroom]
name = "Headroom init proxy"
base_url = "http://127.0.0.1:8787/v1"
supports_websockets = true
```

### 2. Headroom Proxy Wrapper (most stable)
Edit `/Users/activi/.headroom/run-proxy.sh` (used by LaunchAgent `io.headroom.proxy.plist`):

```zsh
exec "$HOME/.venvs/headroom/bin/headroom" proxy \
  --host 127.0.0.1 \
  --port 8787 \
  --backend openai \
  --openai-api-url https://app.manifest.build/v1 \
  --memory \
  --memory-storage project \
  --memory-db-path "$HOME/.headroom/memory.db" \
  --log-file "$HOME/.headroom/logs/proxy.jsonl" \
  --no-telemetry
```

### 3. Restart via LaunchAgent
```bash
launchctl unload ~/Library/LaunchAgents/io.headroom.proxy.plist
launchctl load ~/Library/LaunchAgents/io.headroom.proxy.plist
```

This is the preferred approach because:
- LaunchAgent provides `KeepAlive`
- Survives reboots and crashes
- Single source of truth for the proxy command

## Verification
After restart, `curl http://127.0.0.1:8787/v1/models` should return a valid response (may require auth header).

## Command Delivery Notes (User Preference)
When providing setup or diagnostic commands for this user:
- Prefer **individual single-line commands** over large multi-line heredoc scripts.
- Multi-line heredocs frequently break on paste (zsh history expansion errors like "event not found").
- For diagnostics, provide numbered individual commands the user can run one-by-one.
- Only deliver full scripts after confirming the user wants them or when the task is simple enough to avoid heredoc issues.