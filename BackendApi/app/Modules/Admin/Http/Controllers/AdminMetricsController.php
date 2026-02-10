<?php

namespace App\Modules\Admin\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Book;
use App\Models\Order;
use App\Modules\Orders\Resources\OrderResource;
use App\Support\ApiResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\DB;

class AdminMetricsController extends Controller
{
    public function overview(Request $request)
    {
        $days = $this->resolveRangeDays((string) $request->get('range', '30d'));
        $threshold = (int) $request->integer('low_stock_threshold', 5);
        $start = now()->subDays($days)->startOfDay();

        $metrics = [
            'books_count' => Book::query()->count(),
            'categories_count' => DB::table('categories')->count(),
            'orders_count' => Order::query()->where('created_at', '>=', $start)->count(),
            'pending_orders_count' => Order::query()
                ->where('created_at', '>=', $start)
                ->where('status', 'pending')
                ->count(),
            'low_stock_count' => Book::query()
                ->where('stock_quantity', '<=', $threshold)
                ->where('stock_quantity', '>=', 0)
                ->count(),
            'paid_revenue_cents' => (int) Order::query()
                ->where('created_at', '>=', $start)
                ->whereIn('payment_status', ['paid'])
                ->sum('total_cents'),
        ];

        return ApiResponse::success('Admin overview metrics retrieved.', $metrics);
    }

    public function ordersSeries(Request $request)
    {
        $days = $this->resolveRangeDays((string) $request->get('range', '30d'));
        $start = now()->subDays($days)->startOfDay();

        $countsByDate = Order::query()
            ->where('created_at', '>=', $start)
            ->select(DB::raw('DATE(created_at) as date'), DB::raw('COUNT(*) as count'))
            ->groupBy('date')
            ->orderBy('date')
            ->get()
            ->pluck('count', 'date')
            ->toArray();

        $series = [];
        for ($i = $days - 1; $i >= 0; $i--) {
            $date = now()->subDays($i)->format('Y-m-d');
            $series[] = [
                'date' => $date,
                'orders' => (int) ($countsByDate[$date] ?? 0),
            ];
        }

        return ApiResponse::success('Orders series retrieved.', [
            'series' => $series,
        ]);
    }

    public function orderStatus(Request $request)
    {
        $days = $this->resolveRangeDays((string) $request->get('range', '30d'));
        $start = now()->subDays($days)->startOfDay();

        $status = Order::query()
            ->where('created_at', '>=', $start)
            ->select('status', DB::raw('COUNT(*) as count'))
            ->groupBy('status')
            ->get()
            ->map(fn ($row) => [
                'name' => (string) $row->status,
                'count' => (int) $row->count,
            ])
            ->values();

        return ApiResponse::success('Order status metrics retrieved.', [
            'status' => $status,
        ]);
    }

    public function ordersOverTime(Request $request)
    {
        $seriesResponse = $this->ordersSeries($request);
        $series = $seriesResponse->getData(true)['data']['series'] ?? [];

        $labels = array_map(static fn (array $item): string => (string) ($item['date'] ?? ''), $series);
        $values = array_map(static fn (array $item): int => (int) ($item['orders'] ?? 0), $series);

        return ApiResponse::success('Orders over time retrieved.', [
            'labels' => $labels,
            'values' => $values,
        ]);
    }

    public function topCategories(Request $request)
    {
        $days = $this->resolveRangeDays((string) $request->get('range', '30d'));
        $start = now()->subDays($days)->startOfDay();

        $data = DB::table('order_items')
            ->join('orders', 'order_items.order_id', '=', 'orders.id')
            ->join('books', 'order_items.book_id', '=', 'books.id')
            ->join('categories', 'books.category_id', '=', 'categories.id')
            ->where('orders.created_at', '>=', $start)
            ->select('categories.name', DB::raw('SUM(order_items.quantity) as total_quantity'))
            ->groupBy('categories.id', 'categories.name')
            ->orderByDesc('total_quantity')
            ->limit(10)
            ->get();

        return ApiResponse::success('Top categories retrieved.', [
            'items' => $data->map(fn ($row) => [
                'category' => (string) $row->name,
                'count' => (int) $row->total_quantity,
            ]),
        ]);
    }

    public function recentOrders(Request $request)
    {
        $limit = max(1, min(50, (int) $request->integer('limit', 10)));

        $orders = Order::query()
            ->with(['user', 'address', 'items.book.category.genre', 'payment'])
            ->orderByDesc('created_at')
            ->limit($limit)
            ->get();

        return ApiResponse::success('Recent orders retrieved.', OrderResource::collection($orders));
    }

    public function orderStatusDistribution(Request $request)
    {
        $statusResponse = $this->orderStatus($request);
        $statusData = $statusResponse->getData(true)['data']['status'] ?? [];

        return ApiResponse::success('Order status distribution retrieved.', [
            'items' => array_map(
                static fn (array $item): array => [
                    'name' => ucfirst((string) ($item['name'] ?? 'unknown')),
                    'value' => (int) ($item['count'] ?? 0),
                ],
                $statusData
            ),
        ]);
    }

    public function lowStock(Request $request)
    {
        $threshold = max(0, (int) $request->integer('threshold', 5));
        $limit = max(1, min(50, (int) $request->integer('limit', 10)));

        $books = Book::query()
            ->where('stock_quantity', '<=', $threshold)
            ->where('stock_quantity', '>=', 0)
            ->orderBy('stock_quantity')
            ->limit($limit)
            ->get(['id', 'title', 'stock_quantity', 'price_cents']);

        return ApiResponse::success('Low stock books retrieved.', $books);
    }

    private function resolveRangeDays(string $range): int
    {
        return match ($range) {
            '7d' => 7,
            '90d' => 90,
            default => 30,
        };
    }
}
