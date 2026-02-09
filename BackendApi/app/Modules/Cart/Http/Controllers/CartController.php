<?php

namespace App\Modules\Cart\Http\Controllers;

use App\Http\Controllers\Controller;
use App\Models\CartItem;
use App\Modules\Cart\Http\Requests\AddCartItemRequest;
use App\Modules\Cart\Http\Requests\UpdateCartItemRequest;
use App\Modules\Cart\Resources\CartResource;
use App\Modules\Cart\Services\CartService;
use App\Support\ApiResponse;
use Illuminate\Http\Request;

class CartController extends Controller
{
    public function __construct(
        private readonly CartService $cartService
    ) {}

    public function show(Request $request)
    {
        $cart = $this->cartService->getUserCart($request->user());
        $this->authorize('view', $cart);

        return ApiResponse::success(
            'Cart retrieved successfully.',
            new CartResource($cart)
        );
    }

    public function store(AddCartItemRequest $request)
    {
        $quantity = (int) ($request->validated('quantity') ?? 1);
        $cart = $this->cartService->addItem(
            $request->user(),
            (int) $request->validated('book_id'),
            $quantity
        );

        $this->authorize('update', $cart);

        return ApiResponse::success(
            'Book added to cart successfully.',
            new CartResource($cart)
        );
    }

    public function update(UpdateCartItemRequest $request, CartItem $cartItem)
    {
        $this->authorize('update', $cartItem);

        $cart = $this->cartService->updateItemQuantity(
            $cartItem->load('book', 'cart'),
            (int) $request->validated('quantity')
        );

        return ApiResponse::success(
            'Cart item updated successfully.',
            new CartResource($cart)
        );
    }

    public function destroy(CartItem $cartItem)
    {
        $this->authorize('delete', $cartItem);

        $cart = $this->cartService->removeItem($cartItem->load('cart'));

        return ApiResponse::success(
            'Cart item removed successfully.',
            new CartResource($cart)
        );
    }

    public function clear(Request $request)
    {
        $cart = $this->cartService->getUserCart($request->user());
        $this->authorize('update', $cart);

        $cart = $this->cartService->clearCart($request->user());

        return ApiResponse::success(
            'Cart cleared successfully.',
            new CartResource($cart)
        );
    }
}
