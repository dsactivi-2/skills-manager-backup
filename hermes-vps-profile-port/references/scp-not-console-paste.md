# Get files onto a VPS without paste

## Broken

- Paste a SKILL/script/diff into the VPS interactive bash (lines become commands: `+set`, `@@`, `!/usr/bin/env`).
- Paste 300+ lines into `nano` from chat. `$((PASS + 1))` often lands as `PASS=*** + 1))`. Function bodies break; later `present: command not found`.

## Working

1. Dedicated Mac key (`ssh-keygen -t ed25519 -f ~/.ssh/<name> -N ""`). Show **only** the `.pub`.
2. User password-SSHs once and appends that `.pub` to `/root/.ssh/authorized_keys` (mode 600).
3. After reinstall: verify host fingerprint **on the VPS**, then `ssh-keygen -R <ip>` on the Mac.
4. `scp -i ~/.ssh/<name> -o IdentitiesOnly=yes <local> root@<ip>:<remote>`
5. `ssh -i … 'bash /root/<script>'`

Preflight lives at `~/Desktop/hermes-vps-port/vps-preflight.sh` (read-only, continue-on-error, errlog). Prefer scp of that file over re-pasting it.
