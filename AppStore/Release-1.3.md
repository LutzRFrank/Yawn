# Yawn Sleep 1.3 (19) — Duo release preparation

## Package

- iPhone and Apple Watch: version 1.3, build 19.
- Build with Xcode 27.1 / iOS 27.1 SDK or later for full-display Duo support.
- Minimum OS versions remain iOS 17.6 and watchOS 11.0.
- German release text: `Version-1.3-de.md`.
- English release text: `Version-1.3-en.md`.
- App Review text: `Review-Notes.md`.
- Updated App Store descriptions and promotional text: `Metadata-de.md` and
  `Metadata-en.md` (including Duo, sleep logs, and the current score components).

## Visual review

The user supplied and approved Duo screenshots on 22 October 2026.
`Screens/Duo-1.3/` retains four distinct views: narrow/open welcome and
narrow/open dashboard. The duplicate open dashboard image is omitted.
These are review references; dashboard images show placeholder data and a
Health access message. These references do not record which screenshots were
selected for the submitted App Store version.

Confirmed from those screenshots:

- Narrow dashboard uses the vertical layout.
- Open dashboard places scene and score breakdown side by side.
- Content clears the side toolbar.
- Welcome sheet lays out in narrow and open configurations.

Additional interactive checks whose results have not been recorded here:

- Fold/unfold continuity and rotation in both directions.
- Sleep Logs, Current Sleep Pattern, diagnostics, and share sheets.
- Dark appearance and accessibility text sizes, including scrolling.
- Read-only Health authorization and a recorded night on a device.
- Watch companion launch and score synchronization.

## Archive

Create the Release archive using the shared Yawn scheme and generic iOS device
destination. The local preparation archive is stored under
`build/Release-1.3/Yawn-1.3-19.xcarchive` (excluded from Git).
Validation on 22 October 2026:

- Release archive succeeded with Xcode 27.2 / iOS 27.2 SDK.
- iPhone and embedded Watch app both contain version 1.3, build 19.
- Built iPhone Info.plist includes portrait and both landscape orientations.
- Development signing succeeded; `codesign --verify --deep --strict` passed
  with access to the system certificate store.
- Archive log: `build/Release-1.3/archive.log` (excluded from Git).
- Xcode emitted the existing signed-Watch stripping warning and notices that
  App Intents extraction was skipped because neither target uses App Intents.
- The local archive was prepared by the coding assistant. The user subsequently
  completed the App Store Connect submission; see the status below.

## Submission

The user confirmed submission on 22 October 2026 and supplied an App Store
Connect screenshot showing **iOS App Version 1.3 — Waiting for Review** and
**1 Item Submitted**. The screenshot confirms submission of version 1.3;
it does not independently identify the selected build number.
