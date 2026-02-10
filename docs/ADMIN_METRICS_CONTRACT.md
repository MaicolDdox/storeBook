# Admin Metrics Contract

## Top Categories Endpoint
- Endpoint: `GET /api/admin/metrics/top-categories?range=7d|30d|90d`
- Auth: `auth:sanctum` and `role:admin`
- Purpose: Returns the most sold categories for the selected range.

## JSON Contract
```json
{
  "success": true,
  "message": "Top categories fetched successfully.",
  "data": {
    "items": [
      { "category": "Fantasy", "count": 12 },
      { "category": "Mystery", "count": 8 }
    ]
  }
}
```

## Contract Rules
- `data.items` is always an array.
- `category` is always a non-empty string.
  - Backend fallback: `"Unknown"`.
- `count` is always an integer greater than or equal to `0`.

## Aggregation Logic
- Primary aggregation path:
  - `order_items` -> `orders` -> `books` -> `categories`
- Metric:
  - `SUM(order_items.quantity)` grouped by category.
- Sort/limit:
  - Descending by sold quantity.
  - Top 10 categories.
