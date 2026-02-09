<?php

namespace App\Modules\Admin\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Modules\Admin\Http\Requests\UpdateOrderStatusRequest;
use App\Modules\Admin\Services\AdminOrderService;
use App\Modules\Orders\Resources\OrderResource;
use App\Support\ApiResponse;
use Illuminate\Http\Request;

class OrderAdminController extends Controller
{
    public function __construct(
        private readonly AdminOrderService $orderService
    ) {}

    public function index(Request $request)
    {
        $orders = $this->orderService->listOrders($request->only(['status', 'user_email', 'per_page']));

        return ApiResponse::paginated(
            'Orders retrieved successfully.',
            OrderResource::collection($orders->items()),
            $orders
        );
    }

    public function show(Order $order)
    {
        $this->authorize('view', $order);

        return ApiResponse::success(
            'Order retrieved successfully.',
            new OrderResource($order->load(['user', 'address', 'items.book.category.genre', 'payment']))
        );
    }

    public function updateStatus(UpdateOrderStatusRequest $request, Order $order)
    {
        $this->authorize('updateStatus', $order);

        $order = $this->orderService->updateOrderStatus($order, (string) $request->validated('status'));

        return ApiResponse::success(
            'Order status updated successfully.',
            new OrderResource($order)
        );
    }
}
