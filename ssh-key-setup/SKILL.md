---
name: ssh-key-setup
description: Use when setting up SSH key access to a new host.
version: 1
author: Hermes Agent
license: mit
metadata:
  hermes:
    tags: [ssh, vps, devops, access]
    related_skills: [direct-instructions]
---

# SSH Key Access Setup

## When to Use
User wants to access a new server via SSH, create a new SSH key, or add an SSH alias (Host block) to `~/.ssh/config`.

## Procedure
1. Create the key (ed25519, no passphrase unless asked):
   `ssh-keygen -t ed25519 -f ~/.ssh/id_ed25519_<name> -C "<name>" -N ""`
   Name the file `id_ed25519_<descriptive>` so it sorts with the existing keys.
2. Add a `Host` block to `~/.ssh/config` (see templates/ssh-config-host.md). Edit with the `patch` tool. Editing this file triggers a consent prompt; if it times out with no answer, explain the block in plain words and ask the user to approve — do NOT silently substitute a raw `cat >>` command as the primary response.
3. Install the public key on the server, one of:
   - `ssh-copy-id -i ~/.ssh/id_ed25519_<name>.pub <user>@<ip>` (needs password login), or
   - have the user paste the bare public key into `~/.ssh/authorized_keys` via the hoster panel/console.
4. Verify the connection (also trusts the host key on first connect):
   `ssh -o StrictHostKeyChecking=accept-new -o ConnectTimeout=10 <alias> 'echo OK; whoami'`
   Use `ssh -o BatchMode=yes` for a non-interactive auth-only test (fails fast if the key is not accepted).

## Pitfalls
- Re-display the public key from DISK, never from memory or chat history. A single misread character (letter `O` vs digit `0`, `l` vs `1` vs `I`) silently breaks key auth — the server rejects the key and the failure looks like "key not accepted". Always `cat ~/.ssh/id_ed25519_<name>.pub` and `ssh-keygen -lf` it, then hand the user the exact bytes. If the user reports "I set it up but it's wrong", diff their pasted string against the on-disk key character by character — the last few chars are where transpositions hide.
- When the user must paste the key onto the server, output the BARE form `ssh-ed25519 AAAA…` (key type + data only) with no trailing comment — some panels reject or mis-store the comment field.
- `User root` is the default for this user's VPS hosts; confirm if the host uses a different user.
- A duplicate `AddKeysToAgent yes` in the config is harmless; clean it only if the user asks.
- Do not over-explain between steps. This user wants the agent to perform the setup, then report the verified result in a few lines.

## References
- templates/ssh-config-host.md — copy-ready Host block.
