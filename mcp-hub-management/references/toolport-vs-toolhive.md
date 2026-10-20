# Toolport vs ToolHive (session SoT, 2026-07)

## User default

**ToolHive Desktop** — user rejected Toolport as too small/untrusted. Do not push Toolport unless they re-ask for Hermes-first single gateway.

## Quick pick

| | Toolport | ToolHive |
|--|----------|----------|
| Role | Local MCP **gateway** shared by all clients | MCP **runtime** + registry + optional K8s gateway/vMCP |
| GUI | Desktop (Tauri) | Desktop Studio + Cloud UI |
| Hermes | First-class (`~/.hermes/config.yaml`) | Manual HTTP/SSE URL into Hermes |
| Claude / Codex | Yes | Yes (auto-config) |
| Skills (agentskills.io) | No | Yes (browse/install/registry) |
| Isolation | Gateway + integrity checks | Containers (Docker/OrbStack) per server |
| Token angle | Lazy discovery / meta-tools | Optimizer / vMCP tool filter |
| Install | Releases / toolport.app | Studio DMG preferred; brew `thv` **XOR** Studio |
| License | MIT (app) | Apache-2.0 |

## Desktop XOR brew (ToolHive)

Studio refuses external CLI:

```text
External ToolHive CLI Detected
Found: /opt/homebrew/bin/thv
brew uninstall thv  →  Check Again
```

Bundled CLI when Desktop is SoT:

`/Applications/ToolHive.app/Contents/Resources/bin/darwin-arm64/thv`

## URLs

- Toolport: https://toolport.app · https://github.com/tsouth89/toolport · clients: https://toolport.app/clients/
- ToolHive: https://github.com/stacklok/toolhive · docs https://docs.stacklok.com/toolhive/ · download https://stacklok.com/download/
- Skills: https://docs.stacklok.com/toolhive/concepts/skills · https://agentskills.io/
- Client matrix: https://docs.stacklok.com/toolhive/reference/client-compatibility

## brew thv (CLI-only path, not user default)

```text
brew tap stacklok/tap
brew trust stacklok/tap
brew install thv
# then do NOT open ToolHive.app
```

OrbStack must be running.

Hermes (not auto): `printf 'n\nY\n' | hermes mcp add <name> --url http://127.0.0.1:<port>/mcp`  
Full steps: `references/thv-live-setup.md`

## Three layers (teach once)

Client (agent) → Skill (playbook) → MCP (tools). ToolHive distributes MCP+Skills; it is not Hermes/Claude.

## awesome-list note

mahseema/awesome-ai-tools Developer tools: **ToolHive** one-liner only. No Toolport. Adjacent non-hubs: AgentDock, Portkey, TensorZero, Langfuse, Agenta.
