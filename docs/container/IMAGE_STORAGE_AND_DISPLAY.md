# Image Storage And Display

## Overview

Book covers are uploaded through admin endpoints and stored on Laravel's `public` disk.
The API returns a usable `coverImageUrl` (absolute URL) so Vue can render images reliably.

## Laravel storage location

- Disk: `public`
- Physical path: `storage/app/public`
- Book cover folder: `storage/app/public/books/covers`
- Database field: `books.cover_image` stores only the relative file path, for example:
  - `books/covers/abc123.jpg`

## Required symlink

Laravel serves public disk files through:

- `public/storage -> storage/app/public`

If this symlink is missing, create it:

```bash
php artisan storage:link
```

## API image URL output

`BookResource` exposes:

- `coverImageUrl` (absolute URL)
- `cover_image_url` (compatibility key)

Rules:

1. If no image path exists, URL is `null`.
2. If the stored value is already an `http/https` URL, it is returned as-is.
3. Otherwise, the API builds a public URL from the `public` disk path and returns an absolute URL.

Quick check:

1. Open catalog API response in browser/network.
2. Copy `coverImageUrl`.
3. Open it directly in the browser.
4. The image must render with HTTP `200`.

## Vue image rendering

- URL resolver utility: `frontend/src/shared/utils/resolveAssetUrl.js`
- Placeholder image path: `frontend/public/images/placeholders/book-cover.png`

Components using this resolver and fallback:

- `frontend/src/components/catalog/BookCard.vue`
- `frontend/src/modules/client/pages/BookDetailPage.vue`

If an image URL is missing or fails to load, Vue swaps to the placeholder.

## Environment variables

Frontend uses:

- `VITE_API_ORIGIN` (preferred)
- `VITE_API_BASE_URL` (fallback)

Set one of them to your Laravel origin, for example:

- `http://127.0.0.1:8000`

Backend absolute URL generation depends on the active request host and should align with local API host configuration.
