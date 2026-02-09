<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;

class DatabaseSeeder extends Seeder
{
    /**
     * Seed the application's database.
     */
    public function run(): void
    {
        $this->call([
            RolesAndAdminSeeder::class,
            CatalogSeeder::class,
        ]);

        $client = User::query()->firstOrCreate(
            ['email' => 'client@example.com'],
            [
                'name' => 'Demo Client',
                'password' => Hash::make('Client1234!'),
            ]
        );

        $client->syncRoles(['client']);
    }
}
