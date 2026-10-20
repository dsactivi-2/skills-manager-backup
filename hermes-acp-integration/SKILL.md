---
name: hermes-acp-integration
description: "Use when integrating Hermes with ACP hosts."
version: 1.0.0
created_by: agent
---

# Hermes ACP Integration

## Procedure

1. Install ACP from the Hermes checkout, not with a guessed standalone package:

   ```bash
   cd ~/.hermes/hermes-agent
   uv pip install -e '.[acp]'
   ```

2. Verify the adapter before configuring a host:

   ```bash
   hermes acp --check
   hermes acp --version
   ```

3. Install optional browser support non-interactively when the user requested it:

   ```bash
   hermes acp --setup-browser --yes
   ```

4. Verify browser automation with the actual browser CLI rather than only checking that a launcher is on `PATH`:

   ```bash
   agent-browser doctor
   ```

   Require a passing headless-launch test before claiming browser support is ready. A detected system Chrome/Chromium is a valid browser backend; do not require a separate Playwright download when it launches successfully.

5. Configure an ACP host to start the same Hermes installation:

   ```json
   {"command":"hermes","args":["acp"]}
   ```

6. Keep ACP's standard output reserved for JSON-RPC. Diagnose server logs through stderr or the host's runtime log, never by placing shell output in the ACP stream.

## Security

- Treat ACP hosts that auto-answer approvals as unattended privileged automation because Hermes ACP includes terminal and code-execution tools.
- For collaboration bridges, use a dedicated agent identity and OS account, restrict who can prompt it, and keep channel membership as the access boundary.
- Prefer session-scoped approvals in editor workflows. Use permanent approvals only for idempotent commands that are safe across projects.

## Host behavior

- ACP sessions bind file and terminal tools to the workspace sent by the host, so validate the editor workspace before asking Hermes to modify files.
- Let a host that supplies session MCP servers set `HERMES_ACP_SKIP_CONFIGURED_MCP=1`; this skips only global configured MCP startup, not session-provided servers.

## Buzz Desktop

1. Verify `hermes acp --check` before opening Buzz.
2. In Buzz, inspect Settings → Agents → Agent runtimes. Treat `Hermes Agent — Ready` as successful runtime discovery; Buzz starts `hermes acp` only when a Hermes agent session is launched, so no persistent ACP daemon is expected.
3. Create or configure a Buzz agent with the `Hermes Agent` harness to start an actual ACP session. Do not silently change the global default harness when the user only asked to connect Hermes.
4. Re-read the agent card or runtime state after creation before claiming that a Hermes agent is active.

- Distinguish ACP hosts from OpenAI-compatible API clients. VS Code, Zed, JetBrains, and Buzz Desktop use ACP; Open WebUI uses Hermes' API server and gains no ACP-specific UI features.
- When the user asks about "app extensions" in an ACP discussion, list only ACP-compatible hosts and bridges unless they explicitly request broader Hermes integrations.
- Keep Buzz agents owner-only. Buzz auto-answers ACP permission requests, making its terminal-capable ACP runtime unattended privileged automation.
