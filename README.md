# AURA777 Flutter Mobile App - Android APK Build Instructions

## Quick Start (Build APK Locally)

### 1. Prerequisites
- Install [Flutter SDK](https://docs.flutter.dev/get-started/install) (`>= 3.10.0`).
- Install [Android Studio](https://developer.android.com/studio) with Android SDK and Command-line Tools.

---

### 2. Install Dependencies
In the root of this folder, run:
```bash
flutter pub get
```

---

### 3. Run Locally (Testing on Emulator or Device)
```bash
flutter run
```

---

### 4. Build Release Android APK
To compile the release APK ready to distribute:
```bash
flutter build apk --release
```

The generated APK will be located at:
`build/app/outputs/flutter-apk/app-release.apk`

---

### 5. Backend Connection
The app is pre-configured to connect to:
`https://aura777.info/app/api/`
All 234 games, live wallet balance, deposit requests, and withdrawal requests sync in real-time with the live platform.
