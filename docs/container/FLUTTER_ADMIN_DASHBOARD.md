# Flutter Admin Dashboard

## Overview
The Flutter admin dashboard now uses real API metrics and renders:
- KPI summary cards
- Orders over time line chart
- Order status distribution donut chart
- Top categories bar chart
- Recent orders section
- Low stock books section

## Flutter Files
- Screen: `books_mobile/lib/modules/admin/presentation/screens/admin_dashboard_screen.dart`
- Dashboard state/provider: `books_mobile/lib/modules/admin/presentation/providers/admin_dashboard_controller.dart`
- Metrics repository: `books_mobile/lib/modules/admin/data/admin_metrics_repository.dart`
- Metrics models: `books_mobile/lib/modules/admin/models/admin_metrics_data.dart`
- Range enum: `books_mobile/lib/modules/admin/models/admin_dashboard_range.dart`

## Endpoints Used
All endpoints are under `auth:sanctum` + `role:admin`.

- `GET /api/admin/metrics/overview?range=7d|30d|90d`
  - KPI cards:
    - `books_count`
    - `categories_count`
    - `orders_count`
    - `pending_orders_count`
    - `low_stock_count`
    - `paid_revenue_cents`

- `GET /api/admin/metrics/orders-series?range=7d|30d|90d`
  - Line chart:
    - `series: [{ date, orders }]`

- `GET /api/admin/metrics/order-status?range=7d|30d|90d`
  - Donut chart:
    - `status: [{ name, count }]`

- `GET /api/admin/metrics/top-categories?range=7d|30d|90d`
  - Bar chart:
    - `items: [{ category, count }]`

- `GET /api/admin/metrics/recent-orders?limit=10`
  - Recent orders section.

- `GET /api/admin/metrics/low-stock?threshold=5&limit=10`
  - Low stock section.

## Range Selector
- The dashboard range selector provides:
  - Last 7 days
  - Last 30 days
  - Last 90 days
- Changing the range triggers a full dashboard refresh through:
  - `adminDashboardControllerProvider.load(range: ...)`

## Chart Mapping
- Orders over time:
  - x-axis index maps to `series[index].date`
  - y-axis value maps to `series[index].orders`
- Order status distribution:
  - each donut section maps to `status[index].count`
  - legend maps to `status[index].name`
- Top categories:
  - each bar maps to `items[index].count`
  - x label maps to `items[index].category`

## Backend Recommended Additions Implemented
Added REST metrics aliases for clearer dashboard contracts:
- `GET /api/admin/metrics/overview`
- `GET /api/admin/metrics/orders-series`
- `GET /api/admin/metrics/order-status`

Legacy metrics routes remain available for backward compatibility.
