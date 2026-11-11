# Firebase Cloud Messaging demo

This Flutter app demonstrates foreground FCM messages, notification taps from
the background, terminated-app notification launches, and safe handling of
unsupported payload values.

## Project setup

The project already includes `firebase_core`, `firebase_messaging`, generated
Firebase options in `lib/firebase_options.dart`, and the Android Firebase
configuration at `android/app/google-services.json`. Confirm these files use
the Firebase project and Android application ID for your own app before
building.

Place the images at:

- `assets/default.png`
- `assets/promo.png`

Both paths are declared in `pubspec.yaml`. After adding or replacing assets,
run `flutter pub get`.

On Android 13 and later, allow notifications when prompted. The Android
manifest declares `POST_NOTIFICATIONS`; the app requests notification
permission when it starts. The Google Services Gradle plugin is already
configured in the Android project.

## Sending a test message

Run the app on a device with Google Play services and wait for startup to
complete. The Firebase Messaging 17 API logs the device's Firebase Installation
ID after registration. Treat it as a private device identifier and do not
include it in screenshots or a public submission. Send a test notification
through a sender that supports this FCM registration target, including these
custom data fields:

```json
{
  "action": "update_ui",
  "asset": "promo"
}
```

Use `default` instead of `promo` to display the default image. For tap tests,
send a notification with its data payload, then tap it while the app is in the
background or terminated. To test validation, use `"asset": "unknown"`; the
warning is shown and the previously displayed image is retained.

The screen shows the handler (`onMessage`, `onMessageOpenedApp`, or
`getInitialMessage`), number of received messages, message ID, and a diagnostic.
The background isolate logs receipt only; the foreground UI updates when the
user opens the notification.
