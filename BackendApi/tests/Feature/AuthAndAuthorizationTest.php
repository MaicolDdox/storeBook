<?php

namespace Tests\Feature;

use App\Models\User;
use Database\Seeders\RolesAndAdminSeeder;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Illuminate\Support\Facades\Hash;
use Laravel\Sanctum\Sanctum;
use Tests\TestCase;

class AuthAndAuthorizationTest extends TestCase
{
    use RefreshDatabase;

    protected function setUp(): void
    {
        parent::setUp();
        $this->seed(RolesAndAdminSeeder::class);
    }

    public function test_register_assigns_client_role(): void
    {
        $response = $this->postJson('/api/auth/register', [
            'name' => 'Client User',
            'email' => 'client.user@example.com',
            'password' => 'Client1234!',
            'device_name' => 'test-suite',
        ]);

        $response
            ->assertCreated()
            ->assertJsonPath('success', true)
            ->assertJsonPath('data.token_type', 'Bearer');

        $user = User::query()->where('email', 'client.user@example.com')->firstOrFail();

        $this->assertTrue($user->hasRole('client'));
    }

    public function test_login_returns_token(): void
    {
        $user = User::factory()->create([
            'email' => 'existing.user@example.com',
            'password' => Hash::make('Client1234!'),
        ]);
        $user->assignRole('client');

        $response = $this->postJson('/api/auth/login', [
            'email' => 'existing.user@example.com',
            'password' => 'Client1234!',
            'device_name' => 'test-suite',
        ]);

        $response
            ->assertOk()
            ->assertJsonPath('success', true)
            ->assertJsonStructure([
                'success',
                'message',
                'data' => ['token', 'token_type', 'user'],
            ]);
    }

    public function test_client_cannot_access_admin_routes(): void
    {
        $client = User::factory()->create();
        $client->assignRole('client');

        Sanctum::actingAs($client);

        $this->getJson('/api/admin/dashboard')
            ->assertForbidden();
    }

    public function test_admin_can_access_admin_routes(): void
    {
        $admin = User::factory()->create();
        $admin->assignRole('admin');

        Sanctum::actingAs($admin);

        $this->getJson('/api/admin/dashboard')
            ->assertOk()
            ->assertJsonPath('success', true);
    }
}
