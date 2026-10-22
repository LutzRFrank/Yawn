# App Review Notes — Yawn Sleep 1.3 (19)

Yawn Sleep is an iPhone app with an embedded Apple Watch companion app.

Version 1.3 adds basic support for the full, open iPhone Duo display. The main
dashboard responds to the available safe-area size: wide windows place the
morning scene beside the score and its three metric cards, while narrow windows
use a vertical layout. Portrait and both landscape orientations are supported.
Short windows scroll, and accessibility text sizes use stacked metric cards.
This release does not add pose-specific features for partially folded use.

The app requests read-only access to Sleep Analysis in HealthKit. It calculates
a local Yawn Score from sleep duration, bedtime consistency, and interruptions.
Health data is processed locally. The app has no account, server, analytics,
advertising, or tracking.

To review:

1. Launch Yawn Sleep and continue through the welcome screen.
2. Allow read access to Sleep when the system Health authorization sheet appears.
3. With recorded sleep data available, the dashboard shows the calculated score
   and a corresponding illustration. Without data or permission, it keeps an
   illustrative placeholder and displays a Health access message; the displayed
   placeholder values are not a measured night.
4. On iPhone Duo, view the dashboard closed and fully open, rotate in both
   directions, and check the layout while folding and unfolding.
5. Open Help using the question mark. Use the ellipsis menu for Sleep Logs and
   Current Sleep Pattern, and the document/magnifier button for diagnostics.
   System toolbar placement varies with the display configuration.

Sleep Logs covers the last week, month, or year. Reports can be shared as text
or locally generated PDFs and printed through the system print sheet. Current
Sleep Pattern derives typical bedtime and wake time from up to the last 14
recorded nights; it does not read the Sleep Schedule configured in Health.
Reports leave the device only when the user explicitly shares them.

The Yawn Score is an independent wellness visualization. It is not Apple’s
Sleep Score, a diagnostic result, or a substitute for medical advice.

The bundled Apple Watch app uses read-only HealthKit access and can receive the
phone's calculated score. Its version and build match the iPhone app.

Support: https://lutzrfrank.github.io/Yawn/support.html

Privacy: https://lutzrfrank.github.io/Yawn/privacy.html
