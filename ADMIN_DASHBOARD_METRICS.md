# Admin Dashboard Metrics API

This document describes the metrics endpoints used by the Admin Dashboard and how to extend them.

## Existing Endpoints

### Overview (existing)

- **Endpoint:** `GET /api/admin/dashboard`
- **Auth:** `auth:sanctum` + `role:admin`
- **Response:** `{ books_count, categories_count, orders_count, pending_orders_count, paid_revenue_cents }`

### Metrics Endpoints (added)

All metrics endpoints are protected by `auth:sanctum` and `role:admin`.

| Endpoint | Description | Query Params |
|----------|-------------|--------------|
| `GET /api/admin/metrics/orders-over-time` | Orders count per day for charts | `range`: 7d, 30d, 90d |
| `GET /api/admin/metrics/top-categories` | Top categories by quantity sold | `range`: 7d, 30d, 90d |
| `GET /api/admin/metrics/order-status-distribution` | Order count by status (pie chart) | `range`: 7d, 30d, 90d |
| `GET /api/admin/metrics/recent-orders` | Last 10 orders | - |
| `GET /api/admin/metrics/low-stock` | Books with stock <= 5 | - |

### Response Examples

**orders-over-time:**
```json
{
  "success": true,
  "data": {
    "labels": ["2025-02-01", "2025-02-02", ...],
    "values": [3, 5, 2, ...]
  }
}
```

**top-categories:**
```json
{
  "success": true,
  "data": {
    "items": [
      { "name": "Fiction", "value": 42 },
      { "name": "Science", "value": 28 }
    ]
  }
}
```

**low-stock:**
```json
{
  "success": true,
  "data": [
    { "id": 1, "title": "Book Title", "stock_quantity": 2, "price_cents": 1999 }
  ]
}
```

## Recommended Additions (Future)

- `GET /api/admin/metrics/revenue-over-time?range=30d` - Daily revenue for line chart
- `GET /api/admin/metrics/top-books?range=30d&limit=10` - Best-selling books
- Pagination support for `recent-orders` and `low-stock` if datasets grow large
