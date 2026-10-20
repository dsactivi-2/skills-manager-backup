# macOS Process Parsing Reference

## Commands that work

| Command | Output | Notes |
|---------|--------|-------|
| `ps aux` | All processes | Sort manually (Python), no `--sort` flag |
| `top -l 1 -n 0` | Single sample, no updating | macOS-specific |
| `pgrep -lf <name>` | PIDs by name | Pattern match |

## Common stale pattern signatures (extend per agent)

| Agent | Pattern | Command example |
|-------|---------|-----------------|
| Ollama MCP | `npm exec ollama-mcp@latest` | `npm exec ollama-mcp@latest --port 11435` |
| Codex/OpenCode | `opencode` | `opencode run ...` |
| Codex npx | `npx.*codex` | `npx @bitkyc08/opencodex ...` |
| uv/uvx MCP | `uv tool uvx` | `uv tool uvx --python 3.13 ...` |
| Hermes | `hermes_cli.main` | `python -m hermes_cli.main gateway run` |
| Hivemind | `hivemind` | `hivemind-server` |

## Parse ps aux in Python

```python
import subprocess
def parse_ps():
    out = subprocess.run("ps aux", shell=True, capture_output=True, text=True).stdout
    lines = out.strip().split("\n")[1:]
    procs = []
    for line in lines:
        parts = line.split(None, 10)
        if len(parts) < 11: continue
        procs.append({
            "pid": int(parts[1]),
            "cpu_pct": float(parts[2]),
            "mem_pct": float(parts[3]),
            "rss_mb": int(int(parts[5]) / 1024),
            "command": parts[10] if len(parts) > 10 else "",
        })
    procs.sort(key=lambda p: p["rss_mb"], reverse=True)
    return procs
```

## Notes
- `memory_pressure` and `sysctl vm.swapusage` for RAM pressure
- `launchctl list` for services
- `osascript` for Login Items (AppleScript)
