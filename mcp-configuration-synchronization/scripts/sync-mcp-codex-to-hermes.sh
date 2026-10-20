#!/bin/bash
# Codex → Hermes MCP Sync
# Source of truth: ~/.codex/config.toml
# Target: ~/.hermes/config.yaml (only mcp_servers section)

set -e

CODEX_CONFIG="$HOME/.codex/config.toml"
HERMES_CONFIG="$HOME/.hermes/config.yaml"

if [ ! -f "$CODEX_CONFIG" ]; then
    echo "❌ Codex config not found"
    exit 1
fi

python3 - << 'PYEOF'
import toml
import yaml
import re
from pathlib import Path

codex_path = Path.home() / ".codex" / "config.toml"
hermes_path = Path.home() / ".hermes" / "config.yaml"

codex = toml.load(codex_path)
mcp_servers = codex.get("mcp_servers", {})

hermes_mcps = {}
for name, cfg in mcp_servers.items():
    entry = {}
    for key in ["command", "args", "url", "env", "http_headers", 
                "bearer_token_env_var", "startup_timeout_sec", "required"]:
        if key in cfg:
            entry[key] = cfg[key]
    hermes_mcps[name] = entry

with open(hermes_path, "r") as f:
    content = f.read()

# Remove old mcp_servers block
content = re.sub(r"mcp_servers:.*?(?=\n[a-z]|\Z)", "", content, flags=re.DOTALL)

# Insert new block
new_block = "mcp_servers:\n" + yaml.dump(hermes_mcps, default_flow_style=False, sort_keys=False)
content = content.replace("mcp_servers:", new_block, 1)

with open(hermes_path, "w") as f:
    f.write(content)

print(f"✅ {len(hermes_mcps)} MCPs synchronized from Codex")
PYEOF
