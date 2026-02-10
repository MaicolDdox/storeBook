# Images Troubleshooting

## Backend Setup Requirements
- Store uploaded covers on the public disk (`storage/app/public`).
- Ensure the public symbolic link exists:
  - `php artisan storage:link`
- Configure `APP_URL` in `BackendApi/.env` to the backend origin that clients can reach.
  - Web local example: `APP_URL=http://127.0.0.1:8000`
  - Android emulator example: `APP_URL=http://10.0.2.2:8000`
  - Physical device example: `APP_URL=http://192.168.x.x:8000`

## How `image_url` Is Built
- `BookResource` returns `image_url` as an absolute URL.
- For stored files, it now points to:
  - `/api/catalog/books/{book}/cover-image`
- This route reads from the public disk and returns the image with cache headers.
- If no image exists, `image_url` is `null`.

## CORS for Flutter Web
- CORS config is in `BackendApi/config/cors.php`.
- It allows:
  - methods: `GET, POST, PUT, PATCH, DELETE, OPTIONS`
  - headers: `Authorization, Content-Type, Accept, Origin, X-Requested-With`
  - origin patterns for local development:
    - `http://localhost:*`
    - `http://127.0.0.1:*`
- Since cover images are served from `/api/...`, CORS middleware is applied to image responses used by Flutter Web.

## Base URL Rules
- Flutter base URL config is in `books_mobile/lib/core/config/app_config.dart`.
- Defaults:
  - Web/Desktop: `http://127.0.0.1:8000/api`
  - Android emulator: `http://10.0.2.2:8000/api`
- Override when needed:
  - `--dart-define=API_BASE_URL=http://<HOST>:8000/api`
  - `--dart-define=API_ORIGIN=http://<HOST>:8000`

## Quick Verification
1. Open `/api/catalog/books` and copy one `image_url`.
2. Open that `image_url` directly in the browser.
3. Confirm image returns HTTP 200.
4. Run Flutter Web and confirm covers render.
5. Run Android emulator and confirm covers render with `10.0.2.2`.
