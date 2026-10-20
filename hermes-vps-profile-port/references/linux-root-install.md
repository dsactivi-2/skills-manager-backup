# Linux root Hermes install

Official installer (2026-08 docs): `https://hermes-agent.nousresearch.com/install.sh`

Do not use the older GitHub-raw URL from bundled `hermes-agent` unless docs change.

## Layout

| Mode | Code | Binary | Data |
|---|---|---|---|
| Root | `/usr/local/lib/hermes-agent` | `/usr/local/bin/hermes` | `/root/.hermes` |
| Per-user | `~/.hermes/hermes-agent` | `~/.local/bin/hermes` | `~/.hermes` |

## Prerequisite

```bash
apt-get update && apt-get install -y libatomic1 xz-utils git curl
```

Without `libatomic1`, installer-managed Node prints:

`node: error while loading shared libraries: libatomic.so.1: cannot open shared object file`

then may claim Node is too old, download Node 26 into `~/.hermes/node/`, and stop. `hermes` is not installed. `source ~/.bashrc` + `hermes setup` then yields `command not found`.

Resume: install `libatomic1`, re-run the official installer, `hash -r`, verify `command -v hermes`.

Skip browser/Node if that is explicit: `bash -s -- --skip-browser`. Still install `libatomic1` if Node is already half-extracted.

## Sequence

1. Packages (`libatomic1`, `xz-utils`)
2. `curl …/install.sh | bash` — wait until it finishes
3. `hash -r && command -v hermes && hermes --version`
4. `hermes setup` only on a TTY

## Host keys after snapshot restore

A hostname like `snapshot-settings` often means a restored image: SSH host key will not match old `known_hosts`. Verify on the box (`ssh-keygen -lf /etc/ssh/ssh_host_ed25519_key.pub`) before `ssh-keygen -R`. Do not treat a changed key as a permanent dead host.

`write_file` cannot create `~/.ssh/config*`. Use a user-run `cat >>` or `ssh -i` with an explicit key.
