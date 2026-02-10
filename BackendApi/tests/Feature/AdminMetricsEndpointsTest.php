<?php

namespace Tests\Feature;

use App\Models\User;
use Database\Seeders\RolesAndAdminSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AdminMetricsEndpointsTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndAdminSeeder::class);
    }

    public function test_client_cannot_access_admin_metrics_endpoints(): void
    {
        $client = User::factory()->create();
        $client->assignRole('client');

        Sanctum::actingAs($client);

        $this->getJson('/api/admin/metrics/overview?range=30d')->assertForbidden();
        $this->getJson('/api/admin/metrics/orders-series?range=30d')->assertForbidden();
        $this->getJson('/api/admin/metrics/order-status?range=30d')->assertForbidden();
    }

    public function test_admin_can_access_admin_metrics_endpoints(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        Sanctum::actingAs($admin);

        $this->getJson('/api/admin/metrics/overview?range=30d')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => [
                    'books_count',
                    'categories_count',
                    'orders_count',
                    'pending_orders_count',
                    'low_stock_count',
                    'paid_revenue_cents',
                ],
            ]);

        $this->getJson('/api/admin/metrics/orders-series?range=30d')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => ['series'],
            ]);

        $this->getJson('/api/admin/metrics/order-status?range=30d')
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => ['status'],
            ]);
    }
}
