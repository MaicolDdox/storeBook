<?php

namespace App\Modules\Cart\Services;

use App\Models\Book;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\User;
use Illuminate\Validation\ValidationException;

class CartService
{
    public function getOrCreateActiveCart(User $user): Cart
    {
        return Cart::query()->firstOrCreate([
            'user_id' => $user->id,
            'status' => 'active',
        ]);
    }

    public function getUserCart(User $user): Cart
    {
        return $this->getOrCreateActiveCart($user)->load([
            'items.book.category.genre',
        ]);
    }

    public function addItem(User $user, int $bookId, int $quantity): Cart
    {
        $book = Book::query()->findOrFail($bookId);

        $this->assertBookCanBePurchased($book, $quantity);

        $cart = $this->getOrCreateActiveCart($user);

        $cartItem = CartItem::query()->firstOrNew([
            'cart_id' => $cart->id,
            'book_id' => $book->id,
        ]);

        $newQuantity = $cartItem->exists ? $cartItem->quantity + $quantity : $quantity;

        if ($newQuantity > $book->stock_quantity) {
            throw ValidationException::withMessages([
                'quantity' => ['Requested quantity exceeds available stock.'],
            ]);
        }

        $cartItem->quantity = $newQuantity;
        $cartItem->unit_price_cents = $book->price_cents;
        $cartItem->total_price_cents = $newQuantity * $book->price_cents;
        $cartItem->save();

        return $this->refreshCart($cart);
    }

    public function updateItemQuantity(CartItem $cartItem, int $quantity): Cart
    {
        $book = $cartItem->book;
        $this->assertBookCanBePurchased($book, $quantity);

        if ($quantity > $book->stock_quantity) {
            throw ValidationException::withMessages([
                'quantity' => ['Requested quantity exceeds available stock.'],
            ]);
        }

        $cartItem->update([
            'quantity' => $quantity,
            'unit_price_cents' => $book->price_cents,
            'total_price_cents' => $quantity * $book->price_cents,
        ]);

        return $this->refreshCart($cartItem->cart);
    }

    public function removeItem(CartItem $cartItem): Cart
    {
        $cart = $cartItem->cart;
        $cartItem->delete();

        return $this->refreshCart($cart);
    }

    public function clearCart(User $user): Cart
    {
        $cart = $this->getOrCreateActiveCart($user);
        $cart->items()->delete();

        return $this->refreshCart($cart);
    }

    private function refreshCart(Cart $cart): Cart
    {
        return $cart->fresh(['items.book.category.genre']);
    }

    private function assertBookCanBePurchased(Book $book, int $requestedQuantity): void
    {
        if ($book->status !== 'available') {
            throw ValidationException::withMessages([
                'book_id' => ['This book is not available for purchase.'],
            ]);
        }

        if ($requestedQuantity <= 0) {
            throw ValidationException::withMessages([
                'quantity' => ['Quantity must be greater than zero.'],
            ]);
        }
    }
}
