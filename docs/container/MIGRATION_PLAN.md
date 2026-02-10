# StoreBook Migration Plan

## 1. Scope
This migration refactors the project to an English-only domain model and completes the end-to-end e-commerce flow for:
- `BackendApi` (Laravel 12 + Sanctum + Spatie Permission)
- `frontend` (Vue 3 + Vite + Tailwind + Heroicons Solid)
- `books_mobile` (Flutter + Riverpod + Dio + secure token storage)

## 2. English Naming Map
### 2.1 Database and Models
| Old Name | New Name |
| --- | --- |
| `types` | `genres` |
| `Type` model | `Genre` model |
| `descripccion` | `description` |
| `type_id` | `genre_id` |
| `titulo` | `title` |
| `foto` | `cover_image` |
| `descripccion_larga` | `description` |
| `autor` | `author` |
| `editorial` | `publisher` |
| `year` | `published_year` |
| `numero_paginas` | `page_count` |
| `stock` | `stock_quantity` |
| `precio` | `price_cents` |
| `estado` | `status` |
| `shopping_carts` | `carts` + `cart_items` |
| `ShoppingCart` model | `Cart` + `CartItem` models |
| `bills` concept | `orders` + `order_items` + `payments` |

### 2.2 API and Clients
| Old Endpoint | New Endpoint |
| --- | --- |
| `GET /api/me` | `GET /api/auth/me` |
| `GET /api/books` | `GET /api/catalog/books` |
| `GET /api/categories` | `GET /api/catalog/categories` |
| `GET /api/types` | `GET /api/catalog/genres` |
| `shopping_carts` resource routes | `/api/cart/*` routes |

| Old Client Path | New Client Path |
| --- | --- |
| `frontend/src/views/*` | `frontend/src/modules/**` + `frontend/src/layouts/**` |
| `books_mobile/lib/screens/catalogo/*` | `books_mobile/lib/features/catalog/**` |
| `books_mobile/lib/screens/carrito/*` | `books_mobile/lib/features/cart/**` |
| `books_mobile/lib/screens/pagos/*` | `books_mobile/lib/features/orders/**` |

## 3. Backend Schema Changes
## 3.1 Core
1. Add Spatie Permission tables and role middleware aliases.
2. Add roles: `admin`, `client`.
3. Add default admin seeder (`RolesAndAdminSeeder`).
4. Ensure registered users receive `client` role automatically.

## 3.2 Catalog
1. Create/standardize `genres`.
2. Refactor `categories` to use `genre_id`, `slug`, `description`.
3. Refactor `books` to use English fields and searchable/filterable columns.

## 3.3 Commerce Flow
Recommended additions implemented:
1. `carts` (per-user active cart)
2. `cart_items` (quantity + unit price snapshot)
3. `addresses` (shipping/billing support)
4. `orders` (status + payment status + totals)
5. `order_items` (immutable product snapshot)
6. `payments` (mockable payment lifecycle)

These additions are required for real checkout and order history without inventing unrelated modules.

## 4. Legacy Data Strategy
A compatibility migration (`2026_02_09_041500_backfill_legacy_spanish_schema.php`) performs safe backfill when legacy Spanish columns/tables exist.

Important notes:
1. If you already migrated old schema in a shared environment, run database backup first.
2. The compatibility migration copies legacy values to English columns where needed.
3. Legacy `shopping_carts` rows cannot be fully mapped to user-owned carts if user linkage is absent; they should be archived and users rebuild cart state.

## 5. Migration Execution Steps
1. Backup database.
2. Deploy code.
3. Install backend dependencies:
   - `composer install`
4. Run migrations:
   - `php artisan migrate`
5. Seed roles/admin/catalog baseline:
   - `php artisan db:seed`
6. Verify:
   - `php artisan route:list`
   - `php artisan test`

For local clean setup:
1. `php artisan migrate:fresh --seed`

## 6. Security and Authorization Migration
1. Add `auth:sanctum` where needed.
2. Add `role:admin` to `/api/admin/*`.
3. Register and enforce policies:
   - `BookPolicy`, `CategoryPolicy`, `GenrePolicy`
   - `CartPolicy`, `CartItemPolicy`
   - `OrderPolicy`, `AddressPolicy`
4. Add IDOR-protection tests for cross-user order/cart access.

## 7. Frontend and Mobile Migration Sequence
1. Deploy backend first.
2. Deploy Vue app update (new `/app` and `/admin` layout split + new endpoints).
3. Deploy Flutter update (Riverpod + Dio + secure storage + new endpoints).
4. Run full manual flow:
   - Register -> Login -> Browse catalog -> Add to cart -> Checkout -> View orders -> Admin updates order status.

## 8. Rollback Plan
1. Roll back application deployment.
2. Restore database backup.
3. Revert clients to previous API contract.

Because schema was normalized and endpoint contracts changed, a database restore is safer than partial rollback for production incidents.
