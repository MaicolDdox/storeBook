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
    public function ordersOverTime(Request $request)
    {
        $range = $request->get('range', '30d');
        $days = match ($range) {
            '7d' => 7,
            '90d' => 90,
            default => 30,
        };

        $start = now()->subDays($days)->startOfDay();

        $data = Order::query()
            ->where('created_at', '>=', $start)
            ->select(DB::raw('DATE(created_at) as date'), DB::raw('COUNT(*) as count'))
            ->groupBy('date')
            ->orderBy('date')
            ->get()
            ->pluck('count', 'date')
            ->toArray();

        $labels = [];
        $values = [];
        for ($i = $days - 1; $i >= 0; $i--) {
            $d = now()->subDays($i)->format('Y-m-d');
            $labels[] = $d;
            $values[] = $data[$d] ?? 0;
        }

        return ApiResponse::success('Orders over time retrieved.', [
            'labels' => $labels,
            'values' => $values,
        ]);
    }

    public function topCategories(Request $request)
    {
        $range = $request->get('range', '30d');
        $days = match ($range) {
            '7d' => 7,
            '90d' => 90,
            default => 30,
        };

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
            'items' => $data->map(fn ($row) => ['name' => $row->name, 'value' => (int) $row->total_quantity]),
        ]);
    }

    public function recentOrders()
    {
        $orders = Order::query()
            ->with(['user', 'address', 'items.book.category.genre', 'payment'])
            ->orderByDesc('created_at')
            ->limit(10)
            ->get();

        return ApiResponse::success('Recent orders retrieved.', OrderResource::collection($orders));
    }

    public function orderStatusDistribution(Request $request)
    {
        $range = $request->get('range', '30d');
        $days = match ($range) {
            '7d' => 7,
            '90d' => 90,
            default => 30,
        };

        $start = now()->subDays($days)->startOfDay();

        $data = Order::query()
            ->where('created_at', '>=', $start)
            ->select('status', DB::raw('COUNT(*) as count'))
            ->groupBy('status')
            ->get();

        return ApiResponse::success('Order status distribution retrieved.', [
            'items' => $data->map(fn ($row) => ['name' => ucfirst($row->status), 'value' => (int) $row->count]),
        ]);
    }

    public function lowStock()
    {
        $threshold = 5;
        $books = Book::query()
            ->where('stock_quantity', '<=', $threshold)
            ->where('stock_quantity', '>=', 0)
            ->orderBy('stock_quantity')
            ->limit(10)
            ->get(['id', 'title', 'stock_quantity', 'price_cents']);

        return ApiResponse::success('Low stock books retrieved.', $books);
    }
}
