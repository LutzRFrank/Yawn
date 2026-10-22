# Yawn

Yawn turns last night’s sleep into one friendly glance: a soft 3D bed and the
Lil’ Finder Guy react to a locally calculated Yawn Score.

## Platforms

- iPhone
- Apple Watch companion app

## Health data

Yawn reads sleep stages from Apple Health with the user’s permission. Health
data is processed locally on the device and is not uploaded, shared, sold, or
used for advertising.

The Yawn Score is an independent estimate and is not Apple’s Sleep Score.

## Support and privacy

The public support site is published from [`docs/`](docs/):

- [Support](docs/support.html)
- [Privacy Policy](docs/privacy.html)
- [Report an issue](https://github.com/LutzRFrank/Yawn/issues)

## Development

Open `Yawn.xcodeproj` in Xcode. The project contains the iPhone and Apple Watch
targets and requires the HealthKit capability.

For full-display iPhone Duo support, build with the iOS 27.1 SDK or later.
The dashboard adapts to its current safe-area width: at 600 points and above,
scene and metrics appear side by side; narrower windows use a centered vertical
layout. Short windows scroll, and accessibility text sizes use stacked cards.
Portrait and both landscape orientations are supported.

Layout previews in `ContentView.swift` cover narrow, unfolded, short, and large
text layouts without requesting Health access. Before release, check the Duo
simulator closed and fully open, rotate in both directions, and fold/unfold with
the dashboard and each detail sheet visible. Check light/dark appearance and
accessibility text sizes, including scrolling to the last metric.

© 2026 Lutz R. Frank
