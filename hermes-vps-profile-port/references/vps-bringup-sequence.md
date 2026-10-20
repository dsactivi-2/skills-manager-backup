# VPS bring-up before Hermes (user-corrected)

Do this **before** the official installer.

1. Pubkey auth from the Mac. Password SSH is human-only.
2. Reinstall/snapshot: compare `ssh-keygen -lf /etc/ssh/ssh_host_*.pub` on the VPS to the SSH warning, then `ssh-keygen -R <ip>` on the Mac.
3. `apt-get update`. If `/var/run/reboot-required` (kernel/`libc6`), reboot and confirm the new `uname -r` before install.
4. `apt-get install -y libatomic1 xz-utils git curl` (`libatomic1` is easy to miss).
5. `ufw allow OpenSSH` then `ufw enable`. Re-test SSH. Never enable UFW with an empty allow list.
6. Official installer (`--skip-setup` when no TTY). Desktop `curl|bash` may need an explicit approval — do not retry-loop.
7. Then shape A (rsync, no memory) or B (export/import `--name mac`). See `option-b-export.md`.
8. Tailscale is optional overlay, not a Hermes dependency.

Get scripts onto the box with scp, never console/nano paste (`scp-not-console-paste.md`).
