# Agent-skill CLI prerequisites

An installed agent skill may depend on a vendor CLI; the skill package alone does not make its commands executable.

Workflow after installing a third-party skill:

1. Read its on-disk `SKILL.md` and identify the required binary, minimum version, and authentication method.
2. Retrieve the vendor's official installation documentation before choosing an installer.
3. For standalone Python CLIs, prefer an isolated installer (`uv tool install <package>` or `pipx install <package>`) rather than a project `pip install`.
4. Verify the binary with `<command> --version`, then check its auth/status command if documented.
5. Do not start interactive login or set credentials unless the user asked to authenticate. Report the exact remaining action instead.

Parallel example (officially documented):

```bash
uv tool install "parallel-web-tools[cli]"
parallel-cli --version
parallel-cli auth
```

The CLI is installed independently from `parallel-findall`; authentication still requires `parallel-cli login` or `PARALLEL_API_KEY`.

## Pack ships a repo `bin/` (not a PyPI extra)

`npx skills add` copies `SKILL.md` only. If the pack README's installer is `python3 install.py` and the command is `bin/jev`:

1. Clone to `~/hermes-jev-skills` if missing.
2. `python3 install.py --check` first. Full `install.py` copies plugins/skills and can enable plugins in every Hermes profile.
3. If the user asked only for the CLI: symlink `~/hermes-jev-skills/bin/jev` to `~/.local/bin/jev` and `$HERMES_HOME/bin/jev`. Do not run the installer. Use `--enable none` only when they want the installer without turning plugins on.
4. Do not `uv tool install jev-cli`. That is a different unofficial PyPI client (`jev noul` / `jev auth`) that occupies the same binary name and does not implement `jev doctor` / `jev setup-key`.
5. Key check is `jev doctor` (presence + length + reachable). Do not read `.env` or the keychain. Skip `jev setup-key` when doctor already shows `key.present` from the environment.
6. Dashboard: `jev dashboard` (default http://127.0.0.1:8791/). Do not start it as a side effect of skill/CLI install. Off-loopback needs `--host` plus a token; never bind a public address.
7. After CLI+skills: say plainly if `hermes-jev` is missing from `plugins.enabled` and if routing pools are empty — that is why nothing is guaranteed to call Jev.
