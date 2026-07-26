# App Review Notes

Yawn Sleep is an iPhone app with an embedded Apple Watch companion app.

The app requests read-only access to the Sleep Analysis type in HealthKit. It
uses the most recent sleep-stage samples to calculate a local Yawn Score from
sleep duration, efficiency, and restorative stages. Health data never leaves
the user’s device. The app has no account, server, analytics, advertising, or
tracking.

Version 1.1 adds multiple visual scene variants for every Yawn Score category.
Whenever the iPhone or Apple Watch app becomes active, it randomly selects one
illustration from the category matching the calculated score. A rare Lil’
Finder Lady scene may also appear. This variation is entirely visual and does
not change the score, its category, its underlying HealthKit data, or HealthKit
access.

To review:

1. Launch Yawn Sleep on iPhone.
2. Continue through the welcome screen.
3. Grant read access to Sleep when the system Health authorization sheet
   appears.
4. If the review device contains sleep samples from the last 18 hours, the
   score and illustration update automatically.

If no sleep samples are available, the app retains its illustrative placeholder
and displays a message explaining that Health access and a recorded night are
required.

The Yawn Score is an independent wellness visualization. It is not Apple’s
Sleep Score, a diagnostic result, or a substitute for medical advice.

The Apple Watch app is bundled with the iPhone app and uses the same read-only
HealthKit purpose.

Support: https://lutzrfrank.github.io/Yawn/support.html

Privacy: https://lutzrfrank.github.io/Yawn/privacy.html
