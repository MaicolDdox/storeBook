<?php

namespace App\Modules\Orders\Services;

use App\Models\Address;
use App\Models\Book;
use App\Models\Cart;
use App\Models\Order;
use App\Models\Payment;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class OrderService
{
    /**
     * @param  array<string, mixed>  $payload
     */
    public function createAddress(User $user, array $payload): Address
    {
        if (($payload['is_default'] ?? false) === true) {
            Address::query()
                ->where('user_id', $user->id)
                ->where('type', $payload['type'])
                ->update(['is_default' => false]);
        }

        return Address::query()->create([
            'user_id' => $user->id,
            'type' => $payload['type'],
            'recipient_name' => $payload['recipient_name'],
            'line1' => $payload['line1'],
            'line2' => $payload['line2'] ?? null,
            'city' => $payload['city'],
            'state' => $payload['state'] ?? null,
            'postal_code' => $payload['postal_code'],
            'country' => strtoupper($payload['country']),
            'phone' => $payload['phone'] ?? null,
            'is_default' => (bool) ($payload['is_default'] ?? false),
        ]);
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    public function updateAddress(Address $address, array $payload): Address
    {
        if (($payload['is_default'] ?? false) === true) {
            Address::query()
                ->where('user_id', $address->user_id)
                ->where('type', $payload['type'] ?? $address->type)
                ->where('id', '!=', $address->id)
                ->update(['is_default' => false]);
        }

        if (isset($payload['country'])) {
            $payload['country'] = strtoupper((string) $payload['country']);
        }

        $address->update($payload);

        return $address->fresh();
    }

    public function listUserAddresses(User $user): LengthAwarePaginator
    {
        return Address::query()
            ->where('user_id', $user->id)
            ->orderByDesc('is_default')
            ->orderByDesc('created_at')
            ->paginate(20);
    }

    /**
     * @param  array<string, mixed>  $payload
     */
    public function createOrder(User $user, array $payload): Order
    {
        $address = Address::query()
            ->where('id', $payload['address_id'])
            ->where('user_id', $user->id)
            ->first();

        if (! $address) {
            throw ValidationException::withMessages([
                'address_id' => ['Selected address does not belong to the authenticated user.'],
            ]);
        }

        $cart = Cart::query()
            ->where('user_id', $user->id)
            ->where('status', 'active')
            ->with(['items.book'])
            ->first();

        if (! $cart || $cart->items->isEmpty()) {
            throw ValidationException::withMessages([
                'cart' => ['Cannot create an order from an empty cart.'],
            ]);
        }

        $order = DB::transaction(function () use ($cart, $address, $payload, $user): Order {
            $order = Order::query()->create([
                'user_id' => $user->id,
                'address_id' => $address->id,
                'status' => 'pending',
                'payment_status' => 'pending',
                'subtotal_cents' => 0,
                'total_cents' => 0,
                'placed_at' => now(),
            ]);

            $subtotal = 0;

            foreach ($cart->items as $cartItem) {
                /** @var Book $book */
                $book = Book::query()->lockForUpdate()->findOrFail($cartItem->book_id);

                if ($book->status !== 'available' || $book->stock_quantity < $cartItem->quantity) {
                    throw ValidationException::withMessages([
                        'cart' => ["Book '{$book->title}' does not have enough stock."],
                    ]);
                }

                $lineTotal = $cartItem->quantity * $cartItem->unit_price_cents;
                $subtotal += $lineTotal;

                $order->items()->create([
                    'book_id' => $book->id,
                    'title_snapshot' => $book->title,
                    'unit_price_cents' => $cartItem->unit_price_cents,
                    'quantity' => $cartItem->quantity,
                    'total_price_cents' => $lineTotal,
                ]);

                $book->decrement('stock_quantity', $cartItem->quantity);

                if ($book->fresh()->stock_quantity <= 0) {
                    $book->update(['status' => 'out_of_stock']);
                }
            }

            $order->update([
                'subtotal_cents' => $subtotal,
                'total_cents' => $subtotal,
            ]);

            Payment::query()->create([
                'order_id' => $order->id,
                'method' => $payload['payment_method'],
                'status' => 'pending',
                'amount_cents' => $subtotal,
                'transaction_reference' => null,
            ]);

            $cart->items()->delete();
            $cart->update(['status' => 'checked_out']);

            Cart::query()->firstOrCreate([
                'user_id' => $user->id,
                'status' => 'active',
            ]);

            return $order->fresh(['address', 'items.book.category.genre', 'payment']);
        });

        return $order;
    }

    public function listUserOrders(User $user, int $perPage = 15): LengthAwarePaginator
    {
        return Order::query()
            ->where('user_id', $user->id)
            ->with(['address', 'items.book.category.genre', 'payment'])
            ->orderByDesc('created_at')
            ->paginate($perPage);
    }
}
