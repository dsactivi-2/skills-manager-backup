---
name: dokploy-ssh-key-management
description: Managing multiple per-server SSH keys in Dokploy CLI when keys are stored in external vault (Termius) and CLI requires both private and public key.
---

# Dokploy SSH Key Management

## Purpose
Manage multiple per-server SSH keys in Dokploy when keys are stored in an external vault (e.g. Termius) and the CLI requires both `--privateKey` and `--publicKey`.

## Workflow
1. Export private + public key from Termius for the target server.
2. Write both into a temp file (private key first, public key last).
3. Use `sed` to extract multi-line private key and single-line public key.
4. Call `dokploy ssh-key create`.

## Key Extraction Pattern (multi-line private key)
```bash
PRIVATE_KEY=$(sed -n '1,/-----END OPENSSH PRIVATE KEY-----/p' /tmp/dokploy-key-2.txt)
PUBLIC_KEY=$(tail -n 1 /tmp/dokploy-key-2.txt)

dokploy ssh-key create \
  --name "dokploy-key-89" \
  --privateKey "$PRIVATE_KEY" \
  --publicKey "$PUBLIC_KEY"
```

## Important Notes
- Dokploy requires **both** private and public key.
- Never paste keys into chat — use temp file + local inspection.
- One sshKeyId can be reused, but per-server keys should be stored separately when user maintains separate credentials.

## Verification
After creation, run `dokploy ssh-key all` to confirm the new key was added with correct sshKeyId.