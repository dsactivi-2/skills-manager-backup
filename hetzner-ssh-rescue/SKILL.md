---
name: hetzner-ssh-rescue
description: "Hetzner SSH lockout: use Rescue + API token to add a key."
trigger: "Use when a Hetzner (your-server.de) server rejects all SSH auth and the only credential is a provider 'api-token'. Covers the enable_rescue -> mount OS disk -> append key -> reboot flow and its API quirks."
version: 1
author: hermes-agent
license: MIT
metadata.hermes.tags: [ssh, hetzner, rescue, vps]
metadata.hermes.related_skills: [audited-vps-installation-workflow]
---

# Hetzner Cloud SSH rescue (locked out, API token only)

## When to use

A server rejects `Permission denied (publickey,password)` and you have no working key and no root password — only a token the user calls "api-token". That token is a **Hetzner Cloud API token**, not an SSH password. Confirm the provider first: `dig +short -x <ip>` → `*.your-server.de` is Hetzner.

## Workflow

1. **Verify the token and find the server.**
   `GET https://api.hetzner.cloud/v1/servers` with `Authorization: Bearer <token>`; match `public_net.ipv4.ip` to the target IP. Note the server `id`.
2. **Ensure a local key pair exists** (`<key>` + `<key>.pub`). Register it in the project: `POST /ssh_keys` `{"name":"<alias>","public_key":"<pub>"}` → note the returned `id`.
3. **Enable rescue** — `POST /servers/{id}/actions/enable_rescue` with body `{"ssh_keys":[<keyid>]}` and **omit the `type` field**. Capture `root_password` from the response (informational only).
4. **Boot into rescue with a full power cycle:** `reset` `poweroff`, poll `GET /servers/{id}` until `status:"off"`, then `reset` `poweron`. A soft `reboot` may not enter rescue; a power cycle does.
5. **Wait for port 22, then connect with the registered key:** `ssh -i <key> -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -o UserKnownHostsFile=/dev/null root@<ip>`. The rescue host key differs — keep the throwaway known_hosts only for this step.
6. **Mount the OS disk and append the key (never overwrite):**
   ```bash
   for d in /dev/sda*; do mount "$d" /mnt 2>/dev/null && [ -d /mnt/root ] && break; umount /mnt 2>/dev/null; done
   mkdir -p /mnt/root/.ssh
   grep -qxF "$(cat <key>.pub)" /mnt/root/.ssh/authorized_keys 2>/dev/null || cat <key>.pub >> /mnt/root/.ssh/authorized_keys
   chmod 700 /mnt/root/.ssh; chmod 600 /mnt/root/.ssh/authorized_keys
   umount /mnt; reboot
   ```
7. **After reboot** (rescue auto-consumes, `rescue_enabled:false`) the normal OS boots with your key present. Re-test `ssh <alias>` with key auth.

## Pitfalls

- **Hetzner Cloud v1 has no `add_ssh_key` server action.** `POST /servers/{id}/actions/add_ssh_key`, `attach_ssh_key`, and relationship endpoints all return 404. Keys are only attached at server creation; rescue is the supported way to add one later. Don't hunt for a runtime key-attach API.
- **`enable_rescue` rejects the `type` field.** Both `"ssh"` and `"password"` return 422 "Not a valid choice". Omit `type` entirely — the default works and still returns a `root_password`.
- **Rescue SSH denies the returned `root_password` in ssh-key mode.** Log in with the registered key, not the password (the password is for the rescue console).
- **Preserve existing keys.** Append to `authorized_keys`; the disk may already hold other operators' keys. Overwriting locks them (and you) out.
- **Verify, don't assume, the host key changed.** After rescue the normal-OS host key is usually unchanged. Compare `ssh-keyscan -t ed25519 <ip> | ssh-keygen -lf` against the existing `known_hosts` entry; only `ssh-keygen -R <ip>` + re-add when the fingerprint actually differs.
- **Rescue boot can lag / auto-reboot.** If port 22 stays closed after power-on, wait and re-check — the image may still be coming up or auto-cycling to normal. A `423 Locked` on a reset action is transient; retry after a few seconds.
- **Don't burn the API token as the SSH password.** It is a Bearer token for `api.hetzner.cloud`, not a login credential for the box.

See `references/hetzner-rescue.md` for the exact curl/python command set and a reusable injection script.
