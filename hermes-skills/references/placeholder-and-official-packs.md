# Hub vs local + official packs

- `$HERMES_HOME/skills` SKILL.md count = usable local skills (bundle, copy, symlink, agent).
- `$HERMES_HOME/skills/.hub` = only `hermes skills install` copies. Zero there is fine if local count > 0.
- `hermes skills search` Hub IDs are not the install list. For n8n/LiveKit/Eraser (and other GitHub packs) use `npx skills add` + `--agent hermes-agent --copy`.
- After `--skill <one>`, read the installed SKILL.md. One-line wrappers that only name another skill (e.g. `grill-me` → `grilling`) are inert until that primitive is installed too. See `references/npx-selective-install.md`.
- Never `-g` alone for LiveKit: PromptScript aborts ("does not support global skill installation"). See `references/livekit-npx-install.md`.
- User "gib den Befehl": one pasteable command. Do not dump browse + search + inspect NAME + install NAME.
