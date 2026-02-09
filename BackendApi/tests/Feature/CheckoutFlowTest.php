<?php

namespace Tests\Feature;

use App\Models\Book;
use App\Models\User;
use Database\Seeders\RolesAndAdminSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class CheckoutFlowTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndAdminSeeder::class);
    }

    public function test_client_checkout_flow_and_admin_order_management(): void
    {
        $book = Book::factory()->create();

        $registerResponse = $this->postJson('/api/auth/register', [
            'name' => 'Flow Client',
            'email' => 'flow.client@example.com',
            'password' => 'Client1234!',
            'device_name' => 'feature-test',
        ])->assertCreated();

        $token = $registerResponse->json('data.token');
        $this->assertNotEmpty($token);

        $headers = ['Authorization' => "Bearer {$token}"];

        $this->withHeaders($headers)
            ->getJson('/api/catalog/books')
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->withHeaders($headers)
            ->postJson('/api/cart/items', [
                'book_id' => $book->id,
                'quantity' => 1,
            ])->assertOk();

        $addressResponse = $this->withHeaders($headers)
            ->postJson('/api/addresses', [
                'type' => 'shipping',
                'recipient_name' => 'Flow Client',
                'line1' => '100 Main Street',
                'city' => 'Austin',
                'postal_code' => '73301',
                'country' => 'US',
                'is_default' => true,
            ])->assertCreated();

        $addressId = (int) $addressResponse->json('data.id');

        $orderResponse = $this->withHeaders($headers)
            ->postJson('/api/orders', [
                'address_id' => $addressId,
                'payment_method' => 'cash_on_delivery',
            ])->assertCreated();

        $orderId = (int) $orderResponse->json('data.id');

        $admin = User::factory()->create();
        $admin->assignRole('admin');

        Sanctum::actingAs($admin);

        $this->getJson('/api/admin/orders')
            ->assertOk()
            ->assertJsonPath('success', true);

        $this->patchJson("/api/admin/orders/{$orderId}/status", [
            'status' => 'processing',
        ])->assertOk()
            ->assertJsonPath('data.status', 'processing');
    }
}
