# Yawn Sleep 1.3.1 (20) — release preparation

## Changes

- iPhone and Apple Watch both use version 1.3.1, build 20.
- Registers the custom URL scheme `yawnsleep` for the iPhone app.
- `yawnsleep://events/duo-mornings` opens the existing main dashboard.
- When already open, diagnostics, sleep logs, sleep pattern, and previously
  viewed help sheets close to reveal the dashboard. First-run onboarding stays.
- Unknown routes, queries, fragments, credentials, and explicit ports are ignored.
- Preserves the existing foreground sleep-refresh fix in ContentView: sleep data
  refreshes when the app becomes active, and canceled loads do not overwrite it.

## App Store Connect

- What's New: `Version-1.3.1-de.md` and `Version-1.3.1-en.md`.
- App Review information: `Review-Notes.md`.
- Duo Mornings Event Deep Link: `yawnsleep://events/duo-mornings`.
- The link requires version 1.3.1 or later. Published version 1.3 does not register
  it. Release and verify 1.3.1 before relying on the link in a live event.
- This patch addresses the technical deep-link requirement. The existing event
  still describes the adaptive dashboard, without new timed content. Apple
  determines whether that qualifies for the selected event badge; the link does
  not resolve that editorial eligibility question.

## Validation — 23 October 2026

- Release archive succeeded with Xcode 27.2 and the iOS 27.2 SDK.
- Archive version/build checked in both iPhone and embedded Watch Info.plist.
- `CFBundleURLTypes` in the archived iPhone app contains `yawnsleep`.
- Development signature verified with `codesign --verify --deep --strict`.
- 17 standalone routing tests passed, including rejected malformed/unknown URLs.
- `Configuration/Yawn-Info.plist` passed plist validation.
- `git diff --check` passed.
- Simulator Debug build succeeded. Installed on the already running Duo simulator.
- Opening `yawnsleep://events/duo-mornings` triggered iOS's “Open in Yawn Sleep?”
  confirmation while Beauty of Fractals was foregrounded. The user confirmed
  that accepting it opened Yawn; the dashboard was also observed in Device Hub.
- Warm link delivery with individual detail sheets and first-install onboarding
  still needs interactive verification; the runtime smoke check above does not
  establish every presentation-state case.

Run routing tests from the repository root:

```sh
xcrun swiftc -module-cache-path /private/tmp/Yawn-Swift-ModuleCache \
  Yawn/YawnDeepLink.swift Tests/YawnDeepLinkTests.swift \
  -o /private/tmp/YawnDeepLinkTests
/private/tmp/YawnDeepLinkTests
```

Archive: `build/Release-1.3.1/Yawn-1.3.1-20.xcarchive`.
Archive log: `build/Release-1.3.1/archive.log`.
Both are local build artifacts excluded from Git.
App Store validation, distribution signing, upload, and submission are pending.

## Device checks before submission

- Install 1.3.1 and tap the event link from Notes with the app closed.
- Tap it again with diagnostics, sleep logs, sleep pattern, or help open.
- On first installation, confirm the introduction remains available and Health
  permission is requested through the normal system flow.
- Verify real Health data refresh after returning to the foreground and check
  Watch synchronization.
