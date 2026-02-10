# Icon Setup

## Required Icon File
- Source file: `books_mobile/assets/brand/app_icon.png`
- Keep this exact path.
- Recommended size: `1024x1024` square PNG.

## Current Configuration
- File: `books_mobile/pubspec.yaml`
- Tool: `flutter_launcher_icons`
- Android generation: enabled
- iOS generation: enabled
- Android minimum SDK for icon generation: `21`

## Regenerate Launcher Icons
Run these commands from `books_mobile`:

```bash
flutter pub get
dart run flutter_launcher_icons
```

This updates launcher icons automatically, including Android resources under:
- `books_mobile/android/app/src/main/res/mipmap-*`

## Build APK After Icon Changes
From `books_mobile`:

```bash
flutter build apk --release --dart-define=API_BASE_URL=http://192.168.20.55:8000
```

APK output:
- `books_mobile/build/app/outputs/flutter-apk/app-release.apk`

## Notes
- Android manifest should keep the default launcher icon reference:
  - `android:icon="@mipmap/ic_launcher"`
- If you replace the icon file, run the regenerate commands again.
