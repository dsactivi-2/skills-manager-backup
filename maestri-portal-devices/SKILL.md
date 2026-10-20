---
name: maestri-portal-devices
description: Drive an iOS simulator, Android emulator, or physical Android phone on the Maestri canvas. Tap, type, screenshot, read the accessibility tree, and launch apps. Use when the user asks to run or test a mobile app rather than a web page.
user-invocable: true
---

# Maestri Mobile Device Automation

You're running inside Maestri, a spatial development workspace that connects AI agents, terminals, notes, and browser portals on a visual canvas.
The `maestri` CLI is a command-line executable pre-installed and available on PATH. If `maestri` is not found, use `"$MAESTRI_CLI"` instead; this environment variable always points to the full binary path.

Device portals are embedded mobile devices on the Maestri canvas: an **iOS simulator**, an **Android emulator**, or a **physical Android phone** over adb. You can automate them to tap, type, scroll, press hardware buttons, launch apps, and read the accessibility tree. A device portal is a Portal node, so it takes the same `maestri portal` commands as a browser portal.

Portal name is always required. Run `maestri list` to see connected portal names.

## Opening a device

`maestri portal devices` — list every device this Mac can drive, grouped by OS version, with whether each is booted and whether a portal already holds it.

```
iOS 26.5
  iPhone 17 Pro  [5AFEC770-…]  — booted, in use by "Checkout"
  iPad Pro 13-inch (M5)  [3B82A9C3-…]  — free
Android 16
  Pixel 9  [emulator-5554]  — booted, free
  Pixel 8  [39affe1a]  — physical device, connected, free
Android emulators
  Pixel Tablet  [Pixel_Tablet]  — free
```

A UUID is iOS; `emulator-5554` or a bare serial is Android. Devices grouped under **Android emulators** start when a portal opens on them, which takes a while. A physical device is usable while it's plugged in.

`maestri portal create --simulator <id> ["Name"]` — open a portal on a device and connect it to your terminal. Adopt one marked **free**.

```
maestri portal create --simulator 3B82A9C3-… "Layout check"
```

A device runs once however many portals point at it, so adopting one that's `in use` shares its screen with another agent. Creating and deleting devices belongs to the user: iOS simulators in Maestri's **New Portal** sheet, Android emulators in Android Studio's Device Manager. When nothing on the list suits, ask.

## Snapshot & Refs

The **snapshot** command is the most important — it returns the frontmost app's accessibility tree with **refs** (`@e1`, `@e2`...) that you use as selectors for every other command:

```
maestri portal snapshot "Sim"
```

Returns something like:
```
app: Safari  screen: 393x852pt  elements: 24
@e1 button "Back" [8,60 44x44]
@e2 field "Address" value="apple.com" [60,60 273x40] *focused*
@e3 button "Reload" [345,60 40x40]
@e12 cell "Top Stories" [0,320 393x120]
```

**Selectors** — commands that take one accept:
- `@e3` — ref from snapshot (most reliable)
- `196,430` — x,y coordinates

Coordinates in the tree and in `info` are screen points. Snapshots wait for the UI to settle, so the state you read is current.

On iOS an app exposes a tree when **Maestri launched it**: the accessibility agent is injected at launch, into that process only. For an app started by Xcode, by a build tool, or by tapping its icon, run `maestri portal launch "Sim" <bundle-id>` to bring it under Maestri and get a tree. That's also the command to reach for whenever snapshot returns a screenshot instead of a tree — the header's `accessibility:` line names the reason, and in that mode you tap by pixel coordinates read straight off the returned image, which is captured at the resolution the tap expects.

### Embedded web content

When a web view is on screen — a React Native `WebView`, Capacitor/Ionic, or a native app showing a login or checkout page — the page's elements join the same tree, continuing the same ref sequence, and the header says `(includes web content)`:

```
app: com.example.shop  screen: 402x874pt  elements: 12  (includes web content)
@e1 text "Checkout" [163,74 76x21]
@e3 a "First link" href=https://example.com/one [8,219 58x19]
@e6 input "Search field" type=text [8,243 154x20]
```

