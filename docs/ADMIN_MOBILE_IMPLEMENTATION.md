# Admin Mobile Implementation

## Flutter admin architecture

Admin functionality was added under:

- `books_mobile/lib/modules/admin/data`
- `books_mobile/lib/modules/admin/models`
- `books_mobile/lib/modules/admin/presentation/providers`
- `books_mobile/lib/modules/admin/presentation/screens`
- `books_mobile/lib/modules/admin/presentation/widgets`

Client wrappers were added under:

- `books_mobile/lib/modules/client/presentation/screens`

Shared models remain under:

- `books_mobile/lib/shared/models`

## Admin access guard

`AdminRouteGuard` is implemented in:

- `books_mobile/lib/modules/admin/presentation/widgets/admin_route_guard.dart`

Guard checks:

1. Stored token exists.
2. Authenticated user exists.
3. User role includes `admin`.

If access fails, it renders:

- `AdminAccessDeniedScreen`

## Flutter admin screens

- `AdminShell`: adaptive admin navigation (drawer/mobile, rail/desktop).
- `AdminDashboardScreen`: dashboard metrics.
- `AdminTypesScreen`: CRUD for types (mapped to backend `genres`).
- `AdminCategoriesScreen`: CRUD for categories with type selection.
- `AdminBooksScreen`: list/search/delete books.
- `AdminBookFormScreen`: create/edit book with multipart image upload, preview, and validation handling.
- `AdminOrdersScreen`: list/filter orders and update status.
- `AdminOrderDetailScreen`: view order detail, items, customer, and update status.

## Endpoints consumed by Flutter admin

- `GET /api/admin/dashboard`
- `GET /api/admin/genres`
- `POST /api/admin/genres`
- `PATCH /api/admin/genres/{genre}`
- `DELETE /api/admin/genres/{genre}`
- `GET /api/admin/categories`
- `POST /api/admin/categories`
- `PATCH /api/admin/categories/{category}`
- `DELETE /api/admin/categories/{category}`
- `GET /api/admin/books`
- `POST /api/admin/books`
- `POST /api/admin/books/{book}` with `_method=PATCH` for multipart updates
- `DELETE /api/admin/books/{book}`
- `GET /api/admin/orders`
- `GET /api/admin/orders/{order}`
- `PATCH /api/admin/orders/{order}/status`

## Security behavior in Flutter admin

- Bearer token is attached by Dio interceptor.
- Token is stored with `flutter_secure_storage`.
- `401` handling in admin controller triggers logout.
- `403` and API failures are surfaced as user-facing messages.
- `422` validation payload is mapped and displayed at field level in admin forms.

## Backend adjustments made for admin mobile + Vue upload support

### Book image upload support

Updated request validation:

- `BackendApi/app/Modules/Admin/Http/Requests/StoreBookRequest.php`
- `BackendApi/app/Modules/Admin/Http/Requests/UpdateBookRequest.php`

Added `image` file validation and `remove_image` support on update.

Updated admin catalog service:

- `BackendApi/app/Modules/Admin/Services/AdminCatalogService.php`

Changes:

- Stores uploaded files in `public` disk under `book-covers/`.
- Supports replacing/removing cover images.
- Deletes previous local image file when replaced or book deleted.

Updated resource output:

- `BackendApi/app/Modules/Catalog/Resources/BookResource.php`

Added `cover_image_url` while preserving `cover_image` for compatibility.

Added test coverage:

- `BackendApi/tests/Feature/AdminBookImageUploadTest.php`
