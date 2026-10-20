# unsloth start — verified prereqs

Command family: `unsloth start {claude,codex,openclaw,opencode,hermes,pi}`

Hermes specifically: `unsloth start hermes`

## Dry-run

```bash
unsloth start hermes --no-launch
```

`--no-launch` prints env and command instead of spawning the TUI. Use it from inside an existing Hermes session.

## Resident-model gate

If Studio is running but nothing is loaded:

```
No model is currently resident in Unsloth. Pass --model <hf-id-or-path> to reload one, or load it from the model dropdown in the UI.
```

Stop. Ask for `--model` / `--gguf-variant`. Do not download a 27B GGUF as a silent default.

Inference status (when authenticated): `active_model` null and `loaded: []` means the same gate.

## Launch location

The agent TUI is interactive. Start it in a new Tabby/Terminal/tmux session, not nested in the current Hermes process.

Resume later needs `--persist` (Hermes home is a throwaway temp dir by default).

## Do not dump

`~/.unsloth/studio/run/desktop_backend.json` and `~/.unsloth/studio/auth/agent_api_key.json` hold tokens. Use them only in-process; never print keys.
