# LiveKit skill install (Hermes)

`hermes skills install skills-sh/livekit/agent-skills/livekit-agents` → Could not fetch.

Working path:

```bash
# Do NOT use -g: PromptScript is auto-detected and aborts with
# "PromptScript does not support global skill installation".
npx skills add livekit/agent-skills -y --agent hermes-agent --copy
ln -sfn ~/.agents/skills/livekit-agents ~/.hermes/skills/livekit-agents
ln -sfn ~/.agents/skills/livekit-simulations ~/.hermes/skills/livekit-simulations
```

The official repo has **two** skills. Installing only `--skill livekit-agents` can leave `livekit-simulations` on disk under `~/.agents/skills/` without a Hermes symlink. Hub `livekit-agents` / `livekit-simulations` are protected — do not patch them; use `hermes curator adopt` only if a foreground session must edit.
