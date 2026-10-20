---
name: macos-desktop-app-installation
description: Use when installing a macOS app. Verify before copying.
---

# macOS Desktop App Installation

## Procedure

1. Identify the machine architecture with `uname -m` and select the matching release asset. For Apple Silicon, prefer an `aarch64` or `arm64` build; never install an x64 build merely because it is available.
2. Check whether the target bundle already exists under `/Applications` and read its version from `Contents/Info.plist` before replacing anything.
3. Obtain the asset from the upstream release page or API. Record its SHA-256 locally; treat this as download identity, not publisher verification.
4. Mount a DMG read-only at a temporary `-nobrowse` mountpoint, or extract an archive into a temporary directory. Inspect the contained `.app` before copying it.
5. Verify the bundle with `codesign --verify --deep --strict --verbose=2 <app>` and inspect publisher metadata with `codesign -dvvv <app>`. Run `spctl --assess --type execute --verbose=4 <app>` when applicable.
6. Install only when bundle verification succeeds: copy with `ditto` to `/Applications/<App>.app`, then verify the installed copy again and report its version and path.
7. If verification fails, do not copy the bundle or weaken Gatekeeper. Detach/remove temporary artifacts and report the exact validation blocker and that no app was installed.

## Pitfalls

- Validate the app bundle before copying it into `/Applications`; a DMG can mount successfully while the inner bundle has an invalid or incomplete code signature.
- Do not use `xattr -dr com.apple.quarantine` to bypass a failed `codesign` or `spctl` assessment; quarantine removal cannot make an invalid signature trustworthy.
- Distinguish ad-hoc signing from Developer ID signing and notarization; an ad-hoc signature has no publisher identity and does not establish macOS Gatekeeper trust.
- Keep the DMG mount read-only and temporary; this prevents install remnants when validation or copying fails.
- Live-path before quit/open: `ls /Applications/Setapp/<Name>.app` and `defaults read …/Info CFBundleName`. A version in the user script („CleanMyMac 4“) is often not the folder name (Setapp: `CleanMyMac.app`, executable `CleanMyMac_5_Setapp`, bundle `com.macpaw.CleanMyMac-setapp`).
- Launch with `open` or `open -b <bundleid>`. Executing `Contents/MacOS/…` then `open -a` yields Launch Services -600 and a process with zero windows.
- Menu-bar apps (CleanMyMac Menu) can run with 0 document windows; do not treat window count 0 as „not running“. Do not claim a menubar click worked unless Accessibility actually opened UI.
