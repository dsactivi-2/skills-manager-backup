---
name: podman-macos
description: Use when Podman on Mac fails to start. Check the VM disk.
---

# Podman on macOS (applehv / vfkit)

Daily containers are OrbStack. Podman is a separate Linux VM. Do not install
`podman-mac-helper` — it steals the Docker socket from OrbStack.

German, short, simple. Recreate the machine only after the user says so.

## Loop

```bash
podman machine start
podman machine inspect
```

Exit 125 + `vfkit exited unexpectedly with exit code 1` is usually a missing
`.raw` disk, not a missing vfkit. vfkit ships at
`$(brew --prefix)/opt/podman/libexec/podman/vfkit` and is often not on PATH.

Read `ImagePath` from inspect. `ls` that `.raw`. A `.raw.zst` in `cache/` is
the download, not the boot disk.

## Recreate (disk gone; VM metadata leftover)

```bash
podman machine rm -f
podman machine init
podman machine start
podman version
```

Done when Client and Server both print a version. Old containers in that VM
are already gone if the disk was missing.

Do not `brew upgrade` (unscoped) or treat a 5→6 formula bump as the first fix.
A major upgrade without a disk still fails the same way.
