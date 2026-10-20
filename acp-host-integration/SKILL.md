---
name: acp-host-integration
description: "Use when connecting Hermes to an ACP-compatible host."
version: 1.0.0
author: Hermes Agent
license: MIT
metadata:
  hermes:
    tags: [hermes, acp, buzz, vscode, zed, jetbrains]
---

# ACP Host Integration

## Procedure

1. Install ACP support in the Hermes checkout, then verify the real adapter:

   ```bash
   cd ~/.hermes/hermes-agent
   uv pip install -e '.[acp]'
   hermes acp --check
   ```

2. Install browser support only when the ACP host needs browser tools:

   ```bash
   hermes acp --setup-browser --yes
   agent-browser doctor
   ```

   Accept a detected system Chrome/Chromium as a successful browser backend; Hermes-managed Chromium is not required when the launch test passes.

3. Configure the host to launch `hermes acp` (or `hermes-acp`). ACP is a stdio server; do not start it as a persistent gateway service.

4. State the transport boundary precisely. ACP hosts are VS Code, Zed, JetBrains plugins, Buzz Desktop, and other ACP clients. Open WebUI uses Hermes' OpenAI-compatible API server, not ACP.

5. For Buzz Desktop, open Settings → Agents and confirm `Hermes Agent` is `Ready`. Buzz starts an ACP-backed Hermes session when a Buzz agent using the `hermes` runtime is started; it is not a permanent connection to the current CLI conversation.

6. Keep Buzz agents owner-only. Buzz can answer ACP permission requests without an editor approval dialog, so an agent accessible to other channel members can receive privileged local tool access.

## Buzz agent snapshots

A `.agent.json` import creates a new Buzz agent with a fresh Buzz keypair. It does not copy a Hermes installation, Hermes profile, credentials, session history, or source identity. The new Buzz agent runs against the existing local Hermes configuration through its selected runtime.

Create a v1 snapshot with the required envelope and use `runtime: "hermes"` for the Hermes preset. Omit model/provider fields when the Buzz or harness default should select the model. Keep `memory.level` as `none` unless the user explicitly requests portable plaintext memory.

Before giving a snapshot for import, validate these invariants:

- filename ends exactly in `.agent.json`
- `format` is `buzz-agent-snapshot`
- `version` is `1`
- `definition.name` and `profile.displayName` are nonempty
- `idleTimeoutSeconds` is strictly less than `maxTurnDurationSeconds`

Use conservative values such as `idleTimeoutSeconds: 300` and `maxTurnDurationSeconds: 600` unless the user has a different requirement. Invalid timeout ordering prevents Buzz from starting the imported agent.

## User communication

When a user asks which "app extensions" exist, first establish whether they mean ACP hosts. If so, list only ACP-compatible hosts and explicitly exclude API-server integrations such as Open WebUI rather than mixing transport types.
