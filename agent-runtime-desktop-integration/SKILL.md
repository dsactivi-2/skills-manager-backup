---
name: agent-runtime-desktop-integration
description: "Use when connecting desktop apps to ACP agent runtimes."
created_by: agent
---

# Desktop Agent Runtime Integration

## ACP host setup

1. Treat ACP hosts and OpenAI-compatible chat frontends as separate integrations.
   - ACP hosts start `hermes acp` over stdio and can render agent lifecycle data.
   - Open WebUI uses Hermes' HTTP API server, not ACP.
2. Before configuring a host, install and validate the ACP adapter:

   ```sh
   cd ~/.hermes/hermes-agent
   uv pip install -e '.[acp]'
   hermes acp --check
   ```

3. For Buzz Desktop, open Settings → Agents and verify `Hermes Agent` is `Ready` under Agent runtimes. Discovery is sufficient; Buzz starts `hermes-acp` only when a Hermes agent session is launched.
4. Create or import a Buzz agent only after runtime readiness is verified. Select the `hermes` runtime for the agent.

## Safety

- Keep Hermes agents in Buzz owner-only. Buzz's ACP path can answer terminal permission requests without a human prompt, so a channel-access change can grant shell execution to other participants.
- Do not change a global default harness merely to test integration. Create a distinct agent or import a snapshot so existing Buzz agents keep their current behavior.
- Explain that ACP exposes a curated editor/runtime toolset; it intentionally does not include messaging delivery or cron management.

## Buzz agent snapshot import

Buzz imports snapshots only from filenames ending exactly in `.agent.json` or `.agent.png`. Use `.agent.json` for a hand-authored portable agent definition.

Create a minimal Hermes snapshot with:

```json
{
  "format": "buzz-agent-snapshot",
  "version": 1,
  "definition": {
    "name": "Hermes Agent",
    "sourceIsBuiltin": false,
    "runtime": "hermes",
    "parallelism": 1
  },
  "profile": {
    "displayName": "Hermes Agent"
  },
  "memory": {
    "level": "none"
  }
}
```

- Keep `memory.level` as `none` unless the user explicitly requests plaintext memory export.
- Omit provider and model fields to retain the configured Hermes runtime defaults; set them only when the user asks for a session-specific override.
- Omit `respondTo` to retain Buzz's owner-only default. Never copy source allowlists into a new environment without explicit approval.
- Validate the JSON, required discriminator/version/name/display name, `runtime: "hermes"`, and exact filename suffix before handing it to the user.

## Communication

- When the user asks which app extensions support ACP, list only ACP-compatible hosts: VS Code ACP Client, Zed custom agent server, JetBrains ACP-compatible plugins, Buzz Desktop, Buzz relay bridge, and custom ACP hosts. Do not mix in API-server, gateway, MCP, or general Hermes integrations.
- State clearly that a ready runtime is not a permanently running agent connection; the host spawns Hermes when a session starts.
