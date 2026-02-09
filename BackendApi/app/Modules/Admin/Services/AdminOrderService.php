<?php

namespace App\Modules\Admin\Services;

use App\Models\Order;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;

class AdminOrderService
{
    /**
     * @param  array<string, mixed>  $filters
     */
    public function listOrders(array $filters = []): LengthAwarePaginator
    {
        $query = Order::query()
            ->with(['user', 'address', 'items.book.category.genre', 'payment'])
            ->orderByDesc('created_at');

        if (! empty($filters['status'])) {
            $query->where('status', $filters['status']);
        }

        if (! empty($filters['user_email'])) {
            $userEmail = (string) $filters['user_email'];
            $query->whereHas('user', function ($builder) use ($userEmail): void {
                $builder->where('email', 'like', "%{$userEmail}%");
            });
        }

        $perPage = (int) ($filters['per_page'] ?? 20);

        return $query->paginate(min($perPage, 50));
    }

    public function updateOrderStatus(Order $order, string $status): Order
    {
        return DB::transaction(function () use ($order, $status): Order {
            $paymentStatus = match ($status) {
                'paid', 'processing', 'shipped', 'completed' => 'paid',
                'cancelled' => $order->payment_status === 'paid' ? 'refunded' : 'failed',
                default => 'pending',
            };

            $order->update([
                'status' => $status,
                'payment_status' => $paymentStatus,
            ]);

            if ($order->payment) {
                $order->payment->update([
                    'status' => $paymentStatus,
                    'paid_at' => $paymentStatus === 'paid' ? now() : $order->payment->paid_at,
                ]);
            }

            return $order->fresh(['user', 'address', 'items.book.category.genre', 'payment']);
        });
    }
}
