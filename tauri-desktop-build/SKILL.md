---
name: tauri-desktop-build
description: "Use when building/installing Tauri apps from source."
---

# Tauri desktop build (macOS)

Build a Tauri 2 app from GitHub source and install the .app. Do not stop at a release DMG when the user asked to build.

## Procedure

1. Confirm toolchain: `uname -m`, `node -v`, `pnpm -v`, `cargo -V`. Match the binary arch to the host (`arm64` → aarch64).
2. Clone the requested tag (not necessarily default branch) into a throwaway directory unless a project path is already loaded.
3. Read `package.json` scripts and `src-tauri/tauri.conf.json` (bundle targets, `createUpdaterArtifacts`, updater `pubkey`).
4. `pnpm install` then build only what you will install:
   - macOS local install: `pnpm tauri build --bundles app`
   - If `package.json` wraps `tauri` in `sh ./scripts/tauri.sh`, keep using `pnpm tauri` on macOS/Linux. Use `pnpm tauri:win` only on Windows — that wrapper is POSIX-only.
5. Locate `src-tauri/target/release/bundle/macos/*.app`. If the CLI exited non-zero, still check that path before rebuilding.
6. Install: copy the .app to `/Applications`, then `xattr -dr com.apple.quarantine "/Applications/<App>.app"`.
7. Verify live: `CFBundleShortVersionString`, `file`/`lipo` arch, `open` the app, `pgrep` the executable.

## Pitfalls

- Inspect the bundle path after a Tauri CLI failure when `createUpdaterArtifacts` is true and `TAURI_SIGNING_PRIVATE_KEY` is unset — the bundler writes the .app first, then errors on the updater signature, so a rebuild does not fix a local install.
- Prefer `--bundles app` for a local Mac install — `targets: all` spends time on DMG/updater tarballs you will not copy to `/Applications`.
- Strip quarantine after copy before `open` — local Tauri builds are ad-hoc/linker-signed and not notarized, so Gatekeeper blocks launch otherwise.
- Do not treat in-app GitHub auto-update as working on a local unsigned build — updater artifacts need the private key; say so instead of claiming updates are enabled.