Web lines carry the browser portal's extra detail (`href=`, `type=`, `options=[…]`, `checked`, `disabled`) and cover same-origin iframes. Their coordinates are already device screen points, so `click @e6` behaves exactly as it does on a native element.

## Commands

### Interaction
- `maestri portal click "Sim" @e3` — tap the element's center
- `maestri portal click "Sim" 196,430` — tap x,y coordinates
- `maestri portal type "Sim" "hello world"` — type into the focused field (tap a field first to focus it)
- `maestri portal key "Sim" "Enter"` — press a key (Enter/Return, Tab, Space, Backspace, Escape, Up/Down/Left/Right)
- `maestri portal scroll "Sim" down 400` — swipe-scroll up/down/left/right by an amount
- `maestri portal swipe "Sim" @e3 @e9` — drag between two points; each end is `@ref` or `"x,y"`
- `maestri portal button "Sim" home` — press a hardware button (`home`, `lock`, `side`)

### Resizable iOS apps

iOS 27 lets an app run at an arbitrary size on a separate "Resizable" display. Maestri drives
this with Apple's `devicectl device appResize` and moves the portal onto that display, so the
portal's width and height follow the app. It needs the CoreDevice tools installed by Xcode 27
or later and a simulator on an iOS 27 runtime; older runtimes have no resizable display.

- `maestri portal resize "Sim" status` — one `key: value` line per fact: `available` (the tool
  exists), `runtime`, `resizable_display` (found on the connected simulator or not), `active`,
  `preferred_size`, and the display inventory. Read this first when a resize fails.
- `maestri portal resize "Sim" 800 600` — start a session at 800x600, or change the size of the
  active one. Whole numbers from 100 to 4096. The foreground app must support resizing; Apple's
  tool refuses otherwise and the refusal is returned as the error. The size is a request: the
  `ok:` line and `achieved_size` in status report what the app actually got, which is smaller
  when the app enforces its own limits.
- `maestri portal resize "Sim" stop` — end the session and return the portal to the device screen.

Bring the app to the front (`launch`) before starting. After every resize or stop, take a new
snapshot: element refs and coordinates from before are stale. Only one portal can own a
simulator's resize session at a time; unloading or closing the portal ends it. A failed resize
exits nonzero with the reason. Android portals do not support these commands. Changing
`DEVELOPER_DIR` in a terminal does not change what the running Maestri uses.

### Foldable iPhones (iPhone Duo)

iPhone Duo folds, and Maestri moves its hinge the way Xcode's pose controls do. It needs Xcode
27.1 or later and an iPhone Duo simulator on the iOS 27.1 runtime. The portal always streams
the panel that is lit, turned upright: the cover screen when the device is folded, the large
inner screen when it is open.

- `maestri portal pose "Duo"` (or `pose "Duo" status`): read the pose, one `key: value` line
  per fact: `pose` (folded, book, laptop, flat, standby, or custom), `hinge_angle` in degrees,
  `orientation`, `lit_panel` (cover or inner, with its screen ID and how far it is turned),
  and `view` (screen or 3d). It asks the device first, so a fold made in Xcode shows up.
- `maestri portal pose "Duo" flat`: apply a preset. `folded` is 0°, `book` is 90° held upright,
  `laptop` is 110° with the crease horizontal, `flat` is 180°; `closed` and `open` work too.
  `standby` is Book standing on a table: it locks the device, and StandBy comes up on the
  inner screen (the first time, iOS shows its "Welcome to StandBy" screen). Any other preset
  takes it off the table; `button "Duo" home` unlocks.
  The hinge sweeps there the way a hand would, and the command returns once the device has
  settled.
- `maestri portal pose "Duo" 135`: fold to any angle from 0 (closed) to 180 (flat).
- `maestri portal pose "Duo" landscape-left`: turn the device. `portrait`, `landscape-left`,
  or `landscape-right`. iOS doesn't honor upside down on this device, so it isn't offered.
- `maestri portal screenshot "Duo" 3d`: a PNG of the device as a 3D model in its current pose,
  with the live screen on it. Use it to show or check a pose; tap coordinates still come from
  a plain `screenshot` or `snapshot`.

