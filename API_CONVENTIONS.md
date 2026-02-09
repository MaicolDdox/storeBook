# API Conventions

## 1. Base URL
- Base path: `/api`
- Auth scheme: `Authorization: Bearer <token>`
- Auth backend: Laravel Sanctum Personal Access Tokens

## 2. Response Envelope
## 2.1 Success
```json
{
  "success": true,
  "message": "Books retrieved successfully.",
  "data": [],
  "meta": {
    "pagination": {
      "current_page": 1,
      "last_page": 3,
      "per_page": 12,
      "total": 31,
      "from": 1,
      "to": 12
    }
  }
}
```

## 2.2 Error
```json
{
  "success": false,
  "message": "Validation failed.",
  "errors": {
    "email": ["The email field is required."]
  }
}
```

## 3. HTTP Status Codes
- `200` success
- `201` resource created
- `401` unauthenticated
- `403` forbidden
- `404` resource not found
- `422` validation error
- `429` rate limited

## 4. Pagination
- List endpoints use `meta.pagination`.
- Default per-page values are endpoint-specific.
- Use `per_page` and `page` query params where supported.

## 5. Filtering and Search
Catalog books endpoint:
- `search` (title/author/publisher)
- `category_id`
- `genre_id`
- `status`
- `sort` in `newest|price_asc|price_desc|title_asc`

## 6. Auth and Rate Limits
- `POST /api/auth/register` and `POST /api/auth/login` use `throttle:auth`.
- Search-heavy catalog list uses `throttle:search`.
- Logout revokes the current token.

## 7. Route Groups
## 7.1 Public
- `GET /api/health`
- `GET /api/catalog/books`
- `GET /api/catalog/books/{book}`
- `GET /api/catalog/categories`
- `GET /api/catalog/genres`

## 7.2 Authenticated Client/Admin
- `GET /api/auth/me`
- `POST /api/auth/logout`
- `GET /api/cart`
- `POST /api/cart/items`
- `PATCH /api/cart/items/{cartItem}`
- `DELETE /api/cart/items/{cartItem}`
- `DELETE /api/cart/items`
- `GET /api/addresses`
- `POST /api/addresses`
- `PATCH /api/addresses/{address}`
- `DELETE /api/addresses/{address}`
- `GET /api/orders`
- `POST /api/orders`
- `GET /api/orders/{order}`

## 7.3 Admin Only (`auth:sanctum` + `role:admin`)
- `GET /api/admin/dashboard`
- `GET|POST|GET/{id}|PATCH/{id}|DELETE/{id}` for:
  - `/api/admin/genres`
  - `/api/admin/categories`
  - `/api/admin/books`
- `GET /api/admin/orders`
- `GET /api/admin/orders/{order}`
- `PATCH /api/admin/orders/{order}/status`

## 8. Authorization Rules
- Policies enforce ownership and prevent IDOR.
- Client users can only access:
  - Their own addresses
  - Their own cart and cart items
  - Their own orders
- Admin endpoints require both role middleware and policy authorization.

## 9. Validation
- FormRequest validation is required for write endpoints.
- Only validated payloads are passed to service layer methods.

## 10. Error Safety
- API errors are normalized in `bootstrap/app.php`.
- Internal server exceptions return generic message without stack traces.
- API request logging captures method/path/status/user/ip/duration and excludes secrets.
