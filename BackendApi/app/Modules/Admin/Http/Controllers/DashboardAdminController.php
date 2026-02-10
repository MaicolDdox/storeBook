<?php

namespace App\Modules\Admin\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Book;
use App\Models\Category;
use App\Models\Order;
use App\Support\ApiResponse;

class DashboardAdminController extends Controller
{
    public function index()
    {
        $metrics = [
            'books_count' => Book::query()->count(),
            'categories_count' => Category::query()->count(),
            'orders_count' => Order::query()->count(),
            'pending_orders_count' => Order::query()->where('status', 'pending')->count(),
            'low_stock_count' => Book::query()
                ->where('stock_quantity', '<=', 5)
                ->where('stock_quantity', '>=', 0)
                ->count(),
            'paid_revenue_cents' => (int) Order::query()
                ->whereIn('payment_status', ['paid'])
                ->sum('total_cents'),
        ];

        return ApiResponse::success(
            'Admin dashboard metrics retrieved successfully.',
            $metrics
        );
    }
}
