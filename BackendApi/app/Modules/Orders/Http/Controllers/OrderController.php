<?php

namespace App\Modules\Orders\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Modules\Orders\Http\Requests\CreateOrderRequest;
use App\Modules\Orders\Resources\OrderResource;
use App\Modules\Orders\Services\OrderService;
use App\Support\ApiResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class OrderController extends Controller
{
    public function __construct(
        private readonly OrderService $orderService
    ) {}

    public function index(Request $request)
    {
        $perPage = min((int) $request->integer('per_page', 15), 50);
        $orders = $this->orderService->listUserOrders($request->user(), $perPage);

        return ApiResponse::paginated(
            'Orders retrieved successfully.',
            OrderResource::collection($orders->items()),
            $orders
        );
    }

    public function store(CreateOrderRequest $request)
    {
        $this->authorize('create', Order::class);

        $order = $this->orderService->createOrder($request->user(), $request->validated());

        return ApiResponse::success(
            'Order created successfully.',
            new OrderResource($order),
            Response::HTTP_CREATED
        );
    }

    public function show(Request $request, Order $order)
    {
        $this->authorize('view', $order);

        return ApiResponse::success(
            'Order retrieved successfully.',
            new OrderResource($order->load(['address', 'items.book.category.genre', 'payment']))
        );
    }
}
