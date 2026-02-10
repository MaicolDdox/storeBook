# Flutter Catalog UI and Images

## Book Card Location
- Reusable card widget: `books_mobile/lib/shared/widgets/book_card.dart`
- Cover image widget (loading/error fallback): `books_mobile/lib/shared/widgets/book_cover_image.dart`
- Catalog screen that renders responsive list/grid cards: `books_mobile/lib/features/catalog/presentation/screens/catalog_screen.dart`

## Image URL Resolution
- Book JSON mapping is centralized in `books_mobile/lib/shared/models/book_model.dart`.
- The API key used for image URL is `image_url` (mapped to Dart `imageUrl`).
- URL normalization helpers:
  - `books_mobile/lib/core/utils/resolve_image_url.dart`
  - `books_mobile/lib/core/utils/resolve_book_image_url.dart`
- Resolution rules:
  - Absolute URL (`http://` or `https://`) is used directly.
  - Relative `storage/...` and `public/...` values are transformed into public URLs using the configured API origin.
  - Missing/invalid values return `null`, and UI falls back to a placeholder.

## Base URL Configuration Rules
- API base URL source: `books_mobile/lib/core/config/app_config.dart`
- Defaults:
  - Windows/Desktop/Web local: `http://127.0.0.1:8000/api`
  - Android emulator: `http://10.0.2.2:8000/api`
- Physical device:
  - Use a LAN IP with compile-time overrides:
  - `flutter run --dart-define=API_BASE_URL=http://<LAN_IP>:8000/api --dart-define=API_ORIGIN=http://<LAN_IP>:8000`

## Backend Image Access Requirements
- Books API must return `image_url` as a publicly reachable absolute URL.
- Local storage strategy requires:
  - Files in `storage/app/public`
  - Symbolic link `public/storage` -> `storage/app/public`
  - Run once: `php artisan storage:link`

## How to Verify
1. Open one `image_url` returned by `/api/catalog/books` directly in a browser. It must return the image.
2. Run Flutter catalog and confirm each card renders a large cover image.
3. Disable/remove one image and confirm the placeholder appears (no crash).
4. Check debug console on first catalog load:
   - first resolved image URL is logged
   - first image HTTP status is logged
