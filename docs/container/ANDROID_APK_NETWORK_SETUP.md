# Android APK Network Setup

## 1) Run Laravel for LAN Access
- Start Laravel on all interfaces so the phone can reach your PC:
  - `php artisan serve --host 0.0.0.0 --port 8000`
- If you use Laragon/Nginx/Apache instead, ensure the server listens on `0.0.0.0:8000`.

## 2) Windows Firewall
- Allow inbound TCP port `8000` for your current network profile.
- If blocked, the phone will fail to connect even with the correct IP.

## 3) Verify from Phone Browser
- Open:
  - `http://192.168.20.55:8000`
  - `http://192.168.20.55:8000/api/health`
  - `http://192.168.20.55:8000/api/catalog/books`
- If this fails, confirm the phone is on the same Wi-Fi and use the active Wi-Fi IPv4.

## 4) Backend Image URL Requirements
- Set `APP_URL` in `BackendApi/.env` to the LAN host you are using, for example:
  - `APP_URL=http://192.168.20.55:8000`
- Ensure public storage link exists:
  - `php artisan storage:link`
- `image_url` is generated as an absolute URL using `APP_URL` and Laravel storage URL.

## 5) Flutter Build with Configurable API Base URL
- `API_BASE_URL` must be host only (no `/api` suffix).
- Build release APK:
  - `flutter build apk --release --dart-define=API_BASE_URL=http://192.168.20.55:8000`
- Output APK:
  - `build/app/outputs/flutter-apk/app-release.apk`

## 6) Runtime URL Rules in Flutter
- `apiBaseUrl` = `API_BASE_URL` (normalized, no trailing slash).
- `apiPrefix` = `${apiBaseUrl}/api`.
- All API requests use `apiPrefix`.
- Relative image paths are resolved against `apiBaseUrl`.

## 7) Android Cleartext HTTP
- Production manifest uses domain-scoped cleartext policy through:
  - `android:networkSecurityConfig="@xml/network_security_config"`
- Debug manifest allows broader cleartext traffic for local testing.

## 8) Final Device Verification Checklist
- Login works.
- Catalog loads.
- Book cover images display.
- Add to cart works.
- Orders work.
- Admin views work for admin users.
