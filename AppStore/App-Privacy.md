# App Privacy

## App Store Connect answer

Select:

> No, we do not collect data from this app.

## Basis

- Sleep-analysis data is read from HealthKit only after user authorization.
- Health data is processed locally on the iPhone or Apple Watch.
- No health or personal data is transmitted off device.
- There is no account, backend, analytics, advertising, or tracking SDK.
- The app stores only the local `hasSeenWelcome` preference in UserDefaults.
- The bundled privacy manifests declare no collected data and no tracking.

## Privacy policy

`https://lutzrfrank.github.io/Yawn/privacy.html`

The optional User Privacy Choices URL can remain empty because there is no
server-side account or collected data to access or delete.
