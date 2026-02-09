<?php

namespace Tests\Feature;

use App\Models\Address;
use App\Models\Book;
use App\Models\Cart;
use App\Models\CartItem;
use App\Models\Order;
use App\Models\User;
use Database\Seeders\RolesAndAdminSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class IdorProtectionTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndAdminSeeder::class);
    }

    public function test_client_cannot_access_another_users_order_or_cart_item(): void
    {
        $owner = User::factory()->create();
        $owner->assignRole('client');

        $attacker = User::factory()->create();
        $attacker->assignRole('client');

        $address = Address::query()->create([
            'user_id' => $owner->id,
            'type' => 'shipping',
            'recipient_name' => 'Owner Name',
            'line1' => '100 Main Street',
            'line2' => null,
            'city' => 'Austin',
            'state' => 'TX',
            'postal_code' => '73301',
            'country' => 'US',
            'phone' => null,
            'is_default' => true,
        ]);

        $order = Order::query()->create([
            'user_id' => $owner->id,
            'address_id' => $address->id,
            'status' => 'pending',
            'payment_status' => 'pending',
            'subtotal_cents' => 1000,
            'total_cents' => 1000,
            'placed_at' => now(),
        ]);

        $book = Book::factory()->create();
        $cart = Cart::query()->create([
            'user_id' => $owner->id,
            'status' => 'active',
        ]);
        $cartItem = CartItem::query()->create([
            'cart_id' => $cart->id,
            'book_id' => $book->id,
            'quantity' => 1,
            'unit_price_cents' => $book->price_cents,
            'total_price_cents' => $book->price_cents,
        ]);

        Sanctum::actingAs($attacker);

        $this->getJson("/api/orders/{$order->id}")
            ->assertForbidden();

        $this->patchJson("/api/cart/items/{$cartItem->id}", [
            'quantity' => 2,
        ])->assertForbidden();
    }
}
