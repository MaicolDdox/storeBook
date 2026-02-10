# Auth Branding And Images

## Auth logo source and destination

Original source in repository:

- `docs/logoTipo.png`

Vue public branding asset:

- `frontend/public/brand/logo.png`

Flutter branding asset:

- `books_mobile/assets/brand/logo.png`

If you replace the logo in `docs/`, copy the same file to both destinations above.

## Where logo is shown

Vue:

- `frontend/src/modules/shared/pages/LoginPage.vue`
- `frontend/src/modules/shared/pages/RegisterPage.vue`
- shared block component: `frontend/src/components/brand/AuthBrandLogo.vue`

Flutter:

- `books_mobile/lib/features/auth/presentation/screens/login_screen.dart`
- `books_mobile/lib/features/auth/presentation/screens/register_screen.dart`
- shared widget: `books_mobile/lib/shared/widgets/auth_brand_logo.dart`

## Book image URL in API

`BookResource` includes:

- `image_url` (recommended key)
- `cover_image_url`
- `coverImageUrl` (compatibility key)

All three map to the same resolved absolute URL when a cover exists.

Path storage format in database remains relative:

- `books/covers/<file-name>.<ext>`

URL generation is done in:

- `BackendApi/app/Modules/Catalog/Resources/BookResource.php`

## Public storage requirement

When using local/public disk, book files are served from:

- `storage/app/public`

Laravel must expose:

- `public/storage -> storage/app/public`

Create it if missing:

```bash
php artisan storage:link
```

## Flutter image resolution and environment configuration

Flutter resolver file:

- `books_mobile/lib/core/utils/resolve_book_image_url.dart`

Behavior:

1. Uses absolute URLs from API directly.
2. Converts relative paths to absolute using configured API origin.
3. Supports `storage/...`, `public/...`, and raw relative file paths.

Config:

- `API_BASE_URL` (for API requests, default includes `/api`)
- `API_ORIGIN` (optional explicit origin for image URL resolution)

Examples:

- Android emulator:
  - `--dart-define=API_BASE_URL=http://10.0.2.2:8000/api`
  - `--dart-define=API_ORIGIN=http://10.0.2.2:8000`
- Physical device:
  - `--dart-define=API_BASE_URL=http://192.168.1.10:8000/api`
  - `--dart-define=API_ORIGIN=http://192.168.1.10:8000`

## Vue backend origin configuration

Vue asset resolver file:

- `frontend/src/shared/utils/resolveAssetUrl.js`

Uses:

- `VITE_API_ORIGIN` (preferred)
- `VITE_API_BASE_URL` (fallback)

Set either to your Laravel host origin in local/dev.
