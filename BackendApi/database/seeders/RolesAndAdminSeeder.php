<?php

namespace Database\Seeders;

use App\Models\User;
use Illuminate\Database\Seeder;
use Illuminate\Support\Facades\Hash;
use Spatie\Permission\Models\Role;

class RolesAndAdminSeeder extends Seeder
{
    /**
     * Run the database seeds.
     */
    public function run(): void
    {
        $adminRole = Role::query()->firstOrCreate(['name' => 'admin']);
        $clientRole = Role::query()->firstOrCreate(['name' => 'client']);

        $adminEmail = env('DEFAULT_ADMIN_EMAIL', 'admin@storebook.local');
        $adminPassword = env('DEFAULT_ADMIN_PASSWORD', 'Admin1234!');
        $adminName = env('DEFAULT_ADMIN_NAME', 'System Admin');

        $admin = User::query()->firstOrCreate(
            ['email' => $adminEmail],
            [
                'name' => $adminName,
                'password' => Hash::make($adminPassword),
            ]
        );

        $admin->syncRoles([$adminRole]);

        // Ensure client role exists and can be assigned on registration flow.
        $clientRole->permissions;
    }
}
