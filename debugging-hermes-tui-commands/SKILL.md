---
name: debugging-hermes-tui-commands
description: "Debug Hermes TUI slash commands: Python, gateway, Ink UI."
version: 1.0.0
author: Hermes Agent
license: MIT
platforms: [linux, macos, windows]
metadata:
  hermes:
    tags: [debugging, hermes-agent, tui, slash-commands, typescript, python]
    related_skills: [python-debugpy, node-inspect-debugger, systematic-debugging]
---

# Debugging Hermes TUI Slash Commands

## Overview

Hermes slash commands span three layers — Python command registry, tui_gateway JSON-RPC bridge, and the Ink/TypeScript frontend. When a command misbehaves (missing from autocomplete, works in CLI but not TUI, config persists but UI doesn't update), the bug is almost always one layer being out of sync with another.

Use this skill when you encounter issues with slash commands in the Hermes TUI, particularly when commands aren't showing in autocomplete, aren't working properly in the TUI, or need to be added/updated. Also use it when a profile wrapper (`marge`, `hermes -p NAME`) "does not start": a flash of empty Ink, `Error: invalid_params`, then the shell prompt. A named wrapper without the word Telegram is the TUI, not the messaging bot.

## When to Use

- A slash command exists in one part of the codebase but doesn't work fully
- A command needs to be added to both backend and frontend
- Command autocomplete isn't working for specific commands
- Command behavior is inconsistent between CLI and TUI
- A command persists config but doesn't apply live in the TUI

## Architecture Overview

```
Python backend (hermes_cli/commands.py)     <- canonical COMMAND_REGISTRY
       │
       ▼
TUI gateway (tui_gateway/server.py)         <- slash.exec / command.dispatch
       │
       ▼
TUI frontend (ui-tui/src/app/slash/)        <- local handlers + fallthrough
```

Command definitions must be registered consistently across Python and TypeScript to work properly. The Python `COMMAND_REGISTRY` is the source of truth for: CLI dispatch, gateway help, Telegram BotCommand menu, Slack subcommand map, and autocomplete data shipped to Ink.

## Investigation Steps

1. **Check if the command exists in the TUI frontend:**
   ```bash
   search_files --pattern "/commandname" --file_glob "*.ts" --path ui-tui/
   search_files --pattern "/commandname" --file_glob "*.tsx" --path ui-tui/
   ```

2. **Examine the TUI command definition:**
   ```bash
   read_file ui-tui/src/app/slash/commands/core.ts
   # If not there:
   search_files --pattern "commandname" --path ui-tui/src/app/slash/commands --target files
   ```

3. **Check if the command exists in the Python backend:**
   ```bash
   search_files --pattern "CommandDef" --file_glob "*.py" --path hermes_cli/
   search_files --pattern "commandname" --path hermes_cli/commands.py --context 3
   ```

4. **Examine the gateway implementation:**
   ```bash
   search_files --pattern "complete.slash|slash.exec" --path tui_gateway/
   ```

## Fix: Missing Command Autocomplete

If a command exists in the TUI but doesn't show in autocomplete:

1. Add a `CommandDef` entry to `COMMAND_REGISTRY` in `hermes_cli/commands.py`:
   ```python
   CommandDef("commandname", "Description of the command", "Session",
              cli_only=True, aliases=("alias",),
              args_hint="[arg1|arg2|arg3]",
              subcommands=("arg1", "arg2", "arg3")),
   ```

2. Pick `cli_only` vs gateway availability carefully:
   - `cli_only=True` — only in the interactive CLI/TUI
   - `gateway_only=True` — only in messaging platforms
   - neither — available everywhere
   - `gateway_config_gate="display.foo"` — config-gated availability in the gateway

3. Ensure `subcommands` matches the expected tab-completion options shown by the TUI.

4. If the command runs server-side, add a handler in `HermesCLI.process_command()` in `cli.py`:
   ```python
   elif canonical == "commandname":
       self._handle_commandname(cmd_original)
   ```

5. For gateway-available commands, add a handler in `gateway/run.py`:
   ```python
   if canonical == "commandname":
       return await self._handle_commandname(event)
   ```

## TUI dies on launch (`Error: invalid_params`)

Do not treat `hermes profile list` Gateway=running as proof the TUI can boot. Telegram answering on that profile also does not prove the TUI can boot — messaging `session.create` is a different path than CLI/TUI `GatewaySessionStore.create`.

`--cli` is not a bypass. `hermes -p NAME --cli` and `chat --cli` still spawn Ink (`tui_gateway.ws` on that second). Default `display.interface: cli` does not keep Ink off.

Probe in this order:

1. Wrapper is `exec hermes -p <name> "$@"`. `--version` only proves the launcher.
2. Reproduce with `HERMES_SKIP_UPDATE=1 hermes -p <name> chat --cli -q ping`. Copy `couldn't start the model connection: invalid_params` is `_ensure_gateway_session` / `session.create`, not xAI/OAuth.
3. Log the create payload (method `session.create` via `GatewaySessionStore.call`). Typical extra names in `toolsets` are MCP slugs (`composio`, `dograh`, `dograh-voiceeu`) mixed into `enabled_toolsets`. `gateway/session_policy.py` `_resolve_toolsets` used to refuse the whole create when any name failed `validate_toolset`.
4. Tail `~/.hermes/profiles/<name>/logs/agent.log`: `tui_gateway.ws` `messages=1` + `client_disconnect(code=1006)` is Ink aborting on that same 4001. Telegram `response ready` on the same clock means the provider is fine — do not `/model`.
5. Fix: drop names that fail `validate_toolset` instead of raising; MCP stays on `mcp_servers`. Restart the **messaging** gateway so the live process loads the change (`hermes gateway restart`). Then re-run the `-q ping` probe until it prints a reply, not `invalid_params`.

Do not claim a TUI fix until `-q ping` succeeds after the gateway restart. `hermes update` during restart can delay the gateway (`Gateway starting: deadline`) — wait and retry; do not revert the policy filter.

## Common Issues

1. **Command shows in TUI but not in autocomplete.** The command is defined in the TUI codebase but missing from `COMMAND_REGISTRY` in `hermes_cli/commands.py`. Autocomplete data ships from Python.

2. **Command shows in autocomplete but doesn't work.** Check the command handler in `tui_gateway/server.py` and the frontend handler in `ui-tui/src/app/createSlashHandler.ts`. If the command is local-only in Ink, it must be handled in `app.tsx` built-in branch; otherwise it falls through to `slash.exec` and must have a Python handler.

3. **Command behavior differs between CLI and TUI.** The command might have different implementations. Check both `cli.py::process_command` and the TUI's local handler. Local TUI handlers take precedence over gateway dispatch.

4. **Command persists config but doesn't apply live.** For TUI-local commands, updating `config.set` is not enough. Also patch the relevant nanostore state immediately (usually `patchUiState(...)`) and pass any new state through rendering components. Example: `/details collapsed` must update live detail visibility, not just save `details_mode`; in-session global `/details <mode>` may need a separate command-override flag so live commands can override built-in section defaults while startup/config sync preserves default-expanded thinking/tools behavior.

5. **Gateway dispatch silently ignores the command.** The gateway only dispatches commands it knows about. Check `GATEWAY_KNOWN_COMMANDS` (derived from `COMMAND_REGISTRY` automatically) includes the canonical name. If the command is `cli_only` with a `gateway_config_gate`, verify the gated config value is truthy.

## Debugging Tactics

When surface-level inspection doesn't reveal the bug:

- **Python side hangs or misbehaves:** use the `python-debugpy` skill to break inside `_SlashWorker.exec` or the command handler. `remote-pdb` set at the handler entry is the fastest path.
- **Ink side not reacting:** use the `node-inspect-debugger` skill to break in `app.tsx`'s slash dispatch or the local command branch. `sb('dist/app.js', <line>)` after `npm run build`.
- **Registry mismatch / unclear which side is wrong:** compare the canonical `COMMAND_REGISTRY` entry against the TUI's local command list side-by-side.

## Pitfalls

- Don't forget to set the appropriate category for the command in `CommandDef` (e.g., "Session", "Configuration", "Tools & Skills", "Info", "Exit")
- Make sure any aliases are properly registered in the `aliases` tuple — no other file changes are needed, everything downstream (Telegram menu, Slack mapping, autocomplete, help) derives from it
- For commands with subcommands, ensure the `subcommands` tuple in `CommandDef` matches what's in the TUI code
- `cli_only=True` commands won't work in gateway/messaging platforms — unless you add a `gateway_config_gate` and the gate is truthy
- After adding live UI state, search every consumer of the old prop/helper and thread the new state through all render paths, not just the active streaming path. TUI detail rendering has at least two important paths: live `StreamingAssistant`/`ToolTrail` and transcript/pending `MessageLine` rows. A `/clean` pass should explicitly check both.
- Rebuild the TUI (`npm --prefix ui-tui run build`) before testing — tsx watch mode may lag on first launch

## Verification

After fixing:

1. Rebuild the TUI:
   ```bash
   cd /home/bb/hermes-agent && npm --prefix ui-tui run build
   ```

2. Run the TUI and test the command:
   ```bash
   hermes --tui
   ```

3. Type `/` and verify the command appears in autocomplete suggestions with the expected description and args hint.

4. Execute the command and confirm:
   - Expected behavior fires
   - Any persisted config updates correctly (`read_file ~/.hermes/config.yaml`)
   - Live UI state reflects the change immediately (not just after restart)

5. If the command is also gateway-available, test it from at least one messaging platform (or run the gateway tests: `scripts/run_tests.sh tests/gateway/`).