The device decides which panel is lit: the inner screen from about 85° up, the cover below
that, whether it is opening or closing. So `pose "Duo" 80` shows the cover and
`pose "Duo" 85` the inner screen; the switch can take a second or two to follow the hinge.
`lit_panel` always says which one it is. After every pose change take a new snapshot,
since refs and coordinates from the other panel are stale. `info` lists the pose too. Poses
work on a portal on any floor; a device without a hinge answers `pose` with an error.

### Apps & lifecycle
- `maestri portal launch "Sim" com.apple.mobilesafari` — launch an app by bundle id
- `maestri portal terminate "Sim" com.apple.mobilesafari` — kill an app
- `maestri portal navigate "Sim" "https://example.com"` — open a URL through the device's URL handler
- `maestri portal screenshot "Sim"` — capture a PNG (returns temp file path)
- `maestri portal info "Sim"` — device name, runtime, state, display size, and the `udid` on its first line
- `maestri portal boot "Sim"` / `shutdown "Sim"` — power the device on or off

### Android
Everything above works the same on Android. Four things differ:

- **`key` gains the navigation keys**: `back`, `recents`, `menu`, `volumeup`, `volumedown`. `maestri portal key "Pixel" back` is how you go back, since there's no on-screen button to tap.
- **`launch` takes a package name** rather than a bundle id: `maestri portal launch "Pixel" com.example.app`.
- **`snapshot` takes about two seconds**, because it uses the platform's `uiautomator`. A repeat snapshot on an unchanged screen is free, since the answer is reused.
- **A drag is delivered as a completed swipe.** `scroll` works normally; gestures that depend on holding mid-drag, like pulling a notification shade partway, aren't expressible over adb.

Android reports `resource-id` as `id=…`, the same field iOS uses for accessibility identifiers, so targeting by id works identically on both.

## Recommended Workflow

1. `maestri portal snapshot "Sim"` — read the screen and get refs
2. Use refs to interact: `click @e2`, then `type "..."`, then `key "Enter"`
3. `maestri portal snapshot "Sim"` again to verify the result
4. If refs are stale (the screen changed), run snapshot again to get fresh ones

Use `screenshot` when you need to see the visual layout. Use `snapshot` when you need to understand interactive elements. Prefer `snapshot` + refs over `screenshot` + coordinates — refs are more accurate.

A device portal survives workspace and floor switches, and several can run at once.

## Building an app and running it here

Pass the portal's device to the build tool, or it picks a device of its own and you drive one your build never reached. `maestri portal info "Sim"` gives the `udid`.

**React Native / Expo.** `<runner>` is a placeholder: use whatever the repo uses (a `package.json` script, `bun x`, `pnpm dlx`, `yarn dlx`, `npx`, a bare `expo`), which the lockfile and `packageManager` field tell you. Only the flags matter.

```
<runner> expo run:ios --device <udid>       # or: <runner> react-native run-ios --udid <udid>
maestri portal launch "Sim" <bundle-id>    # Expo launches the app itself, so relaunch for a tree
maestri portal snapshot "Sim"
```

`testID` arrives in the tree as `id=…`, so target those rather than labels that copy changes break. After a JS edit, Fast Refresh reloads in place and the tree stays live. A native change (a new native module, a pod install) needs a rebuild, which relaunches the app.

On Android it's the same shape, and injection isn't involved at all, so no relaunch is needed:

```
<runner> expo run:android --device <emulator-5554>
maestri portal snapshot "Pixel"
```

**Native Swift / SwiftUI.** Ask the build system for the bundle id and product path:

```
xcodebuild -scheme App -destination 'platform=iOS Simulator,id=<udid>' -showBuildSettings \
  | grep -E "PRODUCT_BUNDLE_IDENTIFIER|TARGET_BUILD_DIR|WRAPPER_NAME"
```

```
xcodebuild -scheme App -destination 'platform=iOS Simulator,id=<udid>' -derivedDataPath .build build
xcrun simctl install <udid> .build/Build/Products/Debug-iphonesimulator/App.app
maestri portal launch "Sim" <bundle-id>
maestri portal snapshot "Sim"
```

Relaunch with `maestri portal launch` rather than `simctl launch`: it injects the agent, waits until the app answers, and remembers the bundle so later snapshots describe this app. Every native edit repeats rebuild → install → relaunch.