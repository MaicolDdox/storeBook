# Images Android Fix

## Where Images Are Stored
- Uploaded book covers are stored on Laravel public disk:
  - `storage/app/public/books/covers/...`
- Public link must exist:
  - `php artisan storage:link`
- Public files are served from:
  - `public/storage/...`

## How `image_url` Is Built
- Backend resource: `BackendApi/app/Modules/Catalog/Resources/BookResource.php`
- `image_url` is the canonical field used by Flutter.
- For stored files, backend returns an absolute URL with:
  - `url(Storage::disk('public')->url($path))`
- Host comes from `APP_URL` in `BackendApi/.env`.
- For LAN testing with phone:
  - `APP_URL=http://192.168.20.55:8000`
- If image is missing or file does not exist, `image_url` is `null`.

## Phone Browser Verification
1. Open in phone browser:
   - `http://192.168.20.55:8000/api/catalog/books?per_page=3`
2. Copy one returned `image_url`.
3. Open that URL in phone browser.
4. The image must display directly.

## Flutter Base URL Rules
- Single source of truth:
  - `books_mobile/lib/core/config/app_config.dart`
- Compile-time base:
  - `API_BASE_URL` (host only, no `/api`)
- Derived API prefix:
  - `${apiBaseUrl}/api`
- Defaults and debug candidates include:
  - `http://192.168.20.55:8000` (physical phone LAN)
  - `http://10.0.2.2:8000` (Android emulator)
  - `http://127.0.0.1:8000` (desktop local)

## Image URL Resolution in Flutter
- Resolver: `books_mobile/lib/core/utils/url_resolver.dart`
- Rules:
  - `null/empty` -> `null`
  - absolute `http/https` -> unchanged
  - relative path -> prefixed with active `apiBaseUrl`
- `Image.network` usage includes:
  - loading placeholder
  - error fallback placeholder
  - debug caption with last failing URL

## Debug Diagnostics
- Debug-only panel on login screen:
  - switch active API base URL
  - open diagnostics screen
- Diagnostics screen can:
  - test `/api/health`
  - fetch first catalog books
  - print raw image fields and resolved URL
  - request first image URL and log status/errors
