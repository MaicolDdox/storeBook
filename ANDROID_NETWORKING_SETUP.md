# Android Networking Setup

## Laravel LAN Server
1. Start Laravel so other devices can reach it:
   - `php artisan serve --host 0.0.0.0 --port 8000`
2. Confirm backend health from PC:
   - `http://127.0.0.1:8000/api/health`

## Phone Connectivity Check
1. On the Android phone browser, open:
   - `http://192.168.20.55:8000`
2. Verify one API endpoint:
   - `http://192.168.20.55:8000/api/health`
   - `http://192.168.20.55:8000/api/catalog/books`
3. If the phone cannot open these URLs:
   - ensure phone and PC are on the same Wi-Fi
   - allow inbound TCP `8000` in Windows Firewall
   - verify you are using the active Wi-Fi IPv4 of the PC

## Flutter Base URL Strategy
- `API_BASE_URL` is host only (no `/api` suffix), for example:
  - `http://192.168.20.55:8000`
- Flutter derives:
  - `apiPrefix = ${apiBaseUrl}/api`

## Build APK for Real Device
- `flutter build apk --release --dart-define=API_BASE_URL=http://192.168.20.55:8000`
- APK output:
  - `build/app/outputs/flutter-apk/app-release.apk`

## Run for Android Emulator
- `flutter run -d android --dart-define=API_BASE_URL=http://10.0.2.2:8000`

## Notes for Images
- Backend `image_url` is absolute and built from `APP_URL` plus storage URL.
- Set `APP_URL` in `BackendApi/.env`:
  - `APP_URL=http://192.168.20.55:8000`
- Ensure storage link exists:
  - `php artisan storage:link`
